<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UserDAO2,dao.DataAccessException2,model.User2,model.Reader2,model.Manager2,util.Web2" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-store");
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Một lần đăng nhập mới không được tiếp tục dùng danh tính cũ khi thất bại.
        session.removeAttribute("currentUser");
        String u = request.getParameter("username");
        String p = request.getParameter("password");
        if (u == null || u.isBlank() || p == null || p.isEmpty()) {
            response.setStatus(400);
            message = "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.";
        } else {
            try {
                User2 user = new UserDAO2().checkLogin(u, p);
                if (user instanceof Reader2 || user instanceof Manager2) {
                    request.changeSessionId();
                    session.setAttribute("currentUser", user);
                    response.sendRedirect(user instanceof Reader2 ? "UIReaderHome2.jsp" : "UIManagerHome2.jsp");
                    return;
                }
                response.setStatus(401);
                message = Web2.loginFailure(user);
            } catch (DataAccessException2 e) {
                application.log("Lỗi xác thực LibMan2", e);
                response.setStatus(503);
                message = "Hệ thống chưa thể xác thực. Vui lòng thử lại sau.";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập - Hệ thống Quản lý Thư viện LibMan2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
    <style>
        .login-box {
            max-width: 440px;
            margin: 4rem auto;
            background: white;
            border-radius: 12px;
            padding: 2.5rem;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
            border: 1px solid var(--border);
        }
        .demo-access {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px dashed var(--border);
        }
        .demo-btn {
            display: block;
            width: 100%;
            margin-bottom: 0.75rem;
            text-align: center;
        }
    </style>
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge">Học viện PTIT</span>
        </div>
    </header>

    <div class="container">
        <div class="login-box">
            <h2 style="text-align: center; color: var(--primary-dark); margin-bottom: 0.5rem;">Đăng Nhập</h2>
            <p style="text-align: center; color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">Hệ thống Quản lý Thư viện LibMan2 (Đề số 5)</p>

            <% if (!message.isEmpty()) { %>
                <div role="alert" style="background-color: #fee2e2; color: #b91c1c; padding: 0.75rem; border-radius: 6px; margin-bottom: 1.25rem; font-size: 0.9rem;">
                    <%= Web2.html(message) %>
                </div>
            <% } %>

            <form method="POST" action="index.jsp">
                <div class="form-group">
                    <label class="form-label" for="username">Tên đăng nhập</label>
                    <input type="text" id="username" name="username" autocomplete="username" class="form-control" placeholder="Nhập tên đăng nhập" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" autocomplete="current-password" class="form-control" placeholder="Nhập mật khẩu" required>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem;">Đăng Nhập</button>
            </form>

            <p style="margin-top:1rem;">Vui lòng đăng nhập bằng tài khoản được cấp để sử dụng chức năng.</p>
        </div>
    </div>

    <footer>
        Hệ thống Quản lý Thư viện LibMan2 | Môn học Phân tích và Thiết kế Hệ thống - GV: Đỗ Thị Bích Ngọc
    </footer>
</body>
</html>
