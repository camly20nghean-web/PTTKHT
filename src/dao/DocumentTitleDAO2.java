package dao;

import java.sql.Connection;
import java.sql.SQLException;
import util.Validation2;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.DocumentTitle2;

public class DocumentTitleDAO2 extends DAO2 {

    public DocumentTitleDAO2() {
        super();
    }

    /**
     * Tìm kiếm danh sách đầu tài liệu theo từ khóa (khớp tiêu đề, tác giả hoặc thể loại)
     */
    public ArrayList<DocumentTitle2> searchDocument(String keyword) {
        ArrayList<DocumentTitle2> list = new ArrayList<>();
        String sql = "SELECT * FROM tblDocumentTitle2 WHERE titleName LIKE ? OR author LIKE ? OR category LIKE ?";
        
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            String queryKey = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            ps.setString(1, queryKey);
            ps.setString(2, queryKey);
            ps.setString(3, queryKey);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DocumentTitle2 doc = new DocumentTitle2(
                        rs.getInt("id"),
                        rs.getString("titleName"),
                        rs.getString("category"),
                        rs.getString("author"),
                        rs.getString("publisher"),
                        rs.getInt("publishYear"),
                        rs.getString("description")
                    );
                    list.add(doc);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc dữ liệu.", e);
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết đầu tài liệu theo ID
     */
    public DocumentTitle2 getDocumentTitleById(int titleId) {
        Validation2.requirePositiveId(titleId);
        String sql = "SELECT * FROM tblDocumentTitle2 WHERE id = ?";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, titleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new DocumentTitle2(
                        rs.getInt("id"),
                        rs.getString("titleName"),
                        rs.getString("category"),
                        rs.getString("author"),
                        rs.getString("publisher"),
                        rs.getInt("publishYear"),
                        rs.getString("description")
                    );
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc dữ liệu.", e);
        }
        return null;
    }
}
