package com.caycanhweb.servlet;

import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.User;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeRequestUrl;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.oauth2.Oauth2;
import com.google.api.services.oauth2.model.Userinfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Arrays;

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
            // ── Bước 1: Redirect đến Google ──────────
            GoogleAuthorizationCodeFlow flow = buildFlow();
            GoogleAuthorizationCodeRequestUrl url = flow.newAuthorizationUrl()
                    .setRedirectUri(REDIRECT_URI)
                    .setState("login");

            resp.sendRedirect(url.build());

        } else if (uri.endsWith("/auth/google/callback")) {
            // ── Bước 2: Google callback ───────────────
            String code  = req.getParameter("code");
            String error = req.getParameter("error");

            if (error != null || code == null) {
                resp.sendRedirect(req.getContextPath() + "/login?error=google_cancelled");
                return;
            }

            try {
                // Đổi code lấy access token
                GoogleTokenResponse tokenResponse = new GoogleAuthorizationCodeTokenRequest(
                        HTTP_TRANSPORT, JSON_FACTORY,
                        CLIENT_ID, CLIENT_SECRET,
                        code, REDIRECT_URI
                ).execute();

                // Lấy thông tin user từ Google
                Oauth2 oauth2 = new Oauth2.Builder(HTTP_TRANSPORT, JSON_FACTORY,
                        flow -> tokenResponse.createCredential(null))
                        .setApplicationName("GreenShop")
                        .build();

                Userinfo googleUser = oauth2.userinfo().get().execute();

                String googleId = googleUser.getId();
                String email    = googleUser.getEmail();
                String name     = googleUser.getName();

                // Đăng nhập hoặc tạo tài khoản mới
                User user = userDAO.loginOrRegisterGoogle(googleId, email, name);

                if (user != null) {
                    req.getSession().setAttribute("loggedUser", user);
                    req.getSession().setMaxInactiveInterval(60 * 60);

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

    private GoogleAuthorizationCodeFlow buildFlow() throws IOException {
        return new GoogleAuthorizationCodeFlow.Builder(
                HTTP_TRANSPORT, JSON_FACTORY,
                CLIENT_ID, CLIENT_SECRET,
                Arrays.asList(
                        "https://www.googleapis.com/auth/userinfo.email",
                        "https://www.googleapis.com/auth/userinfo.profile"
                )
        ).build();
    }
}