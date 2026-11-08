package model;

import java.io.Serializable;

public class ImportDetail2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int quantity;
    private double unitPrice;
    private ImportSlip2 importSlip;
    private DocumentTitle2 dcmTitle;

    public ImportDetail2() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }

    public ImportSlip2 getImportSlip() { return importSlip; }
    public void setImportSlip(ImportSlip2 importSlip) { this.importSlip = importSlip; }

    public DocumentTitle2 getDcmTitle() { return dcmTitle; }
    public void setDcmTitle(DocumentTitle2 dcmTitle) { this.dcmTitle = dcmTitle; }
}
