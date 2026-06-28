<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Thanh toán — GreenShop" />
<jsp:include page="header.jsp" />

<%
  java.util.List<com.caycanhweb.model.CartItem> cart =
          (java.util.List<com.caycanhweb.model.CartItem>) session.getAttribute("cart");
  if (cart == null) cart = new java.util.ArrayList<>();
  long total = 0;
  for (com.caycanhweb.model.CartItem item : cart) total += item.getSubtotal();
  request.setAttribute("cart",  cart);
  request.setAttribute("total", total);
%>

<section class="section">
  <div class="container">
    <div class="breadcrumb">
      <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
      <span>›</span>
      <a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a>
      <span>›</span> Thanh toán
    </div>

    <h1 class="section-title" style="margin-bottom:28px">💳 Thanh toán</h1>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">❌ ${error}</div>
    </c:if>

    <div style="display:grid;grid-template-columns:1fr 380px;gap:32px;align-items:start">

      <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">

        <!-- THÔNG TIN GIAO HÀNG -->
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:20px">
            📍 Thông tin giao hàng
          </h3>

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
            <div class="form-group">
              <label>Họ và tên người nhận <span style="color:red">*</span></label>
              <input class="form-control" type="text" name="receiverName" required
                     placeholder="Nguyễn Văn An"
                     value="${loggedUser != null ? loggedUser.fullName : ''}">
            </div>
            <div class="form-group">
              <label>Số điện thoại <span style="color:red">*</span></label>
              <input class="form-control" type="tel" name="receiverPhone" required
                     placeholder="0901 234 567"
                     value="${loggedUser != null ? loggedUser.phone : ''}">
            </div>
          </div>

          <!-- ĐỊA CHỈ GHN -->
          <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:12px">
            <div class="form-group">
              <label>Tỉnh/Thành phố <span style="color:red">*</span></label>
              <select class="form-control" id="province" name="province_id" required
                      onchange="loadDistricts(this.value)">
                <option value="">-- Chọn tỉnh/thành --</option>
              </select>
              <input type="hidden" name="province_name" id="province_name">
            </div>
            <div class="form-group">
              <label>Quận/Huyện <span style="color:red">*</span></label>
              <select class="form-control" id="district" name="district_id" required
                      onchange="loadWards(this.value)" disabled>
                <option value="">-- Chọn quận/huyện --</option>
              </select>
              <input type="hidden" name="district_name" id="district_name">
            </div>
            <div class="form-group">
              <label>Phường/Xã <span style="color:red">*</span></label>
              <select class="form-control" id="ward" name="ward_code" required
                      onchange="calculateFee()" disabled>
                <option value="">-- Chọn phường/xã --</option>
              </select>
              <input type="hidden" name="ward_name" id="ward_name">
            </div>
          </div>

          <div class="form-group">
            <label>Số nhà, tên đường <span style="color:red">*</span></label>
            <input class="form-control" type="text" name="streetAddress" required
                   placeholder="123 Đường Lê Lợi">
          </div>

          <div class="form-group">
            <label>Ghi chú đơn hàng</label>
            <textarea class="form-control" name="note" rows="2"
                      placeholder="Yêu cầu đặc biệt..."></textarea>
          </div>
        </div>

        <!-- PHÍ VẬN CHUYỂN GHN -->
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:16px">
            🚚 Phí vận chuyển (GHN)
          </h3>

          <div id="shippingBox" style="background:var(--cream);border-radius:8px;padding:16px">
            <div id="shippingLoading" style="display:none;color:var(--muted);font-size:14px">
              ⏳ Đang tính phí vận chuyển...
            </div>
            <div id="shippingResult" style="display:none">
              <div style="display:flex;justify-content:space-between;align-items:center">
                <div>
                  <div style="font-weight:700;font-size:14px">🚚 Giao Hàng Nhanh (GHN)</div>
                  <div style="font-size:12px;color:var(--muted)">Giao hàng 2-3 ngày làm việc</div>
                </div>
                <div style="font-weight:800;font-size:18px;color:var(--green-mid)" id="shippingFee">
                  0đ
                </div>
              </div>
            </div>
            <div id="shippingEmpty" style="color:var(--muted);font-size:13px;font-style:italic">
              Chọn địa chỉ giao hàng để xem phí ship
            </div>
          </div>

          <input type="hidden" name="shippingFee" id="shippingFeeInput" value="0">
        </div>

        <!-- PHƯƠNG THỨC THANH TOÁN -->
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:16px">
            💳 Phương thức thanh toán
          </h3>

          <label style="display:flex;align-items:center;gap:12px;padding:14px;
                         border:2px solid var(--green-mid);border-radius:10px;
                         cursor:pointer;margin-bottom:10px;background:var(--cream)">
            <input type="radio" name="paymentMethod" value="cod" checked>
            <div>
              <div style="font-weight:700">💵 Thanh toán khi nhận hàng (COD)</div>
              <div style="font-size:12px;color:var(--muted)">Trả tiền mặt khi nhận được hàng</div>
            </div>
          </label>

          <label style="display:flex;align-items:center;gap:12px;padding:14px;
                         border:1.5px solid var(--sand);border-radius:10px;cursor:pointer">
            <input type="radio" name="paymentMethod" value="transfer">
            <div>
              <div style="font-weight:700">🏦 Chuyển khoản ngân hàng</div>
              <div style="font-size:12px;color:var(--muted)">Vietcombank: 1234567890 — GreenShop JSC</div>
            </div>
          </label>
        </div>

        <!-- MÃ GIẢM GIÁ -->
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:12px">
            🎟️ Mã giảm giá
          </h3>
          <div style="display:flex;gap:10px">
            <input type="text" name="couponCode" id="couponCode" class="form-control"
                   placeholder="Nhập mã: XANH10, GIAM50K...">
            <button type="button" class="btn btn-gold" onclick="checkCoupon()">Áp dụng</button>
          </div>
          <div id="couponResult" style="font-size:13px;margin-top:8px"></div>
        </div>

        <button type="submit" class="btn btn-green btn-block btn-lg">
          ✅ Xác nhận đặt hàng
        </button>
      </form>

      <!-- TÓM TẮT ĐƠN HÀNG -->
      <div style="position:sticky;top:80px">
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:20px">
            📋 Đơn hàng của bạn
          </h3>

          <c:forEach var="item" items="${cart}">
            <div style="display:flex;gap:12px;margin-bottom:12px;padding-bottom:12px;border-bottom:1px solid var(--sand)">
              <img src="${pageContext.request.contextPath}/uploads/${item.mainImage}"
                   onerror="this.src='https://placehold.co/56x56/a8d5a2/1a3a2a?text=🌿'"
                   style="width:56px;height:56px;border-radius:8px;object-fit:cover"
                   alt="${item.productName}">
              <div style="flex:1">
                <div style="font-weight:600;font-size:13px">${item.productName}</div>
                <div style="font-size:12px;color:var(--muted)">x${item.quantity}</div>
              </div>
              <div style="font-weight:700;font-size:13px;color:var(--green-mid)">
                  ${item.subtotalFormatted}đ
              </div>
            </div>
          </c:forEach>

          <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--sand)">
            <span style="font-size:14px">Tạm tính</span>
            <span style="font-weight:700" id="subtotalDisplay">${total}đ</span>
          </div>
          <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--sand)">
            <span style="font-size:14px">Phí vận chuyển</span>
            <span style="font-weight:700;color:var(--green-mid)" id="feeDisplay">Chưa tính</span>
          </div>
          <div style="display:flex;justify-content:space-between;padding-top:12px">
            <span style="font-size:17px;font-weight:800;color:var(--green-dark)">Tổng cộng</span>
            <span style="font-size:20px;font-weight:800;color:var(--green-mid)" id="grandTotal">
              ${total}đ
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>



