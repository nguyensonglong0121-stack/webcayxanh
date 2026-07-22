package com.caycanhweb.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Đọc cấu hình nhạy cảm (API key, mật khẩu ứng dụng, client secret...)
 * từ classpath:config.properties (KHÔNG commit lên Git) hoặc từ biến môi trường.
 *
 * Thứ tự ưu tiên khi tra 1 key, ví dụ "mail.app.password":
 *   1) Biến môi trường MAIL_APP_PASSWORD (viết HOA, dấu '.' -> '_')
 *   2) Giá trị trong config.properties
 *   3) defaultValue truyền vào (nếu có)
 *
 * Cách setup khi chạy local (bắt buộc, làm 1 lần):
 *   1. Copy  src/main/resources/config.properties.example
 *      thành src/main/resources/config.properties
 *   2. Điền giá trị THẬT của bạn vào config.properties.
 *      File này đã được liệt kê trong .gitignore -> sẽ KHÔNG bao giờ bị commit lên Git nữa.
 *
 * Khi deploy lên server thật: nên set biến môi trường tương ứng thay vì dùng file,
 * để không phải copy file chứa secret lên server.
 */
public final class AppConfig {

    private static final Properties PROPS = new Properties();
    private static volatile boolean loaded = false;

    private AppConfig() {}

    private static void ensureLoaded() {
        if (loaded) return;
        synchronized (AppConfig.class) {
            if (loaded) return;
            try (InputStream in = AppConfig.class.getClassLoader()
                    .getResourceAsStream("config.properties")) {
                if (in != null) {
                    PROPS.load(in);
                } else {
                    System.err.println(
                            "[AppConfig] KHÔNG tìm thấy 'config.properties' trong classpath.\n" +
                                    "  -> Copy 'src/main/resources/config.properties.example' thành\n" +
                                    "     'src/main/resources/config.properties' rồi điền giá trị thật,\n" +
                                    "     hoặc set các biến môi trường tương ứng (xem README).");
                }
            } catch (IOException e) {
                System.err.println("[AppConfig] Lỗi đọc config.properties: " + e.getMessage());
            }
            loaded = true;
        }
    }

    /** Lấy giá trị cấu hình, trả về defaultValue nếu không tìm thấy ở đâu cả. */
    public static String get(String key, String defaultValue) {
        ensureLoaded();

        String envKey = key.toUpperCase().replace('.', '_');
        String fromEnv = System.getenv(envKey);
        if (fromEnv != null && !fromEnv.isBlank()) return fromEnv;

        String fromFile = PROPS.getProperty(key);
        if (fromFile != null && !fromFile.isBlank()) return fromFile;

        return defaultValue;
    }

    /** Lấy giá trị cấu hình bắt buộc phải có; ném lỗi rõ ràng ngay lúc khởi động nếu thiếu,
     *  thay vì để lỗi âm thầm (ví dụ gửi mail thất bại) xảy ra lúc người dùng đang thao tác. */
    public static String getRequired(String key) {
        String v = get(key, null);
        if (v == null || v.isBlank()) {
            throw new IllegalStateException(
                    "[AppConfig] Thiếu cấu hình bắt buộc '" + key + "'. " +
                            "Hãy set trong src/main/resources/config.properties hoặc biến môi trường " +
                            key.toUpperCase().replace('.', '_') + ".");
        }
        return v;
    }
}
