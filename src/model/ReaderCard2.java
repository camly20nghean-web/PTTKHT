package model;

import java.io.Serializable;
import java.sql.Date;

public class ReaderCard2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Date issuedDate;
    private Date expiryDate;
    private String status;

    public ReaderCard2() {}

    public ReaderCard2(int id, Date issuedDate, Date expiryDate, String status) {
        this.id = id;
        this.issuedDate = issuedDate;
        this.expiryDate = expiryDate;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Date getIssuedDate() { return issuedDate; }
    public void setIssuedDate(Date issuedDate) { this.issuedDate = issuedDate; }

    public Date getExpiryDate() { return expiryDate; }
    public void setExpiryDate(Date expiryDate) { this.expiryDate = expiryDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
