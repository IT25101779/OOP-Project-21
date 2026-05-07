<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="theme-color" content="#FF6B35">
<title><c:out value="${not empty pageTitle ? pageTitle : 'YummyDish'}"/> &mdash; YummyDish</title>
<!-- Futuristic fonts: Syne display + DM Sans body + DM Mono data -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
<!-- Favicon / tab icon -->
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="/css/yummydish.css" rel="stylesheet">
<script>
(function(){
  var t=localStorage.getItem('ydTheme');
  if(t==='dark') document.documentElement.setAttribute('data-theme','dark');
})();
window.FB_API_KEY='${firebaseApiKey}';
// Leaflet is synchronous &mdash; always ready
window.mapsLoaded=true;
function onMapsReady(fn){ if(document.readyState==='loading'){document.addEventListener('DOMContentLoaded',fn);}else{fn();} }
</script>
<!-- Leaflet &mdash; free maps, no API key needed -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.js"></script>
<script src="/js/maps.js"></script>
<script src="/js/app.js"></script>
</head>
<body>

<c:choose>
  <c:when test="${user != null}">
    <nav class="yd-nav navbar navbar-expand-lg">
      <div class="container-xl">
        <a class="yd-brand navbar-brand" href="/menu">
          <svg width="28" height="28" viewBox="0 0 28 28" fill="none" style="flex-shrink:0;" xmlns="http://www.w3.org/2000/svg">
            <circle cx="14" cy="14" r="14" fill="#FF6B35"/>
            <text x="14" y="19" text-anchor="middle" font-size="15" fill="white" font-family="serif">&#x1F374;</text>
          </svg>
          <span style="font-family:var(--font-display,Georgia,serif);color:var(--c-orange);">YummyDish</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
          <i class="bi bi-list fs-4" style="color:var(--c-text)"></i>
        </button>
        <div class="collapse navbar-collapse" id="navMain">
          <ul class="navbar-nav ms-auto align-items-center gap-1">
            <li class="nav-item">
              <c:set var="m1" value="${pageId=='menu' ? 'active' : ''}"/>
              <a class="nav-link yd-navlink ${m1}" href="/menu">
                <i class="bi bi-house-door-fill me-1"></i>Menu
              </a>
            </li>
            <li class="nav-item">
              <c:set var="m2" value="${pageId=='activity' ? 'active' : ''}"/>
              <a class="nav-link yd-navlink ${m2}" href="/activity">
                <i class="bi bi-bag-check-fill me-1"></i>Orders
              </a>
            </li>
            <li class="nav-item">
              <c:set var="m3" value="${pageId=='account' ? 'active' : ''}"/>
              <a class="nav-link yd-navlink ${m3}" href="/account">
                <i class="bi bi-person-circle me-1"></i><c:out value="${fn:length(user.name) > 0 ? fn:substringBefore(user.name,' ') : 'Account'}"/>
              </a>
            </li>
            <li class="nav-item">
              <button class="yd-theme-btn ms-1" id="themeToggle" title="Toggle dark mode">🌙</button>
            </li>
            <li class="nav-item ms-2">
              <a class="yd-btn yd-cart-btn" href="/cart">
                <i class="bi bi-cart3"></i>
                <span class="yd-cart-count" id="cartCount">0</span>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>
  </c:when>
  <c:otherwise>
    <nav class="yd-nav navbar navbar-expand-lg">
      <div class="container-xl">
        <a class="yd-brand navbar-brand" href="/">
          <svg width="28" height="28" viewBox="0 0 28 28" fill="none" style="flex-shrink:0;" xmlns="http://www.w3.org/2000/svg">
            <circle cx="14" cy="14" r="14" fill="#FF6B35"/>
            <text x="14" y="19" text-anchor="middle" font-size="15" fill="white" font-family="serif">&#x1F374;</text>
          </svg>
          <span style="font-family:var(--font-display,Georgia,serif);color:var(--c-orange);">YummyDish</span>
        </a>
        <div class="ms-auto d-flex align-items-center gap-2">
          <button class="yd-theme-btn" id="themeToggle" title="Toggle dark mode">🌙</button>
          <a href="/login"  class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;color:var(--c-muted);"><i class="bi bi-box-arrow-in-right me-1"></i>Sign In</a>
          <a href="/signup" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;"><i class="bi bi-person-plus me-1"></i>Join Free</a>
        </div>
      </div>
    </nav>
  </c:otherwise>
</c:choose>

<div id="yd-toast"></div>
