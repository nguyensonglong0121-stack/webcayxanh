package com.caycanhweb.dao;

import com.caycanhweb.model.Permission;
import com.caycanhweb.util.DBConnection;

import java.sql.*;

public class PermissionDAO {

    // ── Lấy quyền của user ───────────────────────────
    public Permission getByUserId(int userId) {
        String sql = "SELECT * FROM user_permissions WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        // Không có record → trả về permission rỗng
        return new Permission(userId, false, false, false);
    }

    // ── Lưu hoặc cập nhật quyền ──────────────────────
    public boolean save(Permission p) {
        String sql = """
                INSERT INTO user_permissions (user_id, can_products, can_orders, can_users)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                  can_products=VALUES(can_products),
                  can_orders=VALUES(can_orders),
                  can_users=VALUES(can_users)
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, p.getUserId());
            ps.setBoolean(2, p.isCanProducts());
            ps.setBoolean(3, p.isCanOrders());
            ps.setBoolean(4, p.isCanUsers());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Kiểm tra quyền cụ thể ────────────────────────
    public boolean hasPermission(int userId, String permission) {
        String col = switch (permission) {
            case "products" -> "can_products";
            case "orders"   -> "can_orders";
            case "users"    -> "can_users";
            default         -> null;
        };
        if (col == null) return false;

        String sql = "SELECT " + col + " FROM user_permissions WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBoolean(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private Permission mapRow(ResultSet rs) throws SQLException {
        return new Permission(
                rs.getInt("user_id"),
                rs.getBoolean("can_products"),
                rs.getBoolean("can_orders"),
                rs.getBoolean("can_users")
        );
    }
}