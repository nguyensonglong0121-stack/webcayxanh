package com.caycanhweb.servlet;

import com.caycanhweb.util.GHNService;
import com.google.gson.JsonArray;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/ghn/*")
public class GHNServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        String path = req.getPathInfo(); // → "/fee", "/provinces", "/districts", "/wards"

        switch (path == null ? "" : path) {

            case "/provinces" -> {
                JsonArray data = GHNService.getProvinces();
                resp.getWriter().write(data.toString());
            }

            case "/districts" -> {
                int provinceId = Integer.parseInt(req.getParameter("province_id"));
                JsonArray data = GHNService.getDistricts(provinceId);
                resp.getWriter().write(data.toString());
            }

            case "/wards" -> {
                int districtId = Integer.parseInt(req.getParameter("district_id"));
                JsonArray data = GHNService.getWards(districtId);
                resp.getWriter().write(data.toString());
            }

            case "/fee" -> {
                int    districtId = Integer.parseInt(req.getParameter("district_id"));
                String wardCode   = req.getParameter("ward_code");

                int fee = GHNService.calculateFee(districtId, wardCode, GHNService.DEFAULT_WEIGHT_GRAM);
                resp.getWriter().write("{\"fee\":" + fee + "}");
            }

            default -> resp.getWriter().write("{\"error\":\"Invalid endpoint\"}");
        }
    }
}