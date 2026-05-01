<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="About Us"/>
<c:set var="pageId"    value="about"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.about-hero{position:relative;min-height:480px;background:#0F0F0F;overflow:hidden;display:flex;align-items:center;}
.about-hero-bg{position:absolute;inset:0;background:radial-gradient(circle at 30% 60%,rgba(255,107,53,.22) 0%,transparent 55%),radial-gradient(circle at 70% 20%,rgba(255,107,53,.12) 0%,transparent 50%);}
.about-hero-img{position:absolute;right:0;top:0;bottom:0;width:45%;object-fit:cover;opacity:.35;}
.count-up{font-size:2.8rem;font-weight:800;color:var(--c-orange);}
.team-card{text-align:center;padding:24px;background:var(--c-surface);border-radius:20px;border:1px solid var(--c-border);transition:all .3s var(--ease);}
.team-card:hover{transform:translateY(-6px);box-shadow:var(--shadow-lg);}
.team-avatar{width:80px;height:80px;border-radius:50%;object-fit:cover;margin:0 auto 14px;border:3px solid var(--c-orange);}
.val-card{padding:28px;border-radius:20px;border:2px solid transparent;transition:all .3s var(--ease);background:var(--c-surface);}
.val-card:hover{border-color:var(--c-orange);transform:translateY(-4px);box-shadow:var(--shadow-lg);}
.val-icon{font-size:2.8rem;margin-bottom:14px;}
</style>

<div class="yd-page">
  <!-- Hero -->
  <div class="about-hero">
    <div class="about-hero-bg"></div>
    <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=900&amp;q=80" class="about-hero-img" alt="Food">
    <div class="container" style="position:relative;z-index:1;">
      <div style="max-width:600px;">
        <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(255,107,53,.15);border:1px solid rgba(255,107,53,.3);color:var(--c-orange);padding:6px 16px;border-radius:20px;font-size:.8rem;font-weight:700;margin-bottom:20px;">
          <span class="yd-live-dot"></span>EST. 2024 · KANDY, SRI LANKA
        </div>
        <h1 style="font-family:var(--font-display);font-size:clamp(2.4rem,5vw,4rem);color:white;line-height:1.1;margin-bottom:16px;">
          Bringing Sri Lanka's<br><span class="yd-gradient-text">Finest Flavours</span><br>to Your Door
        </h1>
        <p style="color:rgba(255,255,255,.65);font-size:1.05rem;line-height:1.75;max-width:480px;margin-bottom:28px;">
          YummyDish was born from a simple belief: great food should be accessible to everyone, delivered hot, fresh, and fast.
        </p>
        <div class="d-flex gap-3 flex-wrap">
          <a href="/menu" class="yd-btn yd-btn-primary" style="width:auto;padding:13px 28px;"><i class="bi bi-bag me-2"></i>Order Now</a>
          <a href="/reviews" class="yd-btn yd-btn-outline" style="width:auto;padding:13px 24px;color:rgba(255,255,255,.7);border-color:rgba(255,255,255,.2);">⭐ Read Reviews</a>
        </div>
      </div>
    </div>
  </div>

  <!-- Stats bar -->
  <div style="background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));padding:32px 0;">
    <div class="container">
      <div class="row g-3 text-center">
        <div class="col-6 col-md-3">
          <div style="color:white;">
            <div class="count-up" style="color:white;" data-target="5000">0</div>
            <div style="font-size:.82rem;opacity:.82;">Happy Customers</div>
          </div>
        </div>
        <div class="col-6 col-md-3">
          <div style="color:white;">
            <div class="count-up" style="color:white;" data-target="50000">0</div>
            <div style="font-size:.82rem;opacity:.82;">Orders Delivered</div>
          </div>
        </div>
        <div class="col-6 col-md-3">
          <div style="color:white;">
            <div style="font-size:2.8rem;font-weight:800;color:white;">4.8★</div>
            <div style="font-size:.82rem;opacity:.82;">Average Rating</div>
          </div>
        </div>
        <div class="col-6 col-md-3">
          <div style="color:white;">
            <div style="font-size:2.8rem;font-weight:800;color:white;">&lt;30</div>
            <div style="font-size:.82rem;opacity:.82;">Min Delivery</div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="container py-5" style="max-width:960px;">

    <!-- Values -->
    <div class="text-center mb-5 yd-fade">
      <h2 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:8px;">Why Choose Us?</h2>
      <p style="color:var(--c-muted);">We don't just deliver food — we deliver happiness.</p>
    </div>
    <div class="row g-4 mb-5 yd-stagger">
      <div class="col-md-4 yd-fade">
        <div class="val-card">
          <div class="val-icon">👨‍🍳</div>
          <h5 class="fw-bold mb-2">Expert Chefs</h5>
          <p style="color:var(--c-muted);font-size:.9rem;line-height:1.7;">Our kitchen team has 15+ years of experience crafting authentic Sri Lankan and international cuisine with passion.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div class="val-card">
          <div class="val-icon">⚡</div>
          <h5 class="fw-bold mb-2">Lightning Fast</h5>
          <p style="color:var(--c-muted);font-size:.9rem;line-height:1.7;">Real-time GPS tracking on every delivery. Our drivers know Kandy like the back of their hand. Average delivery: 28 minutes.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div class="val-card">
          <div class="val-icon">🌿</div>
          <h5 class="fw-bold mb-2">Fresh Always</h5>
          <p style="color:var(--c-muted);font-size:.9rem;line-height:1.7;">Ingredients sourced fresh every morning from Kandy's Central Market. Zero frozen shortcuts. Zero compromises.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div class="val-card">
          <div class="val-icon">📱</div>
          <h5 class="fw-bold mb-2">Smart Ordering</h5>
          <p style="color:var(--c-muted);font-size:.9rem;line-height:1.7;">Group orders, scheduled deliveries, loyalty rewards, live tracking, push notifications — all in one app.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div class="val-card">
          <div class="val-icon">💛</div>
          <h5 class="fw-bold mb-2">Community First</h5>
          <p style="color:var(--c-muted);font-size:.9rem;line-height:1.7;">We partner with local farms and employ Kandy's best drivers. Every order supports the local community.</p>
        </div>
      </div>
      <div class="col-md-4 yd-fade">
        <div class="val-card">
          <div class="val-icon">🔒</div>
          <h5 class="fw-bold mb-2">Safe &amp; Secure</h5>
          <p style="color:var(--c-muted);font-size:.9rem;line-height:1.7;">SSL encrypted payments, contactless delivery, food safety certification. Your security is our priority.</p>
        </div>
      </div>
    </div>

    <!-- Map -->
    <div class="yd-fade">
      <h3 style="font-family:var(--font-display);text-align:center;margin-bottom:20px;">📍 Find Us in Kandy</h3>
      <div id="aboutMap" style="width:100%;height:350px;border-radius:20px;border:1px solid var(--c-border);overflow:hidden;"></div>
      <p class="text-center mt-3" style="color:var(--c-muted);font-size:.875rem;">YummyDish Kitchen, Kandy Town, Sri Lanka · Open 7am – 11pm daily · +94 81 234 5678</p>
    </div>

    <!-- CTA -->
    <div class="yd-card mt-5 yd-fade" style="background:linear-gradient(135deg,#0F0F0F,#1a1a1a);border:none;text-align:center;padding:48px 32px;">
      <div style="font-size:3rem;margin-bottom:16px;">🍽️</div>
      <h3 style="font-family:var(--font-display);color:white;margin-bottom:10px;">Ready to Order?</h3>
      <p style="color:rgba(255,255,255,.6);margin-bottom:24px;">Hot, fresh food delivered to your door in Kandy.</p>
      <div class="d-flex gap-3 justify-content-center flex-wrap">
        <a href="/menu" class="yd-btn yd-btn-primary" style="width:auto;padding:13px 32px;">Browse Menu</a>
        <a href="/reviews" class="yd-btn yd-btn-outline" style="width:auto;padding:13px 24px;color:rgba(255,255,255,.6);border-color:rgba(255,255,255,.2);">Read Reviews</a>
      </div>
    </div>
  </div>
</div>

<script>
onMapsReady(function() {
  var r = YDMaps.RESTAURANT;
  var map = YDMaps.initMap('aboutMap', r.lat, r.lng, 15);
  YDMaps.addMarker(map, r.lat, r.lng, r.name,
    '<div style="font-family:sans-serif;padding:10px 14px;"><strong style="font-size:14px;">🍽️ YummyDish Kitchen</strong><br><span style="font-size:12px;color:#888;">Open 7am–11pm · +94 81 234 5678</span><br><a href="/menu" style="color:#FF6B35;font-size:12px;font-weight:600;">Order Now →</a></div>');
});

// Count-up animation on scroll
var countUps = document.querySelectorAll('.count-up[data-target]');
var countObs = new IntersectionObserver(function(entries) {
  entries.forEach(function(entry) {
    if (!entry.isIntersecting) return;
    var el = entry.target;
    var target = parseInt(el.getAttribute('data-target'));
    animateNumber(el, 0, target, 1800);
    countObs.unobserve(el);
  });
}, { threshold: 0.3 });
countUps.forEach(function(el) { countObs.observe(el); });
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
