<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="YummyDish — Kandy's Finest Food Delivered"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.hero{min-height:88vh;background:linear-gradient(135deg,#0F0F0F 0%,#1a1a1a 60%,#0d0d0d 100%);display:flex;align-items:center;position:relative;overflow:hidden;}
.hero-bg-ring{position:absolute;border-radius:50%;border:1px solid rgba(255,107,53,.08);animation:spin 30s linear infinite;}
.hero-food-img{position:absolute;right:0;top:0;bottom:0;width:52%;object-fit:cover;opacity:.22;mask-image:linear-gradient(to left,rgba(0,0,0,.6),transparent);}
.hero-tag{display:inline-flex;align-items:center;gap:7px;background:rgba(255,107,53,.12);border:1px solid rgba(255,107,53,.25);color:var(--c-orange);padding:7px 16px;border-radius:20px;font-size:.78rem;font-weight:700;letter-spacing:.5px;margin-bottom:24px;}
.hero-title{font-family:var(--font-display);font-size:clamp(2.8rem,7vw,5.5rem);color:white;line-height:1.08;margin-bottom:20px;}
.hero-sub{color:rgba(255,255,255,.6);font-size:1.05rem;line-height:1.75;max-width:500px;margin-bottom:36px;}
.hero-cta-row{display:flex;gap:14px;flex-wrap:wrap;align-items:center;}
.hero-trust{display:flex;gap:20px;flex-wrap:wrap;margin-top:36px;}
.trust-item{display:flex;align-items:center;gap:8px;color:rgba(255,255,255,.55);font-size:.82rem;}
.feature-strip{background:var(--c-surface);border-top:1px solid var(--c-border);border-bottom:1px solid var(--c-border);padding:22px 0;overflow:hidden;}
.strip-item{display:flex;align-items:center;gap:10px;white-space:nowrap;padding:0 36px;font-weight:600;font-size:.9rem;}
.strip-dot{color:var(--c-orange);}
.category-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:20px;padding:24px 20px;text-align:center;transition:all .3s var(--ease);cursor:pointer;text-decoration:none;display:block;}
.category-card:hover{transform:translateY(-8px) scale(1.03);box-shadow:var(--shadow-xl);border-color:var(--c-orange);}
.category-card:hover .cat-icon{transform:scale(1.2) rotate(5deg);}
.cat-icon{font-size:2.8rem;margin-bottom:12px;display:block;transition:transform .3s var(--ease);}
.step-num{width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;font-weight:800;font-size:1.1rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.review-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:18px;padding:22px;transition:all .3s var(--ease);}
.review-card:hover{transform:translateY(-4px);box-shadow:var(--shadow-lg);}
.app-cta{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:80px 0;position:relative;overflow:hidden;}
.app-cta::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 20% 80%,rgba(255,107,53,.2) 0%,transparent 55%);}
</style>

