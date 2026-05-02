/* ═══════════════════════════════════════════════════════════════
   YummyDish — app.js   (load WITHOUT defer in header.jsp)
   v8.0 — Notifications, Sound, Loyalty, Auto-refresh
═══════════════════════════════════════════════════════════════ */

// ── Google Maps callback ──────────────────────────────────────────
window.googleMapsReady = function() {
    window.mapsLoaded = true;
    document.dispatchEvent(new Event('mapsready'));
};
function onMapsReady(fn) {
    if (window.mapsLoaded) fn();
    else document.addEventListener('mapsready', fn, { once: true });
}

// ── Theme ─────────────────────────────────────────────────────────
const Theme = (() => {
    function apply(dark) {
        document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
        const btn = document.getElementById('themeToggle');
        if (btn) btn.textContent = dark ? '☀️' : '🌙';
        localStorage.setItem('ydTheme', dark ? 'dark' : 'light');
    }
    function toggle() { apply(document.documentElement.getAttribute('data-theme') !== 'dark'); }
    // Apply on load — check system preference if no saved preference
    const saved = localStorage.getItem('ydTheme');
    if (saved) {
        apply(saved === 'dark');
    } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        apply(true);
    }
    document.addEventListener('DOMContentLoaded', () => {
        const btn = document.getElementById('themeToggle');
        if (btn) {
            btn.addEventListener('click', toggle);
            btn.textContent = document.documentElement.getAttribute('data-theme') === 'dark' ? '☀️' : '🌙';
        }
        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
            if (!localStorage.getItem('ydTheme')) apply(e.matches);
        });
    });
    return { toggle, apply };
})();

// ── Cart ──────────────────────────────────────────────────────────
const Cart = (() => {
    function load() {
        try { return JSON.parse(localStorage.getItem('ydCart') || '[]'); }
        catch(e) { return []; }
    }
    function save(items) { localStorage.setItem('ydCart', JSON.stringify(items)); updateUI(); }
    function add(id, name, price, qty, img) {
        const items = load();
        const ex = items.find(i => i.id === id);
        if (ex) ex.qty += qty; else items.push({ id, name, price: Number(price), qty: Number(qty), img: img || '' });
        save(items);
        showToast('🛒 ' + name + ' added!');
        // Bump cart button
        document.querySelectorAll('.yd-cart-btn').forEach(btn => {
            btn.classList.remove('bump'); void btn.offsetWidth; btn.classList.add('bump');
            setTimeout(() => btn.classList.remove('bump'), 400);
        });
    }
    function remove(id) { save(load().filter(i => i.id !== id)); }
    function updateQty(id, newQty) {
        if (newQty <= 0) { remove(id); return; }
        const items = load(); const item = items.find(i => i.id === id);
        if (item) { item.qty = newQty; save(items); }
    }
    function total()  { return load().reduce((s, i) => s + i.price * i.qty, 0); }
    function count()  { return load().reduce((s, i) => s + i.qty, 0); }
    function clear()  { save([]); }
    function get()    { return load(); }
    function updateUI() {
        const cnt = count(), tot = total();
        document.querySelectorAll('#cartCount').forEach(el => el.textContent = cnt);
        const floatCount = document.getElementById('floatCount');
        const floatTotal = document.getElementById('floatTotal');
        const cartFloat  = document.getElementById('cartFloat');
        if (floatCount) floatCount.textContent = cnt;
        if (floatTotal) floatTotal.textContent  = 'LKR ' + Math.round(tot).toLocaleString();
        if (cartFloat)  cartFloat.classList.toggle('visible', cnt > 0);
    }
    document.addEventListener('DOMContentLoaded', updateUI);
    return { add, remove, updateQty, total, count, clear, get, updateUI };
})();

