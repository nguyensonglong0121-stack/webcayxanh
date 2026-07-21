package com.caycanhweb.model;

/** Thống kê doanh thu / số đơn theo phương thức thanh toán (cod, bank...). */
public class PaymentMethodStat {
    private String method;
    private long   revenue;
    private int    orderCount;

    public PaymentMethodStat() {}

    public PaymentMethodStat(String method, long revenue, int orderCount) {
        this.method = method;
        this.revenue = revenue;
        this.orderCount = orderCount;
    }

    public String getMethod()     { return method; }
    public void   setMethod(String method) { this.method = method; }
    public long   getRevenue()    { return revenue; }
    public void   setRevenue(long revenue) { this.revenue = revenue; }
    public int    getOrderCount() { return orderCount; }
    public void   setOrderCount(int orderCount) { this.orderCount = orderCount; }

    public String getRevenueFormatted() {
        return String.format("%,d", revenue).replace(',', '.');
    }

    public String getMethodLabel() {
        return "cod".equalsIgnoreCase(method) ? "Thanh toán khi nhận hàng (COD)"
                : "bank".equalsIgnoreCase(method) ? "Chuyển khoản"
                  : method;
    }
}