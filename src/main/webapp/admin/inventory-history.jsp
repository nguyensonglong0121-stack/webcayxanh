<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Lịch sử Nhập/Xuất kho — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>🕘 Lịch sử Nhập/Xuất kho</h1>
    <a href="${pageContext.request.contextPath}/admin/inventory" class="btn"
       style="border:1.5px solid var(--sand);color:var(--text)">← Quay lại tồn kho</a>
  </div>

  <div class="admin-card">
    <div class="admin-card-header">
      <h2>Tổng cộng ${total} giao dịch</h2>
    </div>

    <div style="padding:16px 20px 0">
      <form action="${pageContext.request.contextPath}/admin/inventory" method="get" class="admin-search">
        <input type="hidden" name="action" value="history">
        <input type="text" name="keyword" placeholder="Tìm theo tên sản phẩm..." value="${keyword}">
        <select name="type">
          <option value="">-- Tất cả loại --</option>
          <option value="import" ${type=='import'?'selected':''}>📥 Nhập kho</option>
          <option value="export" ${type=='export'?'selected':''}>📤 Xuất kho</option>
          <option value="adjust" ${type=='adjust'?'selected':''}>🛠 Điều chỉnh</option>
        </select>
        <button type="submit" class="btn btn-green btn-sm">Lọc</button>
      </form>
    </div>

    <table class="admin-table">
      <thead>
      <tr><th>Thời gian</th><th>Sản phẩm</th><th>Loại</th><th>Số lượng</th><th>Tồn sau GD</th><th>Ghi chú</th><th>Người thực hiện</th></tr>
      </thead>
      <tbody>
      <c:forEach var="h" items="${history}">
        <tr>
          <td style="white-space:nowrap">${h.createdAtFormatted}</td>
          <td><strong>${h.productName}</strong></td>
          <td>
            <c:choose>
              <c:when test="${h.type=='import'}"><span class="badge badge-success">📥 Nhập kho</span></c:when>
              <c:when test="${h.type=='export'}"><span class="badge badge-danger">📤 Xuất kho</span></c:when>
              <c:otherwise><span class="badge badge-info">🛠 Điều chỉnh</span></c:otherwise>
            </c:choose>
          </td>
          <td style="font-weight:700">
            ${h.type=='export' ? '-' : (h.type=='import' ? '+' : '±')}${h.quantity}
          </td>
          <td>${h.stockAfter}</td>
          <td>${h.note}</td>
          <td>${not empty h.createdByName ? h.createdByName : '—'}</td>
        </tr>
      </c:forEach>
      <c:if test="${empty history}">
        <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:24px">Không có giao dịch nào.</td></tr>
      </c:if>
      </tbody>
    </table>

    <c:if test="${totalPages > 1}">
      <div style="display:flex;gap:6px;justify-content:center;padding:16px">
        <c:forEach begin="1" end="${totalPages}" var="pg">
          <a href="${pageContext.request.contextPath}/admin/inventory?action=history&page=${pg}&type=${type}&keyword=${keyword}"
             class="btn btn-sm ${pg==page?'btn-green':''}"
             style="${pg==page?'':'border:1.5px solid var(--sand);color:var(--text)'}">${pg}</a>
        </c:forEach>
      </div>
    </c:if>
  </div>
</div>
</body></html>