// ── Favourites ────────────────────────────────────────────────────
const Favs = (() => {
    function load() { try { return JSON.parse(localStorage.getItem('ydFavs') || '[]'); } catch(e) { return []; } }
    function save(list) { localStorage.setItem('ydFavs', JSON.stringify(list)); }
    function toggle(id, name, price, img) {
        const list = load(); const idx = list.findIndex(f => f.id === id);
        if (idx >= 0) { list.splice(idx, 1); save(list); showToast('💔 Removed from favourites'); return false; }
        else { list.push({ id, name, price: Number(price), img: img || '' }); save(list); showToast('❤️ Saved to favourites!'); return true; }
    }
    function has(id)  { return load().some(f => f.id === id); }
    function getAll() { return load(); }
    function renderHearts() {
        document.querySelectorAll('[data-fav-id]').forEach(btn => {
            if (has(btn.getAttribute('data-fav-id'))) { btn.classList.add('active'); btn.textContent = '♥'; }
        });
    }
    document.addEventListener('DOMContentLoaded', renderHearts);
    return { toggle, has, getAll };
})();

// ── Toast ─────────────────────────────────────────────────────────
function showToast(msg, duration) {
    let t = document.getElementById('yd-toast');
    if (!t) { t = document.createElement('div'); t.id = 'yd-toast'; document.body.appendChild(t); }
    t.innerHTML = msg;
    t.classList.add('show');
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.remove('show'), duration || 2800);
}

// ── Sound Alerts ──────────────────────────────────────────────────
const YDSound = (() => {
    let ctx = null;
    function getCtx() {
        if (!ctx) {
            try { ctx = new (window.AudioContext || window.webkitAudioContext)(); } catch(e) {}
        }
        return ctx;
    }
    function beep(freq, dur, vol, type) {
        const c = getCtx(); if (!c) return;
        const osc  = c.createOscillator();
        const gain = c.createGain();
        osc.connect(gain); gain.connect(c.destination);
        osc.type      = type || 'sine';
        osc.frequency.setValueAtTime(freq, c.currentTime);
        gain.gain.setValueAtTime(vol || 0.3, c.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, c.currentTime + dur);
        osc.start(c.currentTime);
        osc.stop(c.currentTime + dur);
    }
    // New order alert — 3 ascending tones (for admin)
    function newOrder() {
        beep(440, 0.18, 0.4); 
        setTimeout(() => beep(554, 0.18, 0.4), 200);
        setTimeout(() => beep(659, 0.28, 0.5), 400);
    }
    // Status update — single cheerful chime (for customer)
    function statusUpdate() {
        beep(880, 0.1, 0.3);
        setTimeout(() => beep(1100, 0.18, 0.35), 120);
    }
    // Nearby driver — urgent double beep
    function driverNearby() {
        beep(660, 0.15, 0.5, 'square');
        setTimeout(() => beep(660, 0.15, 0.5, 'square'), 220);
        setTimeout(() => beep(880, 0.25, 0.5, 'square'), 440);
    }
    // Delivery complete
    function delivered() {
        [523, 659, 784, 1047].forEach((f, i) => setTimeout(() => beep(f, 0.25, 0.4), i * 130));
    }
    return { newOrder, statusUpdate, driverNearby, delivered };
})();

