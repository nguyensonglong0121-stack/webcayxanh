package com.caycanhweb.servlet.admin;

import com.caycanhweb.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * Trang báo cáo doanh thu chi tiết cho admin:
 *  - Lọc theo khoảng ngày tùy chọn (mặc định 30 ngày gần nhất) hoặc theo tháng nhanh
 *  - Biểu đồ doanh thu theo ngày trong khoảng đã chọn
 *  - Top sản phẩm bán chạy trong khoảng đã chọn
 *  - Doanh thu theo phương thức thanh toán
 */
@WebServlet("/admin/reports")
public class AdminReportServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String rangeParam = req.getParameter("range"); // "7d" | "30d" | "month" | "year" | "custom"
        if (rangeParam == null || rangeParam.isBlank()) rangeParam = "30d";

        LocalDate today = LocalDate.now();
        LocalDate from;
        LocalDate to = today;

        switch (rangeParam) {
            case "7d"    -> from = today.minusDays(6);
            case "month" -> from = today.withDayOfMonth(1);
            case "year"  -> from = today.withDayOfYear(1);
            case "custom" -> {
                from = parseDate(req.getParameter("from"), today.minusDays(29));
                to   = parseDate(req.getParameter("to"),   today);
                if (from.isAfter(to)) { LocalDate tmp = from; from = to; to = tmp; } // hoán đổi nếu nhập ngược
            }
            default -> from = today.minusDays(29); // 30d
        }

        req.setAttribute("range", rangeParam);
        req.setAttribute("fromDate", from.format(ISO));
        req.setAttribute("toDate",   to.format(ISO));

        long totalRevenue  = orderDAO.getRevenueByDateRange(from, to);
        int  totalOrders   = orderDAO.getOrderCountByDateRange(from, to);
        long avgOrderValue = totalOrders == 0 ? 0 : totalRevenue / totalOrders;

        req.setAttribute("totalRevenue",          totalRevenue);
        req.setAttribute("totalRevenueFormatted", formatMoney(totalRevenue));
        req.setAttribute("totalOrders",           totalOrders);
        req.setAttribute("avgOrderValueFormatted",formatMoney(avgOrderValue));

        req.setAttribute("dailyRevenue",   orderDAO.getRevenueByDay(from, to));
        req.setAttribute("topProducts",    orderDAO.getTopSellingProducts(from, to, 10));
        req.setAttribute("paymentStats",   orderDAO.getRevenueByPaymentMethod(from, to));

        req.getRequestDispatcher("/admin/report.jsp").forward(req, resp);
    }

    private LocalDate parseDate(String s, LocalDate fallback) {
        if (s == null || s.isBlank()) return fallback;
        try {
            return LocalDate.parse(s, ISO);
        } catch (DateTimeParseException e) {
            return fallback;
        }
    }

    private String formatMoney(long v) {
        return String.format("%,d", v).replace(',', '.');
    }
}