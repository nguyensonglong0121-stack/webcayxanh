package com.caycanhweb.servlet;

import com.caycanhweb.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/order-success")
public class OrderSuccessServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int orderId = 0;
        try { orderId = Integer.parseInt(req.getParameter("id")); } catch (Exception ignored) {}
        req.setAttribute("order", orderDAO.getById(orderId));
        req.getRequestDispatcher("/views/order-success.jsp").forward(req, resp);
    }
}