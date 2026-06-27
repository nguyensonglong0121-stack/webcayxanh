package com.caycanhweb.servlet;

import com.caycanhweb.dao.CategoryDAO;
import com.caycanhweb.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = {"", "/home"})
public class HomeServlet extends HttpServlet {

    private final ProductDAO  productDAO  = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("featuredProducts", productDAO.getFeatured(8));
        req.setAttribute("newestProducts",   productDAO.getNewest(8));
        req.setAttribute("categories",       categoryDAO.getAll());

        req.getRequestDispatcher("/views/home.jsp").forward(req, resp);
    }
}