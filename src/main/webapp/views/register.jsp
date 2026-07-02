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
                    <div style="position:relative">
                        <input class="form-control" type="password" name="password" id="pwd" required
                               placeholder="Ít nhất 6 ký tự" style="padding-right:44px">
                        <span id="togglePwd"
                              style="position:absolute;right:14px;top:50%;transform:translateY(-50%);
                         cursor:pointer;color:var(--muted);display:flex">
              <svg class="icon-eye" width="20" height="20" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8Z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
              <svg class="icon-eye-slash" width="20" height="20" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                   style="display:none">
                <path d="M17.94 17.94A10.94 10.94 0 0 1 12 20c-7 0-11-8-11-8a21.6 21.6 0 0 1 5.06-6.06M9.9 4.24A10.94 10.94 0 0 1 12 4c7 0 11 8 11 8a21.6 21.6 0 0 1-3.22 4.44M14.12 14.12a3 3 0 1 1-4.24-4.24"/>
                <line x1="1" y1="1" x2="23" y2="23"/>
              </svg>
            </span>
                    </div>
                </div>
                <div class="form-group">
                    <label>Xác nhận mật khẩu <span style="color:red">*</span></label>
                    <div style="position:relative">
                        <input class="form-control" type="password" name="password2" id="pwd2" required
                               placeholder="Nhập lại mật khẩu" style="padding-right:44px">
                        <span id="togglePwd2"
                              style="position:absolute;right:14px;top:50%;transform:translateY(-50%);
                         cursor:pointer;color:var(--muted);display:flex">
              <svg class="icon-eye" width="20" height="20" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8Z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
              <svg class="icon-eye-slash" width="20" height="20" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                   style="display:none">
                <path d="M17.94 17.94A10.94 10.94 0 0 1 12 20c-7 0-11-8-11-8a21.6 21.6 0 0 1 5.06-6.06M9.9 4.24A10.94 10.94 0 0 1 12 4c7 0 11 8 11 8a21.6 21.6 0 0 1-3.22 4.44M14.12 14.12a3 3 0 1 1-4.24-4.24"/>
                <line x1="1" y1="1" x2="23" y2="23"/>
              </svg>
            </span>
                    </div>
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

    function setupPasswordToggle(inputId, toggleId) {
        document.getElementById(toggleId).addEventListener('click', function() {
            const pwd = document.getElementById(inputId);
            const eye = this.querySelector('.icon-eye');
            const eyeSlash = this.querySelector('.icon-eye-slash');
            const isHidden = pwd.type === 'password';
            pwd.type = isHidden ? 'text' : 'password';
            eye.style.display = isHidden ? 'none' : 'block';
            eyeSlash.style.display = isHidden ? 'block' : 'none';
        });
    }
    setupPasswordToggle('pwd', 'togglePwd');
    setupPasswordToggle('pwd2', 'togglePwd2');
</script>

<jsp:include page="footer.jsp" />