<script>
  const CTX        = '<%=request.getContextPath()%>';
  const BASE_TOTAL = parseInt('<%=request.getAttribute("total") != null ? request.getAttribute("total").toString() : "0"%>') || 0;



  // ── Load Tỉnh/Thành khi trang load ───────────────
  window.addEventListener('DOMContentLoaded', () => {
    fetch(CTX + '/ghn/provinces')
            .then(r => r.json())
            .then(data => {
              const sel = document.getElementById('province');
              data.sort((a,b) => a.ProvinceName.localeCompare(b.ProvinceName, 'vi'));
              data.forEach(p => {
                const opt = new Option(p.ProvinceName, p.ProvinceID);
                sel.add(opt);
              });
            });
  });

  // ── Load Quận/Huyện ───────────────────────────────
  function loadDistricts(provinceId) {
    if (!provinceId) return;
    const pSel = document.getElementById('province');
    document.getElementById('province_name').value =
            pSel.options[pSel.selectedIndex].text;

    const dSel = document.getElementById('district');
    const wSel = document.getElementById('ward');
    dSel.innerHTML = '<option value="">-- Chọn quận/huyện --</option>';
    wSel.innerHTML = '<option value="">-- Chọn phường/xã --</option>';
    dSel.disabled = false;
    wSel.disabled = true;
    resetFee();

    fetch(CTX + '/ghn/districts?province_id=' + provinceId)
            .then(r => r.json())
            .then(data => {
              data.sort((a,b) => a.DistrictName.localeCompare(b.DistrictName,'vi'));
              data.forEach(d => dSel.add(new Option(d.DistrictName, d.DistrictID)));
            });
  }

  // ── Load Phường/Xã ────────────────────────────────
  function loadWards(districtId) {
    if (!districtId) return;
    const dSel = document.getElementById('district');
    document.getElementById('district_name').value =
            dSel.options[dSel.selectedIndex].text;

    const wSel = document.getElementById('ward');
    wSel.innerHTML = '<option value="">-- Chọn phường/xã --</option>';
    wSel.disabled = false;
    resetFee();

    fetch(CTX + '/ghn/wards?district_id=' + districtId)
            .then(r => r.json())
            .then(data => {
              data.sort((a,b) => a.WardName.localeCompare(b.WardName,'vi'));
              data.forEach(w => wSel.add(new Option(w.WardName, w.WardCode)));
            });
  }

  // ── Tính phí vận chuyển ──────────────────────────
  function calculateFee() {
    const districtSel = document.getElementById('district');
    const wardSel     = document.getElementById('ward');

    const districtId = districtSel.value;
    const wardCode   = wardSel.value;

    // Chưa chọn đủ thì không gọi API
    if (!districtId || districtId === '' || !wardCode || wardCode === '') return;

    document.getElementById('ward_name').value =
            wardSel.options[wardSel.selectedIndex].text;

    document.getElementById('shippingEmpty').style.display   = 'none';
    document.getElementById('shippingLoading').style.display = 'block';
    document.getElementById('shippingResult').style.display  = 'none';

    fetch(`${CTX}/ghn/fee?district_id=${encodeURIComponent(districtId)}&ward_code=${encodeURIComponent(wardCode)}`)
            .then(r => {
              if (!r.ok) throw new Error('HTTP ' + r.status);
              return r.json();
            })
            .then(data => {
              const fee = data.fee || 0;
              document.getElementById('shippingLoading').style.display = 'none';
              document.getElementById('shippingResult').style.display  = 'block';
              document.getElementById('shippingFee').textContent       = formatVND(fee) + 'đ';
              document.getElementById('shippingFeeInput').value        = fee;
              document.getElementById('feeDisplay').textContent        = formatVND(fee) + 'đ';
              document.getElementById('grandTotal').textContent        = formatVND(BASE_TOTAL + fee) + 'đ';
            })
            .catch(err => {
              console.error('Lỗi tính phí ship:', err);
              document.getElementById('shippingLoading').style.display = 'none';
              document.getElementById('shippingEmpty').style.display   = 'block';
              document.getElementById('shippingEmpty').textContent     = '⚠️ Không tính được phí ship, vui lòng thử lại';
            });
  }

  function resetFee() {
    document.getElementById('shippingEmpty').style.display   = 'block';
    document.getElementById('shippingEmpty').textContent     = 'Chọn địa chỉ giao hàng để xem phí ship';
    document.getElementById('shippingResult').style.display  = 'none';
    document.getElementById('shippingLoading').style.display = 'none';
    document.getElementById('shippingFeeInput').value        = 0;
    document.getElementById('feeDisplay').textContent        = 'Chưa tính';
    document.getElementById('grandTotal').textContent        = formatVND(BASE_TOTAL) + 'đ';
  }

  function formatVND(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  }

  // Highlight phương thức thanh toán
  document.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
    radio.addEventListener('change', function() {
      document.querySelectorAll('input[name="paymentMethod"]').forEach(r => {
        r.closest('label').style.borderColor = 'var(--sand)';
        r.closest('label').style.background  = 'white';
      });
      this.closest('label').style.borderColor = 'var(--green-mid)';
      this.closest('label').style.background  = 'var(--cream)';
    });
  });

  function checkCoupon() {
    const code = document.getElementById('couponCode').value.trim().toUpperCase();
    const res  = document.getElementById('couponResult');
    const coupons = { 'XANH10': '10%', 'GIAM50K': '50,000đ', 'CANH20': '20%' };
    if (coupons[code]) {
      res.textContent = '✅ Mã hợp lệ! Giảm ' + coupons[code];
      res.style.color = 'green';
    } else if (code) {
      res.textContent = '❌ Mã không hợp lệ';
      res.style.color = 'red';
    }
  }
</script>

<jsp:include page="footer.jsp" />
