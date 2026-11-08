<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% String requiredRole = "MANAGER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<% Manager2 manager = (Manager2) authorizedUser; %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang chủ Quản lý - UIManagerHome2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge" style="background:#10b981; color:white;">Nhân viên Quản lý</span>
        </div>
        <div class="user-nav">
            <span class="user-info">Xin chào: <strong><%= Web2.html(manager.getFullName()) %></strong> (<%= Web2.html(manager.getPosition()) %>)</span>
            <!-- Nút btnLogout: link -->
            <a href="logout2.jsp" class="btn-logout" id="btnLogout">Đăng xuất</a>
        </div>
    </header>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Bảng Điều Khiển Hệ Thống Dành Cho Quản Lý</h1>
        </div>

        <div class="card">
            <h3>Chọn chức năng quản trị</h3>
            <div class="grid-menu">
                <!-- Nút btnViewStat: link -->
                <a href="UISelectStat2.jsp" class="menu-card" id="btnViewStat">
                    <div class="menu-icon">📊</div>
                    <div class="menu-title">Báo cáo & Thống kê</div>
                    <div class="menu-desc">Xem thống kê độc giả theo lượt mượn, lịch sử mượn và chi tiết từng phiếu trong khoảng ngày đã chọn.</div>
                </a>

                <!-- Nút btnManager: link -->
                <div class="menu-card menu-card-disabled" aria-disabled="true">
                    <div class="menu-icon">👥</div>
                    <div class="menu-title">Quản lý nhân viên & độc giả</div>
                    <div class="menu-desc">Phân quyền, cấp phát tài khoản thủ thư và duyệt hồ sơ làm thẻ bạn đọc.</div>
                
                    <span class="availability-note">Chưa triển khai</span>
                </div>

                <div class="menu-card menu-card-disabled" aria-disabled="true">
                    <div class="menu-icon">⚖️</div>
                    <div class="menu-title">Quy định mức phạt</div>
                    <div class="menu-desc">Cấu hình mức phạt vi phạm trễ hạn, làm hỏng hoặc mất sách.</div>
                
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
