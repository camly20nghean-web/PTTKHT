package model;

import java.io.Serializable;
import java.sql.Date;
import java.util.ArrayList;

public class ReturnSlip2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Date actualReturnDate;
    private String note;
    private Reader2 reader;
    private Librarian2 librarian;
    private ArrayList<ReturnDetail2> returnDetails = new ArrayList<>();

    public ReturnSlip2() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Date getActualReturnDate() { return actualReturnDate; }
    public void setActualReturnDate(Date actualReturnDate) { this.actualReturnDate = actualReturnDate; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public Reader2 getReader() { return reader; }
    public void setReader(Reader2 reader) { this.reader = reader; }

    public Librarian2 getLibrarian() { return librarian; }
    public void setLibrarian(Librarian2 librarian) { this.librarian = librarian; }

    public ArrayList<ReturnDetail2> getReturnDetails() { return returnDetails; }
    public void setReturnDetails(ArrayList<ReturnDetail2> returnDetails) { this.returnDetails = returnDetails; }
}
