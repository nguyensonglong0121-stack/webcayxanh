package com.caycanhweb.model;

/**
 * Thống kê số lượng bán / doanh thu của một sản phẩm trong một khoảng
 * thời gian — dùng cho bảng "Top sản phẩm bán chạy" trong báo cáo doanh thu.
 */
public class ProductSalesStat {
    private int    productId;
    private String productName;
    private String mainImage;
    private int    quantitySold;
    private long   revenue;

    public ProductSalesStat() {}

    public int    getProductId()     { return productId; }
    public void   setProductId(int productId) { this.productId = productId; }
    public String getProductName()   { return productName; }
    public void   setProductName(String productName) { this.productName = productName; }
    public String getMainImage()     { return mainImage; }
    public void   setMainImage(String mainImage) { this.mainImage = mainImage; }
    public int    getQuantitySold()  { return quantitySold; }
    public void   setQuantitySold(int quantitySold) { this.quantitySold = quantitySold; }
    public long   getRevenue()       { return revenue; }
    public void   setRevenue(long revenue) { this.revenue = revenue; }

    public String getRevenueFormatted() {
        return String.format("%,d", revenue).replace(',', '.');
    }
}