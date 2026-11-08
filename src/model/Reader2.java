package model;

public class Reader2 extends User2 {
    private static final long serialVersionUID = 1L;

    private String readerType;
    private ReaderCard2 readerCard;

    public Reader2() {
        super();
    }

    public Reader2(int id, String username, String password, String fullName, String address, String phone, String email, String role, String readerType) {
        super(id, username, password, fullName, address, phone, email, role);
        this.readerType = readerType;
    }

    public String getReaderType() { return readerType; }
    public void setReaderType(String readerType) { this.readerType = readerType; }

    public ReaderCard2 getReaderCard() { return readerCard; }
    public void setReaderCard(ReaderCard2 readerCard) { this.readerCard = readerCard; }
}
