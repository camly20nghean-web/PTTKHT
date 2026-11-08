<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Date,java.util.ArrayList,model.BorrowSlip2,model.BorrowDetail2,dao.BorrowSlipDAO2" %>
<% String requiredRole = "MANAGER"; %>
<%@ include file="/WEB-INF/auth2.jspf" %>
<%
    request.setAttribute("uiBackPath", "UISelectStat2.jsp?" + Web2.dateQuery(
            request.getParameter("txtStartDate"), request.getParameter("txtEndDate")));
    int borrowSlipId;
    int readerId;
    Date startDate;
    Date endDate;
    String strStart;
    String strEnd;
    ArrayList<BorrowDetail2> listDetail;
    BorrowSlip2 slip;
    try {
        borrowSlipId = Validation2.positiveId(request.getParameter("borrowSlipId"), "Mã phiếu mượn");
        readerId = Validation2.positiveId(request.getParameter("readerId"), "Mã độc giả");
        startDate = Validation2.date(request.getParameter("txtStartDate"), "Ngày bắt đầu");
        endDate = Validation2.date(request.getParameter("txtEndDate"), "Ngày kết thúc");
        Validation2.requireRange(startDate, endDate);
        strStart = startDate.toString();
        strEnd = endDate.toString();
        BorrowSlipDAO2 slipDAO = new BorrowSlipDAO2();
        slip = slipDAO.getBorrowSlipById(borrowSlipId);
        if (slip == null) {
            response.sendError(404, "Không tìm thấy phiếu mượn.");
            return;
        }
        if (slip.getReader().getId() != readerId
                || slip.getBorrowDate().before(startDate) || slip.getBorrowDate().after(endDate)) {
            throw new IllegalArgumentException("Phiếu mượn không thuộc độc giả hoặc khoảng ngày đã chọn.");
        }
        listDetail = slipDAO.getBorrowSlipDetail(borrowSlipId);
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
    <title>Chi tiết phiếu mượn - UIBorrowSlipDetail2</title>
    <link rel="stylesheet" href="css/style.css?v=20261106-3">
</head>
<body>
    <header>
        <div class="brand-title">
            <span>📚 Thư viện LibMan2</span>
            <span class="brand-badge" style="background:#10b981; color:white;">Chi tiết phiếu mượn</span>
        </div>
        <div class="user-nav">
            <!-- Nút btnBack: link -->
            <a href="UIReaderBorrowHistory2.jsp?readerId=<%= Web2.html(Web2.query(readerId)) %>&amp;txtStartDate=<%= Web2.html(Web2.query((strStart != null ? strStart : ""))) %>&amp;txtEndDate=<%= Web2.html(Web2.query((strEnd != null ? strEnd : ""))) %>" 
               class="btn btn-secondary" id="btnBack" style="color:white;">⬅ Quay lại danh sách phiếu</a>
            <a href="UIManagerHome2.jsp" class="btn btn-secondary" style="color:white;">🏠 Trang chủ</a>
        </div>
    </header>

    <div class="container">
        <div class="card">
            <h2 style="color: var(--primary-dark); margin-bottom: 0.5rem;">
                Phiếu mượn PM-<%= Web2.html(String.format("%04d", slip.getId())) %>
            </h2>
            <div class="reader-profile">
                <div>Độc giả: <strong><%= Web2.html(slip.getReader().getFullName()) %></strong> <strong>DG-<%= Web2.html(String.format("%03d", slip.getReader().getId())) %></strong></div>
                <div>Ngày mượn: <strong><%= Web2.html(Web2.displayDate(slip.getBorrowDate())) %></strong></div>
                <div>Hạn trả: <strong><%= Web2.html(Web2.displayDate(slip.getExpectedReturnDate())) %></strong></div>
                <div>Trạng thái phiếu:
                    <% if ("RETURNED".equalsIgnoreCase(slip.getStatus())) { %>
                        <span class="badge badge-returned">Đã trả đủ</span>
                    <% } else if ("BORROWED".equalsIgnoreCase(slip.getStatus())) { %>
                        <span class="badge badge-borrowed">Đang mượn</span>
                    <% } else { %>
                        <span class="badge">Chưa xác định</span>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Bảng chi tiết các cuốn sách trong phiếu (tblBorrowDetails) -->
        <div class="card">
            <h3>Tài liệu trong phiếu - <%= Web2.html(listDetail.size()) %> cuốn</h3>

            <div class="table-responsive">
                <table class="table-custom" id="tblBorrowDetails">
                    <thead>
                        <tr>
                            <th style="width: 60px;">STT</th>
                            <th>Mã cuốn (Barcode)</th>
                            <th>Tên tài liệu</th>
                            <th>Thể loại</th>
                            <th>Tác giả</th>
                            <th>Nhà xuất bản</th>
                            <th>Tình trạng lúc mượn</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listDetail.isEmpty()) { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">
                                    Không có dữ liệu cuốn sách nào trong phiếu mượn này!
                                </td>
                            </tr>
                        <% } else { 
                            int stt = 1;
                            for (BorrowDetail2 dt : listDetail) { 
                        %>
                            <tr>
                                <td><%= Web2.html(stt++) %></td>
                                <td class="keep-together"><strong style="color: var(--primary);"><%= Web2.html(dt.getDcmCopy().getBarcode()) %></strong></td>
                                <td><strong><%= Web2.html(dt.getDcmCopy().getDcmTitle().getTitleName()) %></strong></td>
                                <td><span class="badge" style="background:#e0f2fe; color:#0369a1;"><%= Web2.html(dt.getDcmCopy().getDcmTitle().getCategory()) %></span></td>
                                <td><%= Web2.html(dt.getDcmCopy().getDcmTitle().getAuthor()) %></td>
                                <td><%= Web2.html(dt.getDcmCopy().getDcmTitle().getPublisher()) %></td>
                                <td><span class="badge" style="background:#f1f5f9; color:#334155;"><%= Web2.html(dt.getConditionAtBorrow()) %></span></td>
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
