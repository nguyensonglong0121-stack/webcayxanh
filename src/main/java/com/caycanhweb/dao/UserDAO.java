package com.caycanhweb.dao;

import com.caycanhweb.model.User;
import com.caycanhweb.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // ── Đăng nhập ────────────────────────────────────────────────
    // password đã được MD5 từ servlet trước khi gọi hàm này
    public User login(String email, String md5Password) {
        String sql = "SELECT * FROM users WHERE email=? AND password=? AND is_active=1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, md5Password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Đăng ký ──────────────────────────────────────────────────
    public boolean register(User u) {
        String sql = "INSERT INTO users (full_name, email, password, phone, address) VALUES (?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());   // đã MD5
            ps.setString(4, u.getPhone());
            ps.setString(5, u.getAddress());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Kiểm tra email đã tồn tại chưa ──────────────────────────
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Lấy theo ID ──────────────────────────────────────────────
    public User getById(int id) {
        String sql = "SELECT * FROM users WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Cập nhật thông tin cá nhân ───────────────────────────────
    public boolean updateProfile(User u) {
        String sql = "UPDATE users SET full_name=?, phone=?, address=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getPhone());
            ps.setString(3, u.getAddress());
            ps.setInt(4, u.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Đổi mật khẩu ─────────────────────────────────────────────
    public boolean changePassword(int userId, String oldMd5, String newMd5) {
        String sql = "UPDATE users SET password=? WHERE user_id=? AND password=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newMd5);
            ps.setInt(2, userId);
            ps.setString(3, oldMd5);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Admin: lấy tất cả user ───────────────────────────────────
    public List<User> getAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Admin: khóa / mở tài khoản ───────────────────────────────
    public boolean setActive(int userId, boolean active) {
        String sql = "UPDATE users SET is_active=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Helper: map ResultSet → User ─────────────────────────────
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setRole(rs.getString("role"));
        u.setActive(rs.getBoolean("is_active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) u.setCreatedAt(ts.toLocalDateTime());
        return u;
    }
    // ═══════════════════════════════════════════════════
// THÊM CÁC METHOD NÀY VÀO CUỐI UserDAO.java
// ═══════════════════════════════════════════════════

    // ── Lưu OTP vào DB ──────────────────────────────
    public boolean saveOTP(String email, String otp) {
        String sql = """
                UPDATE users SET otp_code=?, otp_expires=DATE_ADD(NOW(), INTERVAL 5 MINUTE)
                WHERE email=? AND is_active=1
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, otp);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Xác thực OTP ────────────────────────────────
    public User verifyOTP(String email, String otp) {
        String sql = """
                SELECT * FROM users
                WHERE email=? AND otp_code=? AND otp_expires > NOW() AND is_active=1
                """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, otp);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Xóa OTP sau khi dùng
                    clearOTP(email);
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Xóa OTP sau khi dùng xong ───────────────────
    private void clearOTP(String email) {
        String sql = "UPDATE users SET otp_code=NULL, otp_expires=NULL WHERE email=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // ── Lấy user theo email (cho OTP check) ─────────
    public User getByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email=? AND is_active=1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── Đăng ký hoặc login bằng Google ──────────────
    public User loginOrRegisterGoogle(String googleId, String email, String fullName) {
        // Kiểm tra đã có tài khoản google_id chưa
        String sqlFind = "SELECT * FROM users WHERE google_id=? OR email=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sqlFind)) {
            ps.setString(1, googleId);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Cập nhật google_id nếu chưa có
                    updateGoogleId(rs.getInt("user_id"), googleId);
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }

        // Tạo tài khoản mới từ Google
        String sqlInsert = "INSERT INTO users (full_name, email, password, google_id, role) VALUES (?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, "GOOGLE_AUTH_" + googleId); // password dummy
            ps.setString(4, googleId);
            ps.setString(5, "user");
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return getById(keys.getInt(1));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    private void updateGoogleId(int userId, String googleId) {
        String sql = "UPDATE users SET google_id=? WHERE user_id=? AND google_id IS NULL";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, googleId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}