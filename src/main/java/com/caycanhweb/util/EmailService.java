package com.caycanhweb.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailService {

    // ⚠️ Thay bằng Gmail và App Password của bạn
    private static final String FROM_EMAIL = "nguyensonglong0121@gmail.com";
    private static final String APP_PASSWORD = "ilxh taat drht elih"; // App Password 16 ký tự

    public static boolean sendOTP(String toEmail, String otp) {
        Properties props = new Properties();
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("🌿 GreenShop — Mã xác thực OTP của bạn");

            // Nội dung email HTML đẹp
            String htmlContent = """
                <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;
                            border:1px solid #e8e0d0;border-radius:12px;overflow:hidden">
                  <div style="background:#1a3a2a;padding:24px;text-align:center">
                    <h1 style="color:#a8d5a2;margin:0;font-size:24px">🌿 GreenShop</h1>
                  </div>
                  <div style="padding:32px;text-align:center">
                    <h2 style="color:#1a3a2a;margin-bottom:8px">Mã xác thực OTP</h2>
                    <p style="color:#6b7280;margin-bottom:24px">
                      Nhập mã dưới đây để đăng nhập vào tài khoản của bạn.
                    </p>
                    <div style="background:#f7f4ef;border:2px dashed #a8d5a2;border-radius:12px;
                                padding:24px;margin-bottom:24px">
                      <span style="font-size:40px;font-weight:900;letter-spacing:12px;
                                   color:#1a3a2a;font-family:monospace">
                        %s
                      </span>
                    </div>
                    <p style="color:#dc2626;font-size:13px">
                      ⏰ Mã có hiệu lực trong <strong>5 phút</strong>
                    </p>
                    <p style="color:#6b7280;font-size:12px;margin-top:16px">
                      Nếu bạn không yêu cầu mã này, hãy bỏ qua email này.
                    </p>
                  </div>
                  <div style="background:#f7f4ef;padding:16px;text-align:center;
                              font-size:12px;color:#6b7280">
                    © 2025 GreenShop — Thiên nhiên trong tầm tay bạn 🌿
                  </div>
                </div>
                """.formatted(otp);

            message.setContent(htmlContent, "text/html; charset=UTF-8");
            Transport.send(message);
            return true;

        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}