// ── Push Notifications ────────────────────────────────────────────
const YDPush = (() => {
    async function request() {
        if (!('Notification' in window)) return false;
        if (Notification.permission === 'granted') return true;
        if (Notification.permission === 'denied') return false;
        const perm = await Notification.requestPermission();
        return perm === 'granted';
    }
    function show(title, body, icon, tag) {
        if (Notification.permission !== 'granted') return;
        try {
            const n = new Notification(title, {
                body:  body,
                icon:  icon || '/favicon.ico',
                tag:   tag  || 'yummydish',
                badge: '/favicon.ico',
                vibrate: [200, 100, 200]
            });
            n.onclick = function() { window.focus(); n.close(); };
            setTimeout(() => n.close(), 8000);
        } catch(e) {}
    }
    function orderPlaced(orderId) {
        show('🎉 Order Placed!', 'Order #' + orderId + ' confirmed. Preparing your food!', null, 'order-' + orderId);
    }
    function orderReady(orderId) {
        show('📦 Order Ready!', 'Order #' + orderId + ' is packed and ready for pickup.', null, 'order-' + orderId);
    }
    function driverPickedUp(orderId, driverName) {
        show('🛵 Driver On the Way!', (driverName || 'Driver') + ' has picked up order #' + orderId, null, 'order-' + orderId);
    }
    function driverNearby(orderId) {
        show('🔔 Driver Nearby!', 'Your order #' + orderId + ' is less than 1 km away! Get ready.', null, 'order-' + orderId);
    }
    function delivered(orderId) {
        show('✅ Delivered!', 'Order #' + orderId + ' delivered. Enjoy your meal! 🍽️', null, 'order-' + orderId);
    }
    function newOrderAdmin(orderId, customerName) {
        show('🔔 New Order!', '#' + orderId + ' from ' + customerName + ' — tap to view', null, 'admin-' + orderId);
    }
    return { request, show, orderPlaced, orderReady, driverPickedUp, driverNearby, delivered, newOrderAdmin };
})();

// ── Order Status Poller (for customer activity page) ──────────────
const YDPoller = (() => {
    const pollers   = {};   // orderId → intervalId
    const lastState = {};   // orderId → last known status

    function start(orderId, onUpdate) {
        if (pollers[orderId]) return;
        pollers[orderId] = setInterval(async () => {
            try {
                const r = await fetch('/api/order/' + orderId);
                if (!r.ok) return;
                const d = await r.json();
                const prev = lastState[orderId];
                if (prev && prev !== d.status) {
                    // Status changed — notify and sound
                    handleStatusChange(orderId, prev, d.status, d);
                }
                lastState[orderId] = d.status;
                if (onUpdate) onUpdate(d);
                // Stop polling when terminal state
                if (d.status === 'DELIVERED' || d.status === 'CANCELLED') {
                    stop(orderId);
                }
            } catch(e) {}
        }, 6000);
    }

    function handleStatusChange(orderId, prev, next, data) {
        switch(next) {
            case 'READY':
                YDSound.statusUpdate();
                YDPush.orderReady(orderId);
                showToast('📦 Your order is packed and ready for pickup!', 4000);
                break;
            case 'HANDOVER':
                YDSound.statusUpdate();
                YDPush.driverPickedUp(orderId, data.driverName);
                showToast('🛵 ' + (data.driverName || 'Driver') + ' picked up your order!', 4000);
                break;
            case 'ON_WAY':
                YDSound.statusUpdate();
                showToast('🛵 Driver is on the way to you!', 4000);
                break;
            case 'DELIVERED':
                YDSound.delivered();
                YDPush.delivered(orderId);
                showToast('✅ Order delivered! Enjoy your meal 🍽️', 5000);
                break;
            case 'CANCELLED':
                showToast('❌ Order #' + orderId + ' was cancelled.', 4000);
                break;
        }
    }

    function stop(orderId) {
        if (pollers[orderId]) { clearInterval(pollers[orderId]); delete pollers[orderId]; }
    }

    function stopAll() { Object.keys(pollers).forEach(stop); }

    return { start, stop, stopAll, lastState };
})();

