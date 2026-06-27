package com.caycanhweb.servlet;

import com.caycanhweb.dao.ProductDAO;
import com.caycanhweb.model.CartItem;
import com.caycanhweb.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Hiển thị trang giỏ hàng
        req.getRequestDispatcher("/views/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        switch (action == null ? "" : action) {

            case "add" -> {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity  = parseIntOrOne(req.getParameter("quantity"));

                Product p = productDAO.getById(productId);
                if (p != null) {
                    boolean found = false;
                    for (CartItem item : cart) {
                        if (item.getProductId() == productId) {
                            item.setQuantity(item.getQuantity() + quantity);
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        cart.add(new CartItem(
                                p.getProductId(),
                                p.getName(),
                                p.getMainImage(),
                                p.getDisplayPrice(),
                                quantity));
                    }
                }
                // AJAX trả về số lượng sản phẩm trong giỏ
                if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                    resp.setContentType("application/json");
                    resp.getWriter().write("{\"cartCount\":" + cart.size() + "}");
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/cart");
            }

            case "update" -> {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity  = Integer.parseInt(req.getParameter("quantity"));
                if (quantity <= 0) {
                    cart.removeIf(i -> i.getProductId() == productId);
                } else {
                    for (CartItem item : cart) {
                        if (item.getProductId() == productId) {
                            item.setQuantity(quantity);
                            break;
                        }
                    }
                }
                // Tính lại tổng tiền để trả về AJAX
                long total = cart.stream().mapToLong(CartItem::getSubtotal).sum();
                if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                    resp.setContentType("application/json");
                    resp.getWriter().write("{\"total\":" + total + ",\"cartCount\":" + cart.size() + "}");
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/cart");
            }

            case "remove" -> {
                int productId = Integer.parseInt(req.getParameter("productId"));
                cart.removeIf(i -> i.getProductId() == productId);
                resp.sendRedirect(req.getContextPath() + "/cart");
            }

            case "clear" -> {
                cart.clear();
                resp.sendRedirect(req.getContextPath() + "/cart");
            }

            default -> resp.sendRedirect(req.getContextPath() + "/cart");
        }
    }

    private int parseIntOrOne(String s) {
        try { int v = Integer.parseInt(s); return v < 1 ? 1 : v; } catch (Exception e) { return 1; }
    }
}