<div class="yd-page">

  <!-- ── HERO ──────────────────────────────────────────────────── -->
  <section class="hero">
    <div class="hero-bg-ring" style="width:600px;height:600px;top:50%;right:5%;transform:translateY(-50%);"></div>
    <div class="hero-bg-ring" style="width:900px;height:900px;top:50%;right:-10%;transform:translateY(-50%);animation-duration:50s;animation-direction:reverse;"></div>
    <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&amp;q=80" class="hero-food-img" alt="Food">
    <div class="container" style="position:relative;z-index:1;">
      <div style="max-width:620px;">
        <div class="hero-tag">
          <span class="yd-live-dot"></span>
          NOW DELIVERING IN KANDY
        </div>
        <h1 class="hero-title">
          Kandy's <span class="yd-gradient-text">Finest Food</span>,<br>At Your Door
        </h1>
        <p class="hero-sub">
          Hot, fresh meals from our kitchen to you in under 30 minutes.
          Real-time tracking. Loyalty rewards. Group orders.
          Everything you need, in one app.
        </p>
        <div class="hero-cta-row">
          <a href="/menu" class="yd-btn yd-btn-primary" style="width:auto;padding:16px 36px;font-size:1rem;border-radius:14px;">
            <i class="bi bi-bag-fill me-2"></i>Order Now
          </a>
          <a href="/signup" class="yd-btn yd-btn-outline" style="width:auto;padding:15px 28px;font-size:1rem;color:rgba(255,255,255,.7);border-color:rgba(255,255,255,.2);border-radius:14px;">
            <i class="bi bi-person-plus me-2"></i>Join Free
          </a>
        </div>
        <div class="hero-trust">
          <div class="trust-item"><span style="color:#FFB800;">&#9733;&#9733;&#9733;&#9733;&#9733;</span><span>4.8 rating</span></div>
          <div class="trust-item"><i class="bi bi-lightning-fill" style="color:var(--c-orange);"></i><span>Avg 28 min delivery</span></div>
          <div class="trust-item"><i class="bi bi-shield-check-fill" style="color:var(--c-success);"></i><span>Safe &amp; hygienic</span></div>
          <div class="trust-item"><i class="bi bi-geo-alt-fill" style="color:var(--c-orange);"></i><span>Kandy only</span></div>
        </div>

        <!-- Location Picker -->
        <div style="margin-top:28px;max-width:520px;">
          <div style="background:rgba(255,255,255,.08);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid rgba(255,255,255,.15);border-radius:16px;padding:16px 18px;">
            <div style="font-size:.68rem;font-weight:700;color:rgba(255,255,255,.45);text-transform:uppercase;letter-spacing:.8px;margin-bottom:10px;">&#x1F4CD; Deliver to</div>
            <div style="display:flex;gap:8px;align-items:center;">
              <input id="heroLocInput" type="text" placeholder="Enter your delivery address in Kandy..."
                style="flex:1;min-width:0;background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.2);border-radius:10px;padding:10px 14px;color:white;font-size:.875rem;outline:none;"
                onfocus="this.style.borderColor='var(--c-orange)'" onblur="this.style.borderColor='rgba(255,255,255,.2)'">
              <button onclick="heroGPS()" title="Use GPS location"
                style="background:var(--c-orange);border:none;border-radius:10px;width:40px;height:40px;min-width:40px;color:white;font-size:1rem;cursor:pointer;display:flex;align-items:center;justify-content:center;">
                <i class="bi bi-crosshair"></i>
              </button>
              <button onclick="heroSaveLoc()" title="Save this location"
                style="background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.2);border-radius:10px;width:40px;height:40px;min-width:40px;color:white;font-size:1rem;cursor:pointer;display:flex;align-items:center;justify-content:center;">
                <i class="bi bi-bookmark-plus"></i>
              </button>
            </div>
            <div id="heroSavedChips" style="margin-top:10px;display:flex;flex-wrap:wrap;gap:6px;"></div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── FEATURE STRIP ─────────────────────────────────────────── -->
  <div class="feature-strip">
    <div style="display:flex;animation:stripScroll 18s linear infinite;width:max-content;">
      <c:forEach begin="1" end="3">
        <span class="strip-item"><span class="strip-dot">●</span>Free delivery on first order</span>
        <span class="strip-item"><span class="strip-dot">●</span>Live GPS driver tracking</span>
        <span class="strip-item"><span class="strip-dot">●</span>Earn loyalty points</span>
        <span class="strip-item"><span class="strip-dot">●</span>Group orders for offices</span>
        <span class="strip-item"><span class="strip-dot">●</span>Schedule orders in advance</span>
        <span class="strip-item"><span class="strip-dot">●</span>Fresh daily ingredients</span>
      </c:forEach>
    </div>
  </div>
  <style>@keyframes stripScroll{from{transform:translateX(0)}to{transform:translateX(-33.33%)}}</style>

  <div class="container py-5" style="max-width:1100px;">

    <!-- ── CATEGORIES ─────────────────────────────────────────── -->
    <div class="text-center mb-5 yd-fade">
      <h2 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:8px;">What are you craving?</h2>
      <p style="color:var(--c-muted);">Explore our menu by category</p>
    </div>
    <div class="row g-3 mb-6 yd-stagger" style="margin-bottom:60px;">
      <div class="col-6 col-md-3 yd-fade"><a href="/menu?category=Breakfast" class="category-card"><span class="cat-icon">🍳</span><div class="fw-700">Breakfast</div><div style="font-size:.78rem;color:var(--c-muted);margin-top:4px;">7am–11am</div></a></div>
      <div class="col-6 col-md-3 yd-fade"><a href="/menu?category=Lunch"     class="category-card"><span class="cat-icon">🍛</span><div class="fw-700">Lunch</div><div style="font-size:.78rem;color:var(--c-muted);margin-top:4px;">11am–3pm</div></a></div>
      <div class="col-6 col-md-3 yd-fade"><a href="/menu?category=Dinner"    class="category-card"><span class="cat-icon">🍽️</span><div class="fw-700">Dinner</div><div style="font-size:.78rem;color:var(--c-muted);margin-top:4px;">5pm–11pm</div></a></div>
      <div class="col-6 col-md-3 yd-fade"><a href="/menu"                    class="category-card" style="border-style:dashed;background:var(--c-orange-l);border-color:rgba(255,107,53,.3);"><span class="cat-icon">✨</span><div class="fw-700" style="color:var(--c-orange);">All Items</div><div style="font-size:.78rem;color:var(--c-orange);margin-top:4px;opacity:.7;">Full menu</div></a></div>
    </div>

    <!-- ── HOW IT WORKS ───────────────────────────────────────── -->
    <div class="row g-5 align-items-center mb-5">
      <div class="col-md-5 yd-fade">
        <div class="yd-live-badge mb-3"><span class="yd-live-dot"></span>It's that simple</div>
        <h2 style="font-family:var(--font-display);font-size:2.2rem;line-height:1.2;margin-bottom:12px;">Order in<br>60 seconds</h2>
        <p style="color:var(--c-muted);line-height:1.75;">No app download needed. Order directly from your browser on any device.</p>
      </div>
      <div class="col-md-7 yd-fade">
        <div style="display:flex;flex-direction:column;gap:18px;">
          <div style="display:flex;align-items:center;gap:18px;background:var(--c-surface);border-radius:16px;padding:18px 22px;border:1px solid var(--c-border);">
            <div class="step-num">1</div>
            <div><div style="font-weight:700;margin-bottom:3px;">Browse & Choose</div><div style="font-size:.875rem;color:var(--c-muted);">Search or explore our menu. Filter by category, see ingredients, calories, and reviews.</div></div>
          </div>
          <div style="display:flex;align-items:center;gap:18px;background:var(--c-surface);border-radius:16px;padding:18px 22px;border:1px solid var(--c-border);">
            <div class="step-num">2</div>
            <div><div style="font-weight:700;margin-bottom:3px;">Set Location & Checkout</div><div style="font-size:.875rem;color:var(--c-muted);">Drop a pin on the map or use GPS. Pay cash or card. Apply promo codes.</div></div>
          </div>
          <div style="display:flex;align-items:center;gap:18px;background:var(--c-surface);border-radius:16px;padding:18px 22px;border:1px solid var(--c-border);">
            <div class="step-num">3</div>
            <div><div style="font-weight:700;margin-bottom:3px;">Track Live & Enjoy</div><div style="font-size:.875rem;color:var(--c-muted);">Watch your driver on the map in real-time. Get notified at every step. Earn loyalty points.</div></div>
          </div>
        </div>
      </div>
    </div>

    <!-- ── POPULAR ITEMS (live from API) ─────────────────────── -->
    <div class="text-center mb-4 yd-fade">
      <h2 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:8px;">Most Popular &#x1F525;</h2>
      <p style="color:var(--c-muted);">What Kandy is ordering right now</p>
    </div>
    <div class="row g-4 mb-5 yd-stagger" id="popularGrid">
      <!-- Skeleton while loading -->
      <c:forEach begin="1" end="4">
        <div class="col-6 col-md-3">
          <div style="background:var(--c-surface);border-radius:16px;overflow:hidden;border:1px solid var(--c-border);">
            <div class="yd-skeleton" style="height:180px;"></div>
            <div style="padding:14px;">
              <div class="yd-skeleton" style="height:16px;width:70%;border-radius:6px;margin-bottom:8px;"></div>
              <div class="yd-skeleton" style="height:32px;border-radius:8px;"></div>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>

    <!-- ── FEATURES GRID ──────────────────────────────────────── -->
    <div class="row g-4 mb-5">
      <div class="col-md-4 yd-fade">
        <div style="background:linear-gradient(135deg,#FF6B35,#E84F1A);border-radius:20px;padding:28px;color:white;">
          <div style="font-size:2.4rem;margin-bottom:14px;">🛵</div>
          <h5 class="fw-bold mb-2">Live GPS Tracking</h5>
          <p style="font-size:.875rem;opacity:.85;line-height:1.7;">See your driver's exact position on Google Maps, updated every few seconds. No more guessing.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div style="background:linear-gradient(135deg,#667eea,#764ba2);border-radius:20px;padding:28px;color:white;">
          <div style="font-size:2.4rem;margin-bottom:14px;">⭐</div>
          <h5 class="fw-bold mb-2">Loyalty Rewards</h5>
          <p style="font-size:.875rem;opacity:.85;line-height:1.7;">Earn 1 point for every LKR 10 spent. Redeem for discounts. Points never expire.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div style="background:linear-gradient(135deg,#11998e,#38ef7d);border-radius:20px;padding:28px;color:white;">
          <div style="font-size:2.4rem;margin-bottom:14px;">👥</div>
          <h5 class="fw-bold mb-2">Group Orders</h5>
          <p style="font-size:.875rem;opacity:.85;line-height:1.7;">Office lunch? Create a room, share the code, everyone adds their order. One checkout, one delivery.</p>
        </div>
      </div>
    </div>

    <!-- ── REVIEWS ────────────────────────────────────────────── -->
    <div class="text-center mb-4 yd-fade">
      <h2 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:8px;">What People Say</h2>
      <div style="display:flex;align-items:center;justify-content:center;gap:6px;color:var(--c-muted);font-size:.9rem;">
        <span style="color:#FFB800;font-size:1.1rem;">★★★★★</span> 4.8 average from 200+ reviews
      </div>
    </div>
    <div class="row g-4 mb-5 yd-stagger" id="homeReviews">
      <div style="text-align:center;padding:20px;color:var(--c-muted);">Loading reviews...</div>
    </div>

  </div><!-- /container -->

  <!-- ── CTA FOOTER ────────────────────────────────────────────── -->
  <div class="app-cta">
    <div class="container text-center" style="position:relative;z-index:1;">
      <div style="font-size:4rem;margin-bottom:16px;">🍽️</div>
      <h2 style="font-family:var(--font-display);color:white;font-size:2.8rem;margin-bottom:10px;">
        Ready to eat?
      </h2>
      <p style="color:rgba(255,255,255,.6);font-size:1.05rem;margin-bottom:32px;max-width:480px;margin-left:auto;margin-right:auto;">
        Join thousands of happy customers in Kandy. First order gets 20% off with code <strong style="color:var(--c-orange);">WELCOME20</strong>
      </p>
      <div class="d-flex gap-3 justify-content-center flex-wrap">
        <a href="/menu" class="yd-btn yd-btn-primary" style="width:auto;padding:16px 40px;font-size:1.05rem;border-radius:14px;">
          <i class="bi bi-bag-fill me-2"></i>Browse Menu
        </a>
        <a href="/signup" class="yd-btn yd-btn-outline" style="width:auto;padding:15px 32px;font-size:1.05rem;color:rgba(255,255,255,.7);border-color:rgba(255,255,255,.2);border-radius:14px;">
          Create Free Account
        </a>
      </div>
    </div>
  </div>

