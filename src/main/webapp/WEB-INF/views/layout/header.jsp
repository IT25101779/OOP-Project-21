<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="si" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title><c:out value="${not empty pageTitle ? pageTitle : 'කටගැස්ම'}"/> — Katagasma</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;0,800;0,900;1,400;1,600&family=Lato:wght@300;400;700&family=Noto+Sans+Sinhala:wght@400;600;700&family=Cormorant+Garamond:ital,wght@0,300;0,600;1,300;1,600&display=swap" rel="stylesheet">
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="/css/katagasma.css" rel="stylesheet">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.js"></script>
<script src="/js/maps.js"></script>

<style>
/* ── UN-Gurulugomi Sinhala Font ── */
@font-face {
  font-family: 'UN-Gurulugomi';
  src: url('/fonts/UN-Gurulugomi.ttf') format('truetype');
  font-weight: normal;
  font-style: normal;
  font-display: swap;
}
/* ══ NAVBAR ═══════════════════════════════════════════════════ */
.kg-nav-v2 {
  position: fixed; top: 0; left: 0; right: 0; z-index: 500;
  /* Always solid on inner pages */
  background: rgba(245,240,232,.97);
  backdrop-filter: blur(20px) saturate(1.5);
  -webkit-backdrop-filter: blur(20px) saturate(1.5);
  border-bottom: 1px solid rgba(139,69,19,.12);
  box-shadow: 0 2px 20px rgba(61,43,31,.07);
  transition: background .4s, border-color .4s, box-shadow .4s;
}
/* Hero-page transparent at top */
.kg-nav-v2.hero-page.at-top {
  background: rgba(12,7,2,.3) !important;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-color: rgba(205,133,63,.18) !important;
  box-shadow: none !important;
}
/* Scrolled → always cream */
.kg-nav-v2.scrolled {
  background: rgba(245,240,232,.97) !important;
  border-color: rgba(139,69,19,.13) !important;
  box-shadow: 0 2px 24px rgba(61,43,31,.09) !important;
}
/* Dark mode nav */
[data-theme="dark"] .kg-nav-v2 {
  background: rgba(18,12,4,.97) !important;
  border-color: rgba(205,133,63,.13) !important;
}
[data-theme="dark"] .kg-nav-v2.hero-page.at-top {
  background: rgba(8,4,1,.45) !important;
}
[data-theme="dark"] .kg-nav-v2.scrolled {
  background: rgba(18,12,4,.97) !important;
  border-color: rgba(205,133,63,.15) !important;
}

.kg-nav-inner {
  display: flex; align-items: center;
  padding: 0 20px; height: 80px; gap: 14px;
}

/* ══ BRAND — styled Sinhala text, NO image ══════════════════ */
.kg-brand-v2 {
  display: flex; flex-direction: column; align-items: flex-start;
  text-decoration: none; flex-shrink: 0; gap: 0;
  transition: opacity .2s;
  cursor: default;
}
.kg-brand-v2:hover { opacity: 1; }

