<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Tài khoản — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
  <div class="container" style="max-width:760px">

    <h1 class="section-title" style="margin-bottom:28px">👤 Tài khoản của tôi</h1>

    <!-- TABS -->
    <div class="tabs">
      <button class="tab-btn active" data-tab="tab-info">Thông tin</button>
      <button class="tab-btn"        data-tab="tab-pwd">Đổi mật khẩu</button>
    </div>

    <!-- THÔNG BÁO -->
    <c:if test="${param.updated == '1'}">
      <div class="alert alert-success" style="margin-top:16px">✅ Cập nhật thông tin thành công!</div>
    </c:if>
    <c:if test="${param.pwdChanged == '1'}">
      <div class="alert alert-success" style="margin-top:16px">✅ Đổi mật khẩu thành công!</div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert-danger" style="margin-top:16px">❌ ${error}</div>
    </c:if>

    <!-- TAB: THÔNG TIN -->
    <div id="tab-info" class="tab-content active"
         style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:28px;margin-top:20px">
      <form action="${pageContext.request.contextPath}/profile" method="post">
        <input type="hidden" name="action" value="updateProfile">

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
          <div class="form-group" style="grid-column:1/-1">
            <label>Họ và tên</label>
            <input class="form-control" type="text" name="fullName" required value="${user.fullName}">
          </div>
          <div class="form-group">
            <label>Email</label>
            <input class="form-control" type="email" value="${user.email}" disabled
                   style="background:var(--sand);cursor:not-allowed">
            <div class="form-hint">Email không thể thay đổi</div>
          </div>
          <div class="form-group">
            <label>Số điện thoại</label>
            <input class="form-control" type="tel" name="phone" value="${user.phone}" placeholder="0901 234 567">
          </div>
          <div class="form-group" style="grid-column:1/-1">
            <label>Địa chỉ</label>
            <textarea class="form-control" name="address" rows="2"
                      placeholder="Số nhà, đường, phường, quận, tỉnh/thành">${user.address}</textarea>
          </div>
        </div>

        <div style="display:flex;gap:12px;margin-top:8px">
          <button type="submit" class="btn btn-green">💾 Lưu thay đổi</button>
          <a href="${pageContext.request.contextPath}/orders" class="btn"
             style="border:1.5px solid var(--sand);color:var(--text)">📋 Lịch sử đơn hàng</a>
        </div>
      </form>
    </div>

    <!-- TAB: ĐỔI MẬT KHẨU -->
    <div id="tab-pwd" class="tab-content"
         style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:28px;margin-top:20px">
      <form action="${pageContext.request.contextPath}/profile" method="post">
        <input type="hidden" name="action" value="changePassword">

        <div class="form-group">
          <label>Mật khẩu hiện tại</label>
          <input class="form-control" type="password" name="oldPassword" required placeholder="Nhập mật khẩu hiện tại">
        </div>
        <div class="form-group">
          <label>Mật khẩu mới</label>
          <input class="form-control" type="password" name="newPassword" required
                 placeholder="Ít nhất 6 ký tự" id="newPwd">
        </div>
        <div class="form-group">
          <label>Xác nhận mật khẩu mới</label>
          <input class="form-control" type="password" name="confirmPassword" required
                 placeholder="Nhập lại mật khẩu mới" id="cfmPwd">
          <div class="form-hint" id="pwdHint2"></div>
        </div>
        <button type="submit" class="btn btn-green">🔒 Đổi mật khẩu</button>
      </form>
    </div>

  </div>
</section>

<script>
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
      this.classList.add('active');
      document.getElementById(this.dataset.tab).classList.add('active');
    });
  });

  document.getElementById('cfmPwd').addEventListener('input', function() {
    const hint = document.getElementById('pwdHint2');
    if (this.value !== document.getElementById('newPwd').value) {
      hint.textContent = '❌ Mật khẩu không khớp'; hint.style.color = 'red';
    } else {
      hint.textContent = '✅ Mật khẩu khớp'; hint.style.color = 'green';
    }
  });
</script>

<jsp:include page="footer.jsp" />
s