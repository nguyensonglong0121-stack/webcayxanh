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
  pageContext.setAttribute("cart",  cart);
  pageContext.setAttribute("total", total);
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

      <!-- FORM THÔNG TIN -->
      <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">

        <!-- Thông tin giao hàng -->
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

          <div class="form-group">
            <label>Địa chỉ giao hàng <span style="color:red">*</span></label>
            <input class="form-control" type="text" name="address" required
                   placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành"
                   value="${loggedUser != null ? loggedUser.address : ''}">
          </div>

          <div class="form-group">
            <label>Ghi chú đơn hàng</label>
            <textarea class="form-control" name="note" rows="2"
                      placeholder="Yêu cầu đặc biệt (giao giờ hành chính, để trước cửa...)"></textarea>
          </div>
        </div>

        <!-- Phương thức thanh toán -->
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:20px">
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
                         border:1.5px solid var(--sand);border-radius:10px;
                         cursor:pointer;margin-bottom:10px">
            <input type="radio" name="paymentMethod" value="transfer">
            <div>
              <div style="font-weight:700">🏦 Chuyển khoản ngân hàng</div>
              <div style="font-size:12px;color:var(--muted)">Vietcombank: 1234567890 — GreenShop JSC</div>
            </div>
          </label>
        </div>

        <!-- Mã giảm giá -->
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:16px">
            🎟️ Mã giảm giá
          </h3>
          <div style="display:flex;gap:10px">
            <input type="text" name="couponCode" id="couponCode" class="form-control"
                   placeholder="Nhập mã: XANH10, GIAM50K, CANH20">
            <button type="button" class="btn btn-gold" onclick="checkCoupon()">Áp dụng</button>
          </div>
          <div id="couponResult" style="font-size:13px;margin-top:8px"></div>
        </div>

        <button type="submit" class="btn btn-green btn-block btn-lg">
          ✅ Xác nhận đặt hàng
        </button>
      </form>

      <!-- ĐƠN HÀNG TÓM TẮT -->
      <div style="position:sticky;top:80px">
        <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark);margin-bottom:20px">
            📋 Đơn hàng của bạn
          </h3>

          <c:forEach var="item" items="${cart}">
            <div style="display:flex;gap:12px;margin-bottom:12px;padding-bottom:12px;border-bottom:1px solid var(--sand)">
              <img src="${pageContext.request.contextPath}/uploads/${item.mainImage}"
                   onerror="this.src='https://placehold.co/56x56/a8d5a2/1a3a2a?text=🌿'"
                   style="width:56px;height:56px;border-radius:8px;object-fit:cover;flex-shrink:0"
                   alt="${item.productName}">
              <div style="flex:1;min-width:0">
                <div style="font-weight:600;font-size:13px;margin-bottom:4px">${item.productName}</div>
                <div style="font-size:12px;color:var(--muted)">x${item.quantity}</div>
              </div>
              <div style="font-weight:700;font-size:13px;color:var(--green-mid);white-space:nowrap">
                ${item.subtotalFormatted}đ
              </div>
            </div>
          </c:forEach>

          <div class="summary-row" style="border-bottom:1px solid var(--sand);padding:8px 0">
            <span style="font-size:14px">Tạm tính</span>
            <span style="font-weight:700"><fmt:formatNumber value="${total}" pattern="#,###"/>đ</span>
          </div>
          <div class="summary-row" style="border-bottom:1px solid var(--sand);padding:8px 0">
            <span style="font-size:14px">Phí giao hàng</span>
            <span style="color:green;font-weight:700">Miễn phí</span>
          </div>
          <div style="display:flex;justify-content:space-between;padding-top:12px">
            <span style="font-size:17px;font-weight:800;color:var(--green-dark)">Tổng cộng</span>
            <span style="font-size:20px;font-weight:800;color:var(--green-mid)" id="finalTotal">
              <fmt:formatNumber value="${total}" pattern="#,###"/>đ
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<script>
  // Highlight phương thức thanh toán khi chọn
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
      res.textContent = '✅ Mã hợp lệ! Giảm ' + coupons[code] + ' (áp dụng khi đặt hàng)';
      res.style.color = 'green';
    } else if (code) {
      res.textContent = '❌ Mã không hợp lệ hoặc đã hết hạn';
      res.style.color = 'red';
    }
  }
</script>

<jsp:include page="footer.jsp" />
