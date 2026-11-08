package test;

import dao.*;
import model.*;
import util.Validation2;
import util.Web2;
import java.sql.Connection;
import java.sql.Date;
import java.util.ArrayList;

/** Chạy mặc định không cần DB. --database kiểm tra chỉ đọc trên bộ dữ liệu mẫu. */
public class TestRunner2 {
    private static int checks;

    private static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        checks++;
    }

    private static void invalid(Runnable action) {
        try { action.run(); }
        catch (IllegalArgumentException expected) { checks++; return; }
        throw new AssertionError("Đầu vào sai không bị từ chối");
    }

    public static void main(String[] args) throws Exception {
        boolean database = false;
        for (String arg : args) {
            if (!"--database".equals(arg)) throw new IllegalArgumentException("Chỉ hỗ trợ --database");
            database = true;
        }
        check(Validation2.positiveId("3") == 3, "ID hợp lệ");
        for (String id : new String[] {null, "", "abc", "-1", "0", "2147483648", "1 OR 1=1"}) {
            invalid(() -> Validation2.positiveId(id));
        }
        for (String day : new String[] {null, "", "bad", "2026-02-30", "2026-02-29", "2026-13-01", "2026-9-01", "0000-01-01"}) {
            invalid(() -> Validation2.date(day));
        }
        Date start = Validation2.date("2026-09-01"), end = Validation2.date("2026-10-31");
        check(Validation2.date("2024-02-29").toString().equals("2024-02-29"), "Ngày nhuận");
        Validation2.requireRange(start, start);
        invalid(() -> Validation2.requireRange(null, end));
        invalid(() -> Validation2.requireRange(start, null));
        invalid(() -> Validation2.requireRange(end, start));
        invalid(() -> new StatReaderDAO2().getStatReaderByBorrowCount(null, end));
        invalid(() -> new BorrowSlipDAO2().getBorrowSlipsByReader(3, start, null));
        invalid(() -> new DocumentTitleDAO2().getDocumentTitleById(0));
        String payload = "\"><script>marker</script>&'";
        String escaped = Web2.html(payload);
        check(!escaped.contains("<script>") && escaped.contains("&quot;") && escaped.contains("&#39;"), "Escape HTML");
        check(Web2.html(null).isEmpty(), "HTML null");
        check(Web2.query("a&b=1").equals("a%26b%3D1"), "Encode query");
        check(Web2.html(Web2.query("a&b")).equals("a%26b"), "URL trong thuộc tính HTML");
        check(Web2.displayDate(start).equals("01/09/2026"), "Ngày hiển thị Việt Nam");
        check(Web2.money(6000).equals("6.000 đ"), "Tiền Việt Nam không phụ thuộc locale máy");
        check(Web2.formDate("bad", "2026-09-01").isEmpty(), "Ngày sai trên form không bị đổi thành ngày mặc định");
        check(Web2.loginFailure(null).contains("không chính xác"), "Thông báo sai mật khẩu");
        User2 incomplete = new User2();
        incomplete.setRole("MANAGER");
        check(Web2.loginFailure(incomplete).contains("chưa được cấu hình đầy đủ"), "Thông báo tài khoản thiếu dữ liệu vai trò");
        incomplete.setRole("LIBRARIAN");
        check(Web2.loginFailure(incomplete).contains("chưa có giao diện"), "Thông báo vai trò chưa hỗ trợ");
        if (database) databaseChecks(start, end);
        System.out.println("PASS: " + checks + " kiểm tra; " + (database ? "có kiểm tra DB chỉ đọc" : "không kết nối DB"));
    }

    private static void databaseChecks(Date start, Date end) throws Exception {
        UserDAO2 users = new UserDAO2();
        User2 reader = users.checkLogin("reader1", "123456");
        check(reader instanceof Reader2 && reader.getPassword() == null, "Đăng nhập không giữ mật khẩu");
        check("Sinh viên chính quy".equals(((Reader2) reader).getReaderType()), "Loại bạn đọc thực tế");
        User2 manager = users.checkLogin("manager", "123456");
        check(manager instanceof Manager2 && manager.getPassword() == null, "Phiên quản lý không giữ mật khẩu");
        check("Trưởng phòng thư viện".equals(((Manager2) manager).getPosition()), "Chức vụ thực tế");
        check(users.checkLogin("reader1", "khong-dung") == null, "Sai mật khẩu");
        check(users.getReaderById(3).getPassword() == null, "Hồ sơ không nạp mật khẩu");
        DocumentTitleDAO2 titles = new DocumentTitleDAO2();
        ArrayList<DocumentTitle2> docs = titles.searchDocument("Thiết kế");
        check(docs.stream().anyMatch(d -> d.getId() == 1), "Tìm tài liệu tiếng Việt");
        check(new DocumentCopyDAO2().getCopiesByDocId(1).size() == 3, "Danh sách bản sao");
        check(titles.getDocumentTitleById(Integer.MAX_VALUE) == null, "Tài liệu không tồn tại");
        ArrayList<StatReader2> stats = new StatReaderDAO2().getStatReaderByBorrowCount(start, end);
        check(stats.size() == 3, "Số độc giả có lượt mượn trong bộ dữ liệu mẫu");
        check(stats.get(0).getId() == 3 && stats.get(0).getBorrowCount() == 3
                && stats.get(0).getBorrowedQuantity() == 5, "Tổng thống kê");
        BorrowSlipDAO2 slips = new BorrowSlipDAO2();
        check(slips.getBorrowSlipsByReader(3, start, end).size() == 3, "Lịch sử cùng kỳ");
        check(slips.getBorrowSlipById(1).getReader().getId() == 3, "Chủ phiếu");
        check(slips.getBorrowSlipById(Integer.MAX_VALUE) == null, "Phiếu không tồn tại");
        check(slips.getBorrowSlipDetail(1).size() == 2, "Chi tiết phiếu");
        Date boundary = Validation2.date("2026-09-05");
        ArrayList<StatReader2> oneDay = new StatReaderDAO2().getStatReaderByBorrowCount(boundary, boundary);
        check(oneDay.size() == 1 && oneDay.get(0).getBorrowCount() == 1, "Hai biên cùng ngày");
        check(new StatReaderDAO2().getStatReaderByBorrowCount(Validation2.date("2026-11-01"),
                Validation2.date("2026-11-30")).isEmpty(), "Khoảng không có dữ liệu");
        try (Connection second = DAO2.getConnection()) {
            try (Connection first = DAO2.getConnection()) {
                check(first != second, "Kết nối độc lập");
            }
            check(!second.isClosed() && second.isValid(2), "Đóng một kết nối không đóng kết nối khác");
        }
    }
}
