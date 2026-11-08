package model;

public class Manager2 extends Staff2 {
    private static final long serialVersionUID = 1L;

    public Manager2() {
        super();
    }

    public Manager2(int id, String username, String password, String fullName, String address, String phone, String email, String role, String position) {
        super(id, username, password, fullName, address, phone, email, role, position);
    }
}
