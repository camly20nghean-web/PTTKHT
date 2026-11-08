-- ========================================================
-- DATABASE SCRIPT FOR LIBMAN2 (SYSTEM ANALYSIS & DESIGN - PTIT)
-- Đề tài: Quản lý thư viện (LibMan) - Đề số 5 (Suffix: 2)
-- ========================================================

-- Chỉ dùng để tạo CSDL mẫu mới. Không chạy trên CSDL đang dùng.
-- CREATE DATABASE sẽ báo lỗi nếu libman2 đã tồn tại; không xóa dữ liệu cũ.
CREATE DATABASE libman2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE libman2;

-- 1. Bảng tblUser2 (Tài khoản người dùng chung)
CREATE TABLE tblUser2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fullName VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    role VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- 2. Bảng tblStaff2 (Kế thừa từ tblUser2)
CREATE TABLE tblStaff2 (
    tblUser2id INT PRIMARY KEY,
    position VARCHAR(255),
    FOREIGN KEY (tblUser2id) REFERENCES tblUser2(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Bảng tblManager2 (Kế thừa từ tblStaff2)
CREATE TABLE tblManager2 (
    tblStaff2id INT PRIMARY KEY,
    FOREIGN KEY (tblStaff2id) REFERENCES tblStaff2(tblUser2id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Bảng tblLibrarian2 (Kế thừa từ tblStaff2)
CREATE TABLE tblLibrarian2 (
    tblStaff2id INT PRIMARY KEY,
    shift VARCHAR(255),
    FOREIGN KEY (tblStaff2id) REFERENCES tblStaff2(tblUser2id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Bảng tblReader2 (Kế thừa từ tblUser2)
CREATE TABLE tblReader2 (
    tblUser2id INT PRIMARY KEY,
    readerType VARCHAR(255),
    FOREIGN KEY (tblUser2id) REFERENCES tblUser2(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Bảng tblReaderCard2 (Thẻ thư viện bạn đọc, quan hệ 1-1 với tblReader2)
CREATE TABLE tblReaderCard2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    issuedDate DATE NOT NULL,
    expiryDate DATE NOT NULL,
    status VARCHAR(255) NOT NULL,
    tblReader2id INT NOT NULL UNIQUE,
    FOREIGN KEY (tblReader2id) REFERENCES tblReader2(tblUser2id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Bảng tblSupplier2 (Nhà cung cấp tài liệu)
CREATE TABLE tblSupplier2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplierName VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    description VARCHAR(255)
) ENGINE=InnoDB;

-- 8. Bảng tblImportSlip2 (Phiếu nhập tài liệu)
CREATE TABLE tblImportSlip2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    importDate DATE NOT NULL,
    totalQuantity INT DEFAULT 0,
    amount DOUBLE DEFAULT 0,
    tblLibrarian2id INT NOT NULL,
    tblSupplier2id INT NOT NULL,
    FOREIGN KEY (tblLibrarian2id) REFERENCES tblLibrarian2(tblStaff2id),
    FOREIGN KEY (tblSupplier2id) REFERENCES tblSupplier2(id)
) ENGINE=InnoDB;

-- 9. Bảng tblDocumentTitle2 (Tựa tài liệu / Đầu sách)
CREATE TABLE tblDocumentTitle2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titleName VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publisher VARCHAR(255),
    publishYear INT,
    description VARCHAR(255)
) ENGINE=InnoDB;

-- 10. Bảng tblImportDetail2 (Chi tiết phiếu nhập)
CREATE TABLE tblImportDetail2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
    unitPrice DOUBLE NOT NULL,
    tblImportSlip2id INT NOT NULL,
    tblDocumentTitle2id INT NOT NULL,
    FOREIGN KEY (tblImportSlip2id) REFERENCES tblImportSlip2(id) ON DELETE CASCADE,
    FOREIGN KEY (tblDocumentTitle2id) REFERENCES tblDocumentTitle2(id)
) ENGINE=InnoDB;

-- 11. Bảng tblDocumentCopy2 (Bản sao / Cuốn sách vật lý)
CREATE TABLE tblDocumentCopy2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    physicalCondition VARCHAR(255) NOT NULL DEFAULT 'GOOD',
    status VARCHAR(255) NOT NULL DEFAULT 'AVAILABLE',
    barcode VARCHAR(255) NOT NULL UNIQUE,
    tblDocumentTitle2id INT NOT NULL,
    FOREIGN KEY (tblDocumentTitle2id) REFERENCES tblDocumentTitle2(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 12. Bảng tblBorrowSlip2 (Phiếu mượn tài liệu)
CREATE TABLE tblBorrowSlip2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    borrowDate DATE NOT NULL,
    expectedReturnDate DATE NOT NULL,
    status VARCHAR(255) NOT NULL DEFAULT 'BORROWED',
    tblReader2id INT NOT NULL,
    FOREIGN KEY (tblReader2id) REFERENCES tblReader2(tblUser2id)
) ENGINE=InnoDB;

-- 13. Bảng tblBorrowDetail2 (Chi tiết phiếu mượn)
CREATE TABLE tblBorrowDetail2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conditionAtBorrow VARCHAR(255) NOT NULL DEFAULT 'GOOD',
    tblBorrowSlip2id INT NOT NULL,
    tblDocumentCopy2id INT NOT NULL,
    FOREIGN KEY (tblBorrowSlip2id) REFERENCES tblBorrowSlip2(id) ON DELETE CASCADE,
    FOREIGN KEY (tblDocumentCopy2id) REFERENCES tblDocumentCopy2(id)
) ENGINE=InnoDB;

-- 14. Bảng tblReturnSlip2 (Phiếu trả tài liệu)
CREATE TABLE tblReturnSlip2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    actualReturnDate DATE NOT NULL,
    note VARCHAR(255),
    tblLibrarian2id INT NOT NULL,
    tblReader2tblUser2id INT NOT NULL,
    FOREIGN KEY (tblLibrarian2id) REFERENCES tblLibrarian2(tblStaff2id),
    FOREIGN KEY (tblReader2tblUser2id) REFERENCES tblReader2(tblUser2id)
) ENGINE=InnoDB;

-- 15. Bảng tblFineRule2 (Quy định phạt vi phạm)
CREATE TABLE tblFineRule2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    violationType VARCHAR(255) NOT NULL,
    fixedAmount DECIMAL(15,2) DEFAULT 0,
    percentageRate INT DEFAULT 0
) ENGINE=InnoDB;

-- 16. Bảng tblReturnDetail2 (Mỗi chi tiết mượn có tối đa một chi tiết trả)
CREATE TABLE tblReturnDetail2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conditionAtReturn VARCHAR(255) NOT NULL,
    tblReturnSlip2id INT NOT NULL,
    tblBorrowDetail2id INT NOT NULL UNIQUE,
    FOREIGN KEY (tblReturnSlip2id) REFERENCES tblReturnSlip2(id) ON DELETE CASCADE,
    FOREIGN KEY (tblBorrowDetail2id) REFERENCES tblBorrowDetail2(id)
) ENGINE=InnoDB;

-- 17. Bảng tblFineDetail2 (Một chi tiết trả có 0..n khoản phạt)
CREATE TABLE tblFineDetail2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tblReturnDetail2id INT NOT NULL,
    tblFineRule2id INT NOT NULL,
    fineAmount DECIMAL(15,2) NOT NULL,
    note VARCHAR(255),
    CONSTRAINT chkFineDetail2Amount CHECK (fineAmount >= 0),
    FOREIGN KEY (tblReturnDetail2id) REFERENCES tblReturnDetail2(id) ON DELETE CASCADE,
    FOREIGN KEY (tblFineRule2id) REFERENCES tblFineRule2(id)
) ENGINE=InnoDB;

