package com.caycanhweb.dao;

import com.caycanhweb.model.Order;
import com.caycanhweb.model.OrderItem;
import com.caycanhweb.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    // ── Tạo đơn hàng mới (trả về order_id) ──────────────────────
    public int createOrder(Order o, List<OrderItem> items) {
        String sqlOrder = """
                INSERT INTO orders
                (user_id, receiver_name, receiver_phone, address,
                 total_amount, discount_amount, coupon_code, payment_method, note)
                VALUES (?,?,?,?,?,?,?,?,?)
                """;
        String sqlItem = """
                INSERT INTO order_items
                (order_id, product_id, product_name, quantity, unit_price)
                VALUES (?,?,?,?,?)
                """;
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);   // transaction
            try {
                // 1. Insert order
                int orderId;
                try (PreparedStatement ps = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, o.getUserId());
                    ps.setString(2, o.getReceiverName());
                    ps.setString(3, o.getReceiverPhone());
                    ps.setString(4, o.getAddress());
                    ps.setLong(5, o.getTotalAmount());
                    ps.setLong(6, o.getDiscountAmount());
                    ps.setString(7, o.getCouponCode());
                    ps.setString(8, o.getPaymentMethod());
                    ps.setString(9, o.getNote());
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) { con.rollback(); return -1; }
                        orderId = keys.getInt(1);
                    }
                }
                // 2. Insert từng item
                try (PreparedStatement ps = con.prepareStatement(sqlItem)) {
                    for (OrderItem item : items) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, item.getProductId());
                        ps.setString(3, item.getProductName());
                        ps.setInt(4, item.getQuantity());
                        ps.setLong(5, item.getUnitPrice());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                con.commit();
                return orderId;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    // ── Lấy đơn hàng của một user ────────────────────────────────
    public List<Order> getByUserId(int userId) {
        String sql = "SELECT * FROM orders WHERE user_id=? ORDER BY created_at DESC";
        return queryOrders(sql, userId);
    }

    // ── Lấy tất cả đơn hàng (admin) ──────────────────────────────
    public List<Order> getAll() {
        String sql = """
                SELECT o.*, u.full_name AS user_full_name
                FROM orders o
                LEFT JOIN users u ON o.user_id = u.user_id
                ORDER BY o.created_at DESC
                """;
        List<Order> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order ord = mapRow(rs);
                try { ord.setUserFullName(rs.getString("user_full_name")); } catch (SQLException ignored) {}
                list.add(ord);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Lấy đơn theo ID kèm items ────────────────────────────────
    public Order getById(int orderId) {
        String sql = "SELECT * FROM orders WHERE order_id=?";
        Order o = null;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) o = mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        if (o != null) o.setItems(getItems(orderId));
        return o;
    }

    // ── Lấy items của đơn hàng ───────────────────────────────────
    public List<OrderItem> getItems(int orderId) {
        String sql = "SELECT * FROM order_items WHERE order_id=?";
        List<OrderItem> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setItemId(rs.getInt("item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getLong("unit_price"));
                    list.add(item);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Cập nhật trạng thái đơn ──────────────────────────────────
    public boolean updateStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status=? WHERE order_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Xóa đơn hàng (kèm các item liên quan) ─────────────────────
    public boolean deleteOrder(int orderId) {
        String sqlItems = "DELETE FROM order_items WHERE order_id=?";
        String sqlOrder = "DELETE FROM orders WHERE order_id=?";
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(sqlItems)) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                boolean deleted;
                try (PreparedStatement ps = con.prepareStatement(sqlOrder)) {
                    ps.setInt(1, orderId);
                    deleted = ps.executeUpdate() > 0;
                }
                con.commit();
                return deleted;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Thống kê cho dashboard ────────────────────────────────────
    public long getTotalRevenue() {
        String sql = "SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE status='done'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM orders WHERE status=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ── Helper ───────────────────────────────────────────────────
    private List<Order> queryOrders(String sql, int userId) {
        List<Order> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setUserId(rs.getInt("user_id"));
        o.setReceiverName(rs.getString("receiver_name"));
        o.setReceiverPhone(rs.getString("receiver_phone"));
        o.setAddress(rs.getString("address"));
        o.setTotalAmount(rs.getLong("total_amount"));
        o.setDiscountAmount(rs.getLong("discount_amount"));
        o.setCouponCode(rs.getString("coupon_code"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setStatus(rs.getString("status"));
        o.setNote(rs.getString("note"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) o.setCreatedAt(ts.toLocalDateTime());
        return o;
    }
}