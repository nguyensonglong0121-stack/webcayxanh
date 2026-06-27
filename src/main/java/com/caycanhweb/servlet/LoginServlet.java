package com.caycanhweb.servlet;

import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Đã đăng nhập rồi → về home
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loggedUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email    = req.getParameter("email").trim();
        String password = req.getParameter("password");
        String next     = req.getParameter("next");

        User user = userDAO.login(email, md5(password));

        if (user == null) {
            req.setAttribute("error", "Email hoặc mật khẩu không đúng!");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        // Tạo session
        HttpSession session = req.getSession();
        session.setAttribute("loggedUser", user);
        session.setMaxInactiveInterval(60 * 60); // 1 giờ

        // Admin → dashboard, user → trang trước hoặc home
        if ("admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else if (next != null && !next.isBlank()) {
            resp.sendRedirect(next);
        } else {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }

    public static String md5(String input) {
        try {
            MessageDigest md  = MessageDigest.getInstance("MD5");
            byte[]        arr = md.digest(input.getBytes());
            BigInteger    bi  = new BigInteger(1, arr);
            String        hex = bi.toString(16);
            while (hex.length() < 32) hex = "0" + hex;
            return hex;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
}