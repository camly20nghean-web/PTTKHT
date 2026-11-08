<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate,java.time.ZoneId" %>
<% String requiredRole = "MANAGER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>

<%
    LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
    String selectedStart = Web2.formDate(request.getParameter("txtStartDate"), today.withDayOfMonth(1).toString());
    String selectedEnd = Web2.formDate(request.getParameter("txtEndDate"), today.toString());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chọn loại báo cáo thống kê - UISelectStat2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge" style="background:#10b981; color:white;">Module 2: Thống kê</span>
        </div>
        <div class="user-nav">
            <!-- Nút btnBack: link -->
            <a href="UIManagerHome2.jsp" class="btn btn-secondary" id="btnBack" style="color:white;">🏠 Về trang chủ</a>
            <a href="logout2.jsp" class="btn-logout">Đăng xuất</a>
        </div>
    </header>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Thiết Lập Tiêu Chí Báo Cáo Thống Kê</h1>
        </div>

        <div class="card" style="max-width: 650px; margin: 0 auto;">
            <form method="GET" action="UIStatReader2.jsp">
                <p class="help-text">Chọn khoảng ngày mượn. Thống kê bao gồm cả ngày bắt đầu và ngày kết thúc.</p>
                <!-- Dropdown selectStatType: Select -->
                <div class="form-group">
                    <label class="form-label" for="selectStatType">Chọn loại báo cáo thống kê:</label>
                    <select id="selectStatType" name="selectStatType" class="form-control">
                        <option value="READER_BORROW_STAT" selected>📊 Thống kê độc giả theo số lượt mượn</option>
                        <option value="DOC_BORROW_STAT" disabled>📚 Thống kê tài liệu theo số lượt mượn (đang phát triển)</option>
                        <option value="SUPPLIER_IMPORT_STAT" disabled>🏢 Thống kê nhà cung cấp theo số lượng nhập (đang phát triển)</option>
                    </select>
                </div>

                <div class="date-range">
                    <!-- Ô txtStartDate: Date -->
                    <div class="form-group">
                        <label class="form-label" for="txtStartDate">Ngày mượn từ</label>
                        <input type="date" id="txtStartDate" name="txtStartDate" class="form-control" value="<%= Web2.html(selectedStart) %>" required>
                    </div>

                    <!-- Ô txtEndDate: Date -->
                    <div class="form-group">
                        <label class="form-label" for="txtEndDate">Ngày mượn đến</label>
                        <input type="date" id="txtEndDate" name="txtEndDate" class="form-control" value="<%= Web2.html(selectedEnd) %>" required>
                    </div>
                </div>

                <div class="form-actions">
                    <!-- Nút btnView: submit -->
                    <button type="submit" id="btnView" class="btn btn-primary" style="flex: 2;">
                        📈 Xem Thống Kê
                    </button>
                    <!-- Nút quay lại -->
                    <a href="UIManagerHome2.jsp" class="btn btn-secondary" style="flex: 1;">
                        Hủy bỏ
                    </a>
                </div>
            </form>
        </div>
    </div>

    <footer>
        Hệ thống Quản lý Thư viện LibMan2 | Môn học Phân tích và Thiết kế Hệ thống - GV: Đỗ Thị Bích Ngọc
    </footer>
</body>
</html>
