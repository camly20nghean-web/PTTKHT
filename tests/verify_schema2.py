"""Kiểm chứng SQL mới trên MariaDB có datadir/cổng riêng, không kết nối DB thật.

--baseline là bản SQL trước khi sửa, chỉ nạp vào schema legacy của server tạm.
Không đăng ký Windows service và không đổi cấu hình kết nối của ứng dụng gốc.
"""
import argparse
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import re
import socket
import subprocess
import sys
import tempfile
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mysql-home', type=Path, required=True)
    parser.add_argument('--tomcat-home', type=Path, required=True)
    parser.add_argument('--scratch', type=Path, required=True)
    parser.add_argument('--baseline', type=Path, required=True)
    args = parser.parse_args()
    project = Path(__file__).resolve().parents[1]
    args.scratch.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='schema2-', dir=args.scratch))
    data = work / 'data'
    checks = []
    def check(ok, label):
        if not ok:
            raise AssertionError(label)
        checks.append(label)
    with socket.socket() as sock:
        sock.bind(('127.0.0.1', 0))
        port = sock.getsockname()[1]
    if port == 3306:
        raise RuntimeError('Từ chối cổng DB mặc định')
    bin_dir = args.mysql_home.resolve() / 'bin'
    flags = subprocess.CREATE_NO_WINDOW if sys.platform == 'win32' else 0
    install = subprocess.run([str(bin_dir / 'mysql_install_db.exe'), '--datadir=' + str(data),
                              '--port=' + str(port)], capture_output=True, timeout=90,
                             creationflags=flags)
    (work / 'install.log').write_bytes(install.stdout + install.stderr)
    check(install.returncode == 0, 'Khởi tạo datadir mới, không service')
    command = [str(bin_dir / 'mysqld.exe'), '--no-defaults', '--basedir=' + str(args.mysql_home.resolve()),
               '--datadir=' + str(data), '--port=' + str(port), '--bind-address=127.0.0.1',
               '--console', '--innodb-buffer-pool-size=32M', '--max-connections=25']
    client = [str(bin_dir / 'mysql.exe'), '--no-defaults', '--protocol=TCP', '--host=127.0.0.1',
              '--port=' + str(port), '--user=root', '--default-character-set=utf8mb4', '-N', '-B']
    def query(sql, database=None, failure=False, error_code=None):
        result = subprocess.run(client + ([database] if database else []), input=sql.encode('utf-8'),
                                capture_output=True, timeout=25, creationflags=flags)
        if failure:
            check(result.returncode != 0 and (error_code is None or
                  f'ERROR {error_code}'.encode() in result.stderr), 'Từ chối: ' + next((line for line in sql.splitlines() if line.startswith('INSERT')), sql)[:110])
        elif result.returncode != 0:
            raise AssertionError(result.stderr.decode('utf-8', errors='replace'))
        return result.stdout.decode('utf-8', errors='replace').replace('\r\n', '\n').strip()
    def payload(path):
        text = path.read_text(encoding='utf-8')
        # Chỉ bỏ các lệnh chọn/tạo/xóa schema; DDL và seed còn lại được chạy nguyên trên server tạm.
        return re.sub(r'^(?:DROP DATABASE|CREATE DATABASE|USE )[^\n]*\n', '', text, flags=re.M)
    with (work / 'mysql.log').open('wb') as log:
        server = subprocess.Popen(command, stdout=log, stderr=log, creationflags=flags)
        try:
            deadline = time.monotonic() + 45
            while True:
                try:
                    if query('SELECT 1;') == '1':
                        break
                except (AssertionError, subprocess.TimeoutExpired):
                    pass
                if server.poll() is not None or time.monotonic() > deadline:
                    raise RuntimeError('Server tạm không sẵn sàng; xem mysql.log')
                time.sleep(0.25)
            actual = query('SELECT @@datadir, @@port, VERSION();').split('\t')
            check(Path(actual[0]).resolve() == data.resolve() and int(actual[1]) == port,
                  'Xác minh đúng datadir và cổng tách biệt trước mọi DDL/DML')
            query('CREATE DATABASE legacy CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
                  'CREATE DATABASE libman2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
            query(payload(args.baseline), 'legacy')
            query(payload(project / 'sql' / 'libman2.sql'), 'libman2')
            check(query('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=\'libman2\';') == '17',
                  'Nạp đủ 17 bảng của SQL mới trên MariaDB')
            check(query('SELECT COALESCE(SUM(fineAmount),0) FROM legacy.tblReturnDetail2;') ==
                  query('SELECT COALESCE(SUM(fineAmount),0) FROM libman2.tblFineDetail2;') or
                  Decimal(query('SELECT SUM(fineAmount) FROM legacy.tblReturnDetail2;')) ==
                  Decimal(query('SELECT SUM(fineAmount) FROM libman2.tblFineDetail2;')),
                  'Tổng tiền chi tiết trước/sau bằng 6000')
            check(Decimal(query('SELECT SUM(totalFine) FROM legacy.tblReturnSlip2;')) ==
                  Decimal(query('SELECT SUM(fineAmount) FROM libman2.tblFineDetail2;')) == Decimal('6000'),
                  'Tổng phiếu cũ và tổng FineDetail mới đều 6000')
            check(query('SELECT id, tblReader2tblUser2id FROM tblReturnSlip2 ORDER BY id;', 'libman2') ==
                  '1\t3\n2\t3\n3\t4', 'Ánh xạ độc giả phiếu trả 1->3, 2->3, 3->4')
            check(query('SELECT COUNT(*) FROM tblFineDetail2 WHERE tblReturnDetail2id IN (1,2,4);', 'libman2') == '0',
                  'Chi tiết không phạt có 0 dòng phạt')
            check(query('SELECT tblReturnDetail2id,tblFineRule2id,fineAmount FROM tblFineDetail2;', 'libman2') ==
                  '3\t1\t6000.00', 'Khoản cũ 6000 giữ đúng chi tiết trả 3 và quy tắc 1')
            check(query("SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='libman2' "
                        "AND ((table_name='tblReturnSlip2' AND column_name IN ('totalFine','tblBorrowSlip2id')) "
                        "OR (table_name='tblReturnDetail2' AND column_name IN ('fineAmount','tblFineRule2id')));" ) == '0',
                  'Không còn cột phạt cũ hoặc khóa trực tiếp phiếu mượn')
            metadata = query("SELECT table_name,column_name,column_type,is_nullable,column_key FROM information_schema.columns "
                             "WHERE table_schema='libman2' AND table_name IN ('tblReturnSlip2','tblReturnDetail2','tblFineDetail2','tblFineRule2') "
                             "ORDER BY table_name,ordinal_position;")
            (work / 'columns.tsv').write_text(metadata, encoding='utf-8')
            check('tblfinedetail2\tfineamount\tdecimal(15,2)\tno' in metadata.lower() and
                  'tblfinerule2\tfixedamount\tdecimal(15,2)' in metadata.lower(), 'Hai trường tiền dùng DECIMAL(15,2) thực tế')
            for table in ['tblReturnSlip2', 'tblReturnDetail2', 'tblFineDetail2', 'tblFineRule2']:
                (work / (table + '-ddl.tsv')).write_text(query('SHOW CREATE TABLE ' + table + ';', 'libman2'), encoding='utf-8')
            check(query("SELECT COUNT(*) FROM information_schema.key_column_usage k "
                        "JOIN information_schema.columns c ON c.table_schema=k.table_schema AND c.table_name=k.table_name AND c.column_name=k.column_name "
                        "JOIN information_schema.columns p ON p.table_schema=k.referenced_table_schema AND p.table_name=k.referenced_table_name AND p.column_name=k.referenced_column_name "
                        "WHERE k.table_schema='libman2' AND k.referenced_table_name IS NOT NULL AND c.column_type<>p.column_type;") == '0',
                  'Mọi khóa ngoại có kiểu dữ liệu khớp khóa được tham chiếu')
            check(query("SELECT COUNT(*) FROM legacy.tblReturnDetail2 old LEFT JOIN "
                        "(SELECT tblReturnDetail2id,SUM(fineAmount) amount FROM libman2.tblFineDetail2 GROUP BY tblReturnDetail2id) f "
                        "ON f.tblReturnDetail2id=old.id WHERE old.fineAmount<>COALESCE(f.amount,0);") == '0',
                  'Tiền của từng chi tiết trả được bảo toàn, không chỉ tổng toàn bộ')
            # Kiểm tra bằng thao tác thật trong transaction, kết nối đóng sẽ rollback nếu gặp lỗi.
            for sql, code in [
                ('INSERT INTO tblFineDetail2 VALUES (1,3,1,1,NULL);',1062),
                ('INSERT INTO tblReturnSlip2 VALUES (1,CURRENT_DATE,NULL,2,3);',1062),
                ("INSERT INTO tblReturnDetail2 VALUES (1,'GOOD',1,4);",1062),
                ("INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',1,1);",1062),
                ("INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',1,NULL);",1048),
                ("INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',1,99999);",1452),
                ("INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',99999,4);",1452),
                ("INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',NULL,4);",1048),
                ('INSERT INTO tblReturnSlip2 VALUES (100,CURRENT_DATE,NULL,2,NULL);',1048),
                ('INSERT INTO tblReturnSlip2 VALUES (100,CURRENT_DATE,NULL,2,99999);',1452),
                ('INSERT INTO tblFineDetail2 VALUES (100,NULL,1,1,NULL);',1048),
                ('INSERT INTO tblFineDetail2 VALUES (100,3,NULL,1,NULL);',1048),
                ('INSERT INTO tblFineDetail2 VALUES (100,99999,1,1,NULL);',1452),
                ('INSERT INTO tblFineDetail2 VALUES (100,3,99999,1,NULL);',1452),
                ('INSERT INTO tblFineDetail2 VALUES (100,3,1,NULL,NULL);',1048),
                ('INSERT INTO tblFineDetail2 VALUES (100,3,1,-0.01,NULL);',4025),
            ]:
                query('START TRANSACTION;\n' + sql + '\nROLLBACK;', 'libman2', True, code)
            positive = query("""START TRANSACTION;
INSERT INTO tblFineDetail2 VALUES (100,3,1,1000.10,NULL),(101,3,2,1000.10,'equal amount');
SELECT COUNT(*),SUM(fineAmount) FROM tblFineDetail2 WHERE tblReturnDetail2id=3;
INSERT INTO tblReturnSlip2 VALUES (100,'2026-10-20',NULL,2,3),(101,'2026-10-21',NULL,2,3);
INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',100,4),(101,'GOOD',101,5);
SELECT COUNT(DISTINCT rd.tblReturnSlip2id) FROM tblReturnDetail2 rd JOIN tblBorrowDetail2 bd ON bd.id=rd.tblBorrowDetail2id WHERE bd.tblBorrowSlip2id=3;
INSERT INTO tblBorrowSlip2 VALUES (100,'2026-10-19','2026-11-02','BORROWED',3),(101,'2026-10-19','2026-11-02','BORROWED',3);
INSERT INTO tblBorrowDetail2 VALUES (100,'GOOD',100,1),(101,'GOOD',101,3);
INSERT INTO tblReturnSlip2 VALUES (102,'2026-10-25',NULL,2,3);
INSERT INTO tblReturnDetail2 VALUES (102,'GOOD',102,100),(103,'GOOD',102,101);
SELECT COUNT(DISTINCT bd.tblBorrowSlip2id),COUNT(DISTINCT bs.tblReader2id) FROM tblReturnDetail2 rd JOIN tblBorrowDetail2 bd ON bd.id=rd.tblBorrowDetail2id JOIN tblBorrowSlip2 bs ON bs.id=bd.tblBorrowSlip2id WHERE rd.tblReturnSlip2id=102;
ROLLBACK;""", 'libman2')
            check(positive.splitlines() == ['3\t8000.20','2','2\t1'],
                  'Nhiều phạt bằng tiền, số lẻ chính xác; trả từng phần; gom hai phiếu cùng độc giả')
            # Chứng minh giới hạn FK: sai chủ phiếu vẫn được DB nhận, truy vấn phát hiện được.
            mismatch = query("""START TRANSACTION;
INSERT INTO tblReturnSlip2 VALUES (100,CURRENT_DATE,NULL,2,4);
INSERT INTO tblReturnDetail2 VALUES (100,'GOOD',100,4);
SELECT COUNT(*) FROM tblReturnDetail2 rd JOIN tblReturnSlip2 rs ON rs.id=rd.tblReturnSlip2id
JOIN tblBorrowDetail2 bd ON bd.id=rd.tblBorrowDetail2id JOIN tblBorrowSlip2 bs ON bs.id=bd.tblBorrowSlip2id
WHERE rs.tblReader2tblUser2id<>bs.tblReader2id;
ROLLBACK;""", 'libman2')
            check(mismatch == '1', 'FK đơn lẻ chưa chặn sai độc giả; truy vấn kiểm tra phát hiện 1 vi phạm')
            check(query('SELECT COUNT(*),SUM(fineAmount) FROM tblFineDetail2;', 'libman2') == '1\t6000.00',
                  'Rollback toàn bộ dữ liệu kiểm thử, seed mới giữ nguyên')
            web = subprocess.run([sys.executable, str(project / 'tests' / 'verify_web2.py'),
                                  '--tomcat-home', str(args.tomcat_home), '--scratch', str(work / 'web'),
                                  '--test-db-port', str(port)], capture_output=True, timeout=150,
                                 creationflags=flags)
            (work / 'web-check.log').write_bytes(web.stdout + web.stderr)
            check(web.returncode == 0, 'Biên dịch và kiểm tra Java/DAO/HTTP trên DB mới tách biệt')
            output = {'checks':checks, 'passed':len(checks), 'work':str(work), 'db_port':port,
                      'db_identity':actual, 'sql_sha256':hashlib.sha256((project/'sql/libman2.sql').read_bytes()).hexdigest(),
                      'baseline_sha256':hashlib.sha256(args.baseline.read_bytes()).hexdigest(),
                      'web_result':json.loads(web.stdout.decode('utf-8').splitlines()[-1])}
            (work / 'results.json').write_text(json.dumps(output,ensure_ascii=False,indent=2),encoding='utf-8')
            print(json.dumps(output,ensure_ascii=True),flush=True)
        finally:
            if server.poll() is None:
                subprocess.run([str(bin_dir/'mysqladmin.exe'),'--no-defaults','--protocol=TCP',
                                '--host=127.0.0.1','--port='+str(port),'--user=root','shutdown'],
                               capture_output=True,timeout=15,creationflags=flags)
                try:
                    server.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    server.terminate()
                    server.wait(timeout=10)


if __name__ == '__main__':
    main()
