<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Date,java.util.ArrayList,model.StatReader2,dao.StatReaderDAO2" %>
<% String requiredRole = "MANAGER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<%
    request.setAttribute("uiBackPath", "UISelectStat2.jsp?" + Web2.dateQuery(
            request.getParameter("txtStartDate"), request.getParameter("txtEndDate")));
    Date startDate;
    Date endDate;
    ArrayList<StatReader2> listStatReader;
    try {
        String type = request.getParameter("selectStatType");
        if (type != null && !"READER_BORROW_STAT".equals(type)) {
            throw new IllegalArgumentException("Loại báo cáo chưa được hỗ trợ.");
        }
        startDate = Validation2.date(request.getParameter("txtStartDate"), "Ngày bắt đầu");
        endDate = Validation2.date(request.getParameter("txtEndDate"), "Ngày kết thúc");
        Validation2.requireRange(startDate, endDate);
        listStatReader = new StatReaderDAO2().getStatReaderByBorrowCount(startDate, endDate);
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
    <title>Thống kê độc giả theo số lượt mượn - UIStatReader2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge" style="background:#10b981; color:white;">Báo cáo thống kê</span>
        </div>
        <div class="user-nav">
            <!-- Nút btnBack: link -->
            <a href="UISelectStat2.jsp?<%= Web2.html(Web2.dateQuery(startDate.toString(), endDate.toString())) %>" class="btn btn-secondary" id="btnBack" style="color:white;">⬅ Chọn lại thời gian</a>
            <a href="UIManagerHome2.jsp" class="btn btn-secondary" style="color:white;">🏠 Trang chủ</a>
            <a href="logout2.jsp" class="btn-logout">Đăng xuất</a>
        </div>
    </header>

    <div class="container">
        <div class="page-header">
            <div>
                <h1 class="page-title">Báo Cáo Thống Kê Độc Giả Theo Số Lượt Mượn</h1>
                <p style="color: var(--text-muted); margin-top: 0.25rem;">
                    Khoảng ngày mượn: từ <strong><%= Web2.html(Web2.displayDate(startDate)) %></strong> 
                    đến <strong><%= Web2.html(Web2.displayDate(endDate)) %></strong>
                </p>
            </div>
</div>

        <!-- Bảng danh sách thống kê độc giả (tblStatReader) -->
        <div class="card">
            <p class="help-text">Số lượt mượn tính theo số phiếu có ngày mượn trong khoảng đã chọn, bao gồm cả hai ngày đầu và cuối.</p>
            <h3>Danh sách độc giả theo số lượt mượn (<%= Web2.html(listStatReader.size()) %> độc giả)</h3>

            <div class="table-responsive">
                <table class="table-custom" id="tblStatReader">
                    <thead>
                        <tr>
                            <th style="width: 70px; text-align: center;">STT</th>
                            <th>Mã độc giả</th>
                            <th>Họ và tên</th>
                            <th>Loại bạn đọc</th>
                            <th>Số điện thoại</th>
                            <th style="text-align: center;">Số lượt mượn (phiếu)</th>
                            <th style="text-align: center;">Tổng số cuốn mượn</th>
                            <th style="text-align: center; width: 140px;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listStatReader.isEmpty()) { %>
                            <tr>
                                <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 2rem;">
                                    Không có dữ liệu mượn sách nào trong khoảng thời gian đã chọn!
                                </td>
                            </tr>
                        <% } else { 
                            int stt = 1;
                            for (StatReader2 r : listStatReader) { 
                        %>
                            <tr>
                                <td style="text-align: center;"><%= Web2.html(stt) %></td>
                                <td class="keep-together">DG-<%= Web2.html(String.format("%03d", r.getId())) %></td>
                                <td><strong><%= Web2.html(r.getFullName()) %></strong></td>
                                <td><span class="badge" style="background:#e0f2fe; color:#0369a1;"><%= Web2.html(r.getReaderType()) %></span></td>
                                <td><%= Web2.html(r.getPhone()) %></td>
                                <td style="text-align: center; font-weight: bold; color: var(--primary); font-size: 1.05rem;">
                                    <%= Web2.html(r.getBorrowCount()) %> lượt
                                </td>
                                <td style="text-align: center;"><%= Web2.html(r.getBorrowedQuantity()) %> cuốn</td>
                                <td style="text-align: center;">
                                    <!-- Link viewDetailReader: link -->
                                    <a href="UIReaderBorrowHistory2.jsp?readerId=<%= Web2.html(Web2.query(r.getId())) %>&amp;txtStartDate=<%= Web2.html(Web2.query((startDate != null ? startDate.toString() : ""))) %>&amp;txtEndDate=<%= Web2.html(Web2.query((endDate != null ? endDate.toString() : ""))) %>" 
                                       class="btn btn-primary" style="padding: 0.35rem 0.75rem; font-size: 0.85rem;" id="viewDetailReader">
                                        Xem lịch sử
                                    </a>
                                </td>
                            </tr>
                        <%      stt++;
                            } 
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
