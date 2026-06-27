<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Chi tiết đơn #${order.orderId} — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>📋 Chi tiết đơn hàng #${order.orderId}</h1>
    <a href="${pageContext.request.contextPath}/admin/orders"
       class="btn" style="border:1.5px solid var(--sand);color:var(--text)">← Quay lại</a>
  </div>

  <div style="display:grid;grid-template-columns:1fr 340px;gap:24px;align-items:start">

    <!-- SẢN PHẨM -->
    <div class="admin-card">
      <div class="admin-card-header"><h2>🌿 Sản phẩm trong đơn</h2></div>
      <table class="admin-table">
        <thead><tr><th>Sản phẩm</th><th>Đơn giá</th><th>SL</th><th>Thành tiền</th></tr></thead>
        <tbody>
        <c:forEach var="item" items="${order.items}">
          <tr>
            <td><strong>${item.productName}</strong></td>
            <td>${item.unitPriceFormatted}đ</td>
            <td>${item.quantity}</td>
            <td style="font-weight:700;color:var(--green-mid)">
              ${item.subtotalFormatted}đ
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
      <div style="padding:16px 16px;text-align:right;border-top:2px solid var(--sand)">
        <span style="font-size:18px;font-weight:800;color:var(--green-dark)">
          Tổng: ${order.totalAmountFormatted}đ
        </span>
      </div>
    </div>

    <!-- THÔNG TIN ĐƠN -->
    <div>
      <div class="admin-card" style="margin-bottom:16px">
        <div class="admin-card-header"><h2>👤 Thông tin giao hàng</h2></div>
        <div class="admin-card-body" style="font-size:14px;line-height:2">
          <div><strong>Người nhận:</strong> ${order.receiverName}</div>
          <div><strong>SĐT:</strong> ${order.receiverPhone}</div>
          <div><strong>Địa chỉ:</strong> ${order.address}</div>
          <div><strong>Thanh toán:</strong> ${order.paymentMethod=='cod'?'💵 COD':'🏦 Chuyển khoản'}</div>
          <c:if test="${not empty order.note}">
            <div><strong>Ghi chú:</strong> ${order.note}</div>
          </c:if>
        </div>
      </div>

      <div class="admin-card">
        <div class="admin-card-header"><h2>📝 Cập nhật trạng thái</h2></div>
        <div class="admin-card-body">
          <form action="${pageContext.request.contextPath}/admin/orders" method="get">
            <input type="hidden" name="action" value="updateStatus">
            <input type="hidden" name="id"     value="${order.orderId}">
            <div class="form-group">
              <select class="form-control" name="status">
                <option value="pending"   ${order.status=='pending'  ?'selected':''}>⏳ Chờ xác nhận</option>
                <option value="confirmed" ${order.status=='confirmed'?'selected':''}>✅ Đã xác nhận</option>
                <option value="shipping"  ${order.status=='shipping' ?'selected':''}>🚚 Đang giao hàng</option>
                <option value="done"      ${order.status=='done'     ?'selected':''}>🎉 Hoàn thành</option>
                <option value="cancelled" ${order.status=='cancelled'?'selected':''}>❌ Đã hủy</option>
              </select>
            </div>
            <button type="submit" class="btn btn-green btn-block">Cập nhật</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
</body></html>
