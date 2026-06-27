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
        <button type="submit" class="btn btn-green btn-block btn-lg" style="margin-top:8px">Đăng nhập</button>
      </form>

      <p style="text-align:center;margin-top:20px;font-size:14px;color:var(--muted)">
        Chưa có tài khoản?
        <a href="${pageContext.request.contextPath}/register" style="color:var(--green-mid);font-weight:700">Đăng ký ngay</a>
      </p>

      <div style="margin-top:16px;padding:12px;background:var(--cream);border-radius:8px;font-size:12px;color:var(--muted)">
        <strong>Tài khoản demo:</strong><br>
        Admin: admin@green.vn / admin123<br>
        User: user@green.vn / 123456
      </div>
    </div>
  </div>
</section>
<a href=".../otp-login">📨 Đăng nhập bằng OTP</a>
<a href=".../auth/google">Google Login</a>

<jsp:include page="footer.jsp" />
