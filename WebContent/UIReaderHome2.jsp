<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% String requiredRole = "READER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<% Reader2 reader = (Reader2) authorizedUser; %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chủ Bạn đọc - LibMan2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge">Bạn đọc</span>
        </div>
        <div class="user-nav">
            <span class="user-info">Xin chào: <strong><%= Web2.html(reader.getFullName()) %></strong> (<%= Web2.html(reader.getReaderType()) %>)</span>
            <a href="logout2.jsp" class="btn-logout" id="btnLogout">Đăng xuất</a>
        </div>
    </header>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Cổng Thông Tin Dành Cho Bạn Đọc</h1>
        </div>

        <div class="card">
            <h3>Chọn chức năng thao tác</h3>
            <div class="grid-menu">
                <!-- Nút btnSearchDoc: link -->
                <a href="UISearchDocument2.jsp" class="menu-card" id="btnSearchDoc">
                    <div class="menu-icon">🔍</div>
                    <div class="menu-title">Tìm kiếm tài liệu</div>
                    <div class="menu-desc">Tra cứu đầu sách, giáo trình, tác giả và kiểm tra tình trạng các cuốn sách còn trên giá.</div>
                </a>

                <!-- Nút btnBorrowHistory: link -->
                <div class="menu-card menu-card-disabled" aria-disabled="true">
                    <div class="menu-icon">📖</div>
                    <div class="menu-title">Lịch sử mượn sách</div>
                    <div class="menu-desc">Xem các phiếu mượn cá nhân, hạn trả sách và các khoản phí phạt nếu có.</div>
                
                    <span class="availability-note">Chưa triển khai</span>
                </div>

                <div class="menu-card menu-card-disabled" aria-disabled="true">
                    <div class="menu-icon">🪪</div>
                    <div class="menu-title">Thông tin thẻ thư viện</div>
                    <div class="menu-desc">Kiểm tra trạng thái thẻ thư viện và gia hạn thẻ trực tuyến.</div>
                
                    <span class="availability-note">Chưa triển khai</span>
                </div>
            </div>
        </div>
    </div>

    <footer>
        Hệ thống Quản lý Thư viện LibMan2 | Môn học Phân tích và Thiết kế Hệ thống - GV: Đỗ Thị Bích Ngọc
    </footer>
</body>
</html>
