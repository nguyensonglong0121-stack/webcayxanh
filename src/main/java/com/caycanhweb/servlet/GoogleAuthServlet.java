package com.caycanhweb.servlet;

import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.User;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;

@WebServlet(urlPatterns = {"/auth/google", "/auth/google/callback"})
public class GoogleAuthServlet extends HttpServlet {

    // ⚠️ Thay bằng Client ID và Client Secret từ Google Cloud Console
    private static final String CLIENT_ID     = "923648379028-4de1dn9ug14nk5jp2it8euufhlduqlpo.apps.googleusercontent.com";
    private static final String CLIENT_SECRET = "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";
    private static final String REDIRECT_URI  = "http://localhost:8080/CayCanhWeb/auth/google/callback";

    private static final NetHttpTransport HTTP_TRANSPORT = new NetHttpTransport();
    private static final GsonFactory      JSON_FACTORY   = GsonFactory.getDefaultInstance();

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        if (uri.endsWith("/auth/google")) {
            // ── Bước 1: Redirect đến trang đăng nhập Google ──
            String googleAuthUrl =
                    "https://accounts.google.com/o/oauth2/v2/auth" +
                            "?client_id="     + CLIENT_ID +
                            "&redirect_uri="  + REDIRECT_URI +
                            "&response_type=code" +
                            "&scope=openid%20email%20profile" +
                            "&access_type=offline";

            resp.sendRedirect(googleAuthUrl);

        } else if (uri.endsWith("/auth/google/callback")) {
            // ── Bước 2: Nhận code từ Google ──────────────────
            String code  = req.getParameter("code");
            String error = req.getParameter("error");

            if (error != null || code == null) {
                resp.sendRedirect(req.getContextPath() + "/login?error=google_cancelled");
                return;
            }

            try {
                // Đổi authorization code lấy token
                GoogleTokenResponse tokenResponse =
                        new GoogleAuthorizationCodeTokenRequest(
                                HTTP_TRANSPORT, JSON_FACTORY,
                                "https://oauth2.googleapis.com/token",
                                CLIENT_ID, CLIENT_SECRET,
                                code, REDIRECT_URI
                        ).execute();

                String idTokenStr = tokenResponse.getIdToken();

                // Verify ID token để lấy thông tin user
                GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                        HTTP_TRANSPORT, JSON_FACTORY)
                        .setAudience(Collections.singletonList(CLIENT_ID))
                        .build();

                GoogleIdToken idToken = verifier.verify(idTokenStr);

                if (idToken == null) {
                    resp.sendRedirect(req.getContextPath() + "/login?error=google_failed");
                    return;
                }

                // Lấy thông tin từ payload
                GoogleIdToken.Payload payload = idToken.getPayload();
                String googleId = payload.getSubject();
                String email    = payload.getEmail();
                String fullName = (String) payload.get("name");

                // Đăng nhập hoặc tạo tài khoản mới
                User user = userDAO.loginOrRegisterGoogle(googleId, email, fullName);

                if (user != null) {
                    HttpSession session = req.getSession();
                    session.setAttribute("loggedUser", user);
                    session.setMaxInactiveInterval(60 * 60);

                    if ("admin".equals(user.getRole())) {
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/home");
                    }
                } else {
                    resp.sendRedirect(req.getContextPath() + "/login?error=google_failed");
                }

            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/login?error=google_error");
            }
        }
    }
}