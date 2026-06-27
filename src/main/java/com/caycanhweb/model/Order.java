package com.caycanhweb.model;

import java.time.LocalDateTime;
import java.util.List;

public class Order {
    private int           orderId;
    private int           userId;
    private String        userFullName;
    private String        receiverName;
    private String        receiverPhone;
    private String        address;
    private long          totalAmount;
    private long          discountAmount;
    private String        couponCode;
    private String        paymentMethod;
    private String        status;
    private String        note;
    private LocalDateTime createdAt;
    private List<OrderItem> items;

    public Order() {}

    // Getters & Setters
    public int           getOrderId()       { return orderId; }
    public void          setOrderId(int orderId) { this.orderId = orderId; }
    public int           getUserId()        { return userId; }
    public void          setUserId(int userId) { this.userId = userId; }
    public String        getUserFullName()  { return userFullName; }
    public void          setUserFullName(String userFullName) { this.userFullName = userFullName; }
    public String        getReceiverName()  { return receiverName; }
    public void          setReceiverName(String receiverName) { this.receiverName = receiverName; }
    public String        getReceiverPhone() { return receiverPhone; }
    public void          setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }
    public String        getAddress()       { return address; }
    public void          setAddress(String address) { this.address = address; }
    public long          getTotalAmount()   { return totalAmount; }
    public void          setTotalAmount(long totalAmount) { this.totalAmount = totalAmount; }
    public long          getDiscountAmount(){ return discountAmount; }
    public void          setDiscountAmount(long discountAmount) { this.discountAmount = discountAmount; }
    public String        getCouponCode()    { return couponCode; }
    public void          setCouponCode(String couponCode) { this.couponCode = couponCode; }
    public String        getPaymentMethod() { return paymentMethod; }
    public void          setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String        getStatus()        { return status; }
    public void          setStatus(String status) { this.status = status; }
    public String        getNote()          { return note; }
    public void          setNote(String note) { this.note = note; }
    public LocalDateTime getCreatedAt()     { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public List<OrderItem> getItems()       { return items; }
    public void          setItems(List<OrderItem> items) { this.items = items; }

    public String getStatusLabel() {
        return switch (status) {
            case "pending"   -> "Chờ xác nhận";
            case "confirmed" -> "Đã xác nhận";
            case "shipping"  -> "Đang giao";
            case "done"      -> "Hoàn thành";
            case "cancelled" -> "Đã hủy";
            default          -> status;
        };
    }
    public String getTotalAmountFormatted() {
        return String.format("%,d", totalAmount).replace(',', '.');
    }
    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getCreatedAtDate() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }
}