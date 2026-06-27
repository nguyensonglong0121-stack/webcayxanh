package com.caycanhweb.model;

// ============================================================
// CartItem — lưu trong Session (không lưu DB)
// ============================================================
public class CartItem {
    private int    productId;
    private String productName;
    private String mainImage;
    private long   unitPrice;
    private int    quantity;

    public CartItem() {}

    public CartItem(int productId, String productName, String mainImage, long unitPrice, int quantity) {
        this.productId   = productId;
        this.productName = productName;
        this.mainImage   = mainImage;
        this.unitPrice   = unitPrice;
        this.quantity    = quantity;
    }

    public long getSubtotal() { return unitPrice * quantity; }

    public int    getProductId()   { return productId; }
    public void   setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void   setProductName(String productName) { this.productName = productName; }
    public String getMainImage()   { return mainImage; }
    public void   setMainImage(String mainImage) { this.mainImage = mainImage; }
    public long   getUnitPrice()   { return unitPrice; }
    public void   setUnitPrice(long unitPrice) { this.unitPrice = unitPrice; }
    public int    getQuantity()    { return quantity; }
    public void   setQuantity(int quantity) { this.quantity = quantity; }
    public String getSubtotalFormatted() {
        return String.format("%,d", getSubtotal()).replace(',', '.');
    }

    public String getUnitPriceFormatted() {
        return String.format("%,d", unitPrice).replace(',', '.');
    }
}