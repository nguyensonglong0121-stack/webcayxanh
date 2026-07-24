<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="GreenShop — Cây Cảnh Online" />
<jsp:include page="header.jsp" />

<!-- HERO -->
<section class="hero">
  <div class="hero-content">
    <h1>Thiên nhiên<br><em>trong tầm tay bạn</em></h1>
    <p>Hàng trăm loại cây cảnh cao cấp — giao tận nơi toàn quốc, bảo hành cây sống 30 ngày.</p>
    <div class="hero-btns">
      <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">🌿 Mua ngay</a>
      <a href="${pageContext.request.contextPath}/products?cat=4" class="btn btn-outline btn-lg">Cây Phong Thủy</a>
    </div>
  </div>
</section>

<!-- FEATURES STRIP -->
<div class="features-strip">
  <div class="features-inner">
    <div class="feature-item"><div class="feature-icon">🚚</div><div><h4>Giao hàng toàn quốc</h4><p>Đóng gói chuyên biệt, đảm bảo cây nguyên vẹn</p></div></div>
    <div class="feature-item"><div class="feature-icon">✅</div><div><h4>Bảo hành 30 ngày</h4><p>Đổi mới nếu cây không sống trong 30 ngày</p></div></div>
    <div class="feature-item"><div class="feature-icon">🌱</div><div><h4>Cây chất lượng cao</h4><p>Nhập trực tiếp từ vườn ươm uy tín</p></div></div>
    <div class="feature-item"><div class="feature-icon">💬</div><div><h4>Tư vấn miễn phí</h4><p>Đội ngũ chuyên gia hỗ trợ 8:00 – 21:00</p></div></div>
  </div>
</div>

<!-- DANH MỤC -->
<div class="category-bar">
  <div class="category-bar-inner">
    <a href="${pageContext.request.contextPath}/products" class="cat-chip">🌿 Tất cả</a>
    <c:forEach var="cat" items="${categories}">
      <a href="${pageContext.request.contextPath}/products?cat=${cat.categoryId}" class="cat-chip">${cat.name}</a>
    </c:forEach>
  </div>
</div>

<!-- SẢN PHẨM NỔI BẬT -->
<section class="section">
  <div class="container">
    <div class="section-header">
      <h2 class="section-title">⭐ Sản phẩm <span>nổi bật</span></h2>
      <a href="${pageContext.request.contextPath}/products?sort=newest" class="section-link">Xem tất cả →</a>
    </div>
    <div class="product-grid">
      <c:forEach var="p" items="${featuredProducts}">
        <div class="product-card">
          <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
            <div class="product-card-img">
              <img src="${pageContext.request.contextPath}/uploads/${p.mainImage}"
                   onerror="this.src='https://placehold.co/400x400/a8d5a2/1a3a2a?text=🌿'"
                   alt="${p.name}">
              <c:if test="${p.salePrice > 0 and p.salePrice < p.price}"><span class="badge-sale">SALE</span></c:if>
              <span class="badge-featured">⭐ Nổi bật</span>
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
              (${String.format("%.1f", p.avgRating)})
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
            <form action="${pageContext.request.contextPath}/cart" method="post" data-cart>
              <input type="hidden" name="action"    value="add">
              <input type="hidden" name="productId" value="${p.productId}">
              <input type="hidden" name="quantity"  value="1">
              <button type="submit" class="btn-add-cart">🛒 Thêm giỏ hàng</button>
            </form>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>
</section>

<!-- BANNER GIỮA -->
<div style="background:linear-gradient(135deg,#2d5a3d,#1a3a2a);padding:48px 24px;text-align:center;color:white">
  <div class="container">
    <h2 style="font-size:26px;margin-bottom:12px">🎋 Cây Phong Thủy — Mang Lộc Vào Nhà</h2>
    <p style="color:rgba(255,255,255,.8);margin-bottom:24px">Kim Tiền, Phát Tài, Trúc Phú Quý... Giao ngay trong ngày tại TP.HCM</p>
    <a href="${pageContext.request.contextPath}/products?cat=4" class="btn btn-primary">Xem ngay →</a>
  </div>
</div>

<!-- SẢN PHẨM MỚI NHẤT -->
<section class="section">
  <div class="container">
    <div class="section-header">
      <h2 class="section-title">🆕 Mới <span>về hôm nay</span></h2>
      <a href="${pageContext.request.contextPath}/products" class="section-link">Xem tất cả →</a>
    </div>
    <div class="product-grid">
      <c:forEach var="p" items="${newestProducts}">
        <div class="product-card">
          <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
            <div class="product-card-img">
              <img src="${pageContext.request.contextPath}/uploads/${p.mainImage}"
                   onerror="this.src='https://placehold.co/400x400/a8d5a2/1a3a2a?text=🌿'"
                   alt="${p.name}">
              <c:if test="${p.salePrice > 0 and p.salePrice < p.price}"><span class="badge-sale">SALE</span></c:if>
            </div>
          </a>
          <div class="product-card-body">
            <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
              <div class="product-card-name">${p.name}</div>
            </a>
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
            <form action="${pageContext.request.contextPath}/cart" method="post" data-cart>
              <input type="hidden" name="action"    value="add">
              <input type="hidden" name="productId" value="${p.productId}">
              <input type="hidden" name="quantity"  value="1">
              <button type="submit" class="btn-add-cart">🛒 Thêm giỏ hàng</button>
            </form>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>
</section>

<jsp:include page="footer.jsp" />
