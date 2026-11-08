package model;

public class Staff2 extends User2 {
    private static final long serialVersionUID = 1L;
    
    private String position;

    public Staff2() {
        super();
    }

    public Staff2(int id, String username, String password, String fullName, String address, String phone, String email, String role, String position) {
        super(id, username, password, fullName, address, phone, email, role);
        this.position = position;
    }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
}
