<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ page import="util.Web2,model.User2,model.Reader2,model.Manager2" %>
<%
    Object code = request.getAttribute("jakarta.servlet.error.status_code");
    int status = code instanceof Integer ? ((Integer) code).intValue() : 500;
    String message = "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.";
    if (status == 400) {
        Object validation = request.getAttribute("uiError");
        message = validation instanceof String ? (String) validation
                : "Thông tin yêu cầu không hợp lệ. Vui lòng kiểm tra lại.";
    } else if (status == 403) message = "Tài khoản không có quyền truy cập chức năng này.";
    else if (status == 404) message = "Không tìm thấy đối tượng được yêu cầu. Vui lòng chọn lại từ danh sách.";
    String home = "index.jsp";
    jakarta.servlet.http.HttpSession currentSession = request.getSession(false);
    Object user = currentSession == null ? null : currentSession.getAttribute("currentUser");
    if (user instanceof Reader2) home = "UIReaderHome2.jsp";
    else if (user instanceof Manager2) home = "UIManagerHome2.jsp";
    Object back = request.getAttribute("uiBackPath");
    String backPath = back instanceof String ? (String) back : home;
    response.setHeader("Cache-Control", "no-store");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Không thể thực hiện yêu cầu - LibMan2</title>
    <link rel="stylesheet" href="<%= Web2.html(request.getContextPath() + "/css/style.css?v=20261106-3") %>">
</head>
<body>
    <header><div class="brand-title">Thư viện LibMan2</div></header>
    <main class="container">
        <section class="card error-card" role="alert">
            <p class="help-text">Yêu cầu chưa được thực hiện · <%= Web2.html(status) %></p>
            <h1 class="page-title">Không thể thực hiện yêu cầu</h1>
            <p class="error-message"><%= Web2.html(message) %></p>
            <div class="form-actions">
                <a class="btn btn-primary" href="<%= Web2.html(request.getContextPath() + "/" + backPath) %>">Quay lại và kiểm tra</a>
                <a class="btn btn-secondary" href="<%= Web2.html(request.getContextPath() + "/" + home) %>">Về trang chủ</a>
            </div>
        </section>
    </main>
    <footer>Hệ thống Quản lý Thư viện LibMan2 | Môn học Phân tích và Thiết kế Hệ thống - GV: Đỗ Thị Bích Ngọc</footer>
</body>
</html>
