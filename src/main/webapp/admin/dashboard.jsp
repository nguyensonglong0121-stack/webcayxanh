<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Admin GreenShop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
    <div class="admin-topbar">
        <h1>📊 Dashboard</h1>
        <span style="color:var(--muted);font-size:13px">Xin chào, ${loggedUser.fullName}</span>
    </div>

    <!-- STATS CARDS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background:#dcfce7;color:#166534">💰</div>
            <div>
                <div class="stat-label">Doanh thu</div>
                <div class="stat-value">${totalRevenueFormatted}đđ</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fef9c3;color:#854d0e">⏳</div>
            <div>
                <div class="stat-label">Đơn chờ xử lý</div>
                <div class="stat-value">${pendingOrders}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#dbeafe;color:#1e40af">✅</div>
            <div>
                <div class="stat-label">Đơn hoàn thành</div>
                <div class="stat-value">${doneOrders}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#e0f2fe;color:#0369a1">👥</div>
            <div>
                <div class="stat-label">Tổng khách hàng</div>
                <div class="stat-value">${totalUsers}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fce7f3;color:#9d174d">🌿</div>
            <div>
                <div class="stat-label">Tổng sản phẩm</div>
                <div class="stat-value">${totalProducts}</div>
            </div>
        </div>
    </div>

    <!-- ĐƠN HÀNG GẦN ĐÂY -->
    <div class="admin-card">
        <div class="admin-card-header">
            <h2>📦 Đơn hàng gần đây</h2>
            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-green btn-sm">Xem tất cả</a>
        </div>
        <table class="admin-table">
            <thead>
            <tr>
                <th>#ID</th>
                <th>Người nhận</th>
                <th>Tổng tiền</th>
                <th>Thanh toán</th>
                <th>Trạng thái</th>
                <th>Ngày đặt</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="o" items="${recentOrders}" begin="0" end="9">
                <tr>
                    <td><strong>#${o.orderId}</strong></td>
                    <td>${o.receiverName}</td>
                    <td style="font-weight:700;color:var(--green-mid)">
                        ${o.totalAmountFormatted}đ
                    </td>
                    <td>${o.paymentMethod == 'cod' ? 'COD' : 'Chuyển khoản'}</td>
                    <td>
                        <c:choose>
                            <c:when test="${o.status=='pending'}">  <span class="badge badge-warning">Chờ xác nhận</span></c:when>
                            <c:when test="${o.status=='confirmed'}"><span class="badge badge-info">Đã xác nhận</span></c:when>
                            <c:when test="${o.status=='shipping'}"> <span class="badge badge-primary">Đang giao</span></c:when>
                            <c:when test="${o.status=='done'}">     <span class="badge badge-success">Hoàn thành</span></c:when>
                            <c:when test="${o.status=='cancelled'}"><span class="badge badge-danger">Đã hủy</span></c:when>
                        </c:choose>
                    </td>
                    <td style="color:var(--muted);font-size:13px">
                        ${o.createdAtDate}
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
