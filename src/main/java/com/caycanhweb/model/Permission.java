package com.caycanhweb.model;

public class Permission {
    private int     userId;
    private boolean canProducts;
    private boolean canOrders;
    private boolean canUsers;

    public Permission() {}

    public Permission(int userId, boolean canProducts, boolean canOrders, boolean canUsers) {
        this.userId      = userId;
        this.canProducts = canProducts;
        this.canOrders   = canOrders;
        this.canUsers    = canUsers;
    }

    public int     getUserId()     { return userId; }
    public void    setUserId(int userId) { this.userId = userId; }
    public boolean isCanProducts() { return canProducts; }
    public void    setCanProducts(boolean canProducts) { this.canProducts = canProducts; }
    public boolean isCanOrders()   { return canOrders; }
    public void    setCanOrders(boolean canOrders) { this.canOrders = canOrders; }
    public boolean isCanUsers()    { return canUsers; }
    public void    setCanUsers(boolean canUsers) { this.canUsers = canUsers; }
}