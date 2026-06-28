<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head>
<meta charset="UTF-8"><title>Quản lý Người dùng — Admin</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
<style>
  .perm-card {
    background:white;border:1px solid #e2e8f0;border-radius:10px;
    padding:20px;margin-bottom:12px;
  }
  .perm-header {
    display:flex;align-items:center;justify-content:space-between;
    margin-bottom:14px;flex-wrap:wrap;gap:8px;
  }
  .perm-user { display:flex;align-items:center;gap:12px; }
  .perm-avatar {
    width:40px;height:40px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-size:16px;font-weight:700;color:white;flex-shrink:0;
  }
  .perm-name { font-weight:700;font-size:15px;color:var(--green-dark); }
  .perm-email { font-size:12px;color:var(--muted); }
  .perm-checkboxes {
    display:flex;gap:12px;flex-wrap:wrap;margin-bottom:14px;
  }
  .perm-check {
    display:flex;align-items:center;gap:8px;
    padding:10px 16px;border:2px solid #e2e8f0;border-radius:8px;
    cursor:pointer;transition:.15s;font-size:13px;font-weight:600;
    user-select:none;
  }
  .perm-check:has(input:checked) {
    border-color:var(--green-mid);background:#f0fdf4;color:var(--green-dark);
  }
  .perm-check input { width:16px;height:16px;accent-color:var(--green-mid);cursor:pointer; }
</style>
</head><body>
<jsp:include page="admin-sidebar.jsp" />

<div class="admin-main">
  <div class="admin-topbar">
    <h1>👥 Quản lý Người dùng & Phân quyền</h1>
    <span style="color:var(--muted);font-size:14px">Tổng: ${users.size()} tài khoản</span>
  </div>

  <c:if test="${param.saved == '1'}">
    <div class="alert alert-success" style="margin-bottom:16px">✅ Đã lưu phân quyền thành công!</div>
  </c:if>

  <!-- BẢNG PHÂN QUYỀN CHI TIẾT -->
  <c:forEach var="u" items="${users}">
    <c:if test="${u.role != 'admin'}">
      <div class="perm-card">
        <div class="perm-header">
          <div class="perm-user">
            <div class="perm-avatar"
                 style="background:${u.role=='mod'?'#2d5a3d':'#64748b'}">
                ${u.role=='mod'?'🛡':'👤'}
            </div>
            <div>
              <div class="perm-name">${u.fullName}</div>
              <div class="perm-email">${u.email}</div>
            </div>
          </div>

          <div style="display:flex;align-items:center;gap:10px">
            <!-- Badge role + dropdown đổi role -->
            <span class="badge ${u.role=='mod'?'badge-primary':'badge-muted'}">
                ${u.role=='mod'?'🛡️ Mod':'👤 User'}
            </span>
            <form action="${pageContext.request.contextPath}/admin/users" method="get"
                  style="display:inline">
              <input type="hidden" name="action" value="setRole">
              <input type="hidden" name="id"     value="${u.userId}">
              <select name="role" onchange="this.form.submit()"
                      style="border:1.5px solid var(--sand);border-radius:6px;
                             padding:5px 8px;font-size:12px;font-weight:600">
                <option value="user" ${u.role=='user'?'selected':''}>👤 User</option>
                <option value="mod"  ${u.role=='mod' ?'selected':''}>🛡️ Mod</option>
              </select>
            </form>

            <!-- Khóa / mở -->
            <a href="${pageContext.request.contextPath}/admin/users?action=toggle&id=${u.userId}&active=${!u.active}"
               class="btn btn-sm ${u.active?'btn-danger':''}"
               style="${u.active?'':'background:#dcfce7;color:#166534'}"
               onclick="return confirm('${u.active?'Khóa':'Mở khóa'} ${u.fullName}?')">
                ${u.active?'🔒 Khóa':'🔓 Mở'}
            </a>
          </div>
        </div>

        <!-- Chỉ mod mới có checkbox phân quyền chi tiết -->
        <c:if test="${u.role == 'mod'}">
          <form action="${pageContext.request.contextPath}/admin/users" method="post">
            <input type="hidden" name="action" value="savePermission">
            <input type="hidden" name="userId" value="${u.userId}">

            <div style="font-size:12px;font-weight:700;color:var(--muted);
                        text-transform:uppercase;letter-spacing:1px;margin-bottom:10px">
              Chức năng được phép
            </div>

            <div class="perm-checkboxes">
              <label class="perm-check">
                <input type="checkbox" name="can_products"
                  ${permMap[u.userId].canProducts?'checked':''}>
                🌿 Quản lý Sản phẩm
              </label>
              <label class="perm-check">
                <input type="checkbox" name="can_orders"
                  ${permMap[u.userId].canOrders?'checked':''}>
                📦 Quản lý Đơn hàng
              </label>
              <label class="perm-check">
                <input type="checkbox" name="can_users"
                  ${permMap[u.userId].canUsers?'checked':''}>
                👥 Quản lý Người dùng
              </label>
            </div>

            <button type="submit" class="btn btn-green btn-sm">💾 Lưu phân quyền</button>
          </form>
        </c:if>

        <c:if test="${u.role == 'user'}">
          <div style="font-size:13px;color:var(--muted);font-style:italic">
            Đổi role thành <strong>Mod</strong> để phân quyền chi tiết
          </div>
        </c:if>
      </div>
    </c:if>
  </c:forEach>

  <!-- ADMIN KHÔNG CÓ CHECKBOX -->
  <c:forEach var="u" items="${users}">
    <c:if test="${u.role == 'admin'}">
      <div class="perm-card" style="border-color:var(--gold);background:#fffbeb">
        <div class="perm-user">
          <div class="perm-avatar" style="background:#c9a84c">⚙️</div>
          <div>
            <div class="perm-name">${u.fullName}</div>
            <div class="perm-email">${u.email}</div>
          </div>
          <span class="badge badge-warning" style="margin-left:12px">⚙️ Admin — Toàn quyền</span>
        </div>
      </div>
    </c:if>
  </c:forEach>

</div>
</body></html>
