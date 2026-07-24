// main.js — GreenShop

// ── Cập nhật cart badge sau khi thêm sản phẩm ──────────────
document.querySelectorAll('form[data-cart]').forEach(form => {
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        const submitBtn = this.querySelector('button[type="submit"]');
        const oldText   = submitBtn ? submitBtn.textContent : null;
        if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = 'Đang thêm...'; }

        const data = new URLSearchParams(new FormData(this));
        // Dùng getAttribute('action') thay vì this.action — vì mỗi form đều có
        // <input name="action"> (để CartServlet biết đây là "add"/"update"/...),
        // input trùng tên "action" sẽ GHI ĐÈ thuộc tính this.action của form
        // (DOM Clobbering), khiến this.action trả về chính thẻ <input> đó thay
        // vì chuỗi URL, gây lỗi gửi request sai địa chỉ.
        const formUrl = this.getAttribute('action');
        fetch(formUrl, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            body: data
        })
            .then(r => r.json())
            .then(res => {
                let badge = document.getElementById('cartBadge');
                if (!badge && res.cartCount > 0) {
                    const btn = document.querySelector('.navbar-actions a[href$="/cart"] .btn-nav-icon');
                    if (btn) {
                        badge = document.createElement('span');
                        badge.id = 'cartBadge';
                        badge.className = 'cart-badge';
                        btn.appendChild(badge);
                    }
                }
                if (badge) badge.textContent = res.cartCount;

                // Nếu server báo tồn kho không đủ (Phần 3) thì hiện cảnh báo màu
                // vàng thay vì toast "thành công" màu xanh như bình thường.
                if (res.warning) {
                    showToast('⚠️ ' + res.warning, 'warning');
                } else {
                    showToast('✅ Đã thêm vào giỏ hàng!');
                }
            })
            .catch(() => {
                showToast('⚠️ Không thêm được vào giỏ hàng, vui lòng thử lại!', 'error');
            })
            .finally(() => {
                if (submitBtn) { submitBtn.disabled = false; submitBtn.textContent = oldText; }
            });
    });
});

// ── Toast ────────────────────────────────────────────────────
function showToast(msg, type = 'success') {
    const toast = document.createElement('div');
    toast.textContent = msg;
    const bg = type === 'success' ? '#1a3a2a' : (type === 'warning' ? '#b58a1f' : '#dc2626');
    toast.style.cssText = `
    position:fixed; bottom:24px; right:24px;
    background:${bg};
    color:white; padding:12px 20px; border-radius:10px;
    font-size:14px; font-weight:600; z-index:9999;
    box-shadow:0 4px 20px rgba(0,0,0,.2);
    animation: slideIn .3s ease;
  `;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

// ── Tab switcher (product detail) ────────────────────────────
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        const target = this.dataset.tab;
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        this.classList.add('active');
        const el = document.getElementById(target);
        if (el) el.classList.add('active');
    });
});

// ── Quantity control ─────────────────────────────────────────
document.querySelectorAll('.qty-minus').forEach(btn => {
    btn.addEventListener('click', () => {
        const input = btn.nextElementSibling;
        if (parseInt(input.value) > 1) input.value = parseInt(input.value) - 1;
    });
});
document.querySelectorAll('.qty-plus').forEach(btn => {
    btn.addEventListener('click', () => {
        const input = btn.previousElementSibling;
        input.value = parseInt(input.value) + 1;
    });
});