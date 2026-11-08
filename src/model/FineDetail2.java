package model;

import java.io.Serializable;
import java.math.BigDecimal;

/** Khoản phạt đã ghi nhận; không tự tính lại từ quy định phạt. */
public class FineDetail2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private ReturnDetail2 returnDetail;
    private FineRule2 fineRule;
    private BigDecimal fineAmount = BigDecimal.ZERO;
    private String note;

    public FineDetail2() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public ReturnDetail2 getReturnDetail() { return returnDetail; }
    public void setReturnDetail(ReturnDetail2 returnDetail) { this.returnDetail = returnDetail; }

    public FineRule2 getFineRule() { return fineRule; }
    public void setFineRule(FineRule2 fineRule) { this.fineRule = fineRule; }

    public BigDecimal getFineAmount() { return fineAmount; }
    public void setFineAmount(BigDecimal fineAmount) { this.fineAmount = fineAmount; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
