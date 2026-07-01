package com.caycanhweb.servlet;

import com.caycanhweb.dao.CategoryDAO;
import com.caycanhweb.dao.ProductDAO;
import com.caycanhweb.dao.ReviewDAO;
import com.caycanhweb.model.Product;
import com.caycanhweb.model.Review;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/products", "/product"})
public class ProductServlet extends HttpServlet {

    private final ProductDAO  productDAO  = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ReviewDAO   reviewDAO   = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        if (uri.endsWith("/product")) {
            // ── Chi tiết sản phẩm ──
            showDetail(req, resp);
        } else {
            // ── Danh sách / tìm kiếm ──
            showList(req, resp);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword    = req.getParameter("keyword") == null ? "" : req.getParameter("keyword").trim();
        int    categoryId = parseIntOrZero(req.getParameter("cat"));
        String sort       = req.getParameter("sort") == null ? "newest" : req.getParameter("sort");
        int    page       = parseIntOrOne(req.getParameter("page"));
        int    pageSize   = 9;

        int total     = productDAO.countSearch(keyword, categoryId);
        int totalPage = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("products",   productDAO.search(keyword, categoryId, sort, page, pageSize));
        req.setAttribute("categories", categoryDAO.getAll());
        req.setAttribute("keyword",    keyword);
        req.setAttribute("categoryId", categoryId);
        req.setAttribute("sort",       sort);
        req.setAttribute("page",       page);
        req.setAttribute("totalPage",  totalPage);
        req.setAttribute("total",      total);

        req.getRequestDispatcher("/views/product-list.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int     id      = parseIntOrZero(req.getParameter("id"));
        Product product = productDAO.getById(id);

        if (product == null) {
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        req.setAttribute("product",        product);
        req.setAttribute("relatedProducts", productDAO.getRelated(product.getCategoryId(), id, 4));

        // ── Danh sách đánh giá của sản phẩm ──────────────────────
        List<Review> reviews = reviewDAO.getByProductId(id);
        req.setAttribute("reviews",      reviews);
        req.setAttribute("reviewCount",  reviews.size());

        // ── Nếu user đã đăng nhập: kiểm tra họ đã đánh giá chưa (để prefill form) ──
        HttpSession session = req.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser != null) {
            Review myReview = reviewDAO.getUserReview(id, loggedUser.getUserId());
            req.setAttribute("myReview", myReview);
        }

        // ── Thông báo flash sau khi submit đánh giá (nếu có) ─────
        if (session != null) {
            req.setAttribute("reviewSuccess", session.getAttribute("reviewSuccess"));
            req.setAttribute("reviewError",   session.getAttribute("reviewError"));
            session.removeAttribute("reviewSuccess");
            session.removeAttribute("reviewError");
        }

        req.getRequestDispatcher("/views/product-detail.jsp").forward(req, resp);
    }

    // ── Helpers ──────────────────────────────────────────────────
    private int parseIntOrZero(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return 0; }
    }

    private int parseIntOrOne(String s) {
        try { int v = Integer.parseInt(s); return v < 1 ? 1 : v; } catch (Exception e) { return 1; }
    }
}