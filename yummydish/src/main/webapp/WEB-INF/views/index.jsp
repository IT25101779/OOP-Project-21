<%@ page contentType="text/html;charset=UTF-8" %>
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
          <div class="trust-item"><span style="color:#FFB800;">★★★★★</span><span>4.8 rating</span></div>
          <div class="trust-item"><i class="bi bi-lightning-fill" style="color:var(--c-orange);"></i><span>Avg 28 min delivery</span></div>
          <div class="trust-item"><i class="bi bi-shield-check-fill" style="color:var(--c-success);"></i><span>Safe & hygienic</span></div>
          <div class="trust-item"><i class="bi bi-geo-alt-fill" style="color:var(--c-orange);"></i><span>Kandy only</span></div>
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
      <h2 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:8px;">Most Popular 🔥</h2>
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

<script>
// ── Popular items ────────────────────────────────────────────────
function renderPopular() {
  fetch('/api/foods')
    .then(function(r){ return r.ok ? r.json() : []; })
    .then(function(foods) {
      var items = foods.filter(function(f){ return f.available; });
      var popular = items.filter(function(f){ return f.popular; });
      var show = popular.length >= 4 ? popular.slice(0,4) : items.slice(0,4);
      var grid = document.getElementById('popularGrid');
      if (!grid || !show.length) return;
      grid.innerHTML = show.map(function(f) {
        var img = f.imageUrl && f.imageUrl.length > 4 ? f.imageUrl
                : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80';
        var safeName = (f.name||'').replace(/['"\\]/g,'');
        return '<div class="col-6 col-md-3 yd-fade yd-visible">'
          + '<div class="yd-food-card" style="cursor:pointer;">'
          + '<div class="yd-food-img-wrap" onclick="location.href='/menu/item/'+f.id+''">'
          + '<img class="yd-food-img" src="'+img+'" alt="'+safeName+'"'
          + ' onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80';">'
          + '<span class="yd-badge yd-badge-pop">🔥 Popular</span>'
          + '</div>'
          + '<div class="yd-food-body">'
          + '<div class="yd-food-name">'+f.name+'</div>'
          + '<div class="d-flex justify-content-between align-items-center mt-2">'
          + '<div class="yd-food-price">LKR '+Math.round(f.price).toLocaleString()+'</div>'
          + '<button class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:8px 14px;flex-shrink:0;"'
          + ' onclick="addHomeCart(this,''+f.id+'',''+safeName+'','+f.price+',''+img+'')">'
          + '<i class="bi bi-cart-plus"></i></button>'
          + '</div></div></div></div>';
      }).join('');
    }).catch(function(e){ console.warn('Popular items error:', e); });
}

function addHomeCart(btn, id, name, price, img) {
  if (typeof Cart === 'undefined') { location.href='/menu'; return; }
  Cart.add(id, name, parseFloat(price), 1, img);
  btn.innerHTML = '✓';
  btn.style.background = 'var(--c-success)';
  setTimeout(function(){ btn.innerHTML='<i class="bi bi-cart-plus"></i>'; btn.style.background=''; }, 1800);
}

renderPopular();

// ── Recent reviews ────────────────────────────────────────────────
function renderReviews() {
  fetch('/api/foods')
    .then(function(r){ return r.ok ? r.json() : []; })
    .then(function(foods) {
      var sample = foods.filter(function(f){ return f.available; }).slice(0,8);
      var promises = sample.map(function(f) {
        return fetch('/api/food/' + f.id + '/reviews')
          .then(function(r){ return r.ok ? r.json() : []; })
          .then(function(revs){ return revs.map(function(rv){ rv.foodName=f.name; return rv; }); })
          .catch(function(){ return []; });
      });
      return Promise.all(promises);
    })
    .then(function(nested) {
      var all = [].concat.apply([], nested)
        .filter(function(rv){ return rv.text && rv.text.length > 3; })
        .sort(function(a,b){ return (b.rating||5)-(a.rating||5); })
        .slice(0,3);
      var div = document.getElementById('homeReviews');
      if (!div) return;
      if (!all.length) { div.innerHTML=''; return; }
      div.innerHTML = all.map(function(rv) {
        var stars='';
        for(var i=1;i<=5;i++) stars+='<span style="color:'+(i<=(rv.rating||5)?'#FFB800':'#DDD')+';">★</span>';
        return '<div class="col-md-4 yd-fade yd-visible">'
          +'<div class="review-card">'
          +'<div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">'
          +'<div style="width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;">'+(rv.customerName||'?').charAt(0).toUpperCase()+'</div>'
          +'<div><div style="font-weight:700;font-size:.875rem;">'+(rv.customerName||'Customer')+'</div>'
          +'<div>'+stars+'</div></div></div>'
          +'<p style="font-size:.875rem;color:var(--c-text2);line-height:1.7;font-style:italic;">"'+(rv.text||'')+'&quot;</p>'
          +(rv.foodName?'<span style="background:var(--c-orange-l);color:var(--c-orange);font-size:.7rem;font-weight:700;padding:2px 9px;border-radius:20px;">'+rv.foodName+'</span>':'')
          +'</div></div>';
      }).join('');
    }).catch(function(){});
}

renderReviews();
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
