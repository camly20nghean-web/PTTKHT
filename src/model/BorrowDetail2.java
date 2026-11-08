package model;

import java.io.Serializable;

public class BorrowDetail2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String conditionAtBorrow;
    private DocumentCopy2 dcmCopy;
    private BorrowSlip2 borrowSlip;

    public BorrowDetail2() {}

    public BorrowDetail2(int id, String conditionAtBorrow) {
        this.id = id;
        this.conditionAtBorrow = conditionAtBorrow;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getConditionAtBorrow() { return conditionAtBorrow; }
    public void setConditionAtBorrow(String conditionAtBorrow) { this.conditionAtBorrow = conditionAtBorrow; }

    public DocumentCopy2 getDcmCopy() { return dcmCopy; }
    public void setDcmCopy(DocumentCopy2 dcmCopy) { this.dcmCopy = dcmCopy; }

    public BorrowSlip2 getBorrowSlip() { return borrowSlip; }
    public void setBorrowSlip(BorrowSlip2 borrowSlip) { this.borrowSlip = borrowSlip; }
}
