package model;

import java.io.Serializable;
import java.util.ArrayList;

public class DocumentTitle2 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String titleName;
    private String category;
    private String author;
    private String publisher;
    private int publishYear;
    private String description;
    private ArrayList<DocumentCopy2> dcmCopies = new ArrayList<>();

    public DocumentTitle2() {}

    public DocumentTitle2(int id, String titleName, String category, String author, String publisher, int publishYear, String description) {
        this.id = id;
        this.titleName = titleName;
        this.category = category;
        this.author = author;
        this.publisher = publisher;
        this.publishYear = publishYear;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitleName() { return titleName; }
    public void setTitleName(String titleName) { this.titleName = titleName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }

    public int getPublishYear() { return publishYear; }
    public void setPublishYear(int publishYear) { this.publishYear = publishYear; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public ArrayList<DocumentCopy2> getDcmCopies() { return dcmCopies; }
    public void setDcmCopies(ArrayList<DocumentCopy2> dcmCopies) { this.dcmCopies = dcmCopies; }
}
