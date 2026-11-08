"""Kiểm tra mã mới trên Tomcat tách biệt; chỉ SELECT dữ liệu mẫu đang có.

Ví dụ: python tests/verify_web2.py --tomcat-home D:/xampp/tomcat --scratch C:/temp/libman-check
Không chép ứng dụng vào server đang chạy, không chạy file SQL gốc.
"""
import argparse
import hashlib
import html
import http.cookiejar
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request


LAUNCHER = """import org.apache.catalina.startup.Tomcat;
public class ReviewServer2 {
 public static void main(String[] args) throws Exception {
  Tomcat server = new Tomcat();
  server.setBaseDir(args[0]); server.setPort(0);
  org.apache.catalina.connector.Connector connector = new org.apache.catalina.connector.Connector("org.apache.coyote.http11.Http11Nio2Protocol");
  connector.setPort(0); server.getService().addConnector(connector); server.setConnector(connector);
  server.getConnector().setProperty("address", "127.0.0.1");
  server.addWebapp("/review", args[1]); server.addWebapp("/failure", args[2]);
  server.start();
  System.out.println("REVIEW_READY=" + server.getConnector().getLocalPort());
  System.out.flush();
  try { System.in.read(); } finally { server.stop(); server.destroy(); }
 }
}
"""


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tomcat-home", type=Path, required=True)
    parser.add_argument("--scratch", type=Path, required=True)
    parser.add_argument("--browser-review", action="store_true", help="Giữ server tạm tối đa 15 phút để kiểm tra trình duyệt; tạo browser-done trong thư mục tạm để dừng")
    parser.add_argument("--test-db-port", type=int, help="Chỉ đổi kết nối trong bản sao nguồn tạm, không sửa DAO2 gốc")
    args = parser.parse_args()
    if args.test_db_port is not None and not 1024 <= args.test_db_port <= 65535:
        parser.error("Cổng thử nghiệm phải từ 1024 đến 65535")
    if args.test_db_port == 3306:
        parser.error("Không dùng cổng DB mặc định cho tùy chọn thử nghiệm")
    project = Path(__file__).resolve().parents[1]
    args.scratch.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix="libman2-", dir=args.scratch))
    results = []
    def source_manifest():
        return {str(p.relative_to(project)): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in sorted(project.rglob("*")) if p.is_file() and
                (p.suffix in {".java", ".jsp", ".jspf", ".css"} or p.name == "web.xml") and "target" not in p.parts}
    tested_manifest = source_manifest()

    def run(command, expected=0, cwd=None):
        result = subprocess.run(command, cwd=cwd or project, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=60)
        if result.returncode != expected:
            raise AssertionError(f"Command failed ({result.returncode}): {command[0]}\n{result.stdout}\n{result.stderr}")
        return result

    def check(condition, name):
        if not condition:
            raise AssertionError(name)
        results.append(name)

    app = work / "webapp"
    shutil.copytree(project / "WebContent", app)
    classes = app / "WEB-INF" / "classes"
    classes.mkdir()
    compile_root = project
    if args.test_db_port is not None:
        compile_root = work / "compile-source"
        shutil.copytree(project / "src", compile_root / "src")
        dao = compile_root / "src" / "dao" / "DAO2.java"
        text = dao.read_text(encoding="utf-8")
        original_url = "jdbc:mysql://localhost:3306/libman2?"
        if text.count(original_url) != 1:
            raise AssertionError("Không nhận diện được cấu hình nguồn để tạo bản sao thử nghiệm")
        dao.write_text(text.replace(original_url, f"jdbc:mysql://127.0.0.1:{args.test_db_port}/libman2?"), encoding="utf-8")
    sources = sorted((compile_root / "src").rglob("*.java"))
    compile_result = run(["javac", "--release", "17", "-encoding", "UTF-8", "-Xlint:all", "-d", str(classes),
                          *[str(p.relative_to(compile_root)) for p in sources]], cwd=compile_root)
    check(not compile_result.stderr.strip(), "Biên dịch toàn bộ Java không cảnh báo")
    offline = run(["java", "-Dstdout.encoding=UTF-8", "-cp", str(classes), "test.TestRunner2"])
    check("PASS:" in offline.stdout, "Kiểm tra Java không cần DB")
    mysql = app / "WEB-INF" / "lib" / "mysql-connector-j-8.2.0.jar"
    cp = str(classes) + ";" + str(mysql)
    database = run(["java", "-Dstdout.encoding=UTF-8", "-cp", cp, "test.TestRunner2", "--database"])
    check("PASS:" in database.stdout, "Kiểm tra DAO/đăng nhập/kết nối trên MySQL chỉ đọc")
    missing = subprocess.run(["java", "-cp", str(classes), "test.TestRunner2", "--database"], capture_output=True, timeout=30)
    check(missing.returncode != 0 and b"PASS:" not in missing.stdout, "Thiếu driver phải báo thất bại, không báo PASS")

    failure = work / "failure-app"
    shutil.copytree(app, failure, ignore=shutil.ignore_patterns("mysql-connector*.jar"))
    libs = work / "server-lib"
    libs.mkdir()
    for file in (args.tomcat_home / "lib").glob("*.jar"):
        if "mysql-connector" not in file.name:
            shutil.copyfile(file, libs / file.name)
    shutil.copyfile(args.tomcat_home / "bin" / "tomcat-juli.jar", libs / "tomcat-juli.jar")
    launcher = work / "launcher"
    launcher.mkdir()
    (launcher / "ReviewServer2.java").write_text(LAUNCHER, encoding="utf-8")
    run(["javac", "--release", "17", "-cp", str(libs / "*"), "-d", str(launcher), str(launcher / "ReviewServer2.java")])
    server_base = work / "server"
    (server_base / "conf").mkdir(parents=True)
    shutil.copyfile(args.tomcat_home / "conf" / "web.xml", server_base / "conf" / "web.xml")
    log_path = work / "tomcat.log"
    with log_path.open("w", encoding="utf-8") as log:
        process = subprocess.Popen(["java", "-Dstdout.encoding=UTF-8", "-Dstderr.encoding=UTF-8",
                                    "-cp", str(launcher) + ";" + str(libs / "*"), "ReviewServer2",
                                    str(server_base), str(app), str(failure)],
                                   stdin=subprocess.PIPE, stdout=log, stderr=log)
        try:
            deadline = time.monotonic() + 45
            while True:
                match = re.search(r"REVIEW_READY=(\d+)", log_path.read_text(encoding="utf-8", errors="replace"))
                if match:
                    break
                if process.poll() is not None or time.monotonic() > deadline:
                    raise RuntimeError("Server tách biệt không khởi động: " + log_path.read_text(encoding="utf-8", errors="replace")[-7000:])
                time.sleep(0.2)
            base = "http://127.0.0.1:" + match[1]

            def client():
                cookies = http.cookiejar.CookieJar()
                return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookies), NoRedirect()), cookies

            def request(opener, path, data=None, context="review"):
                encoded = None if data is None else urllib.parse.urlencode(data).encode("utf-8")
                try:
                    res = opener.open(base + "/" + context + "/" + path, encoded, timeout=15)
                except urllib.error.HTTPError as error:
                    res = error
                return res.code, res.read().decode("utf-8", errors="replace"), res.headers

            dates = "txtStartDate=2026-09-01&txtEndDate=2026-10-31"
            protected = ["UIReaderHome2.jsp", "UISearchDocument2.jsp", "UIDocumentDetail2.jsp?docTitleId=1",
                         "UIManagerHome2.jsp", "UISelectStat2.jsp", "UIStatReader2.jsp?" + dates,
                         "UIReaderBorrowHistory2.jsp?readerId=3&" + dates,
                         "UIBorrowSlipDetail2.jsp?borrowSlipId=1&readerId=3&" + dates]
            guest, _ = client()
            for path in protected:
                code, _, headers = request(guest, path)
                check(code == 302 and headers.get("Location", "").endswith("index.jsp"), "Khách bị chặn: " + path.split("?")[0])

            reader, cookies = client()
            request(reader, "index.jsp")
            before = [c.value for c in cookies if c.name == "JSESSIONID"]
            code, _, headers = request(reader, "index.jsp", {"username": "reader1", "password": "123456"})
            after = [c.value for c in cookies if c.name == "JSESSIONID"]
            check(code == 302 and headers.get("Location", "").endswith("UIReaderHome2.jsp") and before != after, "Đăng nhập bạn đọc đổi mã phiên")
            check("Sinh viên chính quy" in request(reader, "UIReaderHome2.jsp")[1], "Thông tin bạn đọc lấy từ DB")
            for path in protected[3:]:
                check(request(reader, path)[0] == 403, "Bạn đọc không vào được quản lý: " + path.split("?")[0])
            code, body, _ = request(reader, "UISearchDocument2.jsp?" + urllib.parse.urlencode({"txtKeyword": "Thiết kế"}))
            check(code == 200 and "Phân tích và Thiết kế Hệ thống" in body, "Tìm kiếm tiếng Việt trên JSP mới")
            check("txtKeyword=Thi%E1%BA%BFt+k%E1%BA%BF" in body, "Link chi tiết giữ từ khóa đã tìm")
            code, detail, _ = request(reader, "UIDocumentDetail2.jsp?docTitleId=1&" + urllib.parse.urlencode({"txtKeyword": "Thiết kế"}))
            check(code == 200 and "UISearchDocument2.jsp?txtKeyword=Thi%E1%BA%BFt+k%E1%BA%BF" in detail, "Link quay lại khôi phục tìm kiếm")
            payload = '\"><script>window.__libmanReview=1</script>&\''
            code, body, _ = request(reader, "UISearchDocument2.jsp?" + urllib.parse.urlencode({"txtKeyword": payload}))
            check(code == 200 and payload not in body and "&lt;script&gt;" in body and "&quot;" in body, "Đầu vào HTML được escape")
            for value in ["abc", "0", "-1", "2147483648"]:
                check(request(reader, "UIDocumentDetail2.jsp?docTitleId=" + value)[0] == 400, "Từ chối mã tài liệu " + value)
            check(request(reader, "UIDocumentDetail2.jsp")[0] == 400, "Không tự chọn tài liệu khi thiếu ID")
            check(request(reader, "UIDocumentDetail2.jsp?docTitleId=2147483647")[0] == 404, "Tài liệu không tồn tại trả 404")
            check(request(reader, "UIDocumentDetail2.jsp?docTitleId=1")[0] == 200, "Chi tiết tài liệu hợp lệ")
            check(request(reader, "logout2.jsp")[0] == 302 and request(reader, "UIReaderHome2.jsp")[0] == 302, "Đăng xuất hủy danh tính")

            manager, _ = client()
            check(request(manager, "index.jsp", {"username": "manager", "password": "123456"})[0] == 302, "Đăng nhập quản lý")
            check("Trưởng phòng thư viện" in request(manager, "UIManagerHome2.jsp")[1], "Chức vụ quản lý lấy từ DB")
            check(request(manager, "UISearchDocument2.jsp")[0] == 403, "Quản lý không tự đổi sang bạn đọc")
            code, body, _ = request(manager, "UIStatReader2.jsp?" + dates)
            check(code == 200 and "3 lượt" in body and "5 cuốn" in body, "Bảng thống kê đúng kỳ")
            check("Khoảng ngày mượn" in body and "01/09/2026" in body and "31/10/2026" in body, "Kỳ kết quả theo ngày mượn, hiển thị Việt Nam")
            check("Tiền phạt" not in body and "getTotalFine" not in body and len(re.findall(r"<th[ >]", body)) == 8,
                  "Thống kê chỉ còn 8 cột, không có tiền phạt")
            check(">STT</th>" in body and all(text not in body for text in ["Thứ hạng", "Top 1", "Top 2", "Top 3", "🥇", "🥈", "🥉", "Bảng xếp hạng"]),
                  "STT thay thứ hạng và huy chương")
            check(re.findall(r'DG-[0-9]+', body) == ["DG-003", "DG-004", "DG-005"], "Giữ thứ tự độc giả 3-2-1 lượt")
            code, form, _ = request(manager, "UISelectStat2.jsp?txtStartDate=2026-09-05&txtEndDate=2026-10-15")
            check(code == 200 and 'value="2026-09-05"' in form and 'value="2026-10-15"' in form, "Form thống kê giữ khoảng ngày truyền vào")
            check("Ngày mượn từ" in form and "Ngày mượn đến" in form, "Nhãn form nói rõ ngày mượn")
            check("btnExportExcel" not in body and "Xuất Excel" not in body and "Xuất file Excel" not in body, "Nút Xuất Excel đã được bỏ hoàn toàn")
            for path in ["UIStatReader2.jsp", "UIStatReader2.jsp?txtStartDate=2026-10-01",
                         "UIStatReader2.jsp?txtStartDate=bad&txtEndDate=2026-10-31",
                         "UIStatReader2.jsp?txtStartDate=2026-02-30&txtEndDate=2026-10-31",
                         "UIStatReader2.jsp?txtStartDate=2026-10-31&txtEndDate=2026-09-01",
                         "UIStatReader2.jsp?selectStatType=DOC_BORROW_STAT&" + dates,
                         "UIReaderBorrowHistory2.jsp?readerId=3&txtStartDate=2026-10-01",
                         "UIReaderBorrowHistory2.jsp?readerId=abc&" + dates]:
                check(request(manager, path)[0] == 400, "Từ chối tham số sai: " + path)
            _, error_body, _ = request(manager, "UIStatReader2.jsp?txtStartDate=2026-10-31&txtEndDate=2026-09-01")
            check("Ngày bắt đầu không được sau ngày kết thúc" in error_body and "Quay lại và kiểm tra" in error_body,
                  "Thông báo ngày đảo rõ nguyên nhân và có đường quay lại")
            check(request(manager, "UIReaderBorrowHistory2.jsp?readerId=2147483647&" + dates)[0] == 404, "Độc giả không tồn tại trả 404")
            code, body, _ = request(manager, "UIReaderBorrowHistory2.jsp?readerId=3&" + dates)
            check(code == 200 and all(p in body for p in ["PM-0001", "PM-0002", "PM-0003"]), "Lịch sử giữ đủ kỳ và phiếu")
            check("05/09/2026" in body and "19/09/2026" in body, "Ngày lịch sử dd/MM/yyyy")
            check("DG-003" in body and "01/09/2026 – 31/10/2026" in body
                  and "Các phiếu có ngày mượn trong khoảng đã chọn" in body and "Chi tiết phiếu" in body,
                  "Lịch sử có mã độc giả, kỳ thống kê và nhãn rõ ngữ cảnh")
            code, detail, _ = request(manager, "UIBorrowSlipDetail2.jsp?borrowSlipId=3&readerId=3&" + dates)
            check(code == 200 and all(text in detail for text in ["Phiếu mượn PM-0003", "Lê Bạn Đọc", "DG-003",
                  "15/10/2026", "29/10/2026", "Đang mượn"])
                  and re.search(r"Tài liệu trong phiếu [—-] 2 cuốn", detail),
                  "Chi tiết phiếu hiển thị dữ liệu chủ phiếu, ngày, trạng thái và số cuốn thực tế")
            check(request(manager, "UIBorrowSlipDetail2.jsp?borrowSlipId=1&readerId=3&" + dates)[0] == 200, "Chi tiết phiếu đúng độc giả")
            check(request(manager, "UIBorrowSlipDetail2.jsp?borrowSlipId=1&readerId=4&" + dates)[0] == 400, "Từ chối phiếu sai độc giả")
            check(request(manager, "UIBorrowSlipDetail2.jsp?borrowSlipId=1&readerId=3&txtStartDate=2026-10-01&txtEndDate=2026-10-31")[0] == 400, "Từ chối phiếu ngoài kỳ")
            check(request(manager, "UIBorrowSlipDetail2.jsp?borrowSlipId=2147483647&readerId=3&" + dates)[0] == 404, "Phiếu không tồn tại trả 404")
            check(request(manager, "UIBorrowSlipDetail2.jsp?borrowSlipId=abc&readerId=3&" + dates)[0] == 400, "Phiếu sai ID không về phiếu mẫu")
            code, body, _ = request(manager, "UIStatReader2.jsp?txtStartDate=2026-11-01&txtEndDate=2026-11-30")
            check(code == 200 and "Không có dữ liệu mượn sách" in body and 'colspan="8"' in body, "Kỳ rỗng có colspan 8, khác lỗi hệ thống")
            check(request(manager, "index.jsp", {"username": "manager", "password": "sai"})[0] == 401
                  and request(manager, "UIManagerHome2.jsp")[0] == 302, "Đăng nhập sai không giữ danh tính cũ")
            broken, _ = client()
            code, body, _ = request(broken, "index.jsp", {"username": "reader1", "password": "123456"}, "failure")
            check(code == 503 and "chưa thể xác thực" in body and "không chính xác" not in body, "Thiếu driver trên bản tách biệt trả lỗi hệ thống")
            # Render nhánh trạng thái lạ trên bản sao JSP tạm, không sửa DB hay nguồn.
            # Chèn trạng thái sau khi DAO đọc để chính HTML của JSP xử lý fallback.
            fixtures = [
                ("UIDocumentDetail2.jsp", "                for (DocumentCopy2 cp : listCopies) {", "                    cp.setStatus(\"UNKNOWN_REVIEW\");", reader),
                ("UIReaderBorrowHistory2.jsp", "                            for (BorrowSlip2 slip : listBorrowSlips) {", "                                slip.setStatus(\"UNKNOWN_REVIEW\");", manager),
                ("UIBorrowSlipDetail2.jsp", "        listDetail = slipDAO.getBorrowSlipDetail(borrowSlipId);", "        slip.setStatus(\"UNKNOWN_REVIEW\");", manager),
            ]
            # Dùng phiên bạn đọc mới vì phiên trước đã đăng xuất.
            fixture_reader, _ = client()
            request(fixture_reader, "index.jsp", {"username": "reader1", "password": "123456"})
            # Phiên manager trước vừa đăng nhập sai; xác thực lại để kiểm tra fixture.
            request(manager, "index.jsp", {"username": "manager", "password": "123456"})
            for original, marker, insertion, _ in fixtures:
                source = (app / original).read_text(encoding="utf-8")
                if marker not in source:
                    raise AssertionError("Không tìm thấy điểm chèn trạng thái kiểm tra: " + original)
                fixture_name = "reviewUnknown" + original
                fixture = app / fixture_name
                fixture.write_text(source.replace(marker, marker + "\n" + insertion, 1), encoding="utf-8")
                params = "docTitleId=1" if original.startswith("UIDocument") else (
                    "readerId=3&" + dates if original.startswith("UIReader") else "borrowSlipId=3&readerId=3&" + dates)
                fixture_client = fixture_reader if original.startswith("UIDocument") else manager
                code, rendered, _ = request(fixture_client, fixture_name + "?" + params)
                check(code == 200 and "Chưa xác định" in rendered and "ĐANG ĐƯỢC MƯỢN" not in rendered
                      and "ĐANG MƯỢN" not in rendered and ">Đang mượn<" not in rendered,
                      "Trạng thái lạ không bị gán đang mượn: " + original)
                fixture.unlink()  # Chỉ xóa file kiểm tra trong bản sao tạm do script tạo.
            if args.browser_review:
                (work / "browser-ready.json").write_text(json.dumps({"base": base + "/review/", "work": str(work)}), encoding="utf-8")
                print(json.dumps({"browser_ready": str(work / "browser-ready.json"), "passed": len(results)}), flush=True)
                deadline = time.monotonic() + 900
                while not (work / "browser-done").exists() and time.monotonic() < deadline:
                    time.sleep(0.5)
        finally:
            if process.poll() is None:
                try:
                    process.communicate(input=b"\n", timeout=15)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=10)

    manifest = source_manifest()
    if manifest != tested_manifest:
        raise AssertionError("Mã nguồn đã đổi trong lúc kiểm tra; cần chạy lại bản mới trước khi xác nhận")
    output = {"passed": len(results), "checks": results, "java_offline": offline.stdout.strip(),
              "java_database": database.stdout.strip(), "source_sha256": manifest,
              "source": str(project), "isolated_work": str(work), "log": str(log_path), "test_db_port": args.test_db_port}
    (work / "results.json").write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({k: output[k] for k in ["passed", "java_offline", "java_database", "isolated_work"]}, ensure_ascii=True))


if __name__ == "__main__":
    main()