</div><!-- /yd-page -->


<!-- Save Location Modal -->
<div id="saveLocModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;">
  <div style="background:var(--c-surface);border-radius:20px;padding:28px;max-width:380px;width:90%;box-shadow:0 24px 64px rgba(0,0,0,.4);">
    <h5 style="font-weight:800;margin-bottom:6px;">Save Location</h5>
    <p style="color:var(--c-muted);font-size:.875rem;margin-bottom:14px;">Give this address a name for quick access later.</p>
    <input id="saveLocNameInp" type="text" class="yd-input" placeholder="e.g. Home, Work, University..." maxlength="30" style="margin-bottom:10px;">
    <div id="saveLocAddrPrev" style="font-size:.8rem;color:var(--c-muted);padding:8px 12px;background:var(--c-bg);border-radius:10px;margin-bottom:18px;"></div>
    <div style="display:flex;gap:10px;">
      <button onclick="confirmSaveLoc()" class="yd-btn yd-btn-primary" style="flex:1;">Save</button>
      <button onclick="document.getElementById('saveLocModal').style.display='none'" class="yd-btn" style="flex:1;background:var(--c-bg);border:1px solid var(--c-border);">Cancel</button>
    </div>
  </div>
</div>

<script>
var _popData = {};
var FB = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=90&fit=crop';

