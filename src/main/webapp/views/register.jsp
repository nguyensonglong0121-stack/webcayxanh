<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đăng ký — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
  <div class="container">
    <div class="form-card" style="max-width:520px">
      <h2>🌱 Tạo tài khoản</h2>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">❌ ${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/register" method="post" id="regForm">
        <div class="form-group">
          <label>Họ và tên <span style="color:red">*</span></label>
          <input class="form-control" type="text" name="fullName" required placeholder="Nguyễn Văn An">
        </div>
        <div class="form-group">
          <label>Email <span style="color:red">*</span></label>
          <input class="form-control" type="email" name="email" required placeholder="email@example.com">
        </div>
        <div class="form-group">
          <label>Số điện thoại</label>
          <input class="form-control" type="tel" name="phone" placeholder="0901 234 567">
        </div>
        <div class="form-group">
          <label>Mật khẩu <span style="color:red">*</span></label>
          <input class="form-control" type="password" name="password" id="pwd" required
                 placeholder="Ít nhất 6 ký tự">
        </div>
        <div class="form-group">
          <label>Xác nhận mật khẩu <span style="color:red">*</span></label>
          <input class="form-control" type="password" name="password2" id="pwd2" required
                 placeholder="Nhập lại mật khẩu">
          <div class="form-hint" id="pwdHint"></div>
        </div>
        <button type="submit" class="btn btn-green btn-block btn-lg" style="margin-top:8px">Đăng ký</button>
      </form>

      <p style="text-align:center;margin-top:20px;font-size:14px;color:var(--muted)">
        Đã có tài khoản?
        <a href="${pageContext.request.contextPath}/login" style="color:var(--green-mid);font-weight:700">Đăng nhập</a>
      </p>
    </div>
  </div>
</section>

<script>
  document.getElementById('pwd2').addEventListener('input', function() {
    const hint = document.getElementById('pwdHint');
    if (this.value !== document.getElementById('pwd').value) {
      hint.textContent = '❌ Mật khẩu không khớp';
      hint.style.color = 'red';
    } else {
      hint.textContent = '✅ Mật khẩu khớp';
      hint.style.color = 'green';
    }
  });
</script>

<jsp:include page="footer.jsp" />
