package com.caycanhweb.servlet;

import com.caycanhweb.dao.ReviewDAO;
import com.caycanhweb.model.Review;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/review"})
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        int productId = parseIntOrZero(req.getParameter("productId"));

        // ── Chưa đăng nhập → về trang login ──────────────────────
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int    rating  = parseIntOrZero(req.getParameter("rating"));
        String comment = req.getParameter("comment");

        // ── Validate ──────────────────────────────────────────────
        if (productId <= 0 || rating < 1 || rating > 5) {
            session.setAttribute("reviewError", "Đánh giá không hợp lệ. Vui lòng chọn từ 1 đến 5 sao.");
            resp.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#tab-review");
            return;
        }

        if (comment != null) comment = comment.trim();

        Review review = new Review(productId, loggedUser.getUserId(), rating, comment);
        boolean ok = reviewDAO.insertOrUpdate(review);

        session.setAttribute("reviewSuccess", ok
                ? "Cảm ơn bạn đã đánh giá sản phẩm!"
                : null);
        if (!ok) {
            session.setAttribute("reviewError", "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#tab-review");
    }

    private int parseIntOrZero(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return 0; }
    }
}