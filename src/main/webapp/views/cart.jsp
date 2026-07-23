<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Giỏ hàng — GreenShop" />
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
      <span>›</span> Giỏ hàng
    </div>
    <h1 class="section-title" style="margin-bottom:28px">🛒 Giỏ hàng của bạn</h1>

    <c:if test="${not empty param.warning}">
      <div class="alert alert-danger" style="background:#fff3cd;color:#7a5b00;border:1px solid #ffe08a">
        ⚠️ <c:out value="${param.warning}"/>
      </div>
    </c:if>

    <c:choose>
      <c:when test="${empty cart}">
        <div class="empty-state">
          <div class="icon">🛒</div>
          <h3>Giỏ hàng đang trống</h3>
          <p>Hãy thêm một vài cây cảnh vào giỏ nhé!</p>
          <a href="${pageContext.request.contextPath}/products" class="btn btn-green">🌿 Mua sắm ngay</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="cart-grid">
          <!-- Danh sách sản phẩm -->
          <div>
            <table class="cart-table">
              <thead>
              <tr>
                <th>Sản phẩm</th>
                <th>Đơn giá</th>
                <th>Số lượng</th>
                <th>Thành tiền</th>
                <th></th>
              </tr>
              </thead>
              <tbody id="cartBody">
              <c:forEach var="item" items="${cart}">
                <tr id="row-${item.productId}">
                  <td>
                    <div style="display:flex;align-items:center;gap:12px">
                      <img class="cart-item-img"
                           src="${pageContext.request.contextPath}/uploads/${item.mainImage}"
                           onerror="this.src='https://placehold.co/64x64/a8d5a2/1a3a2a?text=🌿'"
                           alt="${item.productName}">
                      <span style="font-weight:600">${item.productName}</span>
                    </div>
                  </td>
                  <td>${item.unitPriceFormatted}đ</td>
                  <td>
                    <div class="cart-qty">
                      <button onclick="changeQty(${item.productId}, -1)" class="btn btn-sm">−</button>
                      <input type="number" value="${item.quantity}" min="1"
                             onchange="updateQty(${item.productId}, this.value)"
                             id="qty-${item.productId}" style="width:56px;padding:6px;text-align:center;border:1.5px solid var(--sand);border-radius:6px">
                      <button onclick="changeQty(${item.productId}, 1)" class="btn btn-sm">+</button>
                    </div>
                  </td>
                  <td id="sub-${item.productId}" style="font-weight:700;color:var(--green-mid)">
                    ${item.subtotalFormatted}đ
                  </td>
                  <td>
                    <form action="${pageContext.request.contextPath}/cart" method="post" style="display:inline">
                      <input type="hidden" name="action"    value="remove">
                      <input type="hidden" name="productId" value="${item.productId}">
                      <button type="submit" class="btn btn-danger btn-sm">🗑</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
              </tbody>
            </table>

            <div style="margin-top:16px;display:flex;gap:12px">
              <a href="${pageContext.request.contextPath}/products" class="btn btn-outline" style="border-color:var(--sand);color:var(--text)">← Tiếp tục mua</a>
              <form action="${pageContext.request.contextPath}/cart" method="post">
                <input type="hidden" name="action" value="clear">
                <button type="submit" class="btn btn-danger">🗑 Xóa giỏ hàng</button>
              </form>
            </div>
          </div>

          <!-- Tóm tắt đơn hàng -->
          <div class="cart-summary">
            <h3>📋 Tóm tắt đơn hàng</h3>
            <div id="stockWarning" style="display:none;background:#fff3cd;color:#7a5b00;border:1px solid #ffe08a;border-radius:6px;padding:8px 10px;font-size:12px;margin-bottom:10px"></div>
            <div class="summary-row"><span>Tạm tính</span><span id="summaryTotal"><fmt:formatNumber value="${total}" pattern="#,###"/>đ</span></div>
            <div class="summary-row"><span>Phí giao hàng</span><span style="color:var(--muted);font-style:italic;font-size:13px">Tính ở bước thanh toán</span></div>
            <div class="summary-row total"><span>Tổng cộng</span><span id="summaryFinal"><fmt:formatNumber value="${total}" pattern="#,###"/>đ</span></div>

            <div style="margin:16px 0">
              <label style="font-size:13px;font-weight:600;margin-bottom:6px;display:block">Mã giảm giá</label>
              <div style="display:flex;gap:8px">
                <input type="text" id="couponInput" class="form-control" placeholder="Nhập mã..." style="flex:1">
                <button class="btn btn-gold btn-sm" onclick="applyCoupon()">Áp dụng</button>
              </div>
              <div id="couponMsg" style="font-size:12px;margin-top:4px"></div>
            </div>

            <a href="${pageContext.request.contextPath}/checkout" class="btn btn-green btn-block btn-lg">
              💳 Tiến hành thanh toán
            </a>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</section>

