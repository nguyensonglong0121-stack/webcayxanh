package com.caycanhweb.model;

import java.time.LocalDateTime;

public class User {
    private int           userId;
    private String        fullName;
    private String        email;
    private String        password;
    private String        phone;
    private String        address;
    private String        role;
    private boolean       isActive;
    private LocalDateTime createdAt;

    public User() {}

    public User(int userId, String fullName, String email, String phone, String address, String role, boolean isActive) {
        this.userId   = userId;
        this.fullName = fullName;
        this.email    = email;
        this.phone    = phone;
        this.address  = address;
        this.role     = role;
        this.isActive = isActive;
    }

    // Getters & Setters
    public int           getUserId()   { return userId; }
    public void          setUserId(int userId) { this.userId = userId; }
    public String        getFullName() { return fullName; }
    public void          setFullName(String fullName) { this.fullName = fullName; }
    public String        getEmail()    { return email; }
    public void          setEmail(String email) { this.email = email; }
    public String        getPassword() { return password; }
    public void          setPassword(String password) { this.password = password; }
    public String        getPhone()    { return phone; }
    public void          setPhone(String phone) { this.phone = phone; }
    public String        getAddress()  { return address; }
    public void          setAddress(String address) { this.address = address; }
    public String        getRole()     { return role; }
    public void          setRole(String role) { this.role = role; }
    public boolean       isActive()    { return isActive; }
    public void          setActive(boolean active) { isActive = active; }
    public LocalDateTime getCreatedAt(){ return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }
}