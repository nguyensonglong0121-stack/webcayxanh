package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.CategoryDAO;
import com.caycanhweb.dao.ProductDAO;
import com.caycanhweb.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {
    private final ProductDAO  productDAO  = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            req.setAttribute("product",    productDAO.getById(id));
            req.setAttribute("categories", categoryDAO.getAll());
            req.getRequestDispatcher("/admin/product-form.jsp").forward(req, resp);
        } else if ("delete".equals(action)) {
            productDAO.delete(Integer.parseInt(req.getParameter("id")));
            resp.sendRedirect(req.getContextPath() + "/admin/products?deleted=1");
        } else if ("new".equals(action)) {
            req.setAttribute("categories", categoryDAO.getAll());
            req.getRequestDispatcher("/admin/product-form.jsp").forward(req, resp);
        } else {
            req.setAttribute("products",   productDAO.getAll());
            req.setAttribute("categories", categoryDAO.getAll());
            req.getRequestDispatcher("/admin/product-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        Product p = new Product();
        p.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
        p.setName(req.getParameter("name").trim());
        p.setPrice(Long.parseLong(req.getParameter("price").replaceAll("[^0-9]", "")));
        String saleStr = req.getParameter("salePrice").replaceAll("[^0-9]", "");
        p.setSalePrice(saleStr.isEmpty() ? 0 : Long.parseLong(saleStr));
        p.setStock(Integer.parseInt(req.getParameter("stock")));
        p.setDescription(req.getParameter("description"));
        p.setCareTips(req.getParameter("careTips"));
        p.setMainImage(req.getParameter("mainImage").isBlank() ? "default.jpg" : req.getParameter("mainImage").trim());
        p.setFeatured("on".equals(req.getParameter("isFeatured")));
        p.setStatus(req.getParameter("status"));
        if ("insert".equals(action)) {
            productDAO.insert(p);
        } else {
            p.setProductId(Integer.parseInt(req.getParameter("productId")));
            productDAO.update(p);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }
}