// ── Admin Poller (new orders + sound alert) ───────────────────────
const YDAdminPoller = (() => {
    let lastCount = -1;
    let interval  = null;

    function start() {
        if (interval) return;
        interval = setInterval(async () => {
            try {
                const r = await fetch('/api/orders/new-count');
                if (!r.ok) return;
                const d = await r.json();
                const count = d.count || 0;
                if (lastCount >= 0 && count > lastCount) {
                    // New order(s) arrived
                    const diff = count - lastCount;
                    YDSound.newOrder();
                    YDPush.newOrderAdmin('NEW', diff + ' new order(s)');
                    showAdminAlert(diff + ' new order' + (diff > 1 ? 's' : '') + ' arrived!');
                }
                lastCount = count;
                // Update badge if exists
                const badge = document.getElementById('adminNewBadge');
                if (badge) badge.textContent = count > 0 ? count : '';
            } catch(e) {}
        }, 10000); // poll every 10s
    }

    function showAdminAlert(msg) {
        let alert = document.getElementById('adminNewAlert');
        if (!alert) {
            alert = document.createElement('div');
            alert.id = 'adminNewAlert';
            alert.style.cssText = 'position:fixed;top:80px;right:20px;background:linear-gradient(135deg,#FF6B35,#E84F1A);color:white;padding:16px 24px;border-radius:16px;font-weight:700;z-index:9999;box-shadow:0 8px 32px rgba(255,107,53,.5);cursor:pointer;animation:slideLeft .4s var(--ease);';
            alert.onclick = () => { alert.remove(); };
            document.body.appendChild(alert);
        }
        alert.innerHTML = '🔔 ' + msg + '<br><small style="opacity:.8;font-weight:400;">Click to dismiss</small>';
        setTimeout(() => { if (alert.parentNode) alert.remove(); }, 8000);
    }

    function stop() { if (interval) { clearInterval(interval); interval = null; } }

    return { start, stop };
})();

// ── Promo validation ──────────────────────────────────────────────
async function validatePromo(code, subtotal, displayEl) {
    if (!code) return null;
    try {
        const res  = await fetch('/api/validate-offer', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ code: code.toUpperCase(), subtotal })
        });
        const data = await res.json();
        if (displayEl) {
            displayEl.textContent = data.message;
            displayEl.className   = 'yd-promo-msg ' + (data.valid ? 'yd-promo-ok' : 'yd-promo-err');
            displayEl.style.display = 'block';
        }
        return data.valid ? data : null;
    } catch(e) { return null; }
}

// ── Reorder ───────────────────────────────────────────────────────
function reorder(orderId) {
    fetch('/api/order/' + orderId)
        .then(r => r.json())
        .then(d => {
            if (d.items && d.items.length) {
                d.items.forEach(i => Cart.add(i.foodId, i.foodName, i.price, i.quantity, i.imageUrl || ''));
                showToast('🔄 All items added to cart!');
                setTimeout(() => window.location.href = '/cart', 1200);
            }
        }).catch(() => showToast('Could not reorder'));
}

// ── WhatsApp share ────────────────────────────────────────────────
function shareOnWhatsApp(orderId, items, total) {
    const arr      = Array.isArray(items) && items.length ? items : Cart.get();
    const trackUrl = window.location.origin + '/activity/order/' + orderId;
    const text = '🍽️ *YummyDish Order #' + orderId + '*\n'
        + arr.map(i => '• ' + (i.name||i.foodName||'Item') + ' ×' + (i.qty||i.quantity||1)
            + ' — LKR ' + Math.round((i.price||0) * (i.qty||i.quantity||1)).toLocaleString()).join('\n')
        + '\n\n*Total: LKR ' + Math.round(total||0).toLocaleString() + '*'
        + (orderId ? '\n📍 Track live: ' + trackUrl : '')
        + '\n\nOrdered via YummyDish Kandy 🛵';
    window.open('https://wa.me/?text=' + encodeURIComponent(text), '_blank');
}

// ── Ripple effect ─────────────────────────────────────────────────
document.addEventListener('click', function(e) {
    const btn = e.target.closest('.yd-btn, .yd-food-card .yd-add-btn');
    if (!btn) return;
    const r    = document.createElement('span');
    r.className = 'yd-ripple';
    const rect = btn.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    r.style.cssText = 'width:' + size + 'px;height:' + size + 'px;left:' + (e.clientX-rect.left-size/2) + 'px;top:' + (e.clientY-rect.top-size/2) + 'px;';
    btn.appendChild(r);
    setTimeout(() => r.remove(), 600);
});

