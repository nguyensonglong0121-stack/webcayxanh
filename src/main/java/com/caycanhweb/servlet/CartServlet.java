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
                String warning = null;

                if (p != null) {
                    boolean found = false;
                    for (CartItem item : cart) {
                        if (item.getProductId() == productId) {
                            int newQty = item.getQuantity() + quantity;
                            if (newQty > p.getStock()) {
                                newQty  = p.getStock();
                                warning = "Kho chỉ còn " + p.getStock() + " \"" + p.getName()
                                        + "\" — đã cập nhật số lượng tối đa có thể.";
                            }
                            item.setQuantity(newQty);
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        int qtyToAdd = quantity;
                        if (qtyToAdd > p.getStock()) {
                            qtyToAdd = p.getStock();
                            warning = "Kho chỉ còn " + p.getStock() + " \"" + p.getName()
                                    + "\" — đã thêm số lượng tối đa có thể.";
                        }
                        if (qtyToAdd > 0) {
                            cart.add(new CartItem(
                                    p.getProductId(),
                                    p.getName(),
                                    p.getMainImage(),
                                    p.getDisplayPrice(),
                                    qtyToAdd));
                        } else {
                            warning = "\"" + p.getName() + "\" hiện đã hết hàng.";
                        }
                    }
                }
                // AJAX trả về số lượng sản phẩm trong giỏ
                if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                    resp.setContentType("application/json");
                    String warnJson = warning != null ? ",\"warning\":\"" + escapeJson(warning) + "\"" : "";
                    resp.getWriter().write("{\"cartCount\":" + cart.size() + warnJson + "}");
                    return;
                }
                String redirectUrl = req.getContextPath() + "/cart";
                if (warning != null) {
                    redirectUrl += "?warning=" + java.net.URLEncoder.encode(warning, java.nio.charset.StandardCharsets.UTF_8);
                }
                resp.sendRedirect(redirectUrl);
            }

            case "update" -> {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity  = Integer.parseInt(req.getParameter("quantity"));
                long itemSubtotal = 0;
                String warning = null;

                if (quantity > 0) {
                    Product p = productDAO.getById(productId);
                    if (p != null && quantity > p.getStock()) {
                        warning  = "Kho chỉ còn " + p.getStock() + " \"" + p.getName() + "\".";
                        quantity = p.getStock(); // có thể về 0 nếu vừa hết hàng
                    }
                }

                if (quantity <= 0) {
                    cart.removeIf(i -> i.getProductId() == productId);
                    quantity = 0;
                } else {
                    for (CartItem item : cart) {
                        if (item.getProductId() == productId) {
                            item.setQuantity(quantity);
                            itemSubtotal = item.getSubtotal();
                            break;
                        }
                    }
                }
                // Tính lại tổng tiền để trả về AJAX
                long total = cart.stream().mapToLong(CartItem::getSubtotal).sum();
                if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                    resp.setContentType("application/json");
                    String warnJson = warning != null ? ",\"warning\":\"" + escapeJson(warning) + "\"" : "";
                    resp.getWriter().write("{\"total\":" + total
                            + ",\"cartCount\":" + cart.size()
                            + ",\"quantity\":" + quantity
                            + ",\"itemSubtotal\":" + itemSubtotal + warnJson + "}");
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

    // Escape ký tự đặc biệt để chèn an toàn vào chuỗi JSON viết tay (tránh vỡ JSON
    // nếu tên sản phẩm chứa dấu ngoặc kép hoặc dấu xuống dòng).
    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}