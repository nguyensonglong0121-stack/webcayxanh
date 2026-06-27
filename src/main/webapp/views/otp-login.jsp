<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đăng nhập OTP — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
    <div class="container">
        <div class="form-card" style="max-width:440px">

            <div style="text-align:center;margin-bottom:24px">
                <div style="font-size:48px;margin-bottom:8px">🔐</div>
                <h2 style="margin:0">Đăng nhập bằng OTP</h2>
                <p style="color:var(--muted);font-size:14px;margin-top:8px">
                    Mã xác thực sẽ được gửi đến email của bạn
                </p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">❌ ${error}</div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success">✅ ${success}</div>
            </c:if>

            <%-- BƯỚC 1: Nhập email --%>
            <c:if test="${step == 'email' || empty step}">
                <form action="${pageContext.request.contextPath}/otp-login" method="post">
                    <input type="hidden" name="step" value="sendOTP">

                    <div class="form-group">
                        <label>Email đăng ký <span style="color:red">*</span></label>
                        <input class="form-control" type="email" name="email" required
                               placeholder="email@example.com" autofocus>
                        <div class="form-hint">Nhập email bạn đã đăng ký tài khoản</div>
                    </div>

                    <button type="submit" class="btn btn-green btn-block btn-lg" style="margin-top:8px">
                        📨 Gửi mã OTP
                    </button>
                </form>
            </c:if>

            <%-- BƯỚC 2: Nhập OTP --%>
            <c:if test="${step == 'verify'}">
                <form action="${pageContext.request.contextPath}/otp-login" method="post" id="otpForm">
                    <input type="hidden" name="step"  value="verifyOTP">
                    <input type="hidden" name="email" value="${email}">

                    <div class="form-group">
                        <label>Nhập mã OTP</label>
                        <div style="display:flex;gap:8px;justify-content:center;margin:16px 0">
                            <c:forEach begin="1" end="6" var="i">
                                <input type="text" maxlength="1"
                                       class="otp-digit"
                                       style="width:48px;height:56px;text-align:center;font-size:24px;
                              font-weight:800;border:2px solid var(--sand);border-radius:8px;
                              outline:none;transition:.2s"
                                       id="digit${i}">
                            </c:forEach>
                        </div>
                        <input type="hidden" name="otp" id="otpValue">
                    </div>

                    <!-- Đếm ngược 5 phút -->
                    <div style="text-align:center;margin-bottom:16px">
                        <span style="color:var(--muted);font-size:13px">Mã hết hạn sau: </span>
                        <span id="countdown" style="color:#dc2626;font-weight:700;font-size:15px">05:00</span>
                    </div>

                    <button type="submit" class="btn btn-green btn-block btn-lg" id="verifyBtn">
                        ✅ Xác nhận đăng nhập
                    </button>

                    <div style="text-align:center;margin-top:16px">
                        <a href="${pageContext.request.contextPath}/otp-login"
                           style="color:var(--green-mid);font-size:13px;font-weight:600">
                            ↩ Gửi lại mã OTP
                        </a>
                    </div>
                </form>

                <script>
                    // ── OTP input tự động chuyển ô ────────────────
                    const digits = document.querySelectorAll('.otp-digit');
                    digits.forEach((input, idx) => {
                        input.addEventListener('input', function() {
                            this.style.borderColor = 'var(--green-mid)';
                            if (this.value && idx < digits.length - 1) {
                                digits[idx + 1].focus();
                            }
                            updateOTPValue();
                        });
                        input.addEventListener('keydown', function(e) {
                            if (e.key === 'Backspace' && !this.value && idx > 0) {
                                digits[idx - 1].focus();
                            }
                        });
                        input.addEventListener('focus', function() {
                            this.style.borderColor = 'var(--green-mid)';
                            this.style.boxShadow   = '0 0 0 3px rgba(45,90,61,0.15)';
                        });
                        input.addEventListener('blur', function() {
                            this.style.borderColor = 'var(--sand)';
                            this.style.boxShadow   = 'none';
                        });
                    });

                    // Paste OTP tự điền vào các ô
                    digits[0].addEventListener('paste', function(e) {
                        e.preventDefault();
                        const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
                        [...pasted].slice(0, 6).forEach((ch, i) => {
                            if (digits[i]) { digits[i].value = ch; digits[i].style.borderColor = 'var(--green-mid)'; }
                        });
                        updateOTPValue();
                    });

                    function updateOTPValue() {
                        document.getElementById('otpValue').value = [...digits].map(d => d.value).join('');
                    }

                    // Submit tự động khi điền đủ 6 số
                    function checkAutoSubmit() {
                        const otp = [...digits].map(d => d.value).join('');
                        if (otp.length === 6) {
                            updateOTPValue();
                            // Nhỏ delay để user thấy
                            setTimeout(() => document.getElementById('otpForm').submit(), 300);
                        }
                    }
                    digits.forEach(d => d.addEventListener('input', checkAutoSubmit));

                    // ── Đếm ngược 5 phút ─────────────────────────
                    let seconds = 300;
                    const countdownEl = document.getElementById('countdown');
                    const timer = setInterval(() => {
                        seconds--;
                        const m = String(Math.floor(seconds / 60)).padStart(2, '0');
                        const s = String(seconds % 60).padStart(2, '0');
                        countdownEl.textContent = m + ':' + s;
                        if (seconds <= 0) {
                            clearInterval(timer);
                            countdownEl.textContent = 'Hết hạn!';
                            document.getElementById('verifyBtn').disabled = true;
                            document.getElementById('verifyBtn').textContent = '⏰ Mã đã hết hạn';
                        }
                        if (seconds <= 60) countdownEl.style.color = '#dc2626';
                    }, 1000);

                    // Focus ô đầu tiên
                    digits[0].focus();
                </script>
            </c:if>

            <!-- Divider -->
            <div style="display:flex;align-items:center;gap:12px;margin:24px 0">
                <div style="flex:1;height:1px;background:var(--sand)"></div>
                <span style="color:var(--muted);font-size:13px">hoặc</span>
                <div style="flex:1;height:1px;background:var(--sand)"></div>
            </div>

            <!-- Các cách đăng nhập khác -->
            <div style="display:flex;flex-direction:column;gap:10px">
                <a href="${pageContext.request.contextPath}/login"
                   class="btn btn-block" style="border:1.5px solid var(--sand);color:var(--text)">
                    🔑 Đăng nhập bằng mật khẩu
                </a>
                <a href="${pageContext.request.contextPath}/auth/google"
                   class="btn btn-block" style="border:1.5px solid #ddd;color:#333;background:white">
                    <img src="https://www.google.com/favicon.ico" style="width:16px;height:16px;margin-right:8px" alt="">
                    Đăng nhập bằng Google
                </a>
            </div>

            <p style="text-align:center;margin-top:20px;font-size:14px;color:var(--muted)">
                Chưa có tài khoản?
                <a href="${pageContext.request.contextPath}/register"
                   style="color:var(--green-mid);font-weight:700">Đăng ký ngay</a>
            </p>

        </div>
    </div>
</section>

<jsp:include page="footer.jsp" />
