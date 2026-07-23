package com.caycanhweb.model;

import java.time.LocalDateTime;

/**
 * Model cho bảng "coupons". Một mã giảm giá có thể là:
 *  - percent: giảm theo % (discountValue = 1-100), có thể giới hạn trần giảm (maxDiscount)
 *  - fixed  : giảm thẳng 1 số tiền cố định (discountValue = số tiền, đơn vị VNĐ)
 */
public class Coupon {
    private int            couponId;
    private String         code;
    private String         discountType;   // "percent" | "fixed"
    private long           discountValue;  // % (1-100) nếu percent, hoặc số tiền nếu fixed
    private Long           maxDiscount;    // trần giảm tối đa khi discountType=percent, null = không giới hạn
    private long           minOrderValue;  // đơn hàng tối thiểu (tạm tính, trước ship) mới áp dụng được
    private Integer        usageLimit;     // null = không giới hạn số lần dùng toàn hệ thống
    private int            usedCount;
    private LocalDateTime  startDate;      // null = không giới hạn ngày bắt đầu
    private LocalDateTime  endDate;        // null = không giới hạn ngày kết thúc
    private boolean        active;

    public Coupon() {}

    public int getCouponId() { return couponId; }
    public void setCouponId(int couponId) { this.couponId = couponId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }
    public long getDiscountValue() { return discountValue; }
    public void setDiscountValue(long discountValue) { this.discountValue = discountValue; }
    public Long getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(Long maxDiscount) { this.maxDiscount = maxDiscount; }
    public long getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(long minOrderValue) { this.minOrderValue = minOrderValue; }
    public Integer getUsageLimit() { return usageLimit; }
    public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }
    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }
    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }
    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    /**
     * Kiểm tra mã có còn hiệu lực tại thời điểm hiện tại không
     * (active, còn trong khoảng ngày, chưa vượt usageLimit).
     * KHÔNG kiểm tra minOrderValue ở đây — việc đó tách riêng vì cần biết subtotal.
     */
    public boolean isCurrentlyValid() {
        if (!active) return false;
        LocalDateTime now = LocalDateTime.now();
        if (startDate != null && now.isBefore(startDate)) return false;
        if (endDate != null && now.isAfter(endDate)) return false;
        if (usageLimit != null && usedCount >= usageLimit) return false;
        return true;
    }

    /**
     * Tính số tiền được giảm cho 1 đơn có tổng tạm tính (trước ship) = subtotal.
     * Trả về 0 nếu đơn chưa đạt minOrderValue (không áp dụng được).
     * Số tiền giảm không bao giờ vượt quá subtotal (tránh discount âm tổng đơn).
     */
    public long calculateDiscount(long subtotal) {
        if (subtotal < minOrderValue) return 0;

        long discount;
        if ("percent".equals(discountType)) {
            discount = subtotal * discountValue / 100;
            if (maxDiscount != null && discount > maxDiscount) {
                discount = maxDiscount;
            }
        } else { // fixed
            discount = discountValue;
        }

        if (discount > subtotal) discount = subtotal;
        return discount;
    }
}
