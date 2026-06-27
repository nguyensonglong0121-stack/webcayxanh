<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đăng nhập — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
  <div class="container">
    <div class="form-card">
      <h2>🌿 Đăng nhập</h2>

      <c:if test="${param.registered == '1'}">
        <div class="alert alert-success">✅ Đăng ký thành công! Hãy đăng nhập.</div>
      </c:if>
      <c:if test="${not empty error}">
        <div class="alert alert-danger">❌ ${error}</div>
      </c:if>
      <c:if test="${param.error == 'google_cancelled'}">
        <div class="alert alert-danger">❌ Đăng nhập Google bị hủy.</div>
      </c:if>
      <c:if test="${param.error == 'google_failed'}">
        <div class="alert alert-danger">❌ Đăng nhập Google thất bại. Thử lại!</div>
      </c:if>

      <%-- Form đăng nhập thường --%>
      <form action="${pageContext.request.contextPath}/login" method="post">
        <input type="hidden" name="next" value="${param.next}">
        <div class="form-group">
          <label>Email</label>
          <input class="form-control" type="email" name="email" required
                 placeholder="email@example.com" value="${param.email}">
        </div>
        <div class="form-group">
          <label>Mật khẩu</label>
          <input class="form-control" type="password" name="password" required
                 placeholder="Nhập mật khẩu">
        </div>
        <button type="submit" class="btn btn-green btn-block btn-lg" style="margin-top:8px">
          🔑 Đăng nhập
        </button>
      </form>

      <!-- Divider -->
      <div style="display:flex;align-items:center;gap:12px;margin:20px 0">
        <div style="flex:1;height:1px;background:var(--sand)"></div>
        <span style="color:var(--muted);font-size:13px">hoặc đăng nhập bằng</span>
        <div style="flex:1;height:1px;background:var(--sand)"></div>
      </div>

      <!-- Google + OTP buttons -->
      <div style="display:flex;flex-direction:column;gap:10px">

        <!-- Google Login -->
        <a href="${pageContext.request.contextPath}/auth/google"
           style="display:flex;align-items:center;justify-content:center;gap:10px;
                  padding:12px 20px;border:1.5px solid #ddd;border-radius:10px;
                  background:white;color:#333;font-weight:600;font-size:14px;
                  text-decoration:none;transition:.2s"
           onmouseover="this.style.background='#f8fafc'"
           onmouseout="this.style.background='white'">
          <svg width="18" height="18" viewBox="0 0 48 48">
            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.35-8.16 2.35-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
          </svg>
          Đăng nhập bằng Google
        </a>

        <!-- OTP Login -->
        <a href="${pageContext.request.contextPath}/otp-login"
           style="display:flex;align-items:center;justify-content:center;gap:10px;
                  padding:12px 20px;border:1.5px solid var(--green-sage);border-radius:10px;
                  background:var(--cream);color:var(--green-dark);font-weight:600;font-size:14px;
                  text-decoration:none;transition:.2s"
           onmouseover="this.style.background='#c8e6c2'"
           onmouseout="this.style.background='var(--cream)'">
          📨 Đăng nhập bằng mã OTP (Email)
        </a>
      </div>

      <p style="text-align:center;margin-top:20px;font-size:14px;color:var(--muted)">
        Chưa có tài khoản?
        <a href="${pageContext.request.contextPath}/register"
           style="color:var(--green-mid);font-weight:700">Đăng ký ngay</a>
      </p>

      <div style="margin-top:16px;padding:12px;background:var(--cream);
                  border-radius:8px;font-size:12px;color:var(--muted)">
        <strong>Tài khoản demo:</strong><br>
        Admin: admin@green.vn / admin123<br>
        User: user@green.vn / 123456
      </div>
    </div>
  </div>
</section>

<jsp:include page="footer.jsp" />
