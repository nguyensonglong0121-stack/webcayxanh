package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("detail".equals(action)) {
            req.setAttribute("order", orderDAO.getById(Integer.parseInt(req.getParameter("id"))));
            req.getRequestDispatcher("/admin/order-detail.jsp").forward(req, resp);
        } else if ("updateStatus".equals(action)) {
            orderDAO.updateStatus(Integer.parseInt(req.getParameter("id")), req.getParameter("status"));
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        } else {
            String status = req.getParameter("status");
            if (status != null && !status.isEmpty()) {
                req.setAttribute("orders", orderDAO.getByStatus(status));
            } else {
                req.setAttribute("orders", orderDAO.getAll());
            }
            req.getRequestDispatcher("/admin/order-list.jsp").forward(req, resp);
        }
    }
}