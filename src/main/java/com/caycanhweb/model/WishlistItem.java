package com.caycanhweb.model;

import java.time.LocalDateTime;

public class WishlistItem {
    private int            wishlistId;
    private int            userId;
    private int            productId;
    private LocalDateTime  createdAt;

    // Thông tin sản phẩm (join sang bảng products để hiển thị)
    private String  productName;
    private String  mainImage;
    private long    price;
    private long    salePrice;
    private int     stock;
    private double  avgRating;

    public WishlistItem() {}

    public int           getWishlistId()   { return wishlistId; }
    public void          setWishlistId(int wishlistId) { this.wishlistId = wishlistId; }
    public int           getUserId()       { return userId; }
    public void          setUserId(int userId) { this.userId = userId; }
    public int           getProductId()    { return productId; }
    public void          setProductId(int productId) { this.productId = productId; }
    public LocalDateTime getCreatedAt()    { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String  getProductName()  { return productName; }
    public void    setProductName(String productName) { this.productName = productName; }
    public String  getMainImage()    { return mainImage; }
    public void    setMainImage(String mainImage) { this.mainImage = mainImage; }
    public long    getPrice()        { return price; }
    public void    setPrice(long price) { this.price = price; }
    public long    getSalePrice()    { return salePrice; }
    public void    setSalePrice(long salePrice) { this.salePrice = salePrice; }
    public int     getStock()        { return stock; }
    public void    setStock(int stock) { this.stock = stock; }
    public double  getAvgRating()    { return avgRating; }
    public void    setAvgRating(double avgRating) { this.avgRating = avgRating; }

    public long getDisplayPrice() {
        return salePrice > 0 ? salePrice : price;
    }

    public boolean isOnSale() {
        return salePrice > 0 && salePrice < price;
    }
}