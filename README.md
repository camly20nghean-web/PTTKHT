# HƯỚNG DẪN CÀI ĐẶT VÀ VẬN HÀNH HỆ THỐNG LIBMAN2 TRÊN NETBEANS
**Hệ thống Quản lý Thư viện - Môn học Phân tích và Thiết kế Hệ thống (PTIT)**
**Giảng viên phụ trách: TS. Đỗ Thị Ngọc**
**Môi trường: Apache NetBeans IDE & Apache Tomcat**

---

## 1. VỊ TRÍ DỰ ÁN TRÊN MÁY TÍNH

Dự án hiện đã được sao chép và đồng bộ sẵn tại **2 thư mục**:
1. Thư mục đồ án môn học: `D:\kỳ 1 năm 4\PTKTHT\LibMan2`
2. Thư mục Workspace NetBeans mặc định của bạn: `D:\NetBeansProjects\LibMan2`

---

## 2. HƯỚNG DẪN MỞ VÀ CHẠY DỰ ÁN TRÊN NETBEANS

### Cách 1: Mở trực tiếp (Nhanh nhất - Khuyên dùng)
Dự án đã được tích hợp file cấu hình chuẩn `pom.xml`, NetBeans sẽ tự động nhận diện dự án Web ngay lập tức:
1. Mở **Apache NetBeans**.
2. Trên thanh menu, chọn **File** ➔ **Open Project...** (hoặc nhấn tổ hợp phím `Ctrl + Shift + O`).
3. NetBeans sẽ trỏ ngay vào thư mục `D:\NetBeansProjects`:
   - Bạn sẽ thấy thư mục `LibMan2` hiển thị với biểu tượng **Quả địa cầu / Web** (cùng cấp với thư mục `LAP TRINH MANG` hiện có của bạn).
   - Chọn `LibMan2` ➔ nhấn nút **Open Project**.
4. Chạy dự án:
   - Click chuột phải vào dự án `LibMan2` trong tab Projects ➔ chọn **Run** (hoặc nhấn phím **F6**).
   - NetBeans sẽ tự động biên dịch, triển khai lên Apache Tomcat và mở trình duyệt web.

---

### Cách 2: Mở theo dạng "Web Application with Existing Sources" (Chuẩn Ant truyền thống của giáo trình PTIT)
Nếu bạn hoặc thầy cô yêu cầu mở theo chuẩn Ant Web Project truyền thống:
1. Trong NetBeans, chọn **File** ➔ **New Project...** (hoặc `Ctrl + Shift + N`).
2. Trong bảng chọn:
   - Mục **Categories**: chọn **Java with Ant** ➔ **Java Web**.
   - Mục **Projects**: chọn **Web Application with Existing Sources** ➔ Bấm **Next**.
3. Tại bước **Name and Location**:
   - **Location**: Bấm **Browse...** và chọn thư mục: `D:\NetBeansProjects\LibMan2` (hoặc `D:\kỳ 1 năm 4\PTKTHT\LibMan2`).
   - **Project Name**: Giữ nguyên là `LibMan2` ➔ Bấm **Next**.
4. Tại bước **Server and Settings**:
   - **Server**: Chọn **Apache Tomcat or TomEE** (phiên bản `10.1.60` đã có sẵn trên máy bạn).
   - **Java EE Version**: Chọn bản Java EE / Jakarta EE mặc định.
   - **Context Path**: Để `/LibMan2` ➔ Bấm **Next**.
5. Tại bước **Existing Sources**:
   - **Web Pages Folder**: Nhấn Browse chọn thư mục `WebContent`.
   - **Source Package Folders**: Nhấn Add Folder chọn thư mục `src`.
   - **Libraries Folder**: Nhấn Browse chọn thư mục `WebContent/WEB-INF/lib` (chứa `mysql-connector-j-8.2.0.jar`).
   - Bấm **Finish**.
6. Kiểm tra thư viện MySQL:
   - Click chuột phải vào `LibMan2` ➔ chọn **Properties** ➔ mục **Libraries**.
   - Đảm bảo trong phần **Compile** đã có file `mysql-connector-j-8.2.0.jar`. Nếu chưa có, bấm **Add JAR/Folder...** và trỏ tới file JAR này trong `WebContent/WEB-INF/lib`.
7. Chạy dự án:
   - Click chuột phải vào `LibMan2` ➔ chọn **Run** (phím **F6**).

---

## 3. THÔNG TIN CƠ SỞ DỮ LIỆU & TÀI KHOẢN ĐĂNG NHẬP

- **Hệ quản trị CSDL**: MySQL / MariaDB (chạy trên cổng `3306`).
- **Database**: `libman2` (đã khởi tạo 16 bảng và nạp đầy đủ dữ liệu mẫu).
- **User / Password CSDL**: `root` / *(mật khẩu rỗng)*.

### Tài khoản đăng nhập hệ thống:
| Phân hệ / Vai trò | Username | Password | Tên người dùng |
| :--- | :--- | :--- | :--- |
| **Bạn đọc (Module 1)** | `reader1` | `password123` | Lê Bạn Đọc (Mã thẻ: CARD-001) |
| **Quản lý (Module 2)**| `manager` | `password123` | Nguyễn Văn An |
| **Thủ thư** | `librarian1` | `password123` | Trần Thị Bình |

*Ghi chú: Tại trang đăng nhập `index.jsp` có sẵn 2 nút truy cập nhanh:*
- **👉 Vào Giao diện Bạn đọc (Module 1)**: Tìm kiếm tài liệu, xem chi tiết và trạng thái các cuốn sách.
- **👉 Vào Giao diện Quản lý (Module 2)**: Xem thống kê độc giả mượn nhiều nhất, xem lịch sử và chi tiết từng phiếu mượn.
