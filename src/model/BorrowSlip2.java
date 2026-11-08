package model;

import java.io.Serializable;
import java.sql.Date;
import java.util.ArrayList;

public class BorrowSlip2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Date borrowDate;
    private Date expectedReturnDate;
    private String status;
    private Reader2 reader;
    private ArrayList<BorrowDetail2> borrowDetails = new ArrayList<>();

    public BorrowSlip2() {}

    public BorrowSlip2(int id, Date borrowDate, Date expectedReturnDate, String status) {
        this.id = id;
        this.borrowDate = borrowDate;
        this.expectedReturnDate = expectedReturnDate;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Date getBorrowDate() { return borrowDate; }
    public void setBorrowDate(Date borrowDate) { this.borrowDate = borrowDate; }

    public Date getExpectedReturnDate() { return expectedReturnDate; }
    public void setExpectedReturnDate(Date expectedReturnDate) { this.expectedReturnDate = expectedReturnDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Reader2 getReader() { return reader; }
    public void setReader(Reader2 reader) { this.reader = reader; }

    public ArrayList<BorrowDetail2> getBorrowDetails() { return borrowDetails; }
    public void setBorrowDetails(ArrayList<BorrowDetail2> borrowDetails) { this.borrowDetails = borrowDetails; }
}