function renderPopular() {
  fetch('/api/foods')
    .then(function(r){ return r.ok ? r.json() : []; })
    .then(function(foods) {
      var items  = foods.filter(function(f){ return f.available; });
      var popular = items.filter(function(f){ return f.popular; });
      var show   = popular.length >= 4 ? popular.slice(0,4) : items.slice(0,4);
      var grid   = document.getElementById('popularGrid');
      if (!grid || !show.length) return;

      show.forEach(function(f) {
        _popData[f.id] = {
          name:  f.name,
          price: f.price,
          img:   (f.imageUrl && f.imageUrl.trim().length > 8) ? f.imageUrl : FB
        };
      });

      grid.innerHTML = show.map(function(f) {
        var d = _popData[f.id];
        return '<div class="col-6 col-md-3 yd-fade yd-visible">'
          + '<div class="yd-food-card" style="cursor:pointer;" onclick="location.href=\'/menu/item/' + f.id + '\'">'
          + '<div class="yd-food-img-wrap">'
          + '<img src="' + d.img + '" alt="' + f.name + '"'
          + ' style="width:100%;height:100%;object-fit:cover;display:block;filter:none;transform:none;"'
          + ' loading="eager"'
          + ' onerror="this.src=\'' + FB + '\'">'
          + '<span class="yd-badge yd-badge-pop">&#x1F525; Popular</span>'
          + '</div>'
          + '<div class="yd-food-body">'
          + '<div class="yd-food-name" style="font-size:.875rem;font-weight:700;margin-bottom:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + f.name + '</div>'
          + '<div style="display:flex;justify-content:space-between;align-items:center;gap:6px;">'
          + '<div class="yd-food-price" style="font-size:.9rem;">LKR ' + Math.round(f.price).toLocaleString() + '</div>'
          + '<button id="hpbtn_' + f.id + '"'
          + ' onclick="event.stopPropagation();addHomeCart(\'' + f.id + '\')"'
          + ' class="yd-btn yd-btn-primary yd-btn-sm"'
          + ' style="width:auto;padding:7px 12px;flex-shrink:0;border-radius:10px;">'
          + '<i class="bi bi-cart-plus"></i> Add'
          + '</button>'
          + '</div>'
          + '</div></div></div>';
      }).join('');
    })
    .catch(function(e){ console.warn('Popular items error:', e); });
}

