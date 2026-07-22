<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Nhập / Xuất kho — ${product.name}</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>📦 Nhập / Xuất kho</h1>
    <a href="${pageContext.request.contextPath}/admin/inventory" class="btn"
       style="border:1.5px solid var(--sand);color:var(--text)">← Quay lại</a>
  </div>

  <c:if test="${param.success == '1'}">
    <div class="alert alert-success">✅ Cập nhật tồn kho thành công!</div>
  </c:if>
  <c:if test="${param.error == '1'}">
    <div class="alert alert-danger">❌ Không thể thực hiện. Số lượng xuất có thể vượt quá tồn kho hiện tại.</div>
  </c:if>

  <!-- Thông tin sản phẩm -->
  <div class="admin-card">
    <div class="admin-card-body" style="display:flex;align-items:center;gap:16px">
      <img src="${pageContext.request.contextPath}/uploads/${product.mainImage}"
           onerror="this.src='https://placehold.co/64x64/a8d5a2/1a3a2a?text=🌿'"
           style="width:64px;height:64px;border-radius:10px;object-fit:cover">
      <div style="flex:1">
        <div style="font-weight:800;font-size:16px;color:var(--green-dark)">${product.name}</div>
        <div style="font-size:13px;color:var(--muted)">${product.categoryName}</div>
      </div>
      <div style="text-align:right">
        <div class="stat-label">Tồn kho hiện tại</div>
        <div style="font-size:28px;font-weight:800;
             color:${product.stock==0?'#dc2626':product.stock<=5?'#854d0e':'var(--green-mid)'}">
            ${product.stock}
        </div>
      </div>
    </div>
  </div>

  <!-- Form nhập / xuất / điều chỉnh -->
  <div class="admin-card">
    <div class="admin-card-header"><h2>Cập nhật tồn kho</h2></div>
    <div class="admin-card-body">
      <div style="display:flex;gap:8px;margin-bottom:20px" id="tabBar">
        <button type="button" class="btn btn-green btn-sm tab-btn active" data-tab="import">📥 Nhập kho</button>
        <button type="button" class="btn btn-sm tab-btn" data-tab="export"
                style="border:1.5px solid var(--sand);color:var(--text)">📤 Xuất kho</button>
        <button type="button" class="btn btn-sm tab-btn" data-tab="adjust"
                style="border:1.5px solid var(--sand);color:var(--text)">🛠 Điều chỉnh</button>
      </div>

      <!-- Nhập kho -->
      <form action="${pageContext.request.contextPath}/admin/inventory" method="post" class="tab-panel" id="panel-import">
        <input type="hidden" name="action" value="import">
        <input type="hidden" name="productId" value="${product.productId}">
        <div class="admin-form-grid">
          <div class="form-group">
            <label>Số lượng nhập <span style="color:red">*</span></label>
            <input class="form-control" type="number" name="quantity" min="1" required placeholder="Ví dụ: 20">
          </div>
          <div class="form-group">
            <label>Ghi chú</label>
            <input class="form-control" type="text" name="note" placeholder="Ví dụ: Nhập từ nhà vườn Đà Lạt">
          </div>
        </div>
        <button type="submit" class="btn btn-green btn-lg" style="margin-top:12px">📥 Xác nhận nhập kho</button>
      </form>

      <!-- Xuất kho -->
      <form action="${pageContext.request.contextPath}/admin/inventory" method="post" class="tab-panel" id="panel-export" style="display:none">
        <input type="hidden" name="action" value="export">
        <input type="hidden" name="productId" value="${product.productId}">
        <div class="admin-form-grid">
          <div class="form-group">
            <label>Số lượng xuất <span style="color:red">*</span></label>
            <input class="form-control" type="number" name="quantity" min="1" max="${product.stock}" required placeholder="Ví dụ: 5">
            <div class="form-hint">Tối đa ${product.stock} (số lượng hiện có)</div>
          </div>
          <div class="form-group">
            <label>Ghi chú</label>
            <input class="form-control" type="text" name="note" placeholder="Ví dụ: Hàng hỏng, trả nhà cung cấp...">
          </div>
        </div>
        <button type="submit" class="btn btn-lg" style="margin-top:12px;background:#fee2e2;color:#dc2626">📤 Xác nhận xuất kho</button>
      </form>

      <!-- Điều chỉnh -->
      <form action="${pageContext.request.contextPath}/admin/inventory" method="post" class="tab-panel" id="panel-adjust" style="display:none">
        <input type="hidden" name="action" value="adjust">
        <input type="hidden" name="productId" value="${product.productId}">
        <div class="admin-form-grid">
          <div class="form-group">
            <label>Số lượng tồn kho thực tế <span style="color:red">*</span></label>
            <input class="form-control" type="number" name="newStock" min="0" required value="${product.stock}">
            <div class="form-hint">Dùng khi kiểm kê phát hiện lệch số liệu so với hệ thống.</div>
          </div>
          <div class="form-group">
            <label>Ghi chú</label>
            <input class="form-control" type="text" name="note" placeholder="Ví dụ: Kiểm kê định kỳ tháng 7">
          </div>
        </div>
        <button type="submit" class="btn btn-lg" style="margin-top:12px;background:#dbeafe;color:#1e40af">🛠 Xác nhận điều chỉnh</button>
      </form>
    </div>
  </div>

  <!-- Lịch sử giao dịch của sản phẩm này -->
  <div class="admin-card">
    <div class="admin-card-header"><h2>Lịch sử giao dịch</h2></div>
    <table class="admin-table">
      <thead>
      <tr><th>Thời gian</th><th>Loại</th><th>Số lượng</th><th>Tồn sau GD</th><th>Ghi chú</th><th>Người thực hiện</th></tr>
      </thead>
      <tbody>
      <c:forEach var="h" items="${history}">
        <tr>
          <td>${h.createdAtFormatted}</td>
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
        <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:20px">Chưa có giao dịch nào.</td></tr>
      </c:if>
      </tbody>
    </table>
  </div>
</div>

<script>
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(b => {
      b.classList.remove('btn-green', 'active');
      b.style.border = '1.5px solid var(--sand)';
      b.style.color = 'var(--text)';
    });
    btn.classList.add('btn-green', 'active');
    btn.style.border = 'none';
    btn.style.color = '';

    document.querySelectorAll('.tab-panel').forEach(p => p.style.display = 'none');
    document.getElementById('panel-' + btn.dataset.tab).style.display = 'block';
  });
});
</script>
</body></html>