// ── Navbar scroll effect ──────────────────────────────────────────
window.addEventListener('scroll', () => {
    document.querySelector('.yd-nav')?.classList.toggle('scrolled', window.scrollY > 20);
}, { passive: true });

// ── Scroll-reveal with IntersectionObserver ───────────────────────
document.addEventListener('DOMContentLoaded', () => {
    const io = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) { entry.target.classList.add('yd-visible'); io.unobserve(entry.target); }
        });
    }, { threshold: 0.06, rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.yd-fade').forEach(el => io.observe(el));

    // Request notification permission on first interaction
    document.addEventListener('click', () => {
        if (Notification.permission === 'default') YDPush.request();
    }, { once: true });
});

// ── Number counter animation ──────────────────────────────────────
function animateNumber(el, from, to, duration) {
    const start = performance.now();
    function update(now) {
        const p = Math.min((now - start) / duration, 1);
        const e = 1 - Math.pow(1 - p, 3);
        el.textContent = Math.round(from + (to - from) * e).toLocaleString();
        if (p < 1) requestAnimationFrame(update);
    }
    requestAnimationFrame(update);
}

// ── Smooth page transitions ───────────────────────────────────────
(function() {
    // Add transition overlay to body
    var overlay = document.createElement('div');
    overlay.className = 'page-transition';
    overlay.id = 'pageTransition';
    document.body.appendChild(overlay);

    // Intercept internal link clicks for smooth transition
    document.addEventListener('click', function(e) {
        var link = e.target.closest('a[href]');
        if (!link) return;
        var href = link.getAttribute('href');
        // Only internal links, not anchors, not new tab
        if (!href || href.startsWith('#') || href.startsWith('http') ||
            href.startsWith('tel:') || href.startsWith('mailto:') ||
            link.target === '_blank') return;
        // Skip form submit buttons
        if (e.target.closest('form')) return;
        e.preventDefault();
        var dest = href;
        overlay.classList.add('active');
        setTimeout(function() { window.location.href = dest; }, 320);
    });
})();

// ── Number counter animation ──────────────────────────────────────
function animateNumber(el, from, to, duration) {
    var start = performance.now();
    function update(now) {
        var p = Math.min((now - start) / duration, 1);
        var ease = 1 - Math.pow(1 - p, 3);
        el.textContent = Math.round(from + (to - from) * ease).toLocaleString();
        if (p < 1) requestAnimationFrame(update);
    }
    requestAnimationFrame(update);
}

// ── Skeleton loader utility ───────────────────────────────────────
const Skeleton = {
    card: function(count) {
        var html = '';
        for (var i = 0; i < (count || 4); i++) {
            html += '<div class="col-6 col-md-4 col-lg-3">'
                + '<div style="background:var(--c-surface);border-radius:16px;overflow:hidden;border:1px solid var(--c-border);">'
                + '<div class="yd-skeleton" style="height:200px;border-radius:0;"></div>'
                + '<div style="padding:16px;">'
                + '<div class="yd-skeleton" style="height:18px;width:70%;margin-bottom:10px;border-radius:6px;"></div>'
                + '<div class="yd-skeleton" style="height:14px;width:40%;margin-bottom:14px;border-radius:6px;"></div>'
                + '<div class="yd-skeleton" style="height:38px;border-radius:10px;"></div>'
                + '</div></div></div>';
        }
        return html;
    },
    row: function(count) {
        var html = '';
        for (var i = 0; i < (count || 3); i++) {
            html += '<div style="display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid var(--c-border);">'
                + '<div class="yd-skeleton" style="width:48px;height:48px;border-radius:10px;flex-shrink:0;"></div>'
                + '<div style="flex:1;"><div class="yd-skeleton" style="height:14px;width:60%;margin-bottom:7px;border-radius:4px;"></div>'
                + '<div class="yd-skeleton" style="height:12px;width:35%;border-radius:4px;"></div></div>'
                + '<div class="yd-skeleton" style="width:60px;height:20px;border-radius:6px;"></div>'
                + '</div>';
        }
        return html;
    },
    show: function(containerId, type, count) {
        var el = document.getElementById(containerId);
        if (!el) return;
        el.innerHTML = type === 'row' ? Skeleton.row(count) : Skeleton.card(count);
    }
};

