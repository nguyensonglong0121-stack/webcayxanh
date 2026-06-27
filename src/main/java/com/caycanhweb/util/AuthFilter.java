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

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession         session = req.getSession(false);

        String uri = req.getRequestURI();

        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        // Chưa đăng nhập → về trang login
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?next=" + uri);
            return;
        }

        // Vào /admin/* mà không phải admin → về trang chủ
        if (uri.contains("/admin/") && !"admin".equals(loggedUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        chain.doFilter(request, response);
    }
}