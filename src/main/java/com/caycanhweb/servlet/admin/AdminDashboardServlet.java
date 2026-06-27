package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.OrderDAO;
import com.caycanhweb.dao.ProductDAO;
import com.caycanhweb.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private final OrderDAO   orderDAO   = new OrderDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final UserDAO    userDAO    = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("totalRevenue",          orderDAO.getTotalRevenue());
        req.setAttribute("totalRevenueFormatted", String.format("%,d", orderDAO.getTotalRevenue()).replace(',', '.'));
        req.setAttribute("pendingOrders",         orderDAO.countByStatus("pending"));
        req.setAttribute("doneOrders",            orderDAO.countByStatus("done"));
        req.setAttribute("recentOrders",          orderDAO.getAll());
        req.setAttribute("totalUsers",            userDAO.getAll().size());
        req.setAttribute("totalProducts",         productDAO.getAll().size());
        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }
}