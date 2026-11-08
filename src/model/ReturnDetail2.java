package model;

import java.io.Serializable;
import java.util.ArrayList;

public class ReturnDetail2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String conditionAtReturn;
    private ReturnSlip2 returnSlip;
    private ArrayList<FineDetail2> fineDetails = new ArrayList<>();
    private BorrowDetail2 borrowDetail;

    public ReturnDetail2() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getConditionAtReturn() { return conditionAtReturn; }
    public void setConditionAtReturn(String conditionAtReturn) { this.conditionAtReturn = conditionAtReturn; }

    public ReturnSlip2 getReturnSlip() { return returnSlip; }
    public void setReturnSlip(ReturnSlip2 returnSlip) { this.returnSlip = returnSlip; }

    public ArrayList<FineDetail2> getFineDetails() { return fineDetails; }
    public void setFineDetails(ArrayList<FineDetail2> fineDetails) { this.fineDetails = fineDetails; }

    public BorrowDetail2 getBorrowDetail() { return borrowDetail; }
    public void setBorrowDetail(BorrowDetail2 borrowDetail) { this.borrowDetail = borrowDetail; }
}
