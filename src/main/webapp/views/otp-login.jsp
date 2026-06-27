package com.caycanhweb.servlet;

import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.User;
import com.caycanhweb.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Random;

@WebServlet("/otp-login")
public class OtpServlet extends HttpServlet {

private final UserDAO userDAO = new UserDAO();

@Override
protected void doGet(HttpServletRequest req, HttpServletResponse resp)
throws ServletException, IOException {
// Hiển thị form nhập email để gửi OTP
String step = req.getParameter("step");
req.setAttribute("step", step == null ? "email" : step);
req.getRequestDispatcher("/views/otp-login.jsp").forward(req, resp);
}

@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp)
throws ServletException, IOException {

req.setCharacterEncoding("UTF-8");
String step = req.getParameter("step");

if ("sendOTP".equals(step)) {
// ── Bước 1: Gửi OTP ──────────────────────
String email = req.getParameter("email").trim();

// Kiểm tra email có tồn tại trong DB không
User user = userDAO.getByEmail(email);
if (user == null) {
req.setAttribute("error", "Email này chưa được đăng ký!");
req.setAttribute("step", "email");
req.getRequestDispatcher("/views/otp-login.jsp").forward(req, resp);
return;
}

// Tạo OTP 6 số ngẫu nhiên
String otp = String.format("%06d", new Random().nextInt(999999));

// Lưu OTP vào DB (có hạn 5 phút)
boolean saved = userDAO.saveOTP(email, otp);
if (!saved) {
req.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại!");
req.setAttribute("step", "email");
req.getRequestDispatcher("/views/otp-login.jsp").forward(req, resp);
return;
}

// Gửi email
boolean sent = EmailService.sendOTP(email, otp);
if (!sent) {
req.setAttribute("error", "Không thể gửi email. Kiểm tra lại cấu hình Gmail!");
req.setAttribute("step", "email");
req.getRequestDispatcher("/views/otp-login.jsp").forward(req, resp);
return;
}

// Lưu email vào session để dùng ở bước 2
req.getSession().setAttribute("otpEmail", email);

// Chuyển sang bước nhập OTP
req.setAttribute("step",    "verify");
req.setAttribute("email",   email);
req.setAttribute("success", "Mã OTP đã được gửi đến " + maskEmail(email));
req.getRequestDispatcher("/views/otp-login.jsp").forward(req, resp);

} else if ("verifyOTP".equals(step)) {
// ── Bước 2: Xác thực OTP ─────────────────
HttpSession session = req.getSession();
String email = (String) session.getAttribute("otpEmail");
String otp   = req.getParameter("otp").trim();

if (email == null) {
resp.sendRedirect(req.getContextPath() + "/otp-login");
return;
}

User user = userDAO.verifyOTP(email, otp);
if (user == null) {
req.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn!");
req.setAttribute("step",  "verify");
req.setAttribute("email", email);
req.getRequestDispatcher("/views/otp-login.jsp").forward(req, resp);
return;
}

// Đăng nhập thành công
session.setAttribute("loggedUser", user);
session.removeAttribute("otpEmail");
session.setMaxInactiveInterval(60 * 60);

String next = req.getParameter("next");
if ("admin".equals(user.getRole())) {
resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
} else if (next != null && !next.isBlank()) {
resp.sendRedirect(next);
} else {
resp.sendRedirect(req.getContextPath() + "/home");
}
}
}

// Ẩn email: nguyenvanan@gmail.com → ng*****n@gmail.com
private String maskEmail(String email) {
int at = email.indexOf('@');
if (at <= 2) return email;
return email.charAt(0) + "*****" + email.charAt(at - 1) + email.substring(at);
}
}