<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8">
<title>${product!=null?'Sửa':'Thêm'} sản phẩm — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>${product!=null?'✏️ Sửa sản phẩm':'➕ Thêm sản phẩm mới'}</h1>
    <a href="${pageContext.request.contextPath}/admin/products" class="btn"
       style="border:1.5px solid var(--sand);color:var(--text)">← Quay lại</a>
  </div>

  <div class="admin-card">
    <div class="admin-card-body">
      <form action="${pageContext.request.contextPath}/admin/products" method="post">
        <input type="hidden" name="action"    value="${product!=null?'update':'insert'}">
        <c:if test="${product!=null}">
          <input type="hidden" name="productId" value="${product.productId}">
        </c:if>

        <div class="admin-form-grid">

          <div class="form-group full">
            <label>Tên sản phẩm <span style="color:red">*</span></label>
            <input class="form-control" type="text" name="name" required
                   value="${product!=null?product.name:''}" placeholder="Ví dụ: Cây Kim Tiền">
          </div>

          <div class="form-group">
            <label>Danh mục <span style="color:red">*</span></label>
            <select class="form-control" name="categoryId" required>
              <option value="">-- Chọn danh mục --</option>
              <c:forEach var="cat" items="${categories}">
                <option value="${cat.categoryId}"
                  ${product!=null && product.categoryId==cat.categoryId ? 'selected' : ''}>
                    ${cat.name}
                </option>
              </c:forEach>
            </select>
          </div>

          <div class="form-group">
            <label>Trạng thái</label>
            <select class="form-control" name="status">
              <option value="active"  ${product==null||product.status=='active'  ?'selected':''}>Hiển thị</option>
              <option value="hidden"  ${product!=null&&product.status=='hidden'  ?'selected':''}>Ẩn</option>
            </select>
          </div>

          <div class="form-group">
            <label>Giá gốc (đ) <span style="color:red">*</span></label>
            <input class="form-control" type="number" name="price" required min="0"
                   value="${product!=null?product.price:''}" placeholder="150000">
          </div>

          <div class="form-group">
            <label>Giá khuyến mãi (đ) <em style="font-weight:400;color:var(--muted)">(để trống nếu không có)</em></label>
            <input class="form-control" type="number" name="salePrice" min="0"
                   value="${product!=null&&product.salePrice>0?product.salePrice:''}" placeholder="120000">
          </div>

          <div class="form-group">
            <label>Tồn kho</label>
            <input class="form-control" type="number" name="stock" min="0"
                   value="${product!=null?product.stock:'0'}">
          </div>

          <div class="form-group">
            <label>Tên file ảnh chính</label>
            <input class="form-control" type="text" name="mainImage"
                   value="${product!=null?product.mainImage:''}"
                   placeholder="ten-anh.jpg (đặt file vào thư mục uploads/)">
            <div class="form-hint">Đặt file ảnh vào: webapp/uploads/</div>
          </div>

          <div class="form-group">
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
              <input type="checkbox" name="isFeatured" ${product!=null&&product.featured?'checked':''}>
              ⭐ Sản phẩm nổi bật (hiển thị trên trang chủ)
            </label>
          </div>

          <div class="form-group full">
            <label>Mô tả sản phẩm</label>
            <textarea class="form-control" name="description" rows="4"
                      placeholder="Mô tả chi tiết về cây cảnh...">${product!=null?product.description:''}</textarea>
          </div>

          <div class="form-group full">
            <label>Hướng dẫn chăm sóc</label>
            <textarea class="form-control" name="careTips" rows="4"
                      placeholder="Tưới bao nhiêu lần/tuần, cần ánh sáng như thế nào...">${product!=null?product.careTips:''}</textarea>
          </div>

        </div>

        <div style="display:flex;gap:12px;margin-top:8px">
          <button type="submit" class="btn btn-green btn-lg">
            ${product!=null?'💾 Lưu thay đổi':'➕ Thêm sản phẩm'}
          </button>
          <a href="${pageContext.request.contextPath}/admin/products"
             class="btn btn-lg" style="border:1.5px solid var(--sand);color:var(--text)">Hủy</a>
        </div>
      </form>
    </div>
  </div>
</div>
</body></html>
