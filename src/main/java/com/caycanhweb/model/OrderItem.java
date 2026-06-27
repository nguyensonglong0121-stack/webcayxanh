package com.caycanhweb.model;

public class OrderItem {
    private int    itemId;
    private int    orderId;
    private int    productId;
    private String productName;
    private int    quantity;
    private long   unitPrice;

    public OrderItem() {}

    public OrderItem(int productId, String productName, int quantity, long unitPrice) {
        this.productId   = productId;
        this.productName = productName;
        this.quantity    = quantity;
        this.unitPrice   = unitPrice;
    }



    // Getters & Setters
    public int    getItemId()      { return itemId; }
    public void   setItemId(int itemId) { this.itemId = itemId; }
    public int    getOrderId()     { return orderId; }
    public void   setOrderId(int orderId) { this.orderId = orderId; }
    public int    getProductId()   { return productId; }
    public void   setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void   setProductName(String productName) { this.productName = productName; }
    public int    getQuantity()    { return quantity; }
    public void   setQuantity(int quantity) { this.quantity = quantity; }
    public long   getUnitPrice()   { return unitPrice; }
    public void   setUnitPrice(long unitPrice) { this.unitPrice = unitPrice; }
    public long getSubtotal() {
        return unitPrice * quantity;
    }

    public String getSubtotalFormatted() {
        return String.format("%,d", getSubtotal()).replace(',', '.');
    }

    public String getUnitPriceFormatted() {
        return String.format("%,d", unitPrice).replace(',', '.');
    }
}