-- Khi lưu phiếu trả, phải kiểm tra mọi BorrowDetail thuộc độc giả của ReturnSlip
-- trong cùng giao dịch. Các FK đơn lẻ chưa tự bảo đảm ràng buộc liên bảng này.

-- ========================================================
-- INSERT SEED DATA (DỮ LIỆU MẪU ĐỂ CHẠY HỆ THỐNG VÀ KIỂM THỬ)
-- ========================================================

-- 1. Người dùng mẫu (tblUser2)
INSERT INTO tblUser2 (id, username, password, fullName, address, phone, email, role) VALUES
(1, 'manager', '123456', 'Nguyễn Quản Lý', 'Hà Nội', '0901234567', 'manager@ptit.edu.vn', 'MANAGER'),
(2, 'librarian', '123456', 'Trần Thủ Thư', 'Hà Nội', '0912345678', 'librarian@ptit.edu.vn', 'LIBRARIAN'),
(3, 'reader1', '123456', 'Lê Bạn Đọc', 'Hà Đông, Hà Nội', '0987654321', 'reader1@ptit.edu.vn', 'READER'),
(4, 'reader2', '123456', 'Phạm Văn Nam', 'Thanh Xuân, Hà Nội', '0977112233', 'reader2@ptit.edu.vn', 'READER'),
(5, 'reader3', '123456', 'Hoàng Thị Mai', 'Cầu Giấy, Hà Nội', '0966445566', 'reader3@ptit.edu.vn', 'READER'),
(6, 'reader4', '123456', 'Vũ Minh Tuấn', 'Đống Đa, Hà Nội', '0955778899', 'reader4@ptit.edu.vn', 'READER');

