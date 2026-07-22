package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.InventoryDAO;
import com.caycanhweb.dao.ProductDAO;
import com.caycanhweb.model.Product;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/inventory")
public class AdminInventoryServlet extends HttpServlet {

    private static final int LOW_STOCK_THRESHOLD = 5;
    private static final int PAGE_SIZE            = 20;

    private final ProductDAO   productDAO   = new ProductDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("form".equals(action)) {
            // Form nhập / xuất / điều chỉnh cho 1 sản phẩm + lịch sử của nó
            int id = Integer.parseInt(req.getParameter("id"));
            Product product = productDAO.getById(id);
            if (product == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/inventory");
                return;
            }
            req.setAttribute("product", product);
            req.setAttribute("history", inventoryDAO.getHistoryByProduct(id));
            req.getRequestDispatcher("/admin/inventory-form.jsp").forward(req, resp);
            return;
        }

        if ("history".equals(action)) {
            // Lịch sử nhập/xuất toàn hệ thống
            String type    = req.getParameter("type");
            String keyword = req.getParameter("keyword");
            int    page    = parseIntOrDefault(req.getParameter("page"), 1);

            List<?> history = inventoryDAO.getAllHistory(type, keyword, page, PAGE_SIZE);
            int total       = inventoryDAO.countAllHistory(type, keyword);

            req.setAttribute("history",   history);
            req.setAttribute("total",     total);
            req.setAttribute("page",      page);
            req.setAttribute("totalPages", Math.max(1, (int) Math.ceil(total / (double) PAGE_SIZE)));
            req.setAttribute("type",      type);
            req.setAttribute("keyword",   keyword);
            req.getRequestDispatcher("/admin/inventory-history.jsp").forward(req, resp);
            return;
        }

        // Trang tổng quan tồn kho
        String keyword = req.getParameter("keyword");
        String filter  = req.getParameter("filter"); // low | out | null(all)

        List<Product> products = productDAO.getAll();
        if (keyword != null && !keyword.isBlank()) {
            String kw = keyword.toLowerCase();
            products = products.stream()
                    .filter(p -> p.getName().toLowerCase().contains(kw))
                    .toList();
        }
        if ("low".equals(filter)) {
            products = products.stream()
                    .filter(p -> p.getStock() > 0 && p.getStock() <= LOW_STOCK_THRESHOLD)
                    .toList();
        } else if ("out".equals(filter)) {
            products = products.stream().filter(p -> p.getStock() == 0).toList();
        }

        req.setAttribute("products",  products);
        req.setAttribute("summary",   inventoryDAO.getSummary(LOW_STOCK_THRESHOLD));
        req.setAttribute("threshold", LOW_STOCK_THRESHOLD);
        req.setAttribute("keyword",   keyword);
        req.setAttribute("filter",    filter);
        req.getRequestDispatcher("/admin/inventory-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        int    productId = Integer.parseInt(req.getParameter("productId"));
        String note       = req.getParameter("note");

        HttpSession session = req.getSession(false);
        User loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        Integer userId = (loggedUser != null) ? loggedUser.getUserId() : null;

        boolean ok;
        switch (action) {
            case "import" -> {
                int qty = Integer.parseInt(req.getParameter("quantity"));
                ok = qty > 0 && inventoryDAO.importStock(productId, qty, note, userId);
            }
            case "export" -> {
                int qty = Integer.parseInt(req.getParameter("quantity"));
                ok = qty > 0 && inventoryDAO.exportStock(productId, qty, note, userId);
            }
            case "adjust" -> {
                int newStock = Integer.parseInt(req.getParameter("newStock"));
                ok = newStock >= 0 && inventoryDAO.adjustStock(productId, newStock, note, userId);
            }
            default -> ok = false;
        }

        String redirect = req.getContextPath() + "/admin/inventory?action=form&id=" + productId
                + (ok ? "&success=1" : "&error=1");
        resp.sendRedirect(redirect);
    }

    private int parseIntOrDefault(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
