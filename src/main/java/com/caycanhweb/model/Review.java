package com.caycanhweb.model;

import java.time.LocalDateTime;

public class Review {
    private int           reviewId;
    private int           productId;
    private int           userId;
    private String        userName;   // join từ bảng users, hiển thị "ai đã đánh giá"
    private int           rating;     // 1 - 5
    private String        comment;
    private LocalDateTime createdAt;

    public Review() {}

    public Review(int productId, int userId, int rating, String comment) {
        this.productId = productId;
        this.userId    = userId;
        this.rating    = rating;
        this.comment   = comment;
    }

    // Getters & Setters
    public int           getReviewId()  { return reviewId; }
    public void          setReviewId(int reviewId) { this.reviewId = reviewId; }
    public int           getProductId() { return productId; }
    public void          setProductId(int productId) { this.productId = productId; }
    public int           getUserId()    { return userId; }
    public void          setUserId(int userId) { this.userId = userId; }
    public String        getUserName()  { return userName; }
    public void          setUserName(String userName) { this.userName = userName; }
    public int           getRating()    { return rating; }
    public void          setRating(int rating) { this.rating = rating; }
    public String        getComment()   { return comment; }
    public void          setComment(String comment) { this.comment = comment; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    /** Chữ cái đầu tên user, dùng làm avatar tròn trong JSP (giống UI hiện có) */
    public String getUserInitial() {
        if (userName == null || userName.isBlank()) return "?";
        return userName.trim().substring(0, 1).toUpperCase();
    }
}