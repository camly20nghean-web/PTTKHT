package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DAO2 {

    // Cấu hình kết nối MySQL mặc định cho XAMPP
    private static final String DB_URL = "jdbc:mysql://localhost:3306/libman2?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    public DAO2() {}

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException | java.sql.SQLException e) {
            throw new DataAccessException2("Không thể kết nối cơ sở dữ liệu.", e);
        }
    }
}
