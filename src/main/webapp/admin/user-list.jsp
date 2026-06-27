<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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

  <div class="admin-card">
    <div class="admin-card-header"><h2>Danh sách tài khoản</h2></div>
    <table class="admin-table">
      <thead>
      <tr>
        <th>#</th><th>Họ tên</th><th>Email</th><th>SĐT</th>
        <th>Vai trò</th><th>Trạng thái</th><th>Ngày tạo</th><th>Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach var="u" items="${users}">
        <tr>
          <td style="color:var(--muted)">${u.userId}</td>
          <td><strong>${u.fullName}</strong></td>
          <td style="color:var(--muted);font-size:13px">${u.email}</td>
          <td>${u.phone}</td>
          <td>
              <span class="badge ${u.role=='admin'?'badge-warning':'badge-info'}">
                  ${u.role=='admin'?'⚙️ Admin':'👤 User'}
              </span>
          </td>
          <td>
              <span class="badge ${u.active?'badge-success':'badge-danger'}">
                  ${u.active?'✅ Hoạt động':'🔒 Đã khóa'}
              </span>
          </td>
          <td style="color:var(--muted);font-size:13px">
           ${u.createdAtFormatted}
          </td>
          <td>
            <c:if test="${u.role != 'admin'}">
              <a href="${pageContext.request.contextPath}/admin/users?action=toggle&id=${u.userId}&active=${!u.active}"
                 class="btn btn-sm ${u.active?'btn-danger':''}"
                 style="${u.active?'':'background:#dcfce7;color:#166534'}"
                 onclick="return confirm('${u.active?'Khóa':'Mở khóa'} tài khoản này?')">
                  ${u.active?'🔒 Khóa':'🔓 Mở khóa'}
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
