<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    com.caycanhweb.model.User loggedUser =
            (com.caycanhweb.model.User) session.getAttribute("loggedUser");
    pageContext.setAttribute("loggedUser", loggedUser);
    String uri = request.getRequestURI();
    pageContext.setAttribute("currentUri", uri);
%>
<aside class="admin-sidebar">
    <div class="sidebar-brand">🌿 GreenShop<span>Admin</span></div>

    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard"
           class="${currentUri.contains('dashboard') ? 'active' : ''}">
            📊 Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/admin/products"
           class="${currentUri.contains('products') ? 'active' : ''}">
            🌿 Sản phẩm
        </a>
        <a href="${pageContext.request.contextPath}/admin/orders"
           class="${currentUri.contains('orders') ? 'active' : ''}">
            📦 Đơn hàng
        </a>
        <a href="${pageContext.request.contextPath}/admin/users"
           class="${currentUri.contains('users') ? 'active' : ''}">
            👥 Người dùng
        </a>
        <hr style="border-color:rgba(255,255,255,.1);margin:12px 0">
        <a href="${pageContext.request.contextPath}/home" target="_blank">
            🌐 Xem website
        </a>
        <a href="${pageContext.request.contextPath}/logout" style="color:#fca5a5">
            🚪 Đăng xuất
        </a>
    </nav>
</aside>
