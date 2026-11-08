<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList,model.DocumentTitle2,dao.DocumentTitleDAO2" %>
<% String requiredRole = "READER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<%
    request.setAttribute("uiBackPath", "UISearchDocument2.jsp?txtKeyword=" + Web2.query(request.getParameter("txtKeyword")));
    String keyword = request.getParameter("txtKeyword");
    ArrayList<DocumentTitle2> listDocs;
    try {
        listDocs = new DocumentTitleDAO2().searchDocument(keyword);
    } catch (IllegalArgumentException e) {
        request.setAttribute("uiError", e.getMessage());
        response.sendError(400, "Thông tin yêu cầu không hợp lệ.");
        return;
    } catch (DataAccessException2 e) {
        application.log("Lỗi truy cập dữ liệu LibMan2", e);
        response.sendError(503, "Không thể đọc dữ liệu. Vui lòng thử lại sau.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tìm kiếm tài liệu - UISearchDocument2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge">Module 1: Tìm kiếm tài liệu</span>
        </div>
        <div class="user-nav">
            <!-- Nút btnHome: link -->
            <a href="UIReaderHome2.jsp" class="btn btn-secondary" id="btnHome" style="color:white;">🏠 Về trang chủ</a>
            <a href="logout2.jsp" class="btn-logout">Đăng xuất</a>
        </div>
    </header>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Tra Cứu & Tìm Kiếm Tài Liệu</h1>
        </div>

        <!-- Khung tìm kiếm -->
        <div class="card">
            <form method="GET" action="UISearchDocument2.jsp">
                <div class="search-controls">
                    <div style="flex: 1;">
                        <label class="form-label" for="txtKeyword">Nhập từ khóa tìm kiếm (Tên sách, tác giả, thể loại...):</label>
                        <!-- Ô txtKeyword: text -->
                        <input type="text" id="txtKeyword" name="txtKeyword" class="form-control" 
                               value="<%= Web2.html((keyword != null) ? keyword : "") %>" 
                               placeholder="Ví dụ: Thiết kế, Java, Cơ sở dữ liệu...">
                    </div>
                    <!-- Nút btnSearch: submit -->
                    <button type="submit" id="btnSearch" class="btn btn-primary">
                        🔍 Tìm Kiếm
                    </button>
                </div>
            </form>
        </div>

        <!-- Bảng danh sách kết quả (tblResult) -->
        <div class="card">
            <h3>Danh sách đầu tài liệu tìm được (<%= Web2.html(listDocs.size()) %> kết quả)</h3>
            
            <div class="table-responsive">
                <table class="table-custom" id="tblResult">
                    <thead>
                        <tr>
                            <th style="width: 60px;">STT</th>
                            <th>Tên tài liệu</th>
                            <th>Thể loại</th>
                            <th>Tác giả</th>
                            <th>Nhà xuất bản</th>
                            <th style="width: 100px;">Năm XB</th>
                            <th style="width: 140px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listDocs.isEmpty()) { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 2rem;">
                                    Không tìm thấy tài liệu nào khớp với từ khóa "<%= Web2.html(keyword) %>"!
                                </td>
                            </tr>
                        <% } else { 
                            int stt = 1;
                            for (DocumentTitle2 doc : listDocs) { 
                        %>
                            <tr>
                                <td><%= Web2.html(stt++) %></td>
                                <td><strong><%= Web2.html(doc.getTitleName()) %></strong></td>
                                <td><span class="badge" style="background:#e0f2fe; color:#0369a1;"><%= Web2.html(doc.getCategory()) %></span></td>
                                <td><%= Web2.html(doc.getAuthor()) %></td>
                                <td><%= Web2.html(doc.getPublisher()) %></td>
                                <td><%= Web2.html(doc.getPublishYear()) %></td>
                                <td style="text-align: center;">
                                    <!-- Link viewDetail: link -->
                                    <a href="UIDocumentDetail2.jsp?docTitleId=<%= Web2.html(Web2.query(doc.getId())) %>&amp;txtKeyword=<%= Web2.html(Web2.query(keyword)) %>" class="btn btn-primary" style="padding: 0.35rem 0.75rem; font-size: 0.85rem;" id="viewDetail">
                                        Xem chi tiết
                                    </a>
                                </td>
                            </tr>
                        <%  } 
                           } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <footer>
        Hệ thống Quản lý Thư viện LibMan2 | Môn học Phân tích và Thiết kế Hệ thống - GV: Đỗ Thị Bích Ngọc
    </footer>
</body>
</html>