-- 2. Nhân viên (tblStaff2)
INSERT INTO tblStaff2 (tblUser2id, position) VALUES
(1, 'Trưởng phòng thư viện'),
(2, 'Nhân viên quản lý kho sách');

-- 3. Quản lý (tblManager2)
INSERT INTO tblManager2 (tblStaff2id) VALUES (1);

-- 4. Thủ thư (tblLibrarian2)
INSERT INTO tblLibrarian2 (tblStaff2id, shift) VALUES (2, 'Ca Sáng (07:30 - 11:30)');

-- 5. Bạn đọc (tblReader2)
INSERT INTO tblReader2 (tblUser2id, readerType) VALUES
(3, 'Sinh viên chính quy'),
(4, 'Sinh viên chất lượng cao'),
(5, 'Học viên cao học'),
(6, 'Giảng viên');

-- 6. Thẻ bạn đọc (tblReaderCard2)
INSERT INTO tblReaderCard2 (id, issuedDate, expiryDate, status, tblReader2id) VALUES
(1, '2025-09-01', '2027-09-01', 'ACTIVE', 3),
(2, '2025-09-01', '2027-09-01', 'ACTIVE', 4),
(3, '2025-10-01', '2026-10-01', 'ACTIVE', 5),
(4, '2024-01-01', '2028-01-01', 'ACTIVE', 6);

-- 7. Nhà cung cấp (tblSupplier2)
INSERT INTO tblSupplier2 (id, supplierName, address, phone, email, description) VALUES
(1, 'NXB Giáo Dục Việt Nam', 'Hà Nội', '02438220801', 'nxbgiaoduc@gmail.com', 'Cung cấp giáo trình đại học chuẩn'),
(2, 'NXB Thông Tin & Truyền Thông', 'Hà Nội', '02435772139', 'nxb.tttt@mic.gov.vn', 'Chuyên sách CNTT và Viễn thông');

-- 8. Tựa tài liệu (tblDocumentTitle2)
INSERT INTO tblDocumentTitle2 (id, titleName, category, author, publisher, publishYear, description) VALUES
(1, 'Phân tích và Thiết kế Hệ thống', 'Công nghệ phần mềm', 'Đỗ Thị Ngọc', 'NXB Giáo Dục', 2020, 'Giáo trình thực hành PTKTHT hướng đối tượng với UML'),
(2, 'Lập trình Web nâng cao với J2EE', 'Lập trình ứng dụng', 'Nguyễn Bá Thành', 'NXB Thông Tin & Truyền Thông', 2022, 'Phát triển Web Servlet, JSP, JDBC, Spring MVC'),
(3, 'Cơ sở dữ liệu và Hệ quản trị CSDL', 'Cơ sở dữ liệu', 'Trần Văn Cường', 'NXB Khoa Học Kỹ Thuật', 2021, 'Lý thuyết mô hình quan hệ, chuẩn hóa CSDL và SQL'),
(4, 'Cấu trúc dữ liệu và Giải thuật', 'Khoa học máy tính', 'Lê Minh Hoàng', 'NXB Đại Học Quốc Gia', 2019, 'Các thuật toán kinh điển, cấu trúc cây, đồ thị và quy hoạch động'),
(5, 'An toàn và Bảo mật thông tin', 'An toàn thông tin', 'Phạm Quốc Hùng', 'NXB Bưu Điện', 2023, 'Mật mã học, an ninh mạng và xác thực dữ liệu');

