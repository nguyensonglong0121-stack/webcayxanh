<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="${product.name} — GreenShop" />
<jsp:include page="header.jsp" />

<section class="section">
    <div class="container">

        <!-- BREADCRUMB -->
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span>›</span>
            <a href="${pageContext.request.contextPath}/products">Sản phẩm</a>
            <span>›</span>
            <a href="${pageContext.request.contextPath}/products?cat=${product.categoryId}">${product.categoryName}</a>
            <span>›</span> ${product.name}
        </div>

        <!-- PRODUCT MAIN -->
        <div class="product-detail-grid">

            <!-- Ảnh -->
            <div>
                <div class="product-detail-img">
                    <img src="${pageContext.request.contextPath}/uploads/${product.mainImage}"
                         onerror="this.src='https://placehold.co/600x600/a8d5a2/1a3a2a?text=🌿'"
                         alt="${product.name}" id="mainImg">
                </div>
            </div>

            <!-- Info -->
            <div class="product-detail-info">
                <div style="font-size:12px;font-weight:600;color:var(--green-sage);
                    text-transform:uppercase;letter-spacing:1px;margin-bottom:8px">
                    ${product.categoryName}
                </div>

                <h1>${product.name}</h1>

                <!-- Rating -->
                <div style="display:flex;align-items:center;gap:8px;margin:8px 0">
          <span style="color:#f59e0b;font-size:18px">
            <c:forEach begin="1" end="5" var="i">
                <c:choose>
                    <c:when test="${i <= product.avgRating}">★</c:when>
                    <c:otherwise>☆</c:otherwise>
                </c:choose>
            </c:forEach>
          </span>
                    <span style="font-size:13px;color:var(--muted)">
            ${String.format("%.1f", product.avgRating)} / 5.0
          </span>
                </div>

                <!-- Giá -->
                <div class="product-detail-price">
          <span class="price-current">
            <fmt:formatNumber value="${product.displayPrice}" pattern="#,###"/>đ
          </span>
                    <c:if test="${product.onSale}">
            <span class="price-old">
              <fmt:formatNumber value="${product.price}" pattern="#,###"/>đ
            </span>
                        <span style="background:#fef2f2;color:#dc2626;font-size:12px;
                         font-weight:700;padding:3px 10px;border-radius:20px">
              -${Math.round((product.price - product.salePrice)*100/product.price)}%
            </span>
                    </c:if>
                </div>

                <!-- Tồn kho -->
                <div style="font-size:13px;margin-bottom:16px">
                    <c:choose>
                        <c:when test="${product.stock > 10}">
                            <span style="color:green">✅ Còn hàng (${product.stock} cây)</span>
                        </c:when>
                        <c:when test="${product.stock > 0}">
                            <span style="color:orange">⚠️ Còn ${product.stock} cây — sắp hết</span>
                        </c:when>
                        <c:otherwise>
                            <span style="color:red">❌ Hết hàng</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Thêm giỏ hàng -->
                <div style="display:flex;gap:12px;align-items:center">
                    <c:if test="${product.stock > 0}">
                        <form action="${pageContext.request.contextPath}/cart" method="post" data-cart
                              style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;flex:1">
                            <input type="hidden" name="action"    value="add">
                            <input type="hidden" name="productId" value="${product.productId}">

                            <div class="qty-control">
                                <button type="button" class="qty-minus">−</button>
                                <input type="number" name="quantity" id="qtyInput" value="1" min="1" max="${product.stock}">
                                <button type="button" class="qty-plus">+</button>
                            </div>

                            <button type="submit" class="btn btn-green btn-lg" style="flex:1;min-width:180px">
                                🛒 Thêm vào giỏ hàng
                            </button>
                        </form>
                    </c:if>
                    <button type="button"
                            class="btn-wishlist-detail ${inWishlist ? 'active' : ''}"
                            id="wishlistDetailBtn"
                            data-product-id="${product.productId}"
                            title="Yêu thích">♥</button>
                </div>

                <c:if test="${product.stock > 0}">
                    <a href="${pageContext.request.contextPath}/checkout" class="btn btn-gold btn-block btn-lg"
                       style="margin-top:12px">
                        ⚡ Mua ngay
                    </a>
                </c:if>

                <!-- Đặc điểm nổi bật -->
                <div style="margin-top:24px;padding:16px;background:var(--cream);
                    border-radius:var(--radius);border-left:4px solid var(--green-sage)">
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;font-size:13px">
                        <div>🚚 Giao hàng toàn quốc</div>
                        <div>✅ Bảo hành 30 ngày</div>
                        <div>🌱 Cây chính hãng</div>
                        <div>💬 Tư vấn miễn phí</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- TABS -->
        <div class="tabs" style="margin-top:48px">
            <button class="tab-btn active" data-tab="tab-desc">📋 Mô tả</button>
            <button class="tab-btn"        data-tab="tab-care">🌿 Cách chăm sóc</button>
            <button class="tab-btn"        data-tab="tab-review">⭐ Đánh giá</button>
        </div>

        <div id="tab-desc" class="tab-content active" style="padding:20px 0;line-height:1.9;color:#374151">
            <c:choose>
                <c:when test="${not empty product.description}">${product.description}</c:when>
                <c:otherwise><em style="color:var(--muted)">Chưa có mô tả cho sản phẩm này.</em></c:otherwise>
            </c:choose>
        </div>

        <div id="tab-care" class="tab-content" style="padding:20px 0">
            <c:choose>
                <c:when test="${not empty product.careTips}">
                    <div style="background:var(--cream);border-radius:var(--radius);padding:24px;
                      border-left:4px solid var(--green-mid);line-height:1.9;color:#374151">
                        <div style="font-weight:700;color:var(--green-dark);margin-bottom:12px">
                            🌱 Hướng dẫn chăm sóc ${product.name}
                        </div>
                            ${product.careTips}
                    </div>
                </c:when>
                <c:otherwise><em style="color:var(--muted)">Chưa có hướng dẫn chăm sóc.</em></c:otherwise>
            </c:choose>
        </div>

        <div id="tab-review" class="tab-content" style="padding:20px 0">

            <!-- Thông báo sau khi gửi đánh giá -->
            <c:if test="${not empty reviewSuccess}">
                <div class="alert alert-success" style="margin-bottom:16px">${reviewSuccess}</div>
            </c:if>
            <c:if test="${not empty reviewError}">
                <div class="alert alert-danger" style="margin-bottom:16px">${reviewError}</div>
            </c:if>

            <!-- Form viết / cập nhật review -->
            <c:choose>
                <c:when test="${loggedUser != null}">
                    <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:24px;margin-bottom:24px">
                        <h4 style="font-size:15px;font-weight:700;color:var(--green-dark);margin-bottom:16px">
                            <c:choose>
                                <c:when test="${myReview != null}">✍️ Cập nhật đánh giá của bạn</c:when>
                                <c:otherwise>✍️ Viết đánh giá của bạn</c:otherwise>
                            </c:choose>
                        </h4>
                        <form action="${pageContext.request.contextPath}/review" method="post">
                            <input type="hidden" name="productId" value="${product.productId}">
                            <div class="form-group">
                                <label>Đánh giá</label>
                                <div class="star-rating" id="starRating" style="display:flex;gap:6px;font-size:30px">
                                    <c:forEach begin="1" end="5" var="i">
                                        <span class="star-pick"
                                              data-value="${i}"
                                              style="cursor:pointer;color:#d1d5db;transition:color .15s">★</span>
                                    </c:forEach>
                                </div>
                                <input type="hidden" name="rating" id="ratingInput"
                                       value="${myReview != null ? myReview.rating : 5}">
                            </div>
                            <div class="form-group">
                                <label>Nhận xét</label>
                                <textarea class="form-control" name="comment" rows="3"
                                          placeholder="Chia sẻ trải nghiệm của bạn về sản phẩm...">${myReview != null ? myReview.comment : ''}</textarea>
                            </div>
                            <button type="submit" class="btn btn-green">
                                <c:choose>
                                    <c:when test="${myReview != null}">Cập nhật đánh giá</c:when>
                                    <c:otherwise>Gửi đánh giá</c:otherwise>
                                </c:choose>
                            </button>
                        </form>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-info">
                        <a href="${pageContext.request.contextPath}/login" style="font-weight:700">Đăng nhập</a>
                        để viết đánh giá sản phẩm.
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Danh sách đánh giá -->
            <c:choose>
                <c:when test="${not empty reviews}">
                    <h4 style="font-size:15px;font-weight:700;color:var(--green-dark);margin:24px 0 16px">
                        💬 ${reviewCount} đánh giá từ khách hàng
                    </h4>
                    <div style="display:flex;flex-direction:column;gap:16px">
                        <c:forEach var="rv" items="${reviews}">
                            <div style="background:white;border:1px solid var(--sand);border-radius:var(--radius);padding:18px 20px">
                                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px">
                                    <div style="display:flex;align-items:center;gap:10px">
                                        <div style="width:36px;height:36px;border-radius:50%;background:var(--green-sage);
                                            color:white;display:flex;align-items:center;justify-content:center;
                                            font-weight:700;font-size:14px;flex-shrink:0">
                                                ${rv.userInitial}
                                        </div>
                                        <div>
                                            <div style="font-weight:700;font-size:14px;color:var(--green-dark)">${rv.userName}</div>
                                            <div style="color:#f59e0b;font-size:14px">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <c:choose>
                                                        <c:when test="${i <= rv.rating}">★</c:when>
                                                        <c:otherwise>☆</c:otherwise>
                                                    </c:choose>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                    <span style="font-size:12px;color:var(--muted);white-space:nowrap">${rv.createdAtFormatted}</span>
                                </div>
                                <c:if test="${not empty rv.comment}">
                                    <p style="margin-top:10px;font-size:14px;line-height:1.7;color:#374151">${rv.comment}</p>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <p style="color:var(--muted);font-size:14px;font-style:italic">
                        Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá sản phẩm này!
                    </p>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- SẢN PHẨM LIÊN QUAN -->
        <c:if test="${not empty relatedProducts}">
            <div style="margin-top:56px">
                <h2 class="section-title" style="margin-bottom:24px">
                    🌿 Sản phẩm <span>liên quan</span>
                </h2>
                <div class="product-grid">
                    <c:forEach var="p" items="${relatedProducts}">
                        <div class="product-card" id="prodCard-${p.productId}">
                            <a href="${pageContext.request.contextPath}/product?id=${p.productId}">
                                <div class="product-card-img">
                                    <img src="${pageContext.request.contextPath}/uploads/${p.mainImage}"
                                         onerror="this.src='https://placehold.co/400x400/a8d5a2/1a3a2a?text=🌿'"
                                         alt="${p.name}">
                                    <c:if test="${p.salePrice > 0 and p.salePrice < p.price}"><span class="badge-sale">SALE</span></c:if>
                                </div>
                            </a>
                            <button type="button"
                                    class="btn-wishlist-toggle ${relatedWishlistIds.contains(p.productId) ? 'active' : ''}"
                                    data-product-id="${p.productId}"
                                    title="Yêu thích">♥</button>
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
        </c:if>

    </div>
