package com.caycanhweb.dao;

import com.caycanhweb.model.Coupon;
import com.caycanhweb.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;

public class CouponDAO {

    // ── Tìm mã giảm giá theo code (không phân biệt hoa/thường) ──
    public Coupon findByCode(String code) {
        if (code == null || code.isBlank()) return null;
        String sql = "SELECT * FROM coupons WHERE UPPER(code) = UPPER(?) LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tăng used_count thêm 1 sau khi 1 đơn hàng dùng mã này được tạo thành công.
     * Dùng điều kiện WHERE để tránh vượt usage_limit khi có nhiều request cùng lúc
     * (nếu usage_limit NULL thì luôn cho tăng).
     */
    public boolean incrementUsedCount(String code) {
        String sql = """
                UPDATE coupons
                SET used_count = used_count + 1
                WHERE UPPER(code) = UPPER(?)
                  AND (usage_limit IS NULL OR used_count < usage_limit)
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Coupon map(ResultSet rs) throws SQLException {
        Coupon c = new Coupon();
        c.setCouponId(rs.getInt("coupon_id"));
        c.setCode(rs.getString("code"));
        c.setDiscountType(rs.getString("discount_type"));
        c.setDiscountValue(rs.getLong("discount_value"));

        long maxDiscount = rs.getLong("max_discount");
        c.setMaxDiscount(rs.wasNull() ? null : maxDiscount);

        c.setMinOrderValue(rs.getLong("min_order_value"));

        int usageLimit = rs.getInt("usage_limit");
        c.setUsageLimit(rs.wasNull() ? null : usageLimit);

        c.setUsedCount(rs.getInt("used_count"));

        Timestamp start = rs.getTimestamp("start_date");
        c.setStartDate(start != null ? start.toLocalDateTime() : null);

        Timestamp end = rs.getTimestamp("end_date");
        c.setEndDate(end != null ? end.toLocalDateTime() : null);

        c.setActive(rs.getBoolean("active"));
        return c;
    }
}
