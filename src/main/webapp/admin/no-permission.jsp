<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Không có quyền — GreenShop</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />
<div class="admin-main">
    <div style="text-align:center;padding:80px 24px">
        <div style="font-size:72px;margin-bottom:16px">🚫</div>
        <h1 style="font-size:26px;font-weight:800;color:var(--green-dark);margin-bottom:12px">
            Không có quyền truy cập
        </h1>
        <p style="color:var(--muted);font-size:15px;margin-bottom:32px">
            Bạn không được phép vào trang này.<br>
            Liên hệ Admin để được cấp quyền.
        </p>
        <div style="display:flex;gap:12px;justify-content:center">
            <a href="${pageContext.request.contextPath}/admin/products"
               class="btn btn-green">🌿 Quản lý Sản phẩm</a>
            <a href="${pageContext.request.contextPath}/admin/orders"
               class="btn" style="border:1.5px solid var(--sand);color:var(--text)">
                📦 Quản lý Đơn hàng</a>
        </div>
    </div>
</div>
</body></html>
