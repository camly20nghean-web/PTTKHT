package model;

public class StatReader2 extends Reader2 {
    private static final long serialVersionUID = 1L;

    private int borrowCount;        // Số lượt mượn (số phiếu mượn)
    private int borrowedQuantity;   // Tổng số lượng cuốn tài liệu đã mượn

    public StatReader2() {
        super();
    }

    public int getBorrowCount() { return borrowCount; }
    public void setBorrowCount(int borrowCount) { this.borrowCount = borrowCount; }

    public int getBorrowedQuantity() { return borrowedQuantity; }
    public void setBorrowedQuantity(int borrowedQuantity) { this.borrowedQuantity = borrowedQuantity; }

}
