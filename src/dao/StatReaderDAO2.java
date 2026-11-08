package dao;

import java.sql.Connection;
import java.sql.SQLException;
import util.Validation2;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.StatReader2;

public class StatReaderDAO2 extends DAO2 {

    public StatReaderDAO2() {
        super();
    }

    /**
     * Thống kê độc giả theo số lượt mượn trong khoảng thời gian [startDate, endDate]
     */
    public ArrayList<StatReader2> getStatReaderByBorrowCount(Date startDate, Date endDate) {
        ArrayList<StatReader2> list = new ArrayList<>();
        
        Validation2.requireRange(startDate, endDate);

        String sql = 
            "SELECT " +
            "    r.tblUser2id, " +
            "    u.fullName, " +
            "    u.address, " +
            "    u.phone, " +
            "    u.email, " +
            "    r.readerType, " +
            "    COUNT(DISTINCT bs.id) AS borrowCount, " +
            "    COUNT(bd.id) AS borrowedQuantity " +
            "FROM tblReader2 r " +
            "JOIN tblUser2 u ON r.tblUser2id = u.id " +
            "JOIN tblBorrowSlip2 bs ON bs.tblReader2id = r.tblUser2id " +
            "LEFT JOIN tblBorrowDetail2 bd ON bd.tblBorrowSlip2id = bs.id " +
            "WHERE bs.borrowDate BETWEEN ? AND ? " +
            "GROUP BY r.tblUser2id, u.fullName, u.address, u.phone, u.email, r.readerType " +
            "ORDER BY borrowCount DESC, borrowedQuantity DESC";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StatReader2 stat = new StatReader2();
                    stat.setId(rs.getInt("tblUser2id"));
                    stat.setFullName(rs.getString("fullName"));
                    stat.setAddress(rs.getString("address"));
                    stat.setPhone(rs.getString("phone"));
                    stat.setEmail(rs.getString("email"));
                    stat.setReaderType(rs.getString("readerType"));
                    stat.setBorrowCount(rs.getInt("borrowCount"));
                    stat.setBorrowedQuantity(rs.getInt("borrowedQuantity"));

                    list.add(stat);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc dữ liệu.", e);
        }
        return list;
    }
}
