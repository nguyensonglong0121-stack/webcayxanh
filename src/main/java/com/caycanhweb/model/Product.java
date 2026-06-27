package com.caycanhweb.model;

import java.time.LocalDateTime;

public class Product {
    private int           productId;
    private int           categoryId;
    private String        categoryName;
    private String        name;
    private long          price;
    private long          salePrice;      // 0 = không có khuyến mãi
    private int           stock;
    private String        description;
    private String        careTips;
    private String        mainImage;
    private boolean       isFeatured;
    private String        status;
    private LocalDateTime createdAt;
    private double        avgRating;      // tính từ bảng reviews

    public Product() {}

    // Getters & Setters
    public int           getProductId()    { return productId; }
    public void          setProductId(int productId) { this.productId = productId; }
    public int           getCategoryId()   { return categoryId; }
    public void          setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String        getCategoryName() { return categoryName; }
    public void          setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String        getName()         { return name; }
    public void          setName(String name) { this.name = name; }
    public long          getPrice()        { return price; }
    public void          setPrice(long price) { this.price = price; }
    public long          getSalePrice()    { return salePrice; }
    public void          setSalePrice(long salePrice) { this.salePrice = salePrice; }
    public int           getStock()        { return stock; }
    public void          setStock(int stock) { this.stock = stock; }
    public String        getDescription()  { return description; }
    public void          setDescription(String description) { this.description = description; }
    public String        getCareTips()     { return careTips; }
    public void          setCareTips(String careTips) { this.careTips = careTips; }
    public String        getMainImage()    { return mainImage; }
    public void          setMainImage(String mainImage) { this.mainImage = mainImage; }
    public boolean       isFeatured()      { return isFeatured; }
    public void          setFeatured(boolean featured) { isFeatured = featured; }
    public String        getStatus()       { return status; }
    public void          setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt()    { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public double        getAvgRating()    { return avgRating; }
    public void          setAvgRating(double avgRating) { this.avgRating = avgRating; }

    /** Giá hiển thị: nếu có sale_price thì dùng sale_price, không thì dùng price */
    public long getDisplayPrice() {
        return salePrice > 0 ? salePrice : price;
    }

    public boolean isOnSale() {
        return salePrice > 0 && salePrice < price;
    }
    public String getPriceFormatted() {
        return String.format("%,d", price).replace(',', '.');
    }

    public String getSalePriceFormatted() {
        return salePrice > 0 ? String.format("%,d", salePrice).replace(',', '.') : "";
    }

    public String getDisplayPriceFormatted() {
        long display = salePrice > 0 ? salePrice : price;
        return String.format("%,d", display).replace(',', '.');
    }
}