package com.caycanhweb.servlet;

import com.caycanhweb.dao.WishlistDAO;
import com.caycanhweb.model.User;
import com.caycanhweb.model.WishlistItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/wishlist")
public class WishlistServlet extends HttpServlet {

    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session    = req.getSession(false);
        User        loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login?next=" + req.getContextPath() + "/wishlist");
            return;
        }

        List<WishlistItem> wishlist = wishlistDAO.getByUser(loggedUser.getUserId());
        req.setAttribute("wishlist", wishlist);
        req.getRequestDispatcher("/views/wishlist.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session    = req.getSession(false);
        User        loggedUser = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        boolean     isAjax     = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

        if (loggedUser == null) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json");
                resp.getWriter().write("{\"error\":\"not_logged_in\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        String action    = req.getParameter("action");
        int    userId    = loggedUser.getUserId();
        int    productId = Integer.parseInt(req.getParameter("productId"));

        boolean added;

        switch (action == null ? "" : action) {

            case "toggle" -> {
                if (wishlistDAO.isInWishlist(userId, productId)) {
                    wishlistDAO.remove(userId, productId);
                    added = false;
                } else {
                    wishlistDAO.add(userId, productId);
                    added = true;
                }
                if (isAjax) {
                    resp.setContentType("application/json");
                    resp.getWriter().write("{\"added\":" + added +
                            ",\"count\":" + wishlistDAO.countByUser(userId) + "}");
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/wishlist");
            }

            case "remove" -> {
                wishlistDAO.remove(userId, productId);
                if (isAjax) {
                    resp.setContentType("application/json");
                    resp.getWriter().write("{\"added\":false,\"count\":" + wishlistDAO.countByUser(userId) + "}");
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/wishlist");
            }

            default -> resp.sendRedirect(req.getContextPath() + "/wishlist");
        }
    }
}