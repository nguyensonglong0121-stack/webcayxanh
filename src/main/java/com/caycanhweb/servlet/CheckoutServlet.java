package com.caycanhweb.servlet;

import com.caycanhweb.dao.OrderDAO;
import com.caycanhweb.model.CartItem;
import com.caycanhweb.model.Order;
import com.caycanhweb.model.OrderItem;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        @SuppressWarnings("unchecked")
        List<CartItem> cart = session != null ? (List<CartItem>) session.getAttribute("cart") : null;

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session  = req.getSession(false);
        User loggedUser      = session != null ? (User) session.getAttribute("loggedUser") : null;

        @SuppressWarnings("unchecked")
        List<CartItem> cart  = session != null ? (List<CartItem>) session.getAttribute("cart") : null;

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // ── Lấy thông tin form (null-safe) ───────────────
        String receiverName  = req.getParameter("receiverName")  != null ? req.getParameter("receiverName").trim()  : "";
        String receiverPhone = req.getParameter("receiverPhone") != null ? req.getParameter("receiverPhone").trim() : "";
        String streetAddress = req.getParameter("streetAddress") != null ? req.getParameter("streetAddress").trim() : "";
        String wardName      = req.getParameter("ward_name")     != null ? req.getParameter("ward_name").trim()     : "";
        String districtName  = req.getParameter("district_name") != null ? req.getParameter("district_name").trim() : "";
        String provinceName  = req.getParameter("province_name") != null ? req.getParameter("province_name").trim() : "";
        String paymentMethod = req.getParameter("paymentMethod") != null ? req.getParameter("paymentMethod")        : "cod";
        String note          = req.getParameter("note")          != null ? req.getParameter("note")                 : "";
        String couponCode    = req.getParameter("couponCode")    != null ? req.getParameter("couponCode").trim()    : "";

        // Ghép địa chỉ đầy đủ
        String fullAddress = streetAddress + ", " + wardName + ", " + districtName + ", " + provinceName;

        // ── Validate ──────────────────────────────────────
        if (receiverName.isEmpty() || receiverPhone.isEmpty() || streetAddress.isEmpty()) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin giao hàng!");
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
            return;
        }

        // ── Tính tiền + phí ship ──────────────────────────
        long subtotal    = cart.stream().mapToLong(CartItem::getSubtotal).sum();
        long discount    = 0;
        long shippingFee = 0;
        try {
            String feeParam = req.getParameter("shippingFee");
            if (feeParam != null && !feeParam.isBlank()) {
                shippingFee = Long.parseLong(feeParam);
            }
        } catch (NumberFormatException ignored) {}

        long total = subtotal - discount + shippingFee;

        // ── Tạo Order ────────────────────────────────────
        Order order = new Order();
        order.setUserId(loggedUser != null ? loggedUser.getUserId() : 0);
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setAddress(fullAddress);
        order.setTotalAmount(total);
        order.setDiscountAmount(discount);
        order.setCouponCode(couponCode.isEmpty() ? null : couponCode);
        order.setPaymentMethod(paymentMethod);
        order.setNote(note);

        // ── Chuyển cart → OrderItem ───────────────────────
        List<OrderItem> items = new ArrayList<>();
        for (CartItem c : cart) {
            items.add(new OrderItem(
                    c.getProductId(),
                    c.getProductName(),
                    c.getQuantity(),
                    c.getUnitPrice()));
        }

        int orderId = orderDAO.createOrder(order, items);

        if (orderId > 0) {
            session.removeAttribute("cart");
            resp.sendRedirect(req.getContextPath() + "/order-success?id=" + orderId);
        } else {
            req.setAttribute("error", "Đặt hàng thất bại, vui lòng thử lại!");
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        }
    }
}