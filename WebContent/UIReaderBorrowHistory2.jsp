<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Date,java.util.ArrayList,model.BorrowSlip2,dao.UserDAO2,dao.BorrowSlipDAO2" %>
<% String requiredRole = "MANAGER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<%
    request.setAttribute("uiBackPath", "UISelectStat2.jsp?" + Web2.dateQuery(
            request.getParameter("txtStartDate"), request.getParameter("txtEndDate")));
    int readerId;
    Date startDate;
    Date endDate;
    String strStart;
    String strEnd;
    Reader2 selectedReader;
    ArrayList<BorrowSlip2> listBorrowSlips;
    try {
        readerId = Validation2.positiveId(request.getParameter("readerId"), "Mã độc giả");
        startDate = Validation2.date(request.getParameter("txtStartDate"), "Ngày bắt đầu");
        endDate = Validation2.date(request.getParameter("txtEndDate"), "Ngày kết thúc");
        Validation2.requireRange(startDate, endDate);
        strStart = startDate.toString();
        strEnd = endDate.toString();
        selectedReader = new UserDAO2().getReaderById(readerId);
        if (selectedReader == null) {
            response.sendError(404, "Không tìm thấy bạn đọc.");
            return;
        }
        listBorrowSlips = new BorrowSlipDAO2().getBorrowSlipsByReader(readerId, startDate, endDate);
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
    <title>Lịch sử mượn sách - UIReaderBorrowHistory2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge" style="background:#10b981; color:white;">Lịch sử mượn</span>
        </div>
        <div class="user-nav">
            <!-- Nút btnBack: link -->
            <a href="UIStatReader2.jsp?txtStartDate=<%= Web2.html(Web2.query((strStart != null ? strStart : ""))) %>&amp;txtEndDate=<%= Web2.html(Web2.query((strEnd != null ? strEnd : ""))) %>" 
               class="btn btn-secondary" id="btnBack" style="color:white;">⬅ Quay lại bảng thống kê</a>
            <a href="UIManagerHome2.jsp" class="btn btn-secondary" style="color:white;">🏠 Trang chủ</a>
        </div>
    </header>

    <div class="container">
        <!-- Thông tin độc giả được chọn (selectedReader) -->
        <div class="card">
            <h2 style="color: var(--primary-dark); margin-bottom: 0.75rem;">
                Hồ Sơ Độc Giả: <%= Web2.html((selectedReader != null ? selectedReader.getFullName() : "Mã độc giả " + readerId)) %>
            </h2>
            <% if (selectedReader != null) { %>
                <p class="help-text">Khoảng ngày mượn: <strong><%= Web2.html(Web2.displayDate(startDate)) %> – <%= Web2.html(Web2.displayDate(endDate)) %></strong></p>
                <div class="reader-profile">
                    <div>Mã độc giả: <strong>DG-<%= Web2.html(String.format("%03d", selectedReader.getId())) %></strong></div>
                    <div>Loại độc giả: <strong style="color:var(--text-main);"><%= Web2.html(selectedReader.getReaderType()) %></strong></div>
                    <div>Số điện thoại: <strong style="color:var(--text-main);"><%= Web2.html(selectedReader.getPhone()) %></strong></div>
                    <div>Email: <strong style="color:var(--text-main);"><%= Web2.html(selectedReader.getEmail()) %></strong></div>
                    <div>Địa chỉ: <strong style="color:var(--text-main);"><%= Web2.html(selectedReader.getAddress()) %></strong></div>
                </div>
            <% } %>
        </div>

        <!-- Bảng danh sách phiếu mượn (tlbBorrowSlips) -->
        <div class="card">
            <h3>Các phiếu có ngày mượn trong khoảng đã chọn (<%= Web2.html(listBorrowSlips.size()) %> phiếu)</h3>

            <div class="table-responsive">
                <table class="table-custom" id="tlbBorrowSlips">
                    <thead>
                        <tr>
                            <th style="width: 60px;">STT</th>
                            <th>Mã phiếu mượn</th>
                            <th>Ngày mượn</th>
                            <th>Ngày hẹn trả</th>
                            <th>Trạng thái phiếu</th>
                            <th style="text-align: center; width: 150px;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listBorrowSlips.isEmpty()) { %>
                            <tr>
                                <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">
                                    Độc giả chưa có phiếu mượn nào trong khoảng thời gian này!
                                </td>
                            </tr>
                        <% } else { 
                            int stt = 1;
                            for (BorrowSlip2 slip : listBorrowSlips) { 
                        %>
                            <tr>
                                <td><%= Web2.html(stt++) %></td>
                                <td class="keep-together"><strong style="color: var(--primary);">PM-<%= Web2.html(String.format("%04d", slip.getId())) %></strong></td>
                                <td class="keep-together"><%= Web2.html(Web2.displayDate(slip.getBorrowDate())) %></td>
                                <td class="keep-together"><%= Web2.html(Web2.displayDate(slip.getExpectedReturnDate())) %></td>
                                <td>
                                    <% if ("RETURNED".equalsIgnoreCase(slip.getStatus())) { %>
                                        <span class="badge badge-returned">✔ ĐÃ TRẢ ĐỦ</span>
                                    <% } else if ("BORROWED".equalsIgnoreCase(slip.getStatus())) { %>
                                        <span class="badge badge-borrowed">⏳ ĐANG MƯỢN</span>
                                    <% } else { %>
                                        <span class="badge">Chưa xác định</span>
                                    <% } %>
                                </td>
                                <td style="text-align: center;">
                                    <!-- Link viewBorrowDetail: link -->
                                    <a href="UIBorrowSlipDetail2.jsp?borrowSlipId=<%= Web2.html(Web2.query(slip.getId())) %>&amp;readerId=<%= Web2.html(Web2.query(readerId)) %>&amp;txtStartDate=<%= Web2.html(Web2.query((strStart != null ? strStart : ""))) %>&amp;txtEndDate=<%= Web2.html(Web2.query((strEnd != null ? strEnd : ""))) %>" 
                                       class="btn btn-primary" style="padding: 0.35rem 0.75rem; font-size: 0.85rem;" id="viewBorrowDetail">
                                        Chi tiết phiếu
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
