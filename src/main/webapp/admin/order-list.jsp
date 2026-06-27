<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Quản lý Đơn hàng — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>📦 Quản lý Đơn hàng</h1>
  </div>

  <!-- FILTER TABS -->
  <div style="display:flex;gap:8px;margin-bottom:20px;flex-wrap:wrap">
    <c:forEach items="${['','pending','confirmed','shipping','done','cancelled']}" var="s">
      <a href="${pageContext.request.contextPath}/admin/orders${not empty s ? '?status='.concat(s) : ''}"
         class="btn btn-sm ${(empty param.status && empty s)||(param.status==s)?'btn-green':''}"
         style="${(empty param.status && empty s)||(param.status==s)?'':'border:1.5px solid var(--sand);color:var(--text)'}">
        <c:choose>
          <c:when test="${empty s}">Tất cả</c:when>
          <c:when test="${s=='pending'}">⏳ Chờ xác nhận</c:when>
          <c:when test="${s=='confirmed'}">✅ Đã xác nhận</c:when>
          <c:when test="${s=='shipping'}">🚚 Đang giao</c:when>
          <c:when test="${s=='done'}">🎉 Hoàn thành</c:when>
          <c:when test="${s=='cancelled'}">❌ Đã hủy</c:when>
        </c:choose>
      </a>
    </c:forEach>
  </div>

  <div class="admin-card">
    <div class="admin-card-header">
      <h2>Danh sách đơn hàng</h2>
    </div>
    <table class="admin-table">
      <thead>
      <tr>
        <th>#ID</th><th>Người nhận</th><th>SĐT</th>
        <th>Tổng tiền</th><th>Thanh toán</th><th>Trạng thái</th>
        <th>Ngày đặt</th><th>Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach var="o" items="${orders}">
        <tr>
          <td><strong>#${o.orderId}</strong></td>
          <td>${o.receiverName}</td>
          <td>${o.receiverPhone}</td>
          <td style="font-weight:700;color:var(--green-mid)">
            ${o.totalAmountFormatted}đ
          </td>
          <td>${o.paymentMethod=='cod'?'COD':'CK'}</td>
          <td>
            <!-- Dropdown đổi trạng thái -->
            <form action="${pageContext.request.contextPath}/admin/orders" method="get"
                  style="display:inline">
              <input type="hidden" name="action" value="updateStatus">
              <input type="hidden" name="id"     value="${o.orderId}">
              <select name="status" onchange="this.form.submit()"
                      style="border:1.5px solid var(--sand);border-radius:6px;
                               padding:4px 8px;font-size:12px;font-weight:600">
                <option value="pending"   ${o.status=='pending'  ?'selected':''}>⏳ Chờ xác nhận</option>
                <option value="confirmed" ${o.status=='confirmed'?'selected':''}>✅ Đã xác nhận</option>
                <option value="shipping"  ${o.status=='shipping' ?'selected':''}>🚚 Đang giao</option>
                <option value="done"      ${o.status=='done'     ?'selected':''}>🎉 Hoàn thành</option>
                <option value="cancelled" ${o.status=='cancelled'?'selected':''}>❌ Hủy</option>
              </select>
            </form>
          </td>
          <td style="color:var(--muted);font-size:13px">
            ${o.createdAtFormatted}
          </td>
          <td>
            <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${o.orderId}"
               class="btn btn-sm" style="background:#dbeafe;color:#1e40af">👁 Chi tiết</a>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>
</body></html>
