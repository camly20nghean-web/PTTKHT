# LibMan2

Hệ thống quản lý thư viện, Đề số 05, học phần Phân tích và Thiết kế Hệ thống, PTIT.
Giảng viên hướng dẫn: Đỗ Thị Bích Ngọc.

## Môi trường chạy

- Apache NetBeans có hỗ trợ dự án Maven và một máy chủ Apache Tomcat đã đăng ký trong IDE. Dự án đã được kiểm tra với Tomcat 10.1.60.
- JDK dùng để biên dịch cần hỗ trợ đích Java 17 như khai báo trong `pom.xml`. Chọn JVM từ Java 17 trở lên, tương thích với Tomcat, để chạy ứng dụng.
- MariaDB 10.4.32 là phiên bản đã ghi nhận. Cấu hình mặc định trong `src/dao/DAO2.java` kết nối tới `localhost:3306/libman2` qua MySQL Connector/J 8.2.0.

## Khởi tạo và chạy

1. Tải hoặc clone kho này. Trong NetBeans, chọn **File → Open Project** và mở thư mục chứa `pom.xml`.
2. Khởi động MariaDB. Trên máy mới, chạy [sql/libman2.sql](sql/libman2.sql) để tạo cơ sở dữ liệu `libman2` gồm 17 bảng và nạp dữ liệu mẫu. Nếu đã có cơ sở dữ liệu cùng tên, kiểm tra cấu trúc và dữ liệu hiện có trước khi nhập. Script khởi tạo dành cho cơ sở dữ liệu mới.
3. Đối chiếu địa chỉ, cổng, tên cơ sở dữ liệu và thông tin kết nối trong `src/dao/DAO2.java` với cấu hình MariaDB trên máy chạy. Nếu cần điều chỉnh, thực hiện trên bản cục bộ và giữ thông tin đăng nhập riêng ngoài GitHub.
4. Chọn Apache Tomcat cho dự án trong NetBeans, sau đó chọn **Run**. NetBeans dùng Maven để build gói WAR, triển khai ứng dụng và mở trang đăng nhập. Dùng địa chỉ và context mà NetBeans hiển thị.

## Tài khoản demo

| Vai trò | Tên đăng nhập | Mật khẩu mẫu | Chức năng |
| --- | --- | --- | --- |
| Bạn đọc | `reader1` | `123456` | Tìm thông tin tài liệu theo tên, tác giả hoặc thể loại và xem các bản sao. |
| Quản lý | `manager` | `123456` | Thống kê độc giả theo số lần mượn trong khoảng ngày, xem lịch sử và chi tiết phiếu mượn. |

Các tài khoản trên được nạp từ SQL mẫu và dùng để chạy demo.
