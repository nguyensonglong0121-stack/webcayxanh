<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Sản phẩm yêu thích — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
    <div class="container">

        <!-- BREADCRUMB -->
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span>›</span> Sản phẩm yêu thích
        </div>

        <h2 class="section-title" style="margin-bottom:24px">
            ❤️ Sản phẩm <span>yêu thích</span>
        </h2>

        <c:choose>
            <c:when test="${empty wishlist}">
                <div class="empty-state">
                    <div class="icon">💔</div>
                    <h3>Chưa có sản phẩm yêu thích</h3>
                    <p>Hãy bấm vào biểu tượng trái tim trên sản phẩm để lưu vào danh sách yêu thích.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-green">Khám phá sản phẩm</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="product-grid" style="grid-template-columns:repeat(auto-fill,minmax(200px,1fr))">
                    <c:forEach var="w" items="${wishlist}">
                        <div class="product-card" id="wishCard-${w.productId}">
                            <a href="${pageContext.request.contextPath}/product?id=${w.productId}">
                                <div class="product-card-img">
                                    <img src="${pageContext.request.contextPath}/uploads/${w.mainImage}"
                                         onerror="this.src='https://placehold.co/400x400/a8d5a2/1a3a2a?text=🌿'"
                                         alt="${w.productName}">
                                    <c:if test="${w.salePrice > 0 and w.salePrice < w.price}"><span class="badge-sale">SALE</span></c:if>
                                </div>
                            </a>
                            <button type="button" class="btn-wishlist-toggle active"
                                    data-product-id="${w.productId}"
                                    title="Bỏ khỏi yêu thích">♥</button>

                            <div class="product-card-body">
                                <a href="${pageContext.request.contextPath}/product?id=${w.productId}">
                                    <div class="product-card-name">${w.productName}</div>
                                </a>
                                <div class="stars">
                                    <c:forEach begin="1" end="5" var="i">
                                        <c:choose>
                                            <c:when test="${i <= w.avgRating}">★</c:when>
                                            <c:otherwise>☆</c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <div class="product-card-price">
                                    <span class="price-current">
                                        <fmt:formatNumber value="${w.displayPrice}" pattern="#,###"/>đ
                                    </span>
                                    <c:if test="${w.onSale}">
                                        <span class="price-old"><fmt:formatNumber value="${w.price}" pattern="#,###"/>đ</span>
                                    </c:if>
                                </div>
                                <c:choose>
                                    <c:when test="${w.stock > 0}">
                                        <form action="${pageContext.request.contextPath}/cart" method="post">
                                            <input type="hidden" name="action"    value="add">
                                            <input type="hidden" name="productId" value="${w.productId}">
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
            </c:otherwise>
        </c:choose>

    </div>
</section>

<script>
    document.querySelectorAll('.btn-wishlist-toggle').forEach(btn => {
        btn.addEventListener('click', function () {
            const productId = this.dataset.productId;
            fetch('${pageContext.request.contextPath}/wishlist', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: 'action=remove&productId=' + productId
            })
                .then(res => res.json())
                .then(data => {
                    const card = document.getElementById('wishCard-' + productId);
                    if (card) {
                        card.style.transition = 'opacity .25s';
                        card.style.opacity = '0';
                        setTimeout(() => {
                            card.remove();
                            if (document.querySelectorAll('.product-card').length === 0) {
                                location.reload();
                            }
                        }, 250);
                    }
                })
                .catch(err => console.error(err));
        });
    });
</script>

<jsp:include page="footer.jsp" />
