<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo doanh thu — Admin GreenShop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.4/chart.umd.min.js"></script>
</head>
<body>

<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
    <div class="admin-topbar">
        <h1>📈 Báo cáo doanh thu</h1>
        <span style="color:var(--muted);font-size:13px">
            Từ <strong>${fromDate}</strong> đến <strong>${toDate}</strong>
        </span>
    </div>

    <!-- BỘ LỌC KHOẢNG THỜI GIAN -->
    <div class="admin-card">
        <div class="admin-card-body" style="padding-bottom:0">
            <div style="display:flex;gap:8px;margin-bottom:16px;flex-wrap:wrap">
                <a href="${pageContext.request.contextPath}/admin/reports?range=7d"
                   class="btn btn-sm ${range=='7d'?'btn-green':''}"
                   style="${range=='7d'?'':'border:1.5px solid var(--sand);color:var(--text)'}">7 ngày qua</a>
                <a href="${pageContext.request.contextPath}/admin/reports?range=30d"
                   class="btn btn-sm ${range=='30d'?'btn-green':''}"
                   style="${range=='30d'?'':'border:1.5px solid var(--sand);color:var(--text)'}">30 ngày qua</a>
                <a href="${pageContext.request.contextPath}/admin/reports?range=month"
                   class="btn btn-sm ${range=='month'?'btn-green':''}"
                   style="${range=='month'?'':'border:1.5px solid var(--sand);color:var(--text)'}">Tháng này</a>
                <a href="${pageContext.request.contextPath}/admin/reports?range=year"
                   class="btn btn-sm ${range=='year'?'btn-green':''}"
                   style="${range=='year'?'':'border:1.5px solid var(--sand);color:var(--text)'}">Năm nay</a>
            </div>
            <form action="${pageContext.request.contextPath}/admin/reports" method="get" class="admin-search" style="margin-bottom:16px">
                <input type="hidden" name="range" value="custom">
                <input type="date" name="from" value="${fromDate}" required>
                <span style="align-self:center;color:var(--muted)">đến</span>
                <input type="date" name="to" value="${toDate}" required>
                <button type="submit" class="btn btn-green btn-sm">🔍 Xem báo cáo</button>
            </form>
        </div>
    </div>

    <!-- STATS CARDS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background:#dcfce7;color:#166534">💰</div>
            <div>
                <div class="stat-label">Tổng doanh thu</div>
                <div class="stat-value">${totalRevenueFormatted}đ</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#dbeafe;color:#1e40af">📦</div>
            <div>
                <div class="stat-label">Số đơn hoàn thành</div>
                <div class="stat-value">${totalOrders}</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fef9c3;color:#854d0e">🧾</div>
            <div>
                <div class="stat-label">Giá trị đơn TB</div>
                <div class="stat-value">${avgOrderValueFormatted}đ</div>
            </div>
        </div>
    </div>

    <!-- BIỂU ĐỒ DOANH THU THEO NGÀY -->
    <div class="admin-card">
        <div class="admin-card-header">
            <h2>📊 Doanh thu theo ngày</h2>
        </div>
        <div class="admin-card-body">
            <c:choose>
                <c:when test="${empty dailyRevenue}">
                    <p style="color:var(--muted);text-align:center;padding:24px 0">
                        Không có dữ liệu doanh thu trong khoảng thời gian này.
                    </p>
                </c:when>
                <c:otherwise>
                    <canvas id="revenueChart" height="90"></canvas>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div style="display:grid;grid-template-columns:1.4fr 1fr;gap:24px;align-items:start">

        <!-- TOP SẢN PHẨM BÁN CHẠY -->
        <div class="admin-card">
            <div class="admin-card-header">
                <h2>🌿 Top sản phẩm bán chạy</h2>
            </div>
            <table class="admin-table">
                <thead>
                <tr>
                    <th>Sản phẩm</th>
                    <th>SL bán</th>
                    <th>Doanh thu</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="p" items="${topProducts}">
                    <tr>
                        <td style="display:flex;align-items:center;gap:10px">
                            <c:choose>
                                <c:when test="${not empty p.mainImage}">
                                    <img src="${pageContext.request.contextPath}/uploads/${p.mainImage}" alt="${p.productName}">
                                </c:when>
                                <c:otherwise>
                                    <div style="width:44px;height:44px;border-radius:8px;background:#f1f5f9;display:flex;align-items:center;justify-content:center">🌿</div>
                                </c:otherwise>
                            </c:choose>
                            <span>${p.productName}</span>
                        </td>
                        <td><strong>${p.quantitySold}</strong></td>
                        <td style="font-weight:700;color:var(--green-mid)">${p.revenueFormatted}đ</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty topProducts}">
                    <tr><td colspan="3" style="text-align:center;color:var(--muted);padding:20px">Chưa có sản phẩm nào bán ra</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>

        <!-- DOANH THU THEO PHƯƠNG THỨC THANH TOÁN -->
        <div class="admin-card">
            <div class="admin-card-header">
                <h2>💳 Theo phương thức thanh toán</h2>
            </div>
            <table class="admin-table">
                <thead>
                <tr>
                    <th>Phương thức</th>
                    <th>Số đơn</th>
                    <th>Doanh thu</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="pm" items="${paymentStats}">
                    <tr>
                        <td>${pm.methodLabel}</td>
                        <td>${pm.orderCount}</td>
                        <td style="font-weight:700;color:var(--green-mid)">${pm.revenueFormatted}đ</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty paymentStats}">
                    <tr><td colspan="3" style="text-align:center;color:var(--muted);padding:20px">Chưa có dữ liệu</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    <c:if test="${not empty dailyRevenue}">
    const labels   = [
        <c:forEach var="d" items="${dailyRevenue}">"${d.label}",</c:forEach>
    ];
    const revenues = [
        <c:forEach var="d" items="${dailyRevenue}">${d.revenue},</c:forEach>
    ];
    const orderCounts = [
        <c:forEach var="d" items="${dailyRevenue}">${d.orderCount},</c:forEach>
    ];

    new Chart(document.getElementById('revenueChart'), {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Doanh thu (đ)',
                data: revenues,
                borderColor: '#16a34a',
                backgroundColor: 'rgba(22,163,74,0.12)',
                fill: true,
                tension: 0.3,
                pointRadius: 3
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (ctx) => {
                            const idx = ctx.dataIndex;
                            return 'Doanh thu: ' + ctx.parsed.y.toLocaleString('vi-VN') +
                                   'đ — ' + orderCounts[idx] + ' đơn';
                        }
                    }
                }
            },
            scales: {
                y: { ticks: { callback: (v) => v.toLocaleString('vi-VN') } }
            }
        }
    });
    </c:if>
</script>

</body>
</html>
