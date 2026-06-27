<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Quản lý Người dùng — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>👥 Quản lý Người dùng</h1>
    <span style="color:var(--muted);font-size:14px">Tổng: ${users.size()} tài khoản</span>
  </div>

  <c:if test="${param.updated == '1'}">
    <div class="alert alert-success" style="margin-bottom:16px">✅ Cập nhật quyền thành công!</div>
  </c:if>

  <!-- BẢNG PHÂN QUYỀN -->
  <div class="admin-card" style="margin-bottom:20px">
    <div class="admin-card-header">
      <h2>🔐 Phân quyền hệ thống</h2>
    </div>
    <div style="padding:16px 20px">
      <table style="width:100%;border-collapse:collapse;font-size:13px">
        <thead>
        <tr>
          <th style="padding:10px 16px;background:#f8fafc;text-align:left;border-bottom:2px solid #e2e8f0">Chức năng</th>
          <th style="padding:10px 16px;background:#f8fafc;text-align:center;border-bottom:2px solid #e2e8f0">👤 User</th>
          <th style="padding:10px 16px;background:#f8fafc;text-align:center;border-bottom:2px solid #e2e8f0">🛡️ Mod</th>
          <th style="padding:10px 16px;background:#f8fafc;text-align:center;border-bottom:2px solid #e2e8f0">⚙️ Admin</th>
        </tr>
        </thead>
        <tbody>
        <tr><td style="padding:8px 16px;border-bottom:1px solid #f1f5f9">Mua hàng, xem sản phẩm</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td></tr>
        <tr style="background:#f8fafc"><td style="padding:8px 16px;border-bottom:1px solid #f1f5f9">Quản lý sản phẩm</td>
          <td style="text-align:center;color:#dc2626;font-size:16px">❌</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td></tr>
        <tr><td style="padding:8px 16px;border-bottom:1px solid #f1f5f9">Quản lý đơn hàng</td>
          <td style="text-align:center;color:#dc2626;font-size:16px">❌</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td></tr>
        <tr style="background:#f8fafc"><td style="padding:8px 16px;border-bottom:1px solid #f1f5f9">Quản lý người dùng</td>
          <td style="text-align:center;color:#dc2626;font-size:16px">❌</td>
          <td style="text-align:center;color:#dc2626;font-size:16px">❌</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td></tr>
        <tr><td style="padding:8px 16px">Dashboard & doanh thu</td>
          <td style="text-align:center;color:#dc2626;font-size:16px">❌</td>
          <td style="text-align:center;color:#dc2626;font-size:16px">❌</td>
          <td style="text-align:center;color:green;font-size:16px">✅</td></tr>
        </tbody>
      </table>
    </div>
  </div>

  <!-- DANH SÁCH USER -->
  <div class="admin-card">
    <div class="admin-card-header"><h2>Danh sách tài khoản</h2></div>
    <table class="admin-table">
      <thead>
      <tr>
        <th>#</th><th>Họ tên</th><th>Email</th><th>SĐT</th>
        <th>Vai trò hiện tại</th><th>Trạng thái</th>
        <th>Phân quyền</th><th>Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach var="u" items="${users}">
        <tr>
          <td style="color:var(--muted)">${u.userId}</td>
          <td><strong>${u.fullName}</strong></td>
          <td style="color:var(--muted);font-size:13px">${u.email}</td>
          <td>${u.phone}</td>

          <!-- Badge role -->
          <td>
            <c:choose>
              <c:when test="${u.role == 'admin'}">
                <span class="badge badge-warning">⚙️ Admin</span>
              </c:when>
              <c:when test="${u.role == 'mod'}">
                <span class="badge badge-primary">🛡️ Mod</span>
              </c:when>
              <c:otherwise>
                <span class="badge badge-muted">👤 User</span>
              </c:otherwise>
            </c:choose>
          </td>

          <!-- Trạng thái -->
          <td>
              <span class="badge ${u.active ? 'badge-success' : 'badge-danger'}">
                  ${u.active ? '✅ Hoạt động' : '🔒 Đã khóa'}
              </span>
          </td>

          <!-- Dropdown đổi role (chỉ cho user và mod, không đổi admin) -->
          <td>
            <c:choose>
              <c:when test="${u.role != 'admin'}">
                <form action="${pageContext.request.contextPath}/admin/users" method="get"
                      style="display:inline">
                  <input type="hidden" name="action" value="setRole">
                  <input type="hidden" name="id"     value="${u.userId}">
                  <select name="role" onchange="this.form.submit()"
                          style="border:1.5px solid var(--sand);border-radius:6px;
                                   padding:5px 8px;font-size:12px;font-weight:600;
                                   background:white;cursor:pointer">
                    <option value="user" ${u.role=='user'?'selected':''}>👤 User</option>
                    <option value="mod"  ${u.role=='mod' ?'selected':''}>🛡️ Mod</option>
                    <option value="admin" ${u.role=='admin'?'selected':''}>⚙️ Admin</option>
                  </select>
                </form>
              </c:when>
              <c:otherwise>
                <span style="color:var(--muted);font-size:12px">Không thể thay đổi</span>
              </c:otherwise>
            </c:choose>
          </td>

          <!-- Khóa / mở tài khoản -->
          <td>
            <c:if test="${u.role != 'admin'}">
              <a href="${pageContext.request.contextPath}/admin/users?action=toggle&id=${u.userId}&active=${!u.active}"
                 class="btn btn-sm ${u.active ? 'btn-danger' : ''}"
                 style="${u.active ? '' : 'background:#dcfce7;color:#166534'}"
                 onclick="return confirm('${u.active ? 'Khóa' : 'Mở khóa'} tài khoản ${u.fullName}?')">
                  ${u.active ? '🔒 Khóa' : '🔓 Mở khóa'}
              </a>
            </c:if>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>
</body></html>
