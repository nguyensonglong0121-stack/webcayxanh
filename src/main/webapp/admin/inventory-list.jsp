<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Quản lý Tồn kho — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>📦 Quản lý Tồn kho</h1>
    <a href="${pageContext.request.contextPath}/admin/inventory?action=history" class="btn"
       style="border:1.5px solid var(--sand);color:var(--text)">🕘 Lịch sử giao dịch</a>
  </div>

  <!-- STATS CARDS -->
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-icon" style="background:#e0f2fe;color:#0369a1">🌿</div>
      <div>
        <div class="stat-label">Tổng số sản phẩm</div>
        <div class="stat-value">${summary.totalProducts}</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:#dcfce7;color:#166534">📥</div>
      <div>
        <div class="stat-label">Tổng số lượng tồn</div>
        <div class="stat-value">${summary.totalStock}</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:#fef9c3;color:#854d0e">⚠️</div>
      <div>
        <div class="stat-label">Sắp hết hàng (≤ ${threshold})</div>
        <div class="stat-value">${summary.lowStock}</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon" style="background:#fee2e2;color:#dc2626">🚫</div>
      <div>
        <div class="stat-label">Đã hết hàng</div>
        <div class="stat-value">${summary.outOfStock}</div>
      </div>
    </div>
  </div>

  <c:if test="${param.success == '1'}">
    <div class="alert alert-success">✅ Cập nhật tồn kho thành công!</div>
  </c:if>
  <c:if test="${param.error == '1'}">
    <div class="alert alert-danger">❌ Không thể cập nhật (kiểm tra lại số lượng tồn kho).</div>
  </c:if>

  <div class="admin-card">
    <div class="admin-card-header">
      <h2>Danh sách tồn kho (${products.size()})</h2>
    </div>

    <div style="padding:16px 20px 0">
      <form action="${pageContext.request.contextPath}/admin/inventory" method="get" class="admin-search">
        <input type="text" name="keyword" placeholder="Tìm sản phẩm..." value="${keyword}">
        <select name="filter" onchange="this.form.submit()">
          <option value="">-- Tất cả --</option>
          <option value="low" ${filter=='low'?'selected':''}>⚠️ Sắp hết hàng</option>
          <option value="out" ${filter=='out'?'selected':''}>🚫 Đã hết hàng</option>
        </select>
        <button type="submit" class="btn btn-green btn-sm">Lọc</button>
        <c:if test="${not empty keyword || not empty filter}">
          <a href="${pageContext.request.contextPath}/admin/inventory" class="btn btn-sm"
             style="border:1.5px solid var(--sand);color:var(--text)">Xoá lọc</a>
        </c:if>
      </form>
    </div>

    <table class="admin-table">
      <thead>
      <tr>
        <th>#</th><th>Ảnh</th><th>Tên sản phẩm</th><th>Danh mục</th>
        <th>Tồn kho hiện tại</th><th>Trạng thái</th><th>Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach var="p" items="${products}">
        <tr>
          <td style="color:var(--muted)">${p.productId}</td>
          <td>
            <img src="${pageContext.request.contextPath}/uploads/${p.mainImage}"
                 onerror="this.src='https://placehold.co/44x44/a8d5a2/1a3a2a?text=🌿'"
                 alt="${p.name}">
          </td>
          <td><strong>${p.name}</strong></td>
          <td><span class="badge badge-muted">${p.categoryName}</span></td>
          <td>
            <span style="color:${p.stock==0?'#dc2626':p.stock<=threshold?'#854d0e':'inherit'};font-weight:700;font-size:15px">
                ${p.stock}
            </span>
          </td>
          <td>
            <c:choose>
              <c:when test="${p.stock == 0}">
                <span class="badge badge-danger">Hết hàng</span>
              </c:when>
              <c:when test="${p.stock <= threshold}">
                <span class="badge badge-warning">Sắp hết</span>
              </c:when>
              <c:otherwise>
                <span class="badge badge-success">Còn hàng</span>
              </c:otherwise>
            </c:choose>
          </td>
          <td>
            <div class="tbl-actions">
              <a href="${pageContext.request.contextPath}/admin/inventory?action=form&id=${p.productId}"
                 class="btn btn-green btn-sm">📦 Nhập / Xuất</a>
            </div>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty products}">
        <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:24px">
          Không có sản phẩm nào phù hợp.
        </td></tr>
      </c:if>
      </tbody>
    </table>
  </div>
</div>
</body></html>
