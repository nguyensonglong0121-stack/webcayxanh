package com.caycanhweb.dao;

import com.caycanhweb.model.Product;
import com.caycanhweb.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // ── Lấy tất cả sản phẩm active ──────────────────────────────
    public List<Product> getAll() {
        String sql = """
                SELECT p.*, c.name AS category_name,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                LEFT JOIN reviews    r ON p.product_id  = r.product_id
                WHERE p.status = 'active'
                GROUP BY p.product_id
                ORDER BY p.created_at DESC
                """;
        return query(sql);
    }

    // ── Sản phẩm nổi bật (is_featured = 1) ──────────────────────
    public List<Product> getFeatured(int limit) {
        String sql = """
                SELECT p.*, c.name AS category_name,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                LEFT JOIN reviews    r ON p.product_id  = r.product_id
                WHERE p.status = 'active' AND p.is_featured = 1
                GROUP BY p.product_id
                ORDER BY p.created_at DESC
                LIMIT ?
                """;
        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Sản phẩm mới nhất ────────────────────────────────────────
    public List<Product> getNewest(int limit) {
        String sql = """
                SELECT p.*, c.name AS category_name,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                LEFT JOIN reviews    r ON p.product_id  = r.product_id
                WHERE p.status = 'active'
                GROUP BY p.product_id
                ORDER BY p.created_at DESC
                LIMIT ?
                """;
        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Lấy theo ID ──────────────────────────────────────────────
    public Product getById(int id) {
        String sql = """
                SELECT p.*, c.name AS category_name,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                LEFT JOIN reviews    r ON p.product_id  = r.product_id
                WHERE p.product_id = ?
                GROUP BY p.product_id
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Tìm kiếm + filter + sắp xếp + phân trang ────────────────
    public List<Product> search(String keyword, int categoryId, String sort, int page, int pageSize) {
        StringBuilder sql = new StringBuilder("""
                SELECT p.*, c.name AS category_name,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                LEFT JOIN reviews    r ON p.product_id  = r.product_id
                WHERE p.status = 'active'
                """);

        if (keyword != null && !keyword.isBlank())
            sql.append(" AND p.name LIKE ?");
        if (categoryId > 0)
            sql.append(" AND p.category_id = ?");

        sql.append(" GROUP BY p.product_id");

        sql.append(switch (sort) {
            case "price_asc"  -> " ORDER BY p.price ASC";
            case "price_desc" -> " ORDER BY p.price DESC";
            case "name_asc"   -> " ORDER BY p.name ASC";
            default           -> " ORDER BY p.created_at DESC";
        });

        sql.append(" LIMIT ? OFFSET ?");

        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isBlank())
                ps.setString(idx++, "%" + keyword + "%");
            if (categoryId > 0)
                ps.setInt(idx++, categoryId);
            ps.setInt(idx++, pageSize);
            ps.setInt(idx,   (page - 1) * pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Đếm tổng để phân trang ───────────────────────────────────
    public int countSearch(String keyword, int categoryId) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM products p WHERE p.status = 'active'");
        if (keyword != null && !keyword.isBlank())
            sql.append(" AND p.name LIKE ?");
        if (categoryId > 0)
            sql.append(" AND p.category_id = ?");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isBlank())
                ps.setString(idx++, "%" + keyword + "%");
            if (categoryId > 0)
                ps.setInt(idx, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ── Sản phẩm cùng danh mục (gợi ý liên quan) ────────────────
    public List<Product> getRelated(int categoryId, int excludeId, int limit) {
        String sql = """
                SELECT p.*, c.name AS category_name,
                       IFNULL(AVG(r.rating),0) AS avg_rating
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                LEFT JOIN reviews    r ON p.product_id  = r.product_id
                WHERE p.status = 'active'
                  AND p.category_id = ?
                  AND p.product_id != ?
                GROUP BY p.product_id
                ORDER BY RAND()
                LIMIT ?
                """;
        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, excludeId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── CRUD cho Admin ───────────────────────────────────────────
    public int insert(Product p) {
        String sql = """
                INSERT INTO products
                (category_id, name, price, sale_price, stock, description, care_tips, main_image, is_featured, status)
                VALUES (?,?,?,?,?,?,?,?,?,?)
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setLong(3, p.getPrice());
            ps.setLong(4, p.getSalePrice());
            ps.setInt(5, p.getStock());
            ps.setString(6, p.getDescription());
            ps.setString(7, p.getCareTips());
            ps.setString(8, p.getMainImage());
            ps.setBoolean(9, p.isFeatured());
            ps.setString(10, p.getStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    public boolean update(Product p) {
        String sql = """
                UPDATE products SET
                  category_id=?, name=?, price=?, sale_price=?, stock=?,
                  description=?, care_tips=?, main_image=?, is_featured=?, status=?
                WHERE product_id=?
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, p.getCategoryId());
            ps.setString(2, p.getName());
            ps.setLong(3, p.getPrice());
            ps.setLong(4, p.getSalePrice());
            ps.setInt(5, p.getStock());
            ps.setString(6, p.getDescription());
            ps.setString(7, p.getCareTips());
            ps.setString(8, p.getMainImage());
            ps.setBoolean(9, p.isFeatured());
            ps.setString(10, p.getStatus());
            ps.setInt(11, p.getProductId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean delete(int id) {
        String sql = "UPDATE products SET status='hidden' WHERE product_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Helper ───────────────────────────────────────────────────
    private List<Product> query(String sql) {
        List<Product> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name"));
        p.setName(rs.getString("name"));
        p.setPrice(rs.getLong("price"));
        p.setSalePrice(rs.getLong("sale_price"));
        p.setStock(rs.getInt("stock"));
        p.setDescription(rs.getString("description"));
        p.setCareTips(rs.getString("care_tips"));
        p.setMainImage(rs.getString("main_image"));
        p.setFeatured(rs.getBoolean("is_featured"));
        p.setStatus(rs.getString("status"));
        p.setAvgRating(rs.getDouble("avg_rating"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts.toLocalDateTime());
        return p;
    }
    // Trừ tồn kho khi đơn hàng hoàn thành
    public boolean reduceStock(int productId, int quantity) {
        String sql = "UPDATE products SET stock = stock - ? WHERE product_id = ? AND stock >= ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.setInt(3, quantity); // đảm bảo không trừ âm
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}