<script>
  var CTX = '${pageContext.request.contextPath}';
  var CART_TOTAL = ${total};

  // Bấm nút +/- : đọc số lượng HIỆN TẠI trong ô input rồi cộng/trừ delta,
  // thay vì dùng số cố định tính từ lúc trang tải (đó là nguyên nhân gây lỗi
  // bấm +/- không ăn sau lần đầu tiên).
  function changeQty(productId, delta) {
    const input = document.getElementById('qty-' + productId);
    let qty = (parseInt(input.value, 10) || 1) + delta;
    updateQty(productId, qty);
  }

  function updateQty(productId, qty) {
    qty = parseInt(qty, 10);
    if (isNaN(qty) || qty < 1) qty = 0;
    fetch('${pageContext.request.contextPath}/cart', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: `action=update&productId=\${productId}&quantity=\${qty}`
    })
            .then(r => r.json())
            .then(data => {
              if (qty === 0) {
                document.getElementById('row-' + productId).remove();
              } else {
                // Đồng bộ lại ô số lượng và thành tiền của dòng đó
                document.getElementById('qty-' + productId).value = data.quantity;
                document.getElementById('sub-' + productId).textContent = formatVND(data.itemSubtotal) + 'đ';
              }
              document.getElementById('summaryTotal').textContent = formatVND(data.total) + 'đ';
              document.getElementById('summaryFinal').textContent = formatVND(data.total) + 'đ';
              document.getElementById('cartBadge') && (document.getElementById('cartBadge').textContent = data.cartCount);
              // Đồng bộ lại CART_TOTAL để lần sau bấm "Áp dụng" mã giảm giá,
              // server nhận đúng số tiền tạm tính MỚI NHẤT (trước đây bị bỏ sót
              // dòng này nên coupon check luôn dùng số tiền lúc mới tải trang).
              CART_TOTAL = data.total;

              var stockMsg = document.getElementById('stockWarning');
              if (data.warning) {
                stockMsg.textContent = '⚠️ ' + data.warning; // textContent tự an toàn, không cần escape
                stockMsg.style.display = 'block';
              } else if (stockMsg) {
                stockMsg.style.display = 'none';
              }
            });
  }

  function formatVND(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  function applyCoupon() {
    const code = document.getElementById('couponInput').value.trim();
    const msg  = document.getElementById('couponMsg');
    if (!code) { msg.textContent = 'Vui lòng nhập mã!'; msg.style.color='red'; return; }

    msg.textContent = 'Đang kiểm tra...';
    msg.style.color = 'var(--muted)';

    fetch(CTX + '/coupon/check?code=' + encodeURIComponent(code) + '&subtotal=' + CART_TOTAL)
      .then(r => r.json())
      .then(data => {
        msg.textContent = (data.valid ? '✅ ' : '❌ ') + data.message +
          (data.valid ? ' (nhập lại mã này ở bước thanh toán để được trừ tiền)' : '');
        msg.style.color = data.valid ? 'green' : 'red';
      })
      .catch(() => {
        msg.textContent = '⚠️ Không kiểm tra được mã, thử lại sau';
        msg.style.color = 'red';
      });
  }
</script>

<jsp:include page="footer.jsp" />
