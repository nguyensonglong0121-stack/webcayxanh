package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // Chặn mod vào trang này
        User loggedUser = (User) req.getSession().getAttribute("loggedUser");
        if ("mod".equals(loggedUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        if ("toggle".equals(action)) {
            // Khóa / mở tài khoản
            int     id     = Integer.parseInt(req.getParameter("id"));
            boolean active = "true".equals(req.getParameter("active"));
            userDAO.setActive(id, active);
            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } else if ("setRole".equals(action)) {
            // Phân quyền role
            int    id   = Integer.parseInt(req.getParameter("id"));
            String role = req.getParameter("role");

            // Chỉ cho phép set role hợp lệ
            if (role.equals("user") || role.equals("mod") || role.equals("admin")) {
                userDAO.setRole(id, role);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users?updated=1");

        } else {
            req.setAttribute("users", userDAO.getAll());
            req.getRequestDispatcher("/admin/user-list.jsp").forward(req, resp);
        }
    }
}