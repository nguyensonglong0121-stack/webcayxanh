package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.UserDAO;
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
        if ("toggle".equals(req.getParameter("action"))) {
            userDAO.setActive(
                    Integer.parseInt(req.getParameter("id")),
                    "true".equals(req.getParameter("active"))
            );
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } else {
            req.setAttribute("users", userDAO.getAll());
            req.getRequestDispatcher("/admin/user-list.jsp").forward(req, resp);
        }
    }
}