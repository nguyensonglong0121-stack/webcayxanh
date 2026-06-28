package com.caycanhweb.util;

import com.caycanhweb.dao.PermissionDAO;
import com.caycanhweb.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/checkout", "/profile", "/orders"})
public class AuthFilter implements Filter {

    private final PermissionDAO permissionDAO = new PermissionDAO();

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

        String role   = loggedUser.getRole();
        int    userId = loggedUser.getUserId();

        if (uri.contains("/admin/")) {
            // User thường không được vào admin
            if ("user".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Admin được vào tất cả
            if ("admin".equals(role)) {
                chain.doFilter(request, response);
                return;
            }

            // Mod + user có quyền → kiểm tra permission chi tiết
            if ("mod".equals(role)) {
                boolean allowed = false;

                if (uri.contains("/admin/products")) {
                    allowed = permissionDAO.hasPermission(userId, "products");
                } else if (uri.contains("/admin/orders")) {
                    allowed = permissionDAO.hasPermission(userId, "orders");
                } else if (uri.contains("/admin/users")) {
                    allowed = permissionDAO.hasPermission(userId, "users");
                } else if (uri.contains("/admin/dashboard")) {
                    allowed = false; // Mod không xem dashboard
                }

                // Cho phép vào trang no-permission (tránh redirect loop)
                if (uri.contains("/admin/no-permission")) {
                    chain.doFilter(request, response);
                    return;
                }

                if (!allowed) {
                    resp.sendRedirect(req.getContextPath() + "/admin/no-permission");
                    return;
                }
                if (!allowed) {
                    // Redirect về trang đầu tiên mod có quyền
                    resp.sendRedirect(req.getContextPath() + "/admin/no-permission");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }
}