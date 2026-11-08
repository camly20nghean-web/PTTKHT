package dao;

import java.sql.Connection;
import java.sql.SQLException;
import util.Validation2;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.DocumentCopy2;

public class DocumentCopyDAO2 extends DAO2 {

    public DocumentCopyDAO2() {
        super();
    }

    /**
     * Lấy danh sách các bản sao (cuốn sách vật lý) theo mã đầu sách docTitleId
     */
    public ArrayList<DocumentCopy2> getCopiesByDocId(int docTitleId) {
        Validation2.requirePositiveId(docTitleId);
        ArrayList<DocumentCopy2> list = new ArrayList<>();
        String sql = "SELECT * FROM tblDocumentCopy2 WHERE tblDocumentTitle2id = ?";
        
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, docTitleId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DocumentCopy2 copy = new DocumentCopy2(
                        rs.getInt("id"),
                        rs.getString("physicalCondition"),
                        rs.getString("status"),
                        rs.getString("barcode")
                    );
                    list.add(copy);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException2("Không thể đọc dữ liệu.", e);
        }
        return list;
    }
}
