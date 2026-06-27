<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Sản phẩm — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
    <div class="container">

        <!-- BREADCRUMB -->
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span>›</span> Sản phẩm
            <c:if test="${not empty param.keyword}">
                <span>›</span> Tìm kiếm: "<strong>${param.keyword}</strong>"
            </c:if>
        </div>

        <div style="display:grid;grid-template-columns:220px 1fr;gap:32px;align-items:start">

            <!-- SIDEBAR FILTER -->
            <aside>
                <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:20px;position:sticky;top:80px">
                    <h3 style="font-size:15px;font-weight:800;color:var(--green-dark);margin-bottom:16px">🔍 Lọc sản phẩm</h3>

                    <form action="${pageContext.request.contextPath}/products" method="get" id="filterForm">
                        <!-- Từ khóa -->
                        <div class="form-group">
                            <label>Tìm kiếm</label>
                            <input class="form-control" type="text" name="keyword"
                                   value="${keyword}" placeholder="Nhập tên cây...">
                        </div>

                        <!-- Danh mục -->
                        <div class="form-group">
                            <label>Danh mục</label>
                            <select class="form-control" name="cat" onchange="this.form.submit()">
                                <option value="0">Tất cả danh mục</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}"
                                        ${categoryId == cat.categoryId ? 'selected' : ''}>
                                            ${cat.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Sắp xếp -->
                        <div class="form-group">
                            <label>Sắp xếp theo</label>
                            <select class="form-control" name="sort" onchange="this.form.submit()">
                                <option value="newest"     ${sort=='newest'     ? 'selected':''}>Mới nhất</option>
                                <option value="price_asc"  ${sort=='price_asc'  ? 'selected':''}>Giá tăng dần</option>
                                <option value="price_desc" ${sort=='price_desc' ? 'selected':''}>Giá giảm dần</option>
                                <option value="name_asc"   ${sort=='name_asc'   ? 'selected':''}>Tên A → Z</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-green btn-block">Tìm kiếm</button>
                        <a href="${pageContext.request.contextPath}/products"
                           class="btn btn-block" style="margin-top:8px;border:1.5px solid var(--sand);color:var(--muted)">
                            Xóa bộ lọc
                        </a>
                    </form>

                    <!-- Danh mục nhanh -->
                    <hr style="border:none;border-top:1px solid var(--sand);margin:20px 0">
                    <h4 style="font-size:13px;font-weight:700;color:var(--green-dark);margin-bottom:10px">Danh mục</h4>
                    <ul style="list-style:none">
                        <li style="margin-bottom:6px">
                            <a href="${pageContext.request.contextPath}/products"
                               style="font-size:13px;color:${categoryId==0?'var(--green-mid)':'var(--muted)'};font-weight:${categoryId==0?'700':'400'}">
                                🌿 Tất cả
                            </a>
                        </li>
                        <c:forEach var="cat" items="${categories}">
                            <li style="margin-bottom:6px">
                                <a href="${pageContext.request.contextPath}/products?cat=${cat.categoryId}"
                                   style="font-size:13px;color:${categoryId==cat.categoryId?'var(--green-mid)':'var(--muted)'};font-weight:${categoryId==cat.categoryId?'700':'400'}">
                                        ${cat.name}
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </aside>

            <!-- SẢN PHẨM -->
            <div>
                <!-- Kết quả -->
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:20px">
                    <p style="font-size:14px;color:var(--muted)">
                        Tìm thấy <strong style="color:var(--green-dark)">${total}</strong> sản phẩm
                    </p>
                </div>

                <c:choose>
                    <c:when test="${empty products}">
                        <div class="empty-state">
                            <div class="icon">🔍</div>
                            <h3>Không tìm thấy sản phẩm</h3>
                            <p>Thử tìm với từ khóa khác hoặc chọn danh mục khác.</p>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-green">Xem tất cả sản phẩm</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="product-grid" style="grid-template-columns:repeat(auto-fill,minmax(200px,1fr))">
                            <c:forEach var="p" items="${products}">
                                <div class="product-card">
                                    <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
                                        <div class="product-card-img">
                                            <img src="${pageContext.request.contextPath}/uploads/${p.mainImage}"
                                                 onerror="this.src='https://placehold.co/400x400/a8d5a2/1a3a2a?text=🌿'"
                                                 alt="${p.name}">
                                            <c:if test="${p.salePrice > 0 and p.salePrice < p.price}"><span class="badge-sale">SALE</span></c:if>
                                            <c:if test="${p.featured}"><span class="badge-featured">⭐</span></c:if>
                                        </div>
                                    </a>
                                    <div class="product-card-body">
                                        <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
                                            <div class="product-card-name">${p.name}</div>
                                        </a>
                                        <div class="stars">
                                            <c:forEach begin="1" end="5" var="i">
                                                <c:choose>
                                                    <c:when test="${i <= p.avgRating}">★</c:when>
                                                    <c:otherwise>☆</c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </div>
                                        <div class="product-card-price">
  <span class="price-current">
    <c:choose>
        <c:when test="${p.salePrice > 0}">
            ${p.salePrice}đ
        </c:when>
        <c:otherwise>
            ${p.price}đ
        </c:otherwise>
    </c:choose>
  </span>
                                            <c:if test="${p.salePrice > 0}">
                                                <span class="price-old">${p.price}đ</span>
                                            </c:if>
                                        </div>
                                        <c:choose>
                                            <c:when test="${p.stock > 0}">
                                                <form action="${pageContext.request.contextPath}/cart" method="post">
                                                    <input type="hidden" name="action"    value="add">
                                                    <input type="hidden" name="productId" value="${p.productId}">
                                                    <input type="hidden" name="quantity"  value="1">
                                                    <button type="submit" class="btn-add-cart">🛒 Thêm giỏ hàng</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn-add-cart" disabled
                                                        style="background:var(--muted);cursor:not-allowed">Hết hàng</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- PHÂN TRANG -->
                        <c:if test="${totalPage > 1}">
                            <div class="pagination">
                                <c:if test="${page > 1}">
                                    <a href="?keyword=${keyword}&cat=${categoryId}&sort=${sort}&page=${page-1}"
                                       class="page-btn">‹</a>
                                </c:if>
                                <c:forEach begin="1" end="${totalPage}" var="i">
                                    <a href="?keyword=${keyword}&cat=${categoryId}&sort=${sort}&page=${i}"
                                       class="page-btn ${i==page?'active':''}">${i}</a>
                                </c:forEach>
                                <c:if test="${page < totalPage}">
                                    <a href="?keyword=${keyword}&cat=${categoryId}&sort=${sort}&page=${page+1}"
                                       class="page-btn">›</a>
                                </c:if>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>

<jsp:include page="footer.jsp" />