function addHomeCart(id) {
  var d = _popData[id];
  if (!d) return;
  // Safe Cart call — works whether app.js loaded synchronously or deferred
  if (typeof Cart !== 'undefined') {
    Cart.add(id, d.name, d.price, 1, d.img);
  } else {
    // Fallback: save to localStorage directly
    try {
      var items = JSON.parse(localStorage.getItem('ydCart') || '[]');
      var ex = items.find(function(i){ return i.id === id; });
      if (ex) { ex.qty += 1; } else { items.push({id:id,name:d.name,price:d.price,qty:1,img:d.img||''}); }
      localStorage.setItem('ydCart', JSON.stringify(items));
      // Update cart count badge manually
      var cnt = items.reduce(function(s,i){ return s+i.qty; }, 0);
      document.querySelectorAll('#cartCount').forEach(function(el){ el.textContent=cnt; });
      if (typeof showToast === 'function') showToast('&#x1F6D2; ' + d.name + ' added!');
    } catch(e) {}
  }
  var btn = document.getElementById('hpbtn_' + id);
  if (btn) {
    btn.innerHTML = '<i class="bi bi-check-lg"></i> Added!';
    btn.style.background = 'var(--c-success)';
    btn.style.borderColor = 'var(--c-success)';
    setTimeout(function(){
      btn.innerHTML = '<i class="bi bi-cart-plus"></i> Add';
      btn.style.background = '';
      btn.style.borderColor = '';
    }, 1800);
  }
}

