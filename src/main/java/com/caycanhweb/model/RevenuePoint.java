package com.caycanhweb.model;

/**
 * Một điểm dữ liệu doanh thu (theo ngày hoặc theo tháng), dùng để vẽ
 * biểu đồ và bảng trong trang báo cáo doanh thu của admin.
 */
public class RevenuePoint {
    private String label;      // "2026-07-21" (ngày) hoặc "2026-07" (tháng)
    private long   revenue;    // tổng doanh thu (chỉ tính đơn status='done')
    private int    orderCount; // số đơn hoàn thành trong kỳ

    public RevenuePoint() {}

    public RevenuePoint(String label, long revenue, int orderCount) {
        this.label = label;
        this.revenue = revenue;
        this.orderCount = orderCount;
    }

    public String getLabel()      { return label; }
    public void   setLabel(String label) { this.label = label; }
    public long   getRevenue()    { return revenue; }
    public void   setRevenue(long revenue) { this.revenue = revenue; }
    public int    getOrderCount() { return orderCount; }
    public void   setOrderCount(int orderCount) { this.orderCount = orderCount; }

    public String getRevenueFormatted() {
        return String.format("%,d", revenue).replace(',', '.');
    }

    // Giá trị đơn hàng trung bình trong kỳ
    public long getAvgOrderValue() {
        return orderCount == 0 ? 0 : revenue / orderCount;
    }

    public String getAvgOrderValueFormatted() {
        return String.format("%,d", getAvgOrderValue()).replace(',', '.');
    }
}