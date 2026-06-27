<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Lịch sử đơn hàng — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
  <div class="container">

    <div class="breadcrumb">
      <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
      <span>›</span>
      <a href="${pageContext.request.contextPath}/profile">Tài khoản</a>
      <span>›</span> Lịch sử đơn hàng
    </div>

    <h1 class="section-title" style="margin-bottom:28px">📋 Lịch sử đơn hàng</h1>

    <c:choose>
      <c:when test="${empty orders}">
        <div class="empty-state">
          <div class="icon">📦</div>
          <h3>Chưa có đơn hàng nào</h3>
          <p>Hãy bắt đầu mua sắm cây cảnh yêu thích!</p>
          <a href="${pageContext.request.contextPath}/products" class="btn btn-green">🌿 Mua sắm ngay</a>
        </div>
      </c:when>
      <c:otherwise>
        <div style="display:flex;flex-direction:column;gap:16px">
          <c:forEach var="o" items="${orders}">
            <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:20px">
              <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">

                <div style="display:flex;gap:24px;align-items:center;flex-wrap:wrap">
                  <div>
                    <div style="font-size:11px;color:var(--muted)">Mã đơn hàng</div>
                    <div style="font-weight:800;font-size:15px;color:var(--green-dark)">#${o.orderId}</div>
                  </div>
                  <div>
                    <div style="font-size:11px;color:var(--muted)">Ngày đặt</div>
                    <div style="font-weight:600;font-size:14px">
                      ${o.createdAtFormatted}
                    </div>
                  </div>
                  <div>
                    <div style="font-size:11px;color:var(--muted)">Tổng tiền</div>
                    <div style="font-weight:800;font-size:15px;color:var(--green-mid)">
                      ${o.totalAmountFormatted}đ
                    </div>
                  </div>
                </div>

                <div style="display:flex;align-items:center;gap:12px">
                    <%-- Trạng thái badge --%>
                  <c:choose>
                    <c:when test="${o.status == 'pending'}">
                      <span style="background:#fef9c3;color:#854d0e;font-size:12px;font-weight:700;padding:5px 14px;border-radius:20px">⏳ Chờ xác nhận</span>
                    </c:when>
                    <c:when test="${o.status == 'confirmed'}">
                      <span style="background:#dbeafe;color:#1e40af;font-size:12px;font-weight:700;padding:5px 14px;border-radius:20px">✅ Đã xác nhận</span>
                    </c:when>
                    <c:when test="${o.status == 'shipping'}">
                      <span style="background:#e0f2fe;color:#0369a1;font-size:12px;font-weight:700;padding:5px 14px;border-radius:20px">🚚 Đang giao</span>
                    </c:when>
                    <c:when test="${o.status == 'done'}">
                      <span style="background:#dcfce7;color:#166534;font-size:12px;font-weight:700;padding:5px 14px;border-radius:20px">🎉 Hoàn thành</span>
                    </c:when>
                    <c:when test="${o.status == 'cancelled'}">
                      <span style="background:#fee2e2;color:#dc2626;font-size:12px;font-weight:700;padding:5px 14px;border-radius:20px">❌ Đã hủy</span>
                    </c:when>
                  </c:choose>
                </div>
              </div>

              <div style="border-top:1px solid var(--sand);margin-top:14px;padding-top:14px;font-size:13px;color:var(--muted)">
                📍 Giao đến: <strong style="color:var(--text)">${o.address}</strong>
                &nbsp;|&nbsp;
                💳 ${o.paymentMethod == 'cod' ? 'Thanh toán khi nhận hàng' : 'Chuyển khoản'}
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</section>

<jsp:include page="footer.jsp" />