-- 9. Bản sao tài liệu (tblDocumentCopy2)
INSERT INTO tblDocumentCopy2 (id, physicalCondition, status, barcode, tblDocumentTitle2id) VALUES
(1, 'Mới (100%)', 'AVAILABLE', 'BC-PTKTHT-001', 1),
(2, 'Tốt (95%)', 'BORROWED',  'BC-PTKTHT-002', 1),
(3, 'Tốt (90%)', 'AVAILABLE', 'BC-PTKTHT-003', 1),
(4, 'Mới (100%)', 'BORROWED',  'BC-J2EE-001',   2),
(5, 'Tốt (90%)', 'AVAILABLE', 'BC-J2EE-002',   2),
(6, 'Tốt (85%)', 'AVAILABLE', 'BC-CSDL-001',   3),
(7, 'Cũ (70%)', 'BORROWED',  'BC-CSDL-002',   3),
(8, 'Mới (100%)', 'BORROWED', 'BC-CTDL-001',   4),
(9, 'Mới (100%)', 'AVAILABLE', 'BC-ATTT-001',   5);

-- 10. Phiếu nhập (tblImportSlip2) & Chi tiết nhập (tblImportDetail2)
INSERT INTO tblImportSlip2 (id, importDate, totalQuantity, amount, tblLibrarian2id, tblSupplier2id) VALUES
(1, '2026-08-15', 5, 450000, 2, 1);

INSERT INTO tblImportDetail2 (id, quantity, unitPrice, tblImportSlip2id, tblDocumentTitle2id) VALUES
(1, 3, 90000, 1, 1),
(2, 2, 90000, 1, 2);

-- 11. Quy định phạt (tblFineRule2)
INSERT INTO tblFineRule2 (id, violationType, fixedAmount, percentageRate) VALUES
(1, 'Trễ hạn trả sách (phạt theo ngày)', 2000, 0),
(2, 'Làm hỏng sách nhẹ (rách bìa, vẽ bẩn)', 10000, 20),
(3, 'Làm mất sách hoàn toàn', 0, 100);

-- 12. Phiếu mượn (tblBorrowSlip2) - Tạo các lần mượn để thống kê
-- Reader 3 (Lê Bạn Đọc) có 3 lượt mượn
-- Reader 4 (Phạm Văn Nam) có 2 lượt mượn
-- Reader 5 (Hoàng Thị Mai) có 1 lượt mượn
INSERT INTO tblBorrowSlip2 (id, borrowDate, expectedReturnDate, status, tblReader2id) VALUES
(1, '2026-09-05', '2026-09-19', 'RETURNED', 3),
(2, '2026-09-25', '2026-10-09', 'RETURNED', 3),
(3, '2026-10-15', '2026-10-29', 'BORROWED', 3),
(4, '2026-09-10', '2026-09-24', 'RETURNED', 4),
(5, '2026-10-01', '2026-10-15', 'BORROWED', 4),
(6, '2026-10-10', '2026-10-24', 'BORROWED', 5);

-- 13. Chi tiết mượn (tblBorrowDetail2)
INSERT INTO tblBorrowDetail2 (id, conditionAtBorrow, tblBorrowSlip2id, tblDocumentCopy2id) VALUES
(1, 'Mới (100%)', 1, 1),
(2, 'Tốt (95%)',  1, 6),
(3, 'Tốt (90%)',  2, 3),
(4, 'Tốt (95%)',  3, 2),
(5, 'Mới (100%)', 3, 4),
(6, 'Tốt (90%)',  4, 5),
(7, 'Cũ (70%)',   5, 7),
(8, 'Mới (100%)', 6, 8);

-- 14. Phiếu trả (tblReturnSlip2)
INSERT INTO tblReturnSlip2 (id, actualReturnDate, note, tblLibrarian2id, tblReader2tblUser2id) VALUES
(1, '2026-09-18', 'Trả sách đúng hạn, tình trạng tốt', 2, 3),
(2, '2026-10-12', 'Trả trễ 3 ngày', 2, 3),
(3, '2026-09-24', 'Trả sách đúng hạn', 2, 4);

-- 15. Chi tiết trả: không lưu tiền hoặc quy tắc phạt trực tiếp
INSERT INTO tblReturnDetail2 (id, conditionAtReturn, tblReturnSlip2id, tblBorrowDetail2id) VALUES
(1, 'Tốt (95%)', 1, 1),
(2, 'Tốt (90%)', 1, 2),
(3, 'Tốt (90%)', 2, 3),
(4, 'Tốt (90%)', 3, 6);

-- 16. Chuyển khoản phạt 6.000 của chi tiết trả 3 sang dòng phạt riêng.
-- Các chi tiết trả không bị phạt không tạo dòng FineDetail.
INSERT INTO tblFineDetail2 (id, tblReturnDetail2id, tblFineRule2id, fineAmount, note) VALUES
(1, 3, 1, 6000.00, NULL);
