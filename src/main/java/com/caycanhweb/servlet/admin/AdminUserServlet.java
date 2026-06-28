package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.PermissionDAO;
import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.Permission;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDAO       userDAO       = new UserDAO();
    private final PermissionDAO permissionDAO = new PermissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Chỉ admin được vào
        User loggedUser = (User) req.getSession().getAttribute("loggedUser");
        if (!"admin".equals(loggedUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        String action = req.getParameter("action");

        if ("toggle".equals(action)) {
            int     id     = Integer.parseInt(req.getParameter("id"));
            boolean active = "true".equals(req.getParameter("active"));
            userDAO.setActive(id, active);
            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } else if ("setRole".equals(action)) {
            int    id   = Integer.parseInt(req.getParameter("id"));
            String role = req.getParameter("role");
            if (role.equals("user") || role.equals("mod") || role.equals("admin")) {
                userDAO.setRole(id, role);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } else {
            // Load danh sách user + permission của từng người
            List<User> users = userDAO.getAll();

            // Map userId → Permission
            Map<Integer, Permission> permMap = new HashMap<>();
            for (User u : users) {
                permMap.put(u.getUserId(), permissionDAO.getByUserId(u.getUserId()));
            }

            req.setAttribute("users",   users);
            req.setAttribute("permMap", permMap);
            req.getRequestDispatcher("/admin/user-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // Chỉ admin được vào
        User loggedUser = (User) req.getSession().getAttribute("loggedUser");
        if (!"admin".equals(loggedUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        String action = req.getParameter("action");

        if ("savePermission".equals(action)) {
            int userId = Integer.parseInt(req.getParameter("userId"));

            Permission p = new Permission();
            p.setUserId(userId);
            p.setCanProducts("on".equals(req.getParameter("can_products")));
            p.setCanOrders("on".equals(req.getParameter("can_orders")));
            p.setCanUsers("on".equals(req.getParameter("can_users")));

            permissionDAO.save(p);
            resp.sendRedirect(req.getContextPath() + "/admin/users?saved=1");
        }
    }
}