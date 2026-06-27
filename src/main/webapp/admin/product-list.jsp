<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Quản lý Sản phẩm — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>🌿 Quản lý Sản phẩm</h1>
    <a href="${pageContext.request.contextPath}/admin/products?action=new" class="btn btn-green">
      + Thêm sản phẩm
    </a>
  </div>

  <c:if test="${param.deleted == '1'}">
    <div class="alert alert-success">✅ Đã ẩn sản phẩm thành công!</div>
  </c:if>

  <div class="admin-card">
    <div class="admin-card-header">
      <h2>Danh sách sản phẩm (${products.size()})</h2>
      <form action="${pageContext.request.contextPath}/admin/products" method="get" style="display:flex;gap:8px">
        <input type="text" name="keyword" placeholder="Tìm sản phẩm..." class="form-control" style="width:200px" value="${param.keyword}">
        <button type="submit" class="btn btn-green btn-sm">Tìm</button>
      </form>
    </div>

    <table class="admin-table">
      <thead>
      <tr>
        <th>#</th><th>Ảnh</th><th>Tên sản phẩm</th><th>Danh mục</th>
        <th>Giá</th><th>Tồn kho</th><th>Nổi bật</th><th>Trạng thái</th><th>Thao tác</th>
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
            <div style="font-weight:700;color:var(--green-mid)">
              ${p.displayPriceFormatted}đ
            </div>
            <c:if test="${p.salePrice > 0 and p.salePrice < p.price}">
              <div style="font-size:11px;text-decoration:line-through;color:var(--muted)">
                  ${p.priceFormatted}đ
              </div>
            </c:if>
          </td>
          <td>
              <span style="color:${p.stock==0?'red':p.stock<5?'orange':'inherit'};font-weight:600">
                  ${p.stock}
              </span>
          </td>
          <td>${p.featured ? '⭐' : '—'}</td>
          <td>
              <span class="badge ${p.status=='active'?'badge-success':'badge-muted'}">
                  ${p.status=='active'?'Hiển thị':'Đã ẩn'}
              </span>
          </td>
          <td>
            <div class="tbl-actions">
              <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.productId}"
                 class="btn btn-sm" style="background:#dbeafe;color:#1e40af">✏️ Sửa</a>
              <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${p.productId}"
                 class="btn btn-danger btn-sm"
                 onclick="return confirm('Ẩn sản phẩm này?')">🗑</a>
            </div>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>
</body></html>
