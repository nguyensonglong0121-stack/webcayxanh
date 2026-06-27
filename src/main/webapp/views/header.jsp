<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    com.caycanhweb.model.User loggedUser =
            (com.caycanhweb.model.User) session.getAttribute("loggedUser");
    java.util.List<?> cart =
            (java.util.List<?>) session.getAttribute("cart");
    int cartCount = (cart != null) ? cart.size() : 0;
    pageContext.setAttribute("loggedUser", loggedUser);
    pageContext.setAttribute("cartCount",  cartCount);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'GreenShop — Cây Cảnh Online'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🌿</text></svg>">
</head>
<body>

<nav class="navbar">
    <div class="navbar-inner">
        <a href="${pageContext.request.contextPath}/home" class="navbar-brand">🌿 Green<span>Shop</span></a>

        <div class="navbar-nav">
            <a href="${pageContext.request.contextPath}/home">Trang Chủ</a>
            <a href="${pageContext.request.contextPath}/products">Sản Phẩm</a>
            <a href="${pageContext.request.contextPath}/products?cat=1">Xương Rồng</a>
            <a href="${pageContext.request.contextPath}/products?cat=4">Phong Thủy</a>
        </div>

        <form class="navbar-search" action="${pageContext.request.contextPath}/products" method="get">
            <input type="text" name="keyword" placeholder="Tìm cây cảnh..." value="${param.keyword}">
            <button type="submit">🔍</button>
        </form>

        <div class="navbar-actions">
            <a href="${pageContext.request.contextPath}/cart">
                <button class="btn-nav-icon">
                    🛒
                    <c:if test="${cartCount > 0}">
                        <span class="cart-badge" id="cartBadge">${cartCount}</span>
                    </c:if>
                </button>
            </a>

            <c:choose>
                <c:when test="${loggedUser != null}">
                    <a href="${pageContext.request.contextPath}/profile">
                        <button class="btn-nav-login">👤 ${loggedUser.fullName}</button>
                    </a>
                    <c:if test="${loggedUser.role == 'admin'}">
                        <a href="${pageContext.request.contextPath}/admin/dashboard">
                            <button class="btn-nav-login" style="background:#c9a84c">⚙️ Admin</button>
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/logout">
                        <button class="btn-nav-login" style="background:rgba(255,255,255,.15);color:white">Đăng xuất</button>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login">
                        <button class="btn-nav-login">Đăng nhập</button>
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>
