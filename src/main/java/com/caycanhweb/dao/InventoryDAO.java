package com.caycanhweb.dao;

import com.caycanhweb.model.StockTransaction;
import com.caycanhweb.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InventoryDAO {

    // ── Nhập kho: tăng stock + ghi lịch sử ──────────────────────
    public boolean importStock(int productId, int quantity, String note, Integer userId) {
        return applyTransaction(productId, quantity, note, userId, "import");
    }

    // ── Xuất kho: giảm stock (không cho âm) + ghi lịch sử ───────
    public boolean exportStock(int productId, int quantity, String note, Integer userId) {
        return applyTransaction(productId, -quantity, note, userId, "export");
    }

    // ── Điều chỉnh: đặt lại tồn kho về đúng 1 con số cụ thể ─────
    public boolean adjustStock(int productId, int newStock, String note, Integer userId) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int current = getCurrentStock(con, productId);
            if (current < 0) { con.rollback(); return false; }
            int diff = newStock - current;

            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE products SET stock = ? WHERE product_id = ?")) {
                ps.setInt(1, newStock);
                ps.setInt(2, productId);
                ps.executeUpdate();
            }
            insertTransactionRow(con, productId, "adjust", Math.abs(diff), newStock, note, userId);

            con.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(con);
            e.printStackTrace();
            return false;
        } finally {
            closeQuietly(con);
        }
    }

    // ── Logic dùng chung cho nhập / xuất (delta có thể âm) ──────
    private boolean applyTransaction(int productId, int delta, String note, Integer userId, String type) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int current = getCurrentStock(con, productId);
            if (current < 0) { con.rollback(); return false; } // sản phẩm không tồn tại

            int newStock = current + delta;
            if (newStock < 0) { con.rollback(); return false; } // xuất quá số tồn kho

            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE products SET stock = ? WHERE product_id = ?")) {
                ps.setInt(1, newStock);
                ps.setInt(2, productId);
                ps.executeUpdate();
            }
            insertTransactionRow(con, productId, type, Math.abs(delta), newStock, note, userId);

            con.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(con);
            e.printStackTrace();
            return false;
        } finally {
            closeQuietly(con);
        }
    }

    private int getCurrentStock(Connection con, int productId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT stock FROM products WHERE product_id = ? FOR UPDATE")) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    private void insertTransactionRow(Connection con, int productId, String type, int quantity,
                                      int stockAfter, String note, Integer userId) throws SQLException {
        String sql = """
                INSERT INTO stock_transactions
                (product_id, type, quantity, stock_after, note, created_by)
                VALUES (?,?,?,?,?,?)
                """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, type);
            ps.setInt(3, quantity);
            ps.setInt(4, stockAfter);
            ps.setString(5, note);
            if (userId != null) ps.setInt(6, userId); else ps.setNull(6, Types.INTEGER);
            ps.executeUpdate();
        }
    }

    // ── Lịch sử giao dịch của 1 sản phẩm ─────────────────────────
    public List<StockTransaction> getHistoryByProduct(int productId) {
        String sql = """
                SELECT t.*, u.full_name AS created_by_name
                FROM stock_transactions t
                LEFT JOIN users u ON t.created_by = u.user_id
                WHERE t.product_id = ?
                ORDER BY t.created_at DESC
                LIMIT 200
                """;
        List<StockTransaction> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Lịch sử toàn bộ (có filter loại giao dịch + từ khoá) ────
    public List<StockTransaction> getAllHistory(String type, String keyword, int page, int pageSize) {
        StringBuilder sql = new StringBuilder("""
                SELECT t.*, p.name AS product_name, u.full_name AS created_by_name
                FROM stock_transactions t
                JOIN products p ON t.product_id = p.product_id
                LEFT JOIN users u ON t.created_by = u.user_id
                WHERE 1=1
                """);
        if (type != null && !type.isBlank()) sql.append(" AND t.type = ?");
        if (keyword != null && !keyword.isBlank()) sql.append(" AND p.name LIKE ?");
        sql.append(" ORDER BY t.created_at DESC LIMIT ? OFFSET ?");

        List<StockTransaction> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (type != null && !type.isBlank()) ps.setString(idx++, type);
            if (keyword != null && !keyword.isBlank()) ps.setString(idx++, "%" + keyword + "%");
            ps.setInt(idx++, pageSize);
            ps.setInt(idx, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countAllHistory(String type, String keyword) {
        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(*) FROM stock_transactions t
                JOIN products p ON t.product_id = p.product_id
                WHERE 1=1
                """);
        if (type != null && !type.isBlank()) sql.append(" AND t.type = ?");
        if (keyword != null && !keyword.isBlank()) sql.append(" AND p.name LIKE ?");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (type != null && !type.isBlank()) ps.setString(idx++, type);
            if (keyword != null && !keyword.isBlank()) ps.setString(idx, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ── Sản phẩm sắp hết / đã hết hàng ───────────────────────────
    public int countLowStock(int threshold) {
        String sql = "SELECT COUNT(*) FROM products WHERE status='active' AND stock > 0 AND stock <= ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countOutOfStock() {
        String sql = "SELECT COUNT(*) FROM products WHERE status='active' AND stock = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ── Tổng quan tồn kho (dùng cho các thẻ thống kê) ───────────
    public Map<String, Object> getSummary(int lowStockThreshold) {
        Map<String, Object> map = new HashMap<>();
        String sql = """
                SELECT COUNT(*) AS total_products,
                       IFNULL(SUM(stock),0) AS total_stock,
                       SUM(CASE WHEN stock = 0 THEN 1 ELSE 0 END) AS out_of_stock,
                       SUM(CASE WHEN stock > 0 AND stock <= ? THEN 1 ELSE 0 END) AS low_stock
                FROM products
                WHERE status = 'active'
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lowStockThreshold);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    map.put("totalProducts", rs.getInt("total_products"));
                    map.put("totalStock",    rs.getLong("total_stock"));
                    map.put("outOfStock",    rs.getInt("out_of_stock"));
                    map.put("lowStock",      rs.getInt("low_stock"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    // ── Helper ────────────────────────────────────────────────
    private StockTransaction mapRow(ResultSet rs) throws SQLException {
        StockTransaction t = new StockTransaction();
        t.setTransactionId(rs.getLong("transaction_id"));
        t.setProductId(rs.getInt("product_id"));
        try { t.setProductName(rs.getString("product_name")); } catch (SQLException ignored) {}
        t.setType(rs.getString("type"));
        t.setQuantity(rs.getInt("quantity"));
        t.setStockAfter(rs.getInt("stock_after"));
        t.setNote(rs.getString("note"));
        int createdBy = rs.getInt("created_by");
        t.setCreatedBy(rs.wasNull() ? null : createdBy);
        t.setCreatedByName(rs.getString("created_by_name"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) t.setCreatedAt(ts.toLocalDateTime());
        return t;
    }

    private void rollbackQuietly(Connection con) {
        if (con != null) try { con.rollback(); } catch (SQLException ignored) {}
    }

    private void closeQuietly(Connection con) {
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
    }
}
