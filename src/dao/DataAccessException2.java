package dao;

/** Phân biệt lỗi truy cập dữ liệu với kết quả truy vấn rỗng. */
public class DataAccessException2 extends RuntimeException {
    private static final long serialVersionUID = 1L;

    public DataAccessException2(String message, Throwable cause) {
        super(message, cause);
    }
}
