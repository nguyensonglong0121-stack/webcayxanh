package com.caycanhweb.servlet;

import com.caycanhweb.dao.OrderDAO;
import com.caycanhweb.dao.UserDAO;
import com.caycanhweb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/profile", "/orders"})
public class ProfileServlet extends HttpServlet {
    private final UserDAO  userDAO  = new UserDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        if (req.getRequestURI().endsWith("/orders")) {
            req.setAttribute("orders", orderDAO.getByUserId(user.getUserId()));
            req.getRequestDispatcher("/views/order-history.jsp").forward(req, resp);
        } else {
            req.setAttribute("user", userDAO.getById(user.getUserId()));
            req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (loggedUser == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }



        if ("updateProfile".equals(req.getParameter("action"))) {
            loggedUser.setFullName(req.getParameter("fullName").trim());
            loggedUser.setPhone(req.getParameter("phone").trim());
            loggedUser.setAddress(req.getParameter("address").trim());
            userDAO.updateProfile(loggedUser);
            session.setAttribute("loggedUser", loggedUser);
            resp.sendRedirect(req.getContextPath() + "/profile?updated=1");
        } else if ("changePassword".equals(req.getParameter("action"))) {
            String newPwd = req.getParameter("newPassword");
            String cfmPwd = req.getParameter("confirmPassword");
            if (!newPwd.equals(cfmPwd)) {
                req.setAttribute("error", "Mật khẩu mới không khớp!");
                req.setAttribute("user", userDAO.getById(loggedUser.getUserId()));
                req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                return;
            }
            boolean ok = userDAO.changePassword(loggedUser.getUserId(),
                    LoginServlet.md5(req.getParameter("oldPassword")),
                    LoginServlet.md5(newPwd));
            if (ok) resp.sendRedirect(req.getContextPath() + "/profile?pwdChanged=1");
            else {
                req.setAttribute("error", "Mật khẩu cũ không đúng!");
                req.setAttribute("user", userDAO.getById(loggedUser.getUserId()));
                req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
            }
        }
    }
}