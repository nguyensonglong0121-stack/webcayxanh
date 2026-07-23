package com.caycanhweb.util;

import com.google.gson.*;
import java.io.*;
import java.net.*;
import java.net.http.*;
import java.nio.charset.StandardCharsets;

public class GHNService {

    // Token/ShopId được đọc từ config.properties (không commit) hoặc biến môi trường
    // GHN_TOKEN / GHN_SHOP_ID — xem AppConfig.java và config.properties.example
    private static final String TOKEN   = AppConfig.get("ghn.token", "");
    private static final String SHOP_ID = AppConfig.get("ghn.shop.id", "");

    private static final String BASE_URL = "https://dev-online-gateway.ghn.vn/shiip/public-api";
    private static final HttpClient HTTP = HttpClient.newHttpClient();
    private static final Gson GSON = new Gson();

    // Cân nặng mặc định (gram) dùng khi tính phí ship cho 1 đơn cây cảnh —
    // dùng chung giữa GHNServlet (preview lúc chọn địa chỉ) và CheckoutServlet
    // (tính lại lúc đặt hàng thật) để 2 nơi luôn ra cùng 1 số tiền.
    public static final int DEFAULT_WEIGHT_GRAM = 500;

    // ── Lấy danh sách Tỉnh/Thành ─────────────────────
    public static JsonArray getProvinces() {
        String json = get("/master-data/province");
        if (json == null) return new JsonArray();
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("data") ? obj.getAsJsonArray("data") : new JsonArray();
    }

    // ── Lấy danh sách Quận/Huyện theo tỉnh ──────────
    public static JsonArray getDistricts(int provinceId) {
        String body = "{\"province_id\":" + provinceId + "}";
        String json = post("/master-data/district", body);
        if (json == null) return new JsonArray();
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("data") ? obj.getAsJsonArray("data") : new JsonArray();
    }

    // ── Lấy danh sách Phường/Xã theo huyện ──────────
    public static JsonArray getWards(int districtId) {
        String body = "{\"district_id\":" + districtId + "}";
        String json = post("/master-data/ward", body);
        if (json == null) return new JsonArray();
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("data") ? obj.getAsJsonArray("data") : new JsonArray();
    }

    // ── Tính phí vận chuyển ───────────────────────────
    public static int calculateFee(int toDistrictId, String toWardCode, int weightGram) {
        String body = String.format("""
                {
                  "shop_id": %s,
                  "service_type_id": 2,
                  "to_district_id": %d,
                  "to_ward_code": "%s",
                  "weight": %d,
                  "insurance_value": 0
                }
                """, SHOP_ID, toDistrictId, toWardCode, weightGram);

        String json = post("/v2/shipping-order/fee", body);
        if (json == null) return 0;

        try {
            JsonObject obj  = JsonParser.parseString(json).getAsJsonObject();
            JsonObject data = obj.getAsJsonObject("data");
            if (data != null && data.has("total")) {
                return data.get("total").getAsInt();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── Tạo đơn hàng GHN (sau khi user đặt hàng) ────
    public static String createOrder(
            String toName, String toPhone, String toAddress,
            int toDistrictId, String toWardCode,
            String note, int codAmount, int weightGram) {

        String body = String.format("""
                {
                  "shop_id": %s,
                  "to_name": "%s",
                  "to_phone": "%s",
                  "to_address": "%s",
                  "to_district_id": %d,
                  "to_ward_code": "%s",
                  "service_type_id": 2,
                  "payment_type_id": 2,
                  "weight": %d,
                  "cod_amount": %d,
                  "note": "%s",
                  "required_note": "KHONGCHOXEMHANG",
                  "items": [{"name":"Cay Canh","quantity":1,"weight":%d}]
                }
                """, SHOP_ID,
                toName, toPhone, toAddress,
                toDistrictId, toWardCode,
                weightGram, codAmount, note, weightGram);

        String json = post("/v2/shipping-order/create", body);
        if (json == null) return null;

        try {
            JsonObject obj  = JsonParser.parseString(json).getAsJsonObject();
            JsonObject data = obj.getAsJsonObject("data");
            if (data != null && data.has("order_code")) {
                return data.get("order_code").getAsString(); // Mã vận đơn GHN
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── HTTP GET ──────────────────────────────────────
    private static String get(String path) {
        if (TOKEN.isBlank() || SHOP_ID.isBlank()) {
            System.err.println("[GHNService] Chưa cấu hình ghn.token / ghn.shop.id trong config.properties.");
            return null;
        }
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .header("Token",       TOKEN)
                    .header("ShopId",      SHOP_ID)
                    .header("Content-Type","application/json")
                    .GET()
                    .build();
            HttpResponse<String> resp = HTTP.send(req, HttpResponse.BodyHandlers.ofString());
            return resp.body();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ── HTTP POST ─────────────────────────────────────
    private static String post(String path, String body) {
        if (TOKEN.isBlank() || SHOP_ID.isBlank()) {
            System.err.println("[GHNService] Chưa cấu hình ghn.token / ghn.shop.id trong config.properties.");
            return null;
        }
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(BASE_URL + path))
                    .header("Token",        TOKEN)
                    .header("ShopId",       SHOP_ID)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                    .build();
            HttpResponse<String> resp = HTTP.send(req, HttpResponse.BodyHandlers.ofString());
            return resp.body();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}