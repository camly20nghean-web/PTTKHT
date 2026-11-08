package dao;

import java.sql.Connection;
import java.sql.SQLException;
import util.Validation2;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.User2;
import model.Reader2;
import model.Manager2;

public class UserDAO2 extends DAO2 {

    public UserDAO2() {
        super();
    }

    /**
     * Xác thực đăng nhập
     */
    public User2 checkLogin(String username, String password) {
        String sql = "SELECT u.id, u.username, u.fullName, u.address, u.phone, u.email, u.role, "
                + "r.tblUser2id AS readerId, r.readerType, s.position, m.tblStaff2id AS managerId "
                + "FROM tblUser2 u LEFT JOIN tblReader2 r ON r.tblUser2id = u.id "
                + "LEFT JOIN tblStaff2 s ON s.tblUser2id = u.id "
                + "LEFT JOIN tblManager2 m ON m.tblStaff2id = s.tblUser2id "
                + "WHERE u.username = ? AND u.password = ?";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    int id = rs.getInt("id");
                    String fullName = rs.getString("fullName");
                    String address = rs.getString("address");
                    String phone = rs.getString("phone");
                    String email = rs.getString("email");

                    if ("READER".equalsIgnoreCase(role) && rs.getObject("readerId") != null) {
                        Reader2 r = new Reader2(id, rs.getString("username"), null, fullName, address, phone, email, role, rs.getString("readerType"));
                        return r;
                    } else if ("MANAGER".equalsIgnoreCase(role) && rs.getObject("managerId") != null) {
                        Manager2 m = new Manager2(id, rs.getString("username"), null, fullName, address, phone, email, role, rs.getString("position"));
                        return m;
                    } else {
                        return new User2(id, rs.getString("username"), null, fullName, address, phone, email, role);
                    }
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc thông tin tài khoản.", e);
        }
        return null;
    }

    /**
     * Lấy thông tin bạn đọc theo ID
     */
    public Reader2 getReaderById(int readerId) {
        Validation2.requirePositiveId(readerId);
        String sql = "SELECT u.id, u.username, u.fullName, u.address, u.phone, u.email, u.role, r.readerType FROM tblUser2 u JOIN tblReader2 r ON u.id = r.tblUser2id WHERE u.id = ?";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, readerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Reader2(
                        rs.getInt("id"),
                        rs.getString("username"),
                        null,
                        rs.getString("fullName"),
                        rs.getString("address"),
                        rs.getString("phone"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getString("readerType")
                    );
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc thông tin tài khoản.", e);
        }
        return null;
    }
}
