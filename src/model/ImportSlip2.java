package model;

import java.io.Serializable;
import java.sql.Date;
import java.util.ArrayList;

public class ImportSlip2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Date importDate;
    private int totalQuantity;
    private double amount;
    private Librarian2 librarian;
    private Supplier2 supplier;
    private ArrayList<ImportDetail2> importDetails = new ArrayList<>();

    public ImportSlip2() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Date getImportDate() { return importDate; }
    public void setImportDate(Date importDate) { this.importDate = importDate; }

    public int getTotalQuantity() { return totalQuantity; }
    public void setTotalQuantity(int totalQuantity) { this.totalQuantity = totalQuantity; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public Librarian2 getLibrarian() { return librarian; }
    public void setLibrarian(Librarian2 librarian) { this.librarian = librarian; }

    public Supplier2 getSupplier() { return supplier; }
    public void setSupplier(Supplier2 supplier) { this.supplier = supplier; }

    public ArrayList<ImportDetail2> getImportDetails() { return importDetails; }
    public void setImportDetails(ArrayList<ImportDetail2> importDetails) { this.importDetails = importDetails; }
}
