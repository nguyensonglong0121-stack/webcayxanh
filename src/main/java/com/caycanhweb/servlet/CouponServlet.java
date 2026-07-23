package com.caycanhweb.servlet;

import com.caycanhweb.dao.CouponDAO;
import com.caycanhweb.model.Coupon;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Endpoint AJAX dùng để KIỂM TRA (preview) mã giảm giá — KHÔNG dùng kết quả
 * này để trừ tiền cuối cùng. Việc tính discount thật sự khi đặt hàng luôn
 * được CheckoutServlet tính lại từ đầu ở phía server (không tin giá trị
 * discount mà client gửi lên), cùng lý do với việc không tin shippingFee
 * gửi từ client.
 *
 * GET /coupon/check?code=XANH10&subtotal=350000
 * → {"valid":true,"discount":35000,"message":"Áp dụng thành công! Giảm 35.000đ"}
 * → {"valid":false,"discount":0,"message":"Mã không tồn tại hoặc đã hết hạn"}
 */
@WebServlet("/coupon/check")
public class CouponServlet extends HttpServlet {

    private final CouponDAO couponDAO = new CouponDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");

        String code = req.getParameter("code");
        long subtotal;
        try {
            subtotal = Long.parseLong(req.getParameter("subtotal"));
        } catch (NumberFormatException | NullPointerException e) {
            subtotal = 0;
        }

        if (code == null || code.isBlank()) {
            writeJson(resp, false, 0, "Vui lòng nhập mã giảm giá");
            return;
        }

        Coupon coupon = couponDAO.findByCode(code.trim());

        if (coupon == null) {
            writeJson(resp, false, 0, "Mã giảm giá không tồn tại");
            return;
        }
        if (!coupon.isCurrentlyValid()) {
            writeJson(resp, false, 0, "Mã giảm giá đã hết hạn hoặc ngừng áp dụng");
            return;
        }

        long discount = coupon.calculateDiscount(subtotal);
        if (discount <= 0) {
            String need = String.format("%,d", coupon.getMinOrderValue()).replace(',', '.');
            writeJson(resp, false, 0, "Đơn hàng cần tối thiểu " + need + "đ để dùng mã này");
            return;
        }

        String formatted = String.format("%,d", discount).replace(',', '.');
        writeJson(resp, true, discount, "Áp dụng thành công! Giảm " + formatted + "đ");
    }

    private void writeJson(HttpServletResponse resp, boolean valid, long discount, String message)
            throws IOException {
        String safeMessage = message.replace("\"", "\\\"");
        resp.getWriter().write(String.format(
                "{\"valid\":%s,\"discount\":%d,\"message\":\"%s\"}",
                valid, discount, safeMessage));
    }
}
