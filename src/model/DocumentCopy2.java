package model;

import java.io.Serializable;

public class DocumentCopy2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String physicalCondition;
    private String status;
    private String barcode;
    private DocumentTitle2 dcmTitle;

    public DocumentCopy2() {}

    public DocumentCopy2(int id, String physicalCondition, String status, String barcode) {
        this.id = id;
        this.physicalCondition = physicalCondition;
        this.status = status;
        this.barcode = barcode;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPhysicalCondition() { return physicalCondition; }
    public void setPhysicalCondition(String physicalCondition) { this.physicalCondition = physicalCondition; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }

    public DocumentTitle2 getDcmTitle() { return dcmTitle; }
    public void setDcmTitle(DocumentTitle2 dcmTitle) { this.dcmTitle = dcmTitle; }
}