// ── Haptic feedback ───────────────────────────────────────────────
function haptic(type) {
    if (!navigator.vibrate) return;
    var patterns = { light: [20], medium: [50], success: [30, 60, 30], error: [100, 50, 100] };
    navigator.vibrate(patterns[type] || patterns.light);
}

// Attach haptic to cart add
var _origCartAdd = Cart.add;
Cart.add = function(id, name, price, qty, img) {
    haptic('medium');
    return _origCartAdd.call(Cart, id, name, price, qty, img);
};

// ── Custom push notification permission prompt ────────────────────
var YDNotifPrompt = (function() {
    var shown = false;
    function show() {
        if (shown || localStorage.getItem('ydNotifDecided')) return;
        if (!('Notification' in window)) return;
        if (Notification.permission !== 'default') return;
        shown = true;
        var card = document.createElement('div');
        card.id = 'notifPrompt';
        card.style.cssText = 'position:fixed;bottom:90px;left:50%;transform:translateX(-50%);background:var(--c-surface);border:1px solid var(--c-border);border-radius:20px;padding:18px 22px;box-shadow:var(--shadow-xl);z-index:9000;display:flex;align-items:center;gap:14px;max-width:360px;width:calc(100% - 32px);animation:fadeUp .4s var(--ease);';
        card.innerHTML = '<div style="font-size:2rem;flex-shrink:0;">🔔</div>'
            + '<div style="flex:1;"><div style="font-weight:700;font-size:.9rem;margin-bottom:3px;">Get Order Updates</div>'
            + '<div style="font-size:.78rem;color:var(--c-muted);">Know when your food is ready and your driver is near</div></div>'
            + '<div style="display:flex;gap:6px;flex-shrink:0;">'
            + '<button onclick="YDNotifPrompt.allow()" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:7px 14px;">Allow</button>'
            + '<button onclick="YDNotifPrompt.dismiss()" style="background:none;border:none;color:var(--c-muted);font-size:1.1rem;cursor:pointer;padding:4px;">✕</button>'
            + '</div>';
        document.body.appendChild(card);
    }
    function allow() {
        YDPush.request().then(function(ok) {
            if (ok) showToast('Notifications enabled! 🔔');
        });
        dismiss();
    }
    function dismiss() {
        localStorage.setItem('ydNotifDecided', '1');
        var el = document.getElementById('notifPrompt');
        if (el) el.remove();
    }
    // Show 5 seconds after page load on menu page
    document.addEventListener('DOMContentLoaded', function() {
        if (document.querySelector('#foodGrid, .yd-food-card')) {
            setTimeout(show, 5000);
        }
    });
    return { show: show, allow: allow, dismiss: dismiss };
})();

// ── Image blur-up lazy loading ────────────────────────────────────
(function() {
    if (!('IntersectionObserver' in window)) return;
    var imgObs = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (!entry.isIntersecting) return;
            var img = entry.target;
            var src = img.getAttribute('data-src');
            if (!src) return;
            var loader = new Image();
            loader.onload = function() {
                img.src = src;
                img.classList.add('loaded');
                img.removeAttribute('data-src');
            };
            loader.onerror = function() {
                img.src = img.getAttribute('data-fallback') || src;
                img.classList.add('loaded');
            };
            loader.src = src;
            imgObs.unobserve(img);
        });
    }, { threshold: 0.05, rootMargin: '100px' });

    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('img[data-src]').forEach(function(img) {
            img.classList.add('yd-img-lazy');
            imgObs.observe(img);
        });
    });
})();
