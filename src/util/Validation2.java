package util;

import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public final class Validation2 {
    private Validation2() {}

    public static int positiveId(String value) {
        if (value == null || !value.matches("[0-9]+")) {
            throw new IllegalArgumentException("Mã phải là số nguyên dương.");
        }
        try {
            int id = Integer.parseInt(value);
            requirePositiveId(id);
            return id;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Mã vượt quá phạm vi cho phép.", e);
        }
    }

    public static int positiveId(String value, String label) {
        try { return positiveId(value); }
        catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(label + " không hợp lệ. Vui lòng chọn lại từ danh sách.", e);
        }
    }

    public static void requirePositiveId(int id) {
        if (id <= 0) throw new IllegalArgumentException("Mã phải là số nguyên dương.");
    }

    public static Date date(String value) {
        if (value == null || !value.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}")) {
            throw new IllegalArgumentException("Cần nhập đầy đủ ngày theo định dạng yyyy-MM-dd.");
        }
        try {
            LocalDate parsed = LocalDate.parse(value);
            if (parsed.getYear() < 1) throw new IllegalArgumentException("Năm phải lớn hơn 0.");
            return Date.valueOf(parsed);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Ngày không tồn tại.", e);
        }
    }

    public static Date date(String value, String label) {
        try { return date(value); }
        catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(label + ": " + e.getMessage(), e);
        }
    }

    public static void requireRange(Date start, Date end) {
        if (start == null || end == null) {
            throw new IllegalArgumentException("Cần nhập cả ngày bắt đầu và ngày kết thúc.");
        }
        if (start.after(end)) {
            throw new IllegalArgumentException("Ngày bắt đầu không được sau ngày kết thúc.");
        }
    }
}