// Run after DOM ready to ensure app.js has initialised
document.addEventListener('DOMContentLoaded', renderPopular);

// ── Reviews ───────────────────────────────────────────────────────
function renderReviews() {
  fetch('/api/foods')
    .then(function(r){ return r.ok ? r.json() : []; })
    .then(function(foods) {
      var sample = foods.filter(function(f){ return f.available; }).slice(0,8);
      return Promise.all(sample.map(function(f) {
        return fetch('/api/food/' + f.id + '/reviews')
          .then(function(r){ return r.ok ? r.json() : []; })
          .then(function(revs){ return revs.map(function(rv){ rv.foodName=f.name; return rv; }); })
          .catch(function(){ return []; });
      }));
    })
    .then(function(nested) {
      var all = [].concat.apply([], nested)
        .filter(function(rv){ return rv.text && rv.text.length > 3; })
        .sort(function(a,b){ return (b.rating||5)-(a.rating||5); })
        .slice(0,3);
      var div = document.getElementById('homeReviews');
      if (!div) return;
      if (!all.length) { div.innerHTML = '<div style="text-align:center;color:var(--c-muted);padding:20px;">No reviews yet. Be the first!</div>'; return; }
      div.innerHTML = all.map(function(rv) {
        var stars = '';
        for(var i=1;i<=5;i++) stars += '<span style="color:' + (i<=(rv.rating||5)?'#FFB800':'#555') + ';">&#9733;</span>';
        return '<div class="col-md-4 yd-fade yd-visible">'
          + '<div class="review-card">'
          + '<div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">'
          + '<div style="width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;">' + (rv.customerName||'?').charAt(0).toUpperCase() + '</div>'
          + '<div><div style="font-weight:700;font-size:.875rem;">' + (rv.customerName||'Customer') + '</div>'
          + '<div>' + stars + '</div></div></div>'
          + '<p style="font-size:.875rem;color:var(--c-muted);line-height:1.7;font-style:italic;">&ldquo;' + (rv.text||'') + '&rdquo;</p>'
          + (rv.foodName ? '<span style="background:var(--c-orange-l);color:var(--c-orange);font-size:.7rem;font-weight:700;padding:2px 9px;border-radius:20px;">' + rv.foodName + '</span>' : '')
          + '</div></div>';
      }).join('');
    }).catch(function(){});
}
renderReviews();

// ── Home page location picker ─────────────────────────────────────
(function() {
  var inp = document.getElementById('heroLocInput');
  if (!inp) return;
  var saved = localStorage.getItem('ydLocation') || '';
  if (saved) inp.value = saved;
  renderHomeSavedChips();
  inp.addEventListener('change', function() {
    var v = inp.value.trim();
    if (v) { localStorage.setItem('ydLocation', v); showToast('Location updated!'); }
  });
  inp.addEventListener('keydown', function(e) { if (e.key === 'Enter') inp.blur(); });
})();

