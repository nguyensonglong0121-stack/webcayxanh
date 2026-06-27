<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    com.caycanhweb.model.User lu =
            (com.caycanhweb.model.User) session.getAttribute("loggedUser");
    String role    = (lu != null) ? lu.getRole() : "";
    String currUri = request.getRequestURI();
    request.setAttribute("sidebarUser", lu);
    request.setAttribute("sidebarRole", role);
    request.setAttribute("currUri",     currUri);
%>
<aside class="admin-sidebar">
    <div class="sidebar-brand">
        🌿 GreenShop
        <span>
      <c:choose>
          <c:when test="${sidebarRole == 'admin'}">⚙️ Admin</c:when>
          <c:when test="${sidebarRole == 'mod'}">🛡️ Moderator</c:when>
          <c:otherwise>Nhân viên</c:otherwise>
      </c:choose>
    </span>
    </div>

    <nav class="sidebar-nav">

        <%-- Dashboard — chỉ Admin --%>
        <c:if test="${sidebarRole == 'admin'}">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="${currUri.contains('dashboard') ? 'active' : ''}">
                📊 Dashboard
            </a>
        </c:if>

        <%-- Sản phẩm — Admin + Mod --%>
        <a href="${pageContext.request.contextPath}/admin/products"
           class="${currUri.contains('products') ? 'active' : ''}">
            🌿 Sản phẩm
        </a>

        <%-- Đơn hàng — Admin + Mod --%>
        <a href="${pageContext.request.contextPath}/admin/orders"
           class="${currUri.contains('orders') ? 'active' : ''}">
            📦 Đơn hàng
        </a>

        <%-- Người dùng — chỉ Admin --%>
        <c:if test="${sidebarRole == 'admin'}">
            <a href="${pageContext.request.contextPath}/admin/users"
               class="${currUri.contains('users') ? 'active' : ''}">
                👥 Người dùng
            </a>
        </c:if>

        <hr style="border-color:rgba(255,255,255,.1);margin:12px 0">

        <a href="${pageContext.request.contextPath}/home" target="_blank">
            🌐 Xem website
        </a>
        <a href="${pageContext.request.contextPath}/logout" style="color:#fca5a5">
            🚪 Đăng xuất
        </a>
    </nav>

    <%-- Info box --%>
    <div style="margin-top:auto;padding:16px;border-top:1px solid rgba(255,255,255,.1)">
        <div style="font-size:12px;color:rgba(255,255,255,.5)">Đăng nhập với</div>
        <c:if test="${sidebarUser != null}">
            <div style="font-size:13px;font-weight:600;color:white;margin-top:4px">
                    ${sidebarUser.fullName}
            </div>
            <div style="font-size:11px;color:rgba(255,255,255,.4)">${sidebarUser.email}</div>
        </c:if>
    </div>
</aside>
