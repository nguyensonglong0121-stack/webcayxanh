package com.caycanhweb.servlet;

import com.caycanhweb.dao.CouponDAO;
import com.caycanhweb.dao.OrderDAO;
import com.caycanhweb.dao.ProductDAO;
import com.caycanhweb.model.CartItem;
import com.caycanhweb.model.Coupon;
import com.caycanhweb.model.Order;
import com.caycanhweb.model.OrderItem;
import com.caycanhweb.model.Product;
import com.caycanhweb.model.User;
import com.caycanhweb.util.GHNService;
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
    private final CouponDAO couponDAO = new CouponDAO();
    private final ProductDAO productDAO = new ProductDAO();

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

        // ── Kiểm tra lại tồn kho NGAY LÚC ĐẶT HÀNG (không tin số lượng đã
        //    thêm vào giỏ từ trước — tồn kho có thể đã đổi vì người khác mua
        //    trước, hoặc admin vừa chỉnh sửa). Đây là chốt chặn cuối cùng,
        //    quan trọng nhất vì là bước ngay trước khi tạo đơn thật. ──
        StringBuilder stockError = new StringBuilder();
        for (CartItem c : cart) {
            Product p = productDAO.getById(c.getProductId());
            if (p == null) {
                stockError.append("Sản phẩm \"").append(c.getProductName()).append("\" không còn tồn tại. ");
            } else if (c.getQuantity() > p.getStock()) {
                stockError.append("\"").append(p.getName()).append("\" chỉ còn ")
                        .append(p.getStock()).append(" (giỏ hàng đang đặt ")
                        .append(c.getQuantity()).append("). ");
            }
        }
        if (stockError.length() > 0) {
            req.setAttribute("error", "Giỏ hàng có thay đổi về tồn kho: " + stockError
                    + "Vui lòng quay lại giỏ hàng để cập nhật số lượng.");
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
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

        // ── Lấy thông tin địa chỉ GHN (bắt buộc để tự tính phí ship) ──
        int districtId;
        try {
            districtId = Integer.parseInt(req.getParameter("district_id"));
        } catch (NumberFormatException | NullPointerException e) {
            districtId = 0;
        }
        String wardCode = req.getParameter("ward_code");

        if (districtId <= 0 || wardCode == null || wardCode.isBlank()) {
            req.setAttribute("error", "Vui lòng chọn đầy đủ Tỉnh/Quận/Phường để tính phí vận chuyển!");
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
            return;
        }

        // ── Tính tiền hàng ─────────────────────────────────
        long subtotal = cart.stream().mapToLong(CartItem::getSubtotal).sum();

        // ── Phí ship: LUÔN tự tính lại ở server bằng GHNService, KHÔNG
        //    dùng giá trị "shippingFee" mà client gửi lên (hidden input đó
        //    chỉ để hiển thị preview cho người dùng xem trước, có thể bị
        //    sửa qua DevTools nên không được tin để tính tiền thật). ──
        long shippingFee = GHNService.calculateFee(districtId, wardCode, GHNService.DEFAULT_WEIGHT_GRAM);
        if (shippingFee <= 0) {
            // calculateFee trả 0 cả khi gọi GHN thất bại lẫn khi phí thật sự = 0
            // (GHN không có phí ship = 0đ) → coi 0 là lỗi, không cho đặt hàng
            // free ship ngoài ý muốn do API lỗi tạm thời.
            req.setAttribute("error", "Không tính được phí vận chuyển cho địa chỉ này, vui lòng thử lại!");
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
            return;
        }

        // ── Mã giảm giá: LUÔN validate + tính lại discount ở server bằng
        //    CouponDAO, KHÔNG tin bất kỳ số tiền giảm nào gửi từ client. ──
        long discount = 0;
        if (!couponCode.isEmpty()) {
            Coupon coupon = couponDAO.findByCode(couponCode);
            if (coupon == null || !coupon.isCurrentlyValid()) {
                req.setAttribute("error", "Mã giảm giá \"" + couponCode + "\" không hợp lệ hoặc đã hết hạn!");
                req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
                return;
            }
            discount = coupon.calculateDiscount(subtotal);
            if (discount <= 0) {
                req.setAttribute("error", "Đơn hàng chưa đạt giá trị tối thiểu để dùng mã \"" + couponCode + "\"!");
                req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
                return;
            }
        }

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
            if (!couponCode.isEmpty()) {
                couponDAO.incrementUsedCount(couponCode);
            }
            session.removeAttribute("cart");
            resp.sendRedirect(req.getContextPath() + "/order-success?id=" + orderId);
        } else {
            req.setAttribute("error", "Đặt hàng thất bại, vui lòng thử lại!");
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        }
    }
}