</section>

<script>
    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            this.classList.add('active');
            document.getElementById(this.dataset.tab).classList.add('active');
        });
    });

    // Quantity control
    const qtyMinus = document.querySelector('.qty-minus');
    const qtyPlus  = document.querySelector('.qty-plus');
    if (qtyMinus) qtyMinus.addEventListener('click', () => {
        const inp = document.getElementById('qtyInput');
        if (parseInt(inp.value) > 1) inp.value = parseInt(inp.value) - 1;
    });
    if (qtyPlus) qtyPlus.addEventListener('click', () => {
        const inp = document.getElementById('qtyInput');
        const max = parseInt(inp.max);
        if (parseInt(inp.value) < max) inp.value = parseInt(inp.value) + 1;
    });

    // Wishlist toggle — works for both the big heart button and card hearts
    function toggleWishlist(btn) {
        const productId = btn.dataset.productId;
        fetch('${pageContext.request.contextPath}/wishlist', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: 'action=toggle&productId=' + productId
        })
            .then(res => {
                if (res.status === 401) {
                    window.location.href = '${pageContext.request.contextPath}/login';
                    return null;
                }
                return res.json();
            })
            .then(data => {
                if (!data) return;
                btn.classList.toggle('active', data.added);
                btn.classList.add('pulse');
                setTimeout(() => btn.classList.remove('pulse'), 350);
            })
            .catch(err => console.error(err));
    }

    const mainWishBtn = document.getElementById('wishlistDetailBtn');
    if (mainWishBtn) mainWishBtn.addEventListener('click', () => toggleWishlist(mainWishBtn));

    document.querySelectorAll('.btn-wishlist-toggle').forEach(btn => {
        btn.addEventListener('click', () => toggleWishlist(btn));
    });

    // Star rating picker (viết đánh giá)
    const starEls    = document.querySelectorAll('#starRating .star-pick');
    const ratingInput = document.getElementById('ratingInput');
    if (starEls.length) {
        function paintStars(value) {
            starEls.forEach(s => {
                s.style.color = parseInt(s.dataset.value) <= value ? '#f59e0b' : '#d1d5db';
            });
        }
        paintStars(parseInt(ratingInput.value) || 5);
        starEls.forEach(s => {
            s.addEventListener('mouseenter', () => paintStars(parseInt(s.dataset.value)));
            s.addEventListener('mouseleave', () => paintStars(parseInt(ratingInput.value)));
            s.addEventListener('click', () => {
                ratingInput.value = s.dataset.value;
                paintStars(parseInt(s.dataset.value));
            });
        });
    }

    // Nếu URL có #tab-review (redirect sau khi gửi đánh giá), tự mở tab đó
    if (window.location.hash === '#tab-review') {
        const reviewBtn = document.querySelector('.tab-btn[data-tab="tab-review"]');
        if (reviewBtn) reviewBtn.click();
    }
</script>

<jsp:include page="footer.jsp" />
