<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList,model.DocumentTitle2,model.DocumentCopy2,dao.DocumentTitleDAO2,dao.DocumentCopyDAO2" %>
<% String requiredRole = "READER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<%
    request.setAttribute("uiBackPath", "UISearchDocument2.jsp?txtKeyword=" + Web2.query(request.getParameter("txtKeyword")));
    int docTitleId;
    DocumentTitle2 docTitle;
    ArrayList<DocumentCopy2> listCopies;
    try {
        docTitleId = Validation2.positiveId(request.getParameter("docTitleId"), "Mã tài liệu");
        docTitle = new DocumentTitleDAO2().getDocumentTitleById(docTitleId);
        if (docTitle == null) {
            response.sendError(404, "Không tìm thấy tài liệu.");
            return;
        }
        listCopies = new DocumentCopyDAO2().getCopiesByDocId(docTitleId);
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
    <title>Chi tiết tài liệu - UIDocumentDetail2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
    <style>
        .detail-grid {
            display: grid;
            grid-template-columns: 140px 1fr;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            font-size: 1rem;
        }
        .detail-label {
            font-weight: 600;
            color: var(--text-muted);
        }
    </style>
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge">Chi tiết tài liệu</span>
        </div>
        <div class="user-nav">
            <!-- Nút btnBack: link -->
            <a href="UISearchDocument2.jsp?txtKeyword=<%= Web2.html(Web2.query(request.getParameter("txtKeyword"))) %>" class="btn btn-secondary" id="btnBack" style="color:white;">⬅ Quay lại tra cứu</a>
            <a href="UIReaderHome2.jsp" class="btn btn-secondary" style="color:white;">🏠 Trang chủ</a>
        </div>
    </header>

    <div class="container">
        <% if (docTitle == null) { %>
            <div class="card">
                <p style="color: var(--danger);">Không tìm thấy thông tin tài liệu yêu cầu!</p>
            </div>
        <% } else { %>
            <!-- Thông tin tựa tài liệu (docTitle) -->
            <div class="card">
                <h2 style="color: var(--primary-dark); margin-bottom: 1rem;"><%= Web2.html(docTitle.getTitleName()) %></h2>
                <div class="detail-grid">
                    <div class="detail-label">Thể loại:</div>
                    <div><span class="badge" style="background:#e0f2fe; color:#0369a1;"><%= Web2.html(docTitle.getCategory()) %></span></div>

                    <div class="detail-label">Tác giả:</div>
                    <div><strong><%= Web2.html(docTitle.getAuthor()) %></strong></div>

                    <div class="detail-label">Nhà xuất bản:</div>
                    <div><%= Web2.html(docTitle.getPublisher()) %> (Năm: <%= Web2.html(docTitle.getPublishYear()) %>)</div>

                    <div class="detail-label">Mô tả tóm tắt:</div>
                    <div><%= Web2.html(docTitle.getDescription()) %></div>
                </div>
            </div>

            <!-- Bảng danh sách các bản sao (tblCopies) -->
            <div class="card">
                <h3>Danh sách các cuốn sách vật lý hiện có (<%= Web2.html(listCopies.size()) %> cuốn)</h3>
                <div class="table-responsive">
                    <table class="table-custom" id="tblCopies">
                        <thead>
                            <tr>
                                <th style="width: 60px;">STT</th>
                                <th>Mã cá biệt (Barcode)</th>
                                <th>Tình trạng vật lý</th>
                                <th>Trạng thái lưu thông</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (listCopies.isEmpty()) { %>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">
                                        Hiện chưa có bản sao nào trong kho cho đầu sách này.
                                    </td>
                                </tr>
                            <% } else { 
                                int stt = 1;
                                for (DocumentCopy2 cp : listCopies) { 
                            %>
                                <tr>
                                    <td><%= Web2.html(stt++) %></td>
                                    <td class="keep-together"><strong style="color: var(--primary);"><%= Web2.html(cp.getBarcode()) %></strong></td>
                                    <td><%= Web2.html(cp.getPhysicalCondition()) %></td>
                                    <td>
                                        <% if ("AVAILABLE".equalsIgnoreCase(cp.getStatus())) { %>
                                            <span class="badge badge-available">🟢 SẴN SÀNG CHO MƯỢN</span>
                                        <% } else if ("BORROWED".equalsIgnoreCase(cp.getStatus())) { %>
                                            <span class="badge badge-borrowed">🟡 ĐANG ĐƯỢC MƯỢN</span>
                                        <% } else { %>
                                            <span class="badge">Chưa xác định</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <%  } 
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>
    </div>

    <footer>
        Hệ thống Quản lý Thư viện LibMan2 | Môn học Phân tích và Thiết kế Hệ thống - GV: Đỗ Thị Bích Ngọc
    </footer>
</body>
</html>
