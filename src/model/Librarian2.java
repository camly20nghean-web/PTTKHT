package model;

public class Librarian2 extends Staff2 {
    private static final long serialVersionUID = 1L;
    
    private String shift;

    public Librarian2() {
        super();
    }

    public Librarian2(int id, String username, String password, String fullName, String address, String phone, String email, String role, String position, String shift) {
        super(id, username, password, fullName, address, phone, email, role, position);
        this.shift = shift;
    }

    public String getShift() { return shift; }
    public void setShift(String shift) { this.shift = shift; }
}
