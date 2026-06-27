<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Đặt hàng thành công — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
  <div class="container" style="max-width:680px">

    <!-- SUCCESS ICON -->
    <div style="text-align:center;padding:40px 0 32px">
      <div style="font-size:72px;margin-bottom:16px">🎉</div>
      <h1 style="font-size:28px;font-weight:800;color:var(--green-dark);margin-bottom:8px">
        Đặt hàng thành công!
      </h1>
      <p style="color:var(--muted);font-size:16px">
        Cảm ơn bạn đã tin tưởng GreenShop. Đơn hàng của bạn đang được xử lý.
      </p>
    </div>

    <!-- CHI TIẾT ĐƠN HÀNG -->
    <c:if test="${order != null}">
      <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:28px;margin-bottom:24px">

        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px">
          <h3 style="font-size:16px;font-weight:800;color:var(--green-dark)">
            📋 Thông tin đơn hàng
          </h3>
          <span style="background:var(--cream);border:1px solid var(--sand);padding:4px 14px;
                       border-radius:20px;font-size:12px;font-weight:700;color:var(--green-mid)">
            #${order.orderId}
          </span>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px">
          <div>
            <div style="font-size:12px;color:var(--muted);margin-bottom:4px">Người nhận</div>
            <div style="font-weight:600">${order.receiverName}</div>
          </div>
          <div>
            <div style="font-size:12px;color:var(--muted);margin-bottom:4px">Số điện thoại</div>
            <div style="font-weight:600">${order.receiverPhone}</div>
          </div>
          <div style="grid-column:1/-1">
            <div style="font-size:12px;color:var(--muted);margin-bottom:4px">Địa chỉ giao hàng</div>
            <div style="font-weight:600">${order.address}</div>
          </div>
          <div>
            <div style="font-size:12px;color:var(--muted);margin-bottom:4px">Thanh toán</div>
            <div style="font-weight:600">
                ${order.paymentMethod == 'cod' ? '💵 Thanh toán khi nhận hàng' : '🏦 Chuyển khoản'}
            </div>
          </div>
          <div>
            <div style="font-size:12px;color:var(--muted);margin-bottom:4px">Trạng thái</div>
            <div>
              <span style="background:#fef9c3;color:#854d0e;font-size:12px;font-weight:700;
                           padding:4px 12px;border-radius:20px">
                ⏳ Chờ xác nhận
              </span>
            </div>
          </div>
        </div>

        <!-- Sản phẩm trong đơn -->
        <div style="border-top:1px solid var(--sand);padding-top:16px">
          <div style="font-size:13px;font-weight:700;color:var(--green-dark);margin-bottom:12px">
            Sản phẩm đã đặt
          </div>
          <c:forEach var="item" items="${order.items}">
            <div style="display:flex;justify-content:space-between;padding:8px 0;
                         border-bottom:1px solid var(--sand);font-size:14px">
              <span>${item.productName} <span style="color:var(--muted)">x${item.quantity}</span></span>
              <span style="font-weight:700;color:var(--green-mid)">
                ${item.subtotalFormatted}đ
              </span>
            </div>
          </c:forEach>
          <div style="display:flex;justify-content:space-between;padding-top:12px;
                       font-size:18px;font-weight:800;color:var(--green-dark)">
            <span>Tổng cộng</span>
            <span><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>đ</span>
          </div>
        </div>
      </div>

      <!-- HƯỚNG DẪN TIẾP THEO -->
      <c:if test="${order.paymentMethod == 'transfer'}">
        <div class="alert alert-info">
          <strong>🏦 Thông tin chuyển khoản:</strong><br>
          Ngân hàng: Vietcombank<br>
          Số tài khoản: <strong>1234567890</strong><br>
          Chủ tài khoản: <strong>CONG TY GREENSHOP</strong><br>
          Nội dung: <strong>GS${order.orderId}</strong>
        </div>
      </c:if>
    </c:if>

    <!-- ACTIONS -->
    <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
      <a href="${pageContext.request.contextPath}/orders" class="btn btn-green btn-lg">
        📋 Xem lịch sử đơn hàng
      </a>
      <a href="${pageContext.request.contextPath}/home" class="btn btn-lg"
         style="border:2px solid var(--sand);color:var(--text)">
        🌿 Tiếp tục mua sắm
      </a>
    </div>

  </div>
</section>

<jsp:include page="footer.jsp" />
