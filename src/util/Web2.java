package util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import model.User2;

public final class Web2 {
    private Web2() {}

    /** Dùng cho văn bản HTML và thuộc tính HTML đặt trong dấu nháy. */
    public static String html(Object value) {
        if (value == null) return "";
        return value.toString().replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    public static String query(Object value) {
        return URLEncoder.encode(value == null ? "" : value.toString(), StandardCharsets.UTF_8);
    }

    public static String displayDate(Date date) {
        return date == null ? "" : date.toLocalDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public static String money(double amount) {
        NumberFormat format = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
        format.setMaximumFractionDigits(0);
        return format.format(amount) + " đ";
    }

    /** Chỉ diễn giải kết quả xác thực, không cấp thêm quyền hoặc nạp thêm dữ liệu. */
    public static String loginFailure(User2 user) {
        if (user == null) return "Tên đăng nhập hoặc mật khẩu không chính xác!";
        if ("MANAGER".equalsIgnoreCase(user.getRole()) || "READER".equalsIgnoreCase(user.getRole())) {
            return "Tài khoản chưa được cấu hình đầy đủ. Vui lòng liên hệ quản trị viên.";
        }
        return "Vai trò này chưa có giao diện trong hai module được triển khai.";
    }

    public static String dateQuery(String start, String end) {
        return "txtStartDate=" + query(start) + "&txtEndDate=" + query(end);
    }

    public static String formDate(String value, String fallback) {
        if (value == null) return fallback;
        try { return Validation2.date(value).toString(); }
        catch (IllegalArgumentException e) { return ""; }
    }
}
