package dao;

import java.sql.Connection;
import java.sql.SQLException;
import util.Validation2;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.BorrowSlip2;
import model.BorrowDetail2;
import model.DocumentCopy2;
import model.DocumentTitle2;

public class BorrowSlipDAO2 extends DAO2 {

    public BorrowSlipDAO2() {
        super();
    }

    /**
     * Lấy danh sách các phiếu mượn của một độc giả trong khoảng thời gian [startDate, endDate]
     */
    public ArrayList<BorrowSlip2> getBorrowSlipsByReader(int readerId, Date startDate, Date endDate) {
        Validation2.requirePositiveId(readerId);
        Validation2.requireRange(startDate, endDate);
        ArrayList<BorrowSlip2> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder("SELECT * FROM tblBorrowSlip2 WHERE tblReader2id = ?");
        sql.append(" AND borrowDate BETWEEN ? AND ?");
        sql.append(" ORDER BY borrowDate DESC");

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            ps.setInt(1, readerId);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BorrowSlip2 slip = new BorrowSlip2(
                        rs.getInt("id"),
                        rs.getDate("borrowDate"),
                        rs.getDate("expectedReturnDate"),
                        rs.getString("status")
                    );
                    list.add(slip);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc dữ liệu.", e);
        }
        return list;
    }

    /**
     * Lấy chi tiết các cuốn tài liệu trong một phiếu mượn (kèm thông tin tựa sách và barcode)
     */
    public ArrayList<BorrowDetail2> getBorrowSlipDetail(int borrowSlipId) {
        Validation2.requirePositiveId(borrowSlipId);
        ArrayList<BorrowDetail2> list = new ArrayList<>();
        String sql = 
            "SELECT " +
            "    bd.id AS detailId, " +
            "    bd.conditionAtBorrow, " +
            "    dc.id AS copyId, " +
            "    dc.barcode, " +
            "    dc.physicalCondition, " +
            "    dc.status AS copyStatus, " +
            "    dt.id AS titleId, " +
            "    dt.titleName, " +
            "    dt.category, " +
            "    dt.author, " +
            "    dt.publisher " +
            "FROM tblBorrowDetail2 bd " +
            "JOIN tblDocumentCopy2 dc ON bd.tblDocumentCopy2id = dc.id " +
            "JOIN tblDocumentTitle2 dt ON dc.tblDocumentTitle2id = dt.id " +
            "WHERE bd.tblBorrowSlip2id = ?";

        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, borrowSlipId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BorrowDetail2 detail = new BorrowDetail2();
                    detail.setId(rs.getInt("detailId"));
                    detail.setConditionAtBorrow(rs.getString("conditionAtBorrow"));

                    // Đóng gói thông tin tựa sách
                    DocumentTitle2 title = new DocumentTitle2();
                    title.setId(rs.getInt("titleId"));
                    title.setTitleName(rs.getString("titleName"));
                    title.setCategory(rs.getString("category"));
                    title.setAuthor(rs.getString("author"));
                    title.setPublisher(rs.getString("publisher"));

                    // Đóng gói thông tin bản sao
                    DocumentCopy2 copy = new DocumentCopy2();
                    copy.setId(rs.getInt("copyId"));
                    copy.setBarcode(rs.getString("barcode"));
                    copy.setPhysicalCondition(rs.getString("physicalCondition"));
                    copy.setStatus(rs.getString("copyStatus"));
                    copy.setDcmTitle(title);

                    detail.setDcmCopy(copy);
                    list.add(detail);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc dữ liệu.", e);
        }
        return list;
    }
    /** Nạp phiếu và chủ phiếu để kiểm tra tồn tại/ngữ cảnh trước khi xem chi tiết. */
    public BorrowSlip2 getBorrowSlipById(int borrowSlipId) {
        Validation2.requirePositiveId(borrowSlipId);
        String sql = "SELECT bs.*, u.fullName FROM tblBorrowSlip2 bs "
                + "JOIN tblReader2 r ON r.tblUser2id = bs.tblReader2id "
                + "JOIN tblUser2 u ON u.id = r.tblUser2id WHERE bs.id = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, borrowSlipId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BorrowSlip2 slip = new BorrowSlip2(rs.getInt("id"), rs.getDate("borrowDate"),
                            rs.getDate("expectedReturnDate"), rs.getString("status"));
                    model.Reader2 reader = new model.Reader2();
                    reader.setId(rs.getInt("tblReader2id"));
                    reader.setFullName(rs.getString("fullName"));
                    slip.setReader(reader);
                    return slip;
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc phiếu mượn.", e);
        }
        return null;
    }
}