function heroGPS() {
  if (!navigator.geolocation) { showToast('GPS not supported on this device'); return; }
  showToast('Getting your location...');
  navigator.geolocation.getCurrentPosition(
    function(pos) {
      var addr = pos.coords.latitude.toFixed(5) + ', ' + pos.coords.longitude.toFixed(5);
      var inp = document.getElementById('heroLocInput');
      if (inp) inp.value = addr;
      localStorage.setItem('ydLocation', addr);
      showToast('Location set!');
    },
    function() { showToast('Location access denied. Enter address manually.'); }
  );
}

function heroSaveLoc() {
  var inp = document.getElementById('heroLocInput');
  var addr = inp ? inp.value.trim() : '';
  if (!addr) { showToast('Enter a delivery address first'); return; }
  document.getElementById('saveLocAddrPrev').textContent = addr;
  document.getElementById('saveLocNameInp').value = '';
  document.getElementById('saveLocModal').style.display = 'flex';
  setTimeout(function() { document.getElementById('saveLocNameInp').focus(); }, 80);
}

function confirmSaveLoc() {
  var name = document.getElementById('saveLocNameInp').value.trim();
  var inp  = document.getElementById('heroLocInput');
  var addr = inp ? inp.value.trim() : '';
  if (!name) { showToast('Enter a name for this location'); return; }
  if (!addr) { showToast('Enter a delivery address first'); return; }
  var locs = [];
  try { locs = JSON.parse(localStorage.getItem('ydSavedLocs') || '[]'); } catch(e) {}
  locs = locs.filter(function(l) { return l.name.toLowerCase() !== name.toLowerCase(); });
  locs.unshift({ name: name, address: addr });
  if (locs.length > 8) locs = locs.slice(0,8);
  localStorage.setItem('ydSavedLocs', JSON.stringify(locs));
  localStorage.setItem('ydLocation', addr);
  document.getElementById('saveLocModal').style.display = 'none';
  renderHomeSavedChips();
  showToast('Saved "' + name + '"!');
}

function renderHomeSavedChips() {
  var c = document.getElementById('heroSavedChips');
  if (!c) return;
  var locs = [];
  try { locs = JSON.parse(localStorage.getItem('ydSavedLocs') || '[]'); } catch(e) {}
  if (!locs.length) { c.innerHTML = ''; return; }
  var icons = { Home:'&#x1F3E0;', Work:'&#x1F3E2;', Office:'&#x1F3E2;', University:'&#x1F393;', School:'&#x1F3EB;', Hotel:'&#x1F3E8;', Hospital:'&#x1F3E5;' };
  c.innerHTML = locs.map(function(loc, i) {
    var icon = icons[loc.name] || '&#x1F4CD;';
    return '<button onclick="useHomeSavedLoc(' + i + ')"'
      + ' style="background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.18);border-radius:20px;padding:5px 13px;color:white;font-size:.75rem;font-weight:600;cursor:pointer;white-space:nowrap;transition:background .2s;"'
      + ' onmouseover="this.style.background=\'rgba(255,107,53,.35)\'" onmouseout="this.style.background=\'rgba(255,255,255,.1)\'">'
      + icon + ' ' + loc.name + '</button>';
  }).join('');
}

function useHomeSavedLoc(i) {
  var locs = [];
  try { locs = JSON.parse(localStorage.getItem('ydSavedLocs') || '[]'); } catch(e) {}
  if (!locs[i]) return;
  var inp = document.getElementById('heroLocInput');
  if (inp) inp.value = locs[i].address;
  localStorage.setItem('ydLocation', locs[i].address);
  showToast(locs[i].name + ' selected');
}

// close modal on backdrop click
(function() {
  var m = document.getElementById('saveLocModal');
  if (m) m.addEventListener('click', function(e) { if (e.target === m) m.style.display = 'none'; });
  var ni = document.getElementById('saveLocNameInp');
  if (ni) ni.addEventListener('keydown', function(e) { if (e.key === 'Enter') confirmSaveLoc(); });
})();
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