.kg-brand-sinhala {
  font-family: 'UN-Gurulugomi', 'Noto Serif Sinhala', 'Noto Sans Sinhala', serif;
  font-size: 2.2rem;
  font-weight: 400;
  line-height: 1;
  /* Copper metallic gradient text */
  background: linear-gradient(135deg, #6B3410 0%, #CD853F 45%, #DAA520 65%, #8B4513 100%);
  background-size: 200% 200%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: brandShimmer 4s ease-in-out infinite;
  letter-spacing: .02em;
  filter: drop-shadow(0 1px 2px rgba(139,69,19,.25));
}
@keyframes brandShimmer {
  0%, 100% { background-position: 0% 50%; }
  50%       { background-position: 100% 50%; }
}
.kg-brand-sub-v2 {
  font-family: 'Lato', sans-serif;
  font-size: .48rem; letter-spacing: .18em;
  text-transform: uppercase;
  color: var(--brown-light);
  font-weight: 400; margin-top: 1px;
  transition: color .3s;
}

/* On dark hero top: brighten the text */
.kg-nav-v2.hero-page.at-top .kg-brand-sinhala {
  background: linear-gradient(135deg, #E8C890 0%, #FFFFFF 40%, #DAA520 65%, #CD853F 100%);
  background-size: 200% 200%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: brandShimmer 4s ease-in-out infinite;
  filter: drop-shadow(0 0 8px rgba(218,165,32,.4));
}
.kg-nav-v2.hero-page.at-top .kg-brand-sub-v2 { color: rgba(245,240,232,.55); }

[data-theme="dark"] .kg-brand-sinhala {
  background: linear-gradient(135deg, #CD853F 0%, #DAA520 50%, #CD853F 100%);
  background-size: 200% 200%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  filter: drop-shadow(0 0 6px rgba(205,133,63,.3));
}
[data-theme="dark"] .kg-brand-sub-v2 { color: rgba(205,133,63,.5); }

/* ══ NAV LINKS ════════════════════════════════════════════════ */
.kg-nav-links-v2 {
  display: flex; align-items: center; gap: 2px;
  margin: 0 auto; list-style: none; padding: 0;
}
.kg-nav-link-v2 {
  color: #6B4C3B !important;
  font-weight: 500; font-size: .82rem;
  padding: 8px 12px; border-radius: 9px;
  transition: all .22s; text-decoration: none; white-space: nowrap;
}
.kg-nav-link-v2:hover,
.kg-nav-link-v2.active { color: #8B4513 !important; background: rgba(139,69,19,.1); }
.kg-nav-v2.hero-page.at-top .kg-nav-link-v2 { color: rgba(245,240,232,.85) !important; }
.kg-nav-v2.hero-page.at-top .kg-nav-link-v2:hover { color: #fff !important; background: rgba(255,255,255,.1); }
[data-theme="dark"] .kg-nav-link-v2 { color: rgba(245,240,232,.72) !important; }
[data-theme="dark"] .kg-nav-link-v2:hover,
[data-theme="dark"] .kg-nav-link-v2.active { color: #CD853F !important; background: rgba(205,133,63,.1); }

/* ══ ACTIONS ══════════════════════════════════════════════════ */
.kg-nav-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }

.kg-theme-btn-v2 {
  width: 38px; height: 38px; border-radius: 9px;
  background: rgba(139,69,19,.1); border: 1px solid rgba(139,69,19,.2);
  display: flex; align-items: center; justify-content: center;
  font-size: 1rem; cursor: pointer; transition: all .22s; color: var(--c-text);
}
.kg-theme-btn-v2:hover { border-color: #8B4513; transform: scale(1.08); background: rgba(139,69,19,.15); }
.kg-nav-v2.hero-page.at-top .kg-theme-btn-v2 { background: rgba(255,255,255,.1); border-color: rgba(255,255,255,.25); }
[data-theme="dark"] .kg-theme-btn-v2 { background: rgba(205,133,63,.1); border-color: rgba(205,133,63,.2); }

.kg-signin-btn {
  color: #6B4C3B !important; font-weight: 600; font-size: .82rem;
  padding: 8px 15px; border-radius: 9px; border: 1px solid rgba(139,69,19,.22);
  text-decoration: none; transition: all .22s; white-space: nowrap;
}
.kg-signin-btn:hover { color: #8B4513 !important; border-color: #8B4513; background: rgba(139,69,19,.08); }
.kg-nav-v2.hero-page.at-top .kg-signin-btn { color: rgba(245,240,232,.85) !important; border-color: rgba(245,240,232,.28) !important; }
.kg-nav-v2.hero-page.at-top .kg-signin-btn:hover { background: rgba(255,255,255,.1); color: #fff !important; }
[data-theme="dark"] .kg-signin-btn { color: rgba(245,240,232,.72) !important; border-color: rgba(205,133,63,.22) !important; }
[data-theme="dark"] .kg-signin-btn:hover { color: #CD853F !important; border-color: #CD853F !important; }

.kg-joinfree-btn {
  background: linear-gradient(135deg,#8B4513,#CD853F);
  color: #FAF7F0 !important; font-weight: 700; font-size: .82rem;
  padding: 9px 18px; border-radius: 9px; text-decoration: none;
  transition: all .25s; box-shadow: 0 3px 12px rgba(139,69,19,.3); white-space: nowrap;
}
.kg-joinfree-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 22px rgba(139,69,19,.45); color: #FAF7F0 !important; }

.kg-cart-btn-v2 {
  background: #8B4513; color: #FAF7F0 !important;
  border-radius: 9px; padding: 9px 15px; font-weight: 700; font-size: .82rem;
  display: flex; align-items: center; gap: 6px; text-decoration: none;
  transition: all .25s; box-shadow: 0 3px 12px rgba(139,69,19,.28); white-space: nowrap;
}
.kg-cart-btn-v2:hover { background: #6B3410; transform: translateY(-2px); color: #FAF7F0 !important; }
.kg-cart-count-v2 {
  background: rgba(0,0,0,.22); border-radius: 5px;
  min-width: 20px; height: 20px; padding: 0 4px;
  display: flex; align-items: center; justify-content: center;
  font-size: .65rem; font-weight: 800;
}
.kg-nav-v2.hero-page.at-top .kg-cart-btn-v2 { background: rgba(139,69,19,.55); backdrop-filter: blur(8px); }

.kg-hamburger {
  background: none; border: 1px solid rgba(139,69,19,.22); border-radius: 9px;
  padding: 7px 10px; cursor: pointer; color: #6B4C3B;
  display: none; align-items: center; transition: all .2s;
}
.kg-hamburger:hover { border-color: #8B4513; background: rgba(139,69,19,.08); }
.kg-nav-v2.hero-page.at-top .kg-hamburger { border-color: rgba(245,240,232,.3); color: rgba(245,240,232,.85); }
[data-theme="dark"] .kg-hamburger { border-color: rgba(205,133,63,.25); color: rgba(245,240,232,.72); }

.kg-mobile-menu {
  display: none; position: fixed; top: 70px; left: 0; right: 0;
  background: rgba(245,240,232,.98); backdrop-filter: blur(24px);
  border-bottom: 1px solid rgba(139,69,19,.12);
  padding: 14px 20px 22px; z-index: 499;
  box-shadow: 0 16px 48px rgba(61,43,31,.15);
  animation: slideDownMob .28s cubic-bezier(.22,1,.36,1);
}
[data-theme="dark"] .kg-mobile-menu { background: rgba(18,12,4,.98) !important; border-color: rgba(205,133,63,.14) !important; }
@keyframes slideDownMob { from{opacity:0;transform:translateY(-10px)} to{opacity:1;transform:translateY(0)} }
.kg-mobile-menu.open { display: block; }
.kg-mobile-link {
  display: flex; align-items: center; gap: 10px; padding: 11px 13px;
  border-radius: 11px; color: #6B4C3B; font-weight: 600;
  font-size: .9rem; text-decoration: none; transition: all .2s;
}
.kg-mobile-link:hover { background: rgba(139,69,19,.1); color: #8B4513; }
[data-theme="dark"] .kg-mobile-link { color: rgba(245,240,232,.72) !important; }
[data-theme="dark"] .kg-mobile-link:hover { background: rgba(205,133,63,.1) !important; color: #CD853F !important; }

/* ══ BACKWARD COMPAT yd- aliases ══════════════════════════════ */
:root {
  --c-orange:var(--copper);--c-orange-d:var(--copper-d);
  --c-orange-l:var(--copper-l);--font-display:var(--font-serif);
  --c-success:var(--leaf-green);--c-text1:var(--c-text);
}
.yd-btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:11px 22px;border-radius:var(--r-sm);font-weight:600;font-size:.875rem;border:none;transition:all var(--dur) var(--ease);cursor:pointer;white-space:nowrap;font-family:var(--font-body);}
.yd-btn-primary{background:#8B4513;color:#FAF7F0!important;width:100%;padding:13px;}
.yd-btn-primary:hover{background:#6B3410;transform:translateY(-2px);}
.yd-btn-outline{background:transparent;border:1.5px solid #8B4513;color:#8B4513;}
.yd-btn-outline:hover{background:rgba(139,69,19,.08);}
.yd-btn-dark{background:transparent;color:var(--c-text2);border:1px solid var(--c-border-b);}
.yd-btn-dark:hover{border-color:#8B4513;color:#8B4513;background:rgba(139,69,19,.06);}
.yd-btn-sm{padding:7px 14px!important;font-size:.78rem!important;width:auto!important;}
.yd-input{width:100%;padding:12px 14px;border-radius:var(--r-sm);border:1.5px solid var(--c-border-b);font-size:.875rem;background:var(--parchment);font-family:var(--font-body);outline:none;transition:all var(--dur);color:var(--c-text);}
.yd-input:focus{border-color:#8B4513;box-shadow:0 0 0 3px rgba(139,69,19,.1);}
.yd-card{background:var(--c-surface);border-radius:var(--r-lg);border:1px solid var(--c-border);overflow:hidden;}
.yd-card-body{padding:22px;}
.yd-page{animation:pageIn .4s var(--ease) both;}
.yd-fade{opacity:0;transform:translateY(16px);transition:opacity .5s var(--ease-s),transform .5s var(--ease-s);}
.yd-fade.yd-visible,.yd-fade.kg-visible,.yd-fade.visible{opacity:1!important;transform:none!important;}
.yd-stagger .yd-fade:nth-child(1){transition-delay:.04s}.yd-stagger .yd-fade:nth-child(2){transition-delay:.08s}
.yd-stagger .yd-fade:nth-child(3){transition-delay:.12s}.yd-stagger .yd-fade:nth-child(4){transition-delay:.16s}
.yd-stagger .yd-fade:nth-child(5){transition-delay:.2s}.yd-stagger .yd-fade:nth-child(6){transition-delay:.24s}
.yd-stagger .yd-fade:nth-child(7){transition-delay:.28s}.yd-stagger .yd-fade:nth-child(8){transition-delay:.32s}
.yd-stagger .yd-fade:nth-child(9){transition-delay:.36s}.yd-stagger .yd-fade:nth-child(10){transition-delay:.4s}
.yd-stagger .yd-fade:nth-child(11){transition-delay:.44s}.yd-stagger .yd-fade:nth-child(12){transition-delay:.48s}
.yd-food-card{background:#FAF7F0!important;border:1px solid rgba(139,69,19,.12)!important;border-radius:16px!important;overflow:hidden!important;transition:transform .4s,box-shadow .4s!important;height:100%!important;position:relative!important;}
.yd-food-card:hover{transform:translateY(-6px)!important;box-shadow:0 20px 50px rgba(61,43,31,.15)!important;}
.yd-food-img-wrap{overflow:hidden!important;position:relative!important;height:185px!important;background:#EDE8DC!important;}
.yd-food-img{width:100%!important;height:100%!important;object-fit:cover!important;transition:transform .5s!important;display:block!important;}
.yd-food-card:hover .yd-food-img{transform:scale(1.06)!important;}
.yd-food-body{padding:13px 15px 16px!important;background:#FAF7F0!important;}
.yd-food-name{font-family:'Playfair Display',serif!important;font-weight:600!important;font-size:.92rem!important;color:#3D2B1F!important;margin-bottom:2px!important;}
.yd-food-price{color:#8B4513!important;font-weight:800!important;font-size:.92rem!important;}
.yd-food-desc{font-size:.76rem!important;color:#6B4C3B!important;line-height:1.6!important;margin-bottom:10px!important;}
.yd-badge{position:absolute;border-radius:99px;font-size:.58rem;font-weight:700;padding:3px 9px;letter-spacing:.04em;text-transform:uppercase;}
.yd-badge-pop{top:10px;left:10px;background:#8B4513;color:#FAF7F0;}
.yd-badge-cat{top:10px;right:10px;background:rgba(61,43,31,.65);color:#FAF7F0;backdrop-filter:blur(4px);}
.yd-fav-btn{position:absolute;bottom:10px;right:10px;background:rgba(245,240,232,.88);border:none;border-radius:50%;width:32px;height:32px;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:.9rem;transition:all .2s;z-index:3;}
.yd-fav-btn:hover,.yd-fav-btn.active{background:#8B4513;color:#FAF7F0;}
.yd-qty{display:flex;align-items:center;background:#EDE8DC;border-radius:8px;border:1px solid rgba(139,69,19,.15);overflow:hidden;}
.yd-qty-btn{background:transparent;border:none;padding:5px 10px;font-size:.85rem;cursor:pointer;color:#6B4C3B;font-weight:700;}
.yd-qty-btn:hover{background:rgba(139,69,19,.12);color:#8B4513;}
.yd-qty-val{min-width:26px;text-align:center;font-weight:700;font-size:.82rem;color:#3D2B1F;}
.yd-stars{display:inline-flex;gap:1px;}
.yd-gradient-text{background:linear-gradient(135deg,#8B4513,#DAA520);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.yd-live-dot{width:7px;height:7px;border-radius:50%;background:var(--leaf-green);animation:badgePulse 1.5s ease-in-out infinite;display:inline-block;}
.yd-table{width:100%;border-collapse:collapse;font-size:.85rem;}
.yd-table th{background:var(--cream-d);color:var(--c-text2);font-weight:600;font-size:.72rem;letter-spacing:.06em;text-transform:uppercase;padding:10px 14px;border-bottom:2px solid var(--c-border-b);text-align:left;}
.yd-table td{padding:12px 14px;border-bottom:1px solid var(--c-border);color:var(--c-text);}
.yd-table tr:hover td{background:var(--copper-xl);}
.yd-admin-tab{padding:10px 18px;border:none;background:none;font-weight:600;font-size:.82rem;color:var(--c-text3);border-bottom:3px solid transparent;cursor:pointer;transition:all .2s;white-space:nowrap;font-family:var(--font-body);}
.yd-admin-tab:hover,.yd-admin-tab.active{color:#8B4513;border-bottom-color:#8B4513;}
.adm-pane{animation:fadeUp .3s var(--ease) both;}
.yd-offer{background:linear-gradient(135deg,#8B4513,#CD853F);border-radius:16px;padding:18px 20px;color:#FAF7F0;cursor:pointer;transition:transform .25s,box-shadow .25s;position:relative;overflow:hidden;min-width:200px;}
.yd-offer:hover{transform:translateY(-4px);box-shadow:var(--shadow-lg);}
.yd-offer-code{font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;letter-spacing:.06em;}
.yd-status{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:99px;font-size:.68rem;font-weight:700;letter-spacing:.04em;text-transform:uppercase;}
.yd-s-pending{background:rgba(218,165,32,.15);color:var(--turmeric);}
.yd-s-cooking{background:rgba(139,69,19,.15);color:#8B4513;}
.yd-s-ready{background:rgba(46,125,50,.15);color:var(--leaf-green);}
.yd-s-onway{background:rgba(21,101,192,.15);color:#1565C0;}
.yd-s-delivered{background:rgba(46,125,50,.15);color:var(--leaf-green);}
.yd-s-cancelled{background:rgba(192,57,43,.15);color:var(--spice-red);}
.yd-wa-btn{display:inline-flex;align-items:center;gap:8px;padding:9px 16px;border-radius:var(--r-sm);font-weight:600;font-size:.82rem;background:#25D366;color:white;border:none;cursor:pointer;transition:all .2s;font-family:var(--font-body);}
.yd-wa-btn:hover{background:#128C7E;transform:translateY(-1px);}
.yd-quick-action{display:flex;align-items:center;gap:10px;padding:14px;border-radius:14px;border:1px solid rgba(255,255,255,.2);color:white;text-decoration:none;transition:all .25s;background:rgba(255,255,255,.12);}
.yd-quick-action:hover{background:rgba(255,255,255,.2);color:white;transform:translateY(-2px);}

@media(max-width:768px){
  .kg-nav-links-v2,.kg-signin-btn,.kg-joinfree-btn{display:none!important;}
  .kg-hamburger{display:flex!important;}
  .kg-cart-btn-v2 span:not(.kg-cart-count-v2){display:none;}
}
@media(min-width:769px){.kg-mobile-menu{display:none!important;}}
</style>

<script>
/* Apply saved theme BEFORE paint to prevent flash — app.js handles the toggle click */
(function(){
  try {
    var saved = localStorage.getItem('kgTheme') || localStorage.getItem('ydTheme');
    document.documentElement.setAttribute('data-theme', saved === 'dark' ? 'dark' : 'light');
  } catch(e) {}
})();
window.mapsLoaded = true;
function onMapsReady(fn){ document.readyState==='loading'?document.addEventListener('DOMContentLoaded',fn):fn(); }
</script>
<script src="/js/app.js"></script>
</head>
<body style="padding-top:0;">

<c:choose>
  <c:when test="${user != null}">
  <nav class="kg-nav-v2 ${pageId==null?'hero-page':''} at-top" id="mainNav">
    <div class="container-xl">
      <div class="kg-nav-inner">
        <a class="kg-brand-v2" href="/menu">
          <span class="kg-brand-sinhala">කටගැස්ම</span>
          <span class="kg-brand-sub-v2">Authentic Sri Lankan Eats</span>
        </a>
        <ul class="kg-nav-links-v2">
          <li><a class="kg-nav-link-v2 ${pageId=='menu'?'active':''}"     href="/menu"><i class="bi bi-grid me-1"></i>Menu</a></li>
          <li><a class="kg-nav-link-v2 ${pageId=='activity'?'active':''}" href="/activity"><i class="bi bi-bag-check me-1"></i>Orders</a></li>
          <li><a class="kg-nav-link-v2 ${pageId=='about'?'active':''}"    href="/about"><i class="bi bi-info-circle me-1"></i>About</a></li>
          <li><a class="kg-nav-link-v2 ${pageId=='contact'?'active':''}"  href="/contact"><i class="bi bi-chat me-1"></i>Contact</a></li>
          <li><a class="kg-nav-link-v2 ${pageId=='account'?'active':''}"  href="/account"><i class="bi bi-person-circle me-1"></i><c:out value="${fn:length(user.name)>0 ? fn:substringBefore(user.name,' ') : 'Account'}"/></a></li>
        </ul>
        <div class="kg-nav-actions">
          <button class="kg-theme-btn-v2" id="themeToggle" title="Toggle dark mode" aria-label="Toggle dark mode">🌙</button>
          <a class="kg-cart-btn-v2" href="/cart">
            <i class="bi bi-basket3-fill"></i>
            <span>Cart</span>
            <span class="kg-cart-count-v2" id="cartCount">0</span>
          </a>
          <button class="kg-hamburger" id="hamburger" onclick="toggleMobile()" aria-label="Menu">
            <i class="bi bi-list fs-5" id="hambIcon"></i>
          </button>
        </div>
      </div>
    </div>
  </nav>
  <div class="kg-mobile-menu" id="mobileMenu">
    <a class="kg-mobile-link" href="/menu"><i class="bi bi-grid me-2"></i>Menu</a>
    <a class="kg-mobile-link" href="/activity"><i class="bi bi-bag-check me-2"></i>Orders</a>
    <a class="kg-mobile-link" href="/about"><i class="bi bi-info-circle me-2"></i>About</a>
    <a class="kg-mobile-link" href="/contact"><i class="bi bi-chat me-2"></i>Contact</a>
    <a class="kg-mobile-link" href="/account"><i class="bi bi-person-circle me-2"></i>Account</a>
    <a class="kg-mobile-link" href="/cart"><i class="bi bi-basket3-fill me-2"></i>Cart</a>
    <div style="border-top:1px solid var(--c-border);margin:10px 0 0;padding-top:10px;">
      <a class="kg-mobile-link" href="/logout" style="color:var(--spice-red);"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a>
    </div>
  </div>
  </c:when>

  <c:otherwise>
  <nav class="kg-nav-v2 ${pageId==null?'hero-page':''} at-top" id="mainNav">
    <div class="container-xl">
      <div class="kg-nav-inner">
        <a class="kg-brand-v2" href="/">
          <span class="kg-brand-sinhala">කටගැස්ම</span>
          <span class="kg-brand-sub-v2">Authentic Sri Lankan Eats</span>
        </a>
        <ul class="kg-nav-links-v2">
          <li><a class="kg-nav-link-v2" href="/menu">Menu</a></li>
          <li><a class="kg-nav-link-v2" href="/#how-it-works">How It Works</a></li>
          <li><a class="kg-nav-link-v2" href="/about">About Us</a></li>
          <li><a class="kg-nav-link-v2" href="/reviews">Reviews</a></li>
          <li><a class="kg-nav-link-v2" href="/contact">Contact</a></li>
        </ul>
        <div class="kg-nav-actions">
          <button class="kg-theme-btn-v2" id="themeToggle" title="Toggle dark mode" aria-label="Toggle dark mode">🌙</button>
          <a href="/login"  class="kg-signin-btn">Sign In</a>
          <a href="/signup" class="kg-joinfree-btn">Join Free</a>
          <button class="kg-hamburger" id="hamburger" onclick="toggleMobile()" aria-label="Menu">
            <i class="bi bi-list fs-5" id="hambIcon"></i>
          </button>
        </div>
      </div>
    </div>
  </nav>
  <div class="kg-mobile-menu" id="mobileMenu">
    <a class="kg-mobile-link" href="/menu">Menu</a>
    <a class="kg-mobile-link" href="/#how-it-works">How It Works</a>
    <a class="kg-mobile-link" href="/about">About Us</a>
    <a class="kg-mobile-link" href="/reviews">Reviews</a>
    <a class="kg-mobile-link" href="/contact">Contact</a>
    <div style="border-top:1px solid var(--c-border);margin:10px 0 0;padding-top:10px;display:flex;gap:10px;">
      <a href="/login"  class="kg-signin-btn" style="flex:1;text-align:center;padding:11px;">Sign In</a>
      <a href="/signup" class="kg-joinfree-btn" style="flex:1;text-align:center;padding:11px;">Join Free</a>
    </div>
  </div>
  </c:otherwise>
</c:choose>

<c:if test="${pageId != null}"><div style="height:80px;"></div></c:if>

<div id="kg-toast" style="position:fixed;bottom:24px;right:24px;z-index:9999;display:flex;flex-direction:column;gap:10px;pointer-events:none;"></div>

<script>
/* ── Navbar scroll ── */
(function(){
  var nav=document.getElementById('mainNav'); if(!nav)return;
  function upd(){var s=window.scrollY>50;nav.classList.toggle('scrolled',s);nav.classList.toggle('at-top',!s);}
  window.addEventListener('scroll',upd,{passive:true}); upd();
})();

/* Dark mode toggle handled by app.js */

/* ── Mobile menu ── */
var mobileOpen=false;
function toggleMobile(){
  mobileOpen=!mobileOpen;
  var m=document.getElementById('mobileMenu'),i=document.getElementById('hambIcon');
  if(m)m.classList.toggle('open',mobileOpen);
  if(i)i.className=mobileOpen?'bi bi-x fs-5':'bi bi-list fs-5';
}
document.addEventListener('click',function(e){
  if(mobileOpen&&!e.target.closest('#mobileMenu')&&!e.target.closest('#hamburger')){
    mobileOpen=false;
    var m=document.getElementById('mobileMenu'),i=document.getElementById('hambIcon');
    if(m)m.classList.remove('open'); if(i)i.className='bi bi-list fs-5';
  }
});

/* ── Cart sync ── */
(function(){
  function sync(){
    try{var items=JSON.parse(localStorage.getItem('ydCart')||'[]');var t=items.reduce(function(s,i){return s+i.qty;},0);document.querySelectorAll('#cartCount').forEach(function(el){el.textContent=t;});}catch(e){}
  }
  sync(); window.addEventListener('storage',sync);
})();

/* ── Scroll reveal ── */
document.addEventListener('DOMContentLoaded',function(){
  var obs=new IntersectionObserver(function(entries){
    entries.forEach(function(e){if(e.isIntersecting)e.target.classList.add('yd-visible','kg-visible','visible');});
  },{threshold:.1});
  document.querySelectorAll('.yd-fade,.reveal,.kg-fade').forEach(function(el){obs.observe(el);});
});

/* ── Toast ── */
window.kgToast=window.ydToast=function(msg,type){
  var c=document.getElementById('kg-toast');if(!c)return;
  var icons={success:'✅',error:'❌',info:'ℹ️',warn:'⚠️'};
  var el=document.createElement('div');
  el.style.cssText='background:var(--brown-dark);color:var(--cream);padding:12px 18px;border-radius:14px;font-size:.85rem;display:flex;align-items:center;gap:10px;box-shadow:0 8px 32px rgba(0,0,0,.3);pointer-events:all;min-width:220px;border-left:3px solid var(--gold);';
  el.innerHTML='<span>'+(icons[type]||'🍛')+'</span><span>'+msg+'</span>';
  c.appendChild(el);
  setTimeout(function(){el.style.transition='opacity .3s,transform .3s';el.style.opacity='0';el.style.transform='translateX(20px)';setTimeout(function(){el.remove();},320);},3500);
};

/* ── Count-up (about page) ── */
function animateNumber(el,start,end,duration){
  var range=end-start,startTime=null;
  function step(ts){if(!startTime)startTime=ts;var p=Math.min((ts-startTime)/duration,1);el.textContent=Math.floor(p*range+start).toLocaleString()+(el.dataset.suffix||'');if(p<1)requestAnimationFrame(step);}
  requestAnimationFrame(step);
}

/* ── Star renderer ── */
document.addEventListener('DOMContentLoaded',function(){
  document.querySelectorAll('.yd-stars[data-rating]').forEach(function(el){
    var r=parseFloat(el.getAttribute('data-rating'))||0,h='';
    for(var i=1;i<=5;i++)h+='<span style="color:'+(i<=r?'#DAA520':'rgba(139,69,19,.2)')+';font-size:.78rem;">★</span>';
    el.innerHTML=h;
  });
});
</script>
