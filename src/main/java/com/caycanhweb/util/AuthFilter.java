package com.caycanhweb.util;

import com.caycanhweb.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/checkout", "/profile", "/orders"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req     = (HttpServletRequest)  request;
        HttpServletResponse resp    = (HttpServletResponse) response;
        HttpSession         session = req.getSession(false);
        String              uri     = req.getRequestURI();

        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        // Chưa đăng nhập → về trang login
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?next=" + uri);
            return;
        }

        String role = loggedUser.getRole();

        // ── Phân quyền chi tiết cho /admin/* ────────────────────────
        if (uri.contains("/admin/")) {

            // Chỉ user thường không được vào admin
            if ("user".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Mod bị chặn các trang chỉ admin mới vào được
            if ("mod".equals(role)) {
                boolean allowed =
                        uri.contains("/admin/products") ||
                                uri.contains("/admin/orders");

                if (!allowed) {
                    // Redirect mod về trang mặc định của mod
                    resp.sendRedirect(req.getContextPath() + "/admin/products");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }
}