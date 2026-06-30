package com.caycanhweb.dao;

import com.caycanhweb.model.WishlistItem;
import com.caycanhweb.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class WishlistDAO {

    // ── Thêm vào wishlist ───────────────────────────────────────
    // Trả về true nếu thêm mới, false nếu đã tồn tại / lỗi
    public boolean add(int userId, int productId) {
        String sql = "INSERT IGNORE INTO wishlist (user_id, product_id) VALUES (?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Xóa khỏi wishlist ────────────────────────────────────────
    public boolean remove(int userId, int productId) {
        String sql = "DELETE FROM wishlist WHERE user_id = ? AND product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Kiểm tra sản phẩm đã có trong wishlist chưa ─────────────
    public boolean isInWishlist(int userId, int productId) {
        String sql = "SELECT 1 FROM wishlist WHERE user_id = ? AND product_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Lấy tập hợp productId đã yêu thích (để đánh dấu nút tim trên danh sách) ──
    public Set<Integer> getProductIdsByUser(int userId) {
        Set<Integer> ids = new HashSet<>();
        String sql = "SELECT product_id FROM wishlist WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("product_id"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return ids;
    }

    // ── Danh sách wishlist đầy đủ thông tin sản phẩm (cho trang wishlist) ──
    public List<WishlistItem> getByUser(int userId) {
        String sql = """
                SELECT w.wishlist_id, w.user_id, w.product_id, w.created_at,
                       p.name AS product_name, p.main_image, p.price, p.sale_price, p.stock,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM wishlist w
                JOIN products p ON w.product_id = p.product_id
                LEFT JOIN reviews r ON p.product_id = r.product_id
                WHERE w.user_id = ?
                GROUP BY w.wishlist_id, w.user_id, w.product_id, w.created_at,
                         p.name, p.main_image, p.price, p.sale_price, p.stock
                ORDER BY w.created_at DESC
                """;
        List<WishlistItem> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WishlistItem w = new WishlistItem();
                    w.setWishlistId(rs.getInt("wishlist_id"));
                    w.setUserId(rs.getInt("user_id"));
                    w.setProductId(rs.getInt("product_id"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) w.setCreatedAt(ts.toLocalDateTime());
                    w.setProductName(rs.getString("product_name"));
                    w.setMainImage(rs.getString("main_image"));
                    w.setPrice(rs.getLong("price"));
                    w.setSalePrice(rs.getLong("sale_price"));
                    w.setStock(rs.getInt("stock"));
                    w.setAvgRating(rs.getDouble("avg_rating"));
                    list.add(w);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Đếm số sản phẩm yêu thích (hiển thị badge trên header) ──
    public int countByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}