<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Menu"/>
<c:set var="pageId"    value="menu"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<style>
/* ── Hero section ─────────────────────────────────── */
.menu-hero {
  background:linear-gradient(135deg,#FF6B35 0%,#f7971e 50%,#FF9A5C 100%);
  background-size:200% 200%; animation:gradMove 6s ease infinite;
  padding:40px 0 32px; position:relative; overflow:hidden;
  margin-bottom:0;
}
.menu-hero::before {
  content:''; position:absolute; top:-60%; right:-10%;
  width:600px; height:600px; border-radius:50%;
  background:rgba(255,255,255,.07); pointer-events:none;
}
.menu-hero::after {
  content:''; position:absolute; bottom:-40%; left:-5%;
  width:400px; height:400px; border-radius:50%;
  background:rgba(255,255,255,.05); pointer-events:none;
}
/* ── Location widget ──────────────────────────────── */
.loc-widget {
  background:rgba(255,255,255,.12);
  backdrop-filter:blur(12px); -webkit-backdrop-filter:blur(12px);
  border:1px solid rgba(255,255,255,.2);
  border-radius:18px; padding:16px 20px; cursor:pointer;
  transition:all .3s; max-width:480px;
}
.loc-widget:hover { background:rgba(255,255,255,.18); transform:translateY(-2px); }
.loc-edit-panel {
  background:var(--c-surface); border-radius:20px;
  border:1px solid var(--c-border); padding:20px;
  margin-top:12px; max-width:480px;
  animation:scaleIn .25s var(--ease) both;
  box-shadow:var(--shadow-xl);
}
.saved-loc-row {
  display:flex; align-items:center; gap:10px; padding:10px 12px;
  border-radius:12px; cursor:pointer; transition:all .2s; margin-bottom:4px;
  border:1px solid transparent;
}
.saved-loc-row:hover { background:var(--c-orange-l); border-color:rgba(255,107,53,.2); }
/* ── Stat counters ────────────────────────────────── */
.hero-stat {
  background:rgba(255,255,255,.15); backdrop-filter:blur(8px);
  border:1px solid rgba(255,255,255,.2); border-radius:14px;
  padding:14px 18px; text-align:center; color:white;
  transition:all .3s var(--ease);
}
.hero-stat:hover { background:rgba(255,255,255,.22); transform:translateY(-3px); }
.hero-stat-num { font-size:1.6rem; font-weight:800; line-height:1; }
.hero-stat-lbl { font-size:.72rem; opacity:.8; margin-top:4px; }
/* ── Category pills ───────────────────────────────── */
.cat-pills { display:flex; gap:8px; padding:16px 0; overflow-x:auto; scrollbar-width:none; }
.cat-pills::-webkit-scrollbar { display:none; }
.cat-pill {
  display:flex; align-items:center; gap:7px; padding:9px 20px; border-radius:99px;
  border:1.5px solid var(--c-border); background:var(--c-surface);
  color:var(--c-text); font-size:.85rem; font-weight:600;
  transition:all .25s var(--ease); white-space:nowrap; cursor:pointer;
  text-decoration:none;
}
.cat-pill:hover, .cat-pill.active {
  background:var(--c-orange); color:white; border-color:var(--c-orange);
  transform:translateY(-2px); box-shadow:0 6px 18px rgba(255,107,53,.3);
}
/* ── Search bar ───────────────────────────────────── */
.search-wrap {
  position:relative; flex:1;
}
.search-wrap i {
  position:absolute; left:14px; top:50%; transform:translateY(-50%);
  color:var(--c-muted); pointer-events:none; font-size:1rem;
}
.search-wrap input {
  padding-left:44px!important; border-radius:12px!important;
  transition:all .3s!important;
}
.search-wrap input:focus { box-shadow:0 0 0 4px rgba(255,107,53,.14)!important; }
/* ── Food section header ──────────────────────────── */
.section-head {
  display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;
}
.section-title { font-family:var(--font-display); font-size:1.5rem; color:var(--c-text); }
/* ── Offer cards ──────────────────────────────────── */
.offers-scroll { display:flex; gap:14px; overflow-x:auto; padding:4px 2px 8px; scrollbar-width:none; }
.offers-scroll::-webkit-scrollbar { display:none; }
</style>

<div class="yd-page">
  <!-- ═══ HERO ═══ -->
  <div class="menu-hero">
    <div class="container-xl" style="position:relative;z-index:1;">
      <div class="row align-items-center gy-4">
        <div class="col-lg-7">
          <div style="color:white;margin-bottom:20px;">
            <div style="font-size:.82rem;font-weight:600;opacity:.75;letter-spacing:2px;text-transform:uppercase;margin-bottom:10px;">
              <i class="bi bi-geo-alt-fill me-1"></i>YummyDish Kandy
            </div>
            <h1 style="font-family:var(--font-display);font-size:clamp(2rem,4vw,3rem);line-height:1.1;margin-bottom:8px;">
              Hello, <span style="color:rgba(255,255,255,.9);">
                <c:out value="${fn:length(user.name)>0 ? fn:substringBefore(user.name,' ') : 'there'}"/>
              </span> 👋
            </h1>
            <p style="opacity:.85;font-size:1.05rem;">What are you craving today?</p>
          </div>
          <!-- Location widget -->
          <div class="loc-widget" onclick="toggleLocEdit()">
            <div style="display:flex;align-items:center;gap:10px;">
              <div style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                <i class="bi bi-geo-alt-fill" style="color:white;font-size:.9rem;"></i>
              </div>
              <div style="flex:1;min-width:0;">
                <div style="font-size:.68rem;color:rgba(255,255,255,.7);font-weight:600;text-transform:uppercase;letter-spacing:1px;">Deliver to</div>
                <div id="locDisplay" style="color:white;font-weight:700;font-size:.95rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                  <c:choose>
                    <c:when test="${fn:length(user.address)>0}"><c:out value="${user.address}"/></c:when>
                    <c:otherwise>Set your location</c:otherwise>
                  </c:choose>
                </div>
              </div>
              <i class="bi bi-chevron-down" style="color:rgba(255,255,255,.7);transition:transform .3s;" id="locChevron"></i>
            </div>
          </div>
          <!-- Location edit panel -->
          <div id="locPanel" style="display:none;" class="loc-edit-panel">
            <div class="d-flex gap-2 mb-3">
              <div class="search-wrap" style="flex:1;">
                <i class="bi bi-search"></i>
                <input type="text" id="locInput" class="yd-input" placeholder="Search address in Kandy...">
              </div>
              <button onclick="useGPS()" class="yd-btn yd-btn-outline" style="width:auto;padding:10px 14px;" title="Use my location">
                <i class="bi bi-crosshair" style="color:var(--c-orange);"></i>
              </button>
              <button onclick="openPinDrop()" class="yd-btn yd-btn-outline" style="width:auto;padding:10px 14px;" title="Drop a pin">
                <i class="bi bi-pin-map-fill" style="color:var(--c-orange);"></i>
              </button>
            </div>
            <!-- Pin map -->
            <div id="pinMapWrap" style="display:none;margin-bottom:12px;">
              <div id="pinMap" style="height:200px;border-radius:14px;border:2px solid var(--c-orange);overflow:hidden;"></div>
              <div id="pinResult" style="display:none;margin-top:8px;display:flex;align-items:center;gap:8px;padding:8px 12px;background:var(--c-orange-l);border-radius:10px;font-size:.82rem;">
                <i class="bi bi-geo-alt-fill" style="color:var(--c-orange);flex-shrink:0;"></i>
                <span id="pinAddr" style="flex:1;color:var(--c-text2);"></span>
                <button onclick="usePinAddr()" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:5px 12px;">Use</button>
              </div>
            </div>
            <!-- Saved locations -->
            <div id="savedLocsWrap"></div>
            <div style="display:flex;gap:8px;margin-top:12px;">
              <button onclick="saveCurrentLoc()" class="yd-btn yd-btn-primary yd-btn-sm" style="flex:1;padding:10px;">
                <i class="bi bi-bookmark-plus me-1"></i>Save Location
              </button>
              <button onclick="closeLocEdit()" class="yd-btn yd-btn-outline yd-btn-sm" style="padding:10px 14px;">Done</button>
            </div>
          </div>
        </div>
        <div class="col-lg-5">
          <div class="row g-3">
            <div class="col-6"><a href="/group" class="yd-quick-action" style="background:linear-gradient(135deg,rgba(255,255,255,.15),rgba(255,255,255,.08));border:1px solid rgba(255,255,255,.2);"><span style="font-size:1.8rem;">👥</span><div><div style="font-weight:700;font-size:.88rem;">Group Order</div><div style="font-size:.72rem;opacity:.8;">Order together</div></div></a></div>
            <div class="col-6"><a href="/schedule" class="yd-quick-action" style="background:linear-gradient(135deg,rgba(255,255,255,.15),rgba(255,255,255,.08));border:1px solid rgba(255,255,255,.2);"><span style="font-size:1.8rem;">📅</span><div><div style="font-weight:700;font-size:.88rem;">Schedule</div><div style="font-size:.72rem;opacity:.8;">Order ahead</div></div></a></div>
            <div class="col-4"><div class="hero-stat"><div class="hero-stat-num">12+</div><div class="hero-stat-lbl">Menu Items</div></div></div>
            <div class="col-4"><div class="hero-stat"><div class="hero-stat-num">30<span style="font-size:1rem;">min</span></div><div class="hero-stat-lbl">Avg Delivery</div></div></div>
            <div class="col-4"><div class="hero-stat"><div class="hero-stat-num">4.8<span style="font-size:1rem;">★</span></div><div class="hero-stat-lbl">Rating</div></div></div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="container-xl py-4">
    <!-- ═══ OFFERS ═══ -->
    <c:if test="${not empty activeOffers}">
    <div class="mb-4 yd-fade">
      <div class="section-head">
        <h5 class="section-title" style="font-size:1.1rem;">🎁 Today's Deals</h5>
        <span style="font-size:.78rem;color:var(--c-muted);">Click to apply</span>
      </div>
      <div class="offers-scroll">
        <c:forEach items="${activeOffers}" var="offer">
          <div class="yd-offer" id="offer-${offer.code}" onclick="applyOffer('${offer.code}',${offer.discountPercent})">
            <div class="yd-offer-code">${offer.code}</div>
            <div style="font-weight:700;margin-top:6px;color:var(--c-text);">${offer.title}</div>
            <div style="font-size:.78rem;color:var(--c-muted);margin-top:3px;">${offer.description}</div>
            <div style="margin-top:8px;font-size:.75rem;font-weight:700;color:var(--c-orange);">${offer.discountPercent}% OFF</div>
          </div>
        </c:forEach>
      </div>
    </div>
    </c:if>

    <!-- ═══ SEARCH + SORT ═══ -->
    <div class="d-flex gap-3 align-items-center mb-3 yd-fade" style="flex-wrap:wrap;">
      <form action="/menu" method="get" class="search-wrap" style="flex:1;min-width:200px;">
        <i class="bi bi-search"></i>
        <input type="text" name="search" class="yd-input" placeholder="Search food..." value="${search}">
        <input type="hidden" name="category" value="${category}">
        <input type="hidden" name="sort" value="${sort}">
      </form>
      <form action="/menu" method="get" id="sortForm" style="min-width:160px;">
        <input type="hidden" name="category" value="${category}">
        <input type="hidden" name="search" value="${search}">
        <select name="sort" class="yd-input" style="padding:11px 14px;border-radius:12px;" onchange="document.getElementById('sortForm').submit()">
          <option value="default" ${sort=='default'?'selected':''}>✨ Featured</option>
          <option value="asc"     ${sort=='asc'?'selected':''}>💰 Price: Low→High</option>
          <option value="desc"    ${sort=='desc'?'selected':''}>💎 Price: High→Low</option>
        </select>
      </form>
    </div>

    <!-- ═══ CATEGORY PILLS ═══ -->
    <div class="cat-pills yd-fade">
      <a href="/menu?category=All&amp;sort=${sort}"       class="cat-pill ${category=='All'?'active':''}">🍽️ All</a>
      <a href="/menu?category=Breakfast&amp;sort=${sort}" class="cat-pill ${category=='Breakfast'?'active':''}">🌅 Breakfast</a>
      <a href="/menu?category=Lunch&amp;sort=${sort}"     class="cat-pill ${category=='Lunch'?'active':''}">☀️ Lunch</a>
      <a href="/menu?category=Dinner&amp;sort=${sort}"    class="cat-pill ${category=='Dinner'?'active':''}">🌙 Dinner</a>
      <a href="/menu?category=Others&amp;sort=${sort}"    class="cat-pill ${category=='Others'?'active':''}">🍰 Others</a>
    </div>

    <!-- ═══ FOOD GRID ═══ -->
    <div class="section-head mt-4">
      <h2 class="section-title">
        <c:choose>
          <c:when test="${not empty search}">Results for "<c:out value='${search}'/>"</c:when>
          <c:when test="${category!='All'}"><c:out value="${category}"/> Menu</c:when>
          <c:otherwise>Our Menu</c:otherwise>
        </c:choose>
      </h2>
      <span style="color:var(--c-muted);font-size:.85rem;">${fn:length(foods)} items</span>
    </div>

    <div class="row g-4 mb-5 yd-stagger" id="foodGrid">
      <c:forEach items="${foods}" var="food">
      <div class="col-6 col-md-4 col-lg-3 yd-fade">
        <div class="yd-food-card">
          <div class="yd-food-img-wrap" onclick="location.href='/menu/item/${food.id}'" style="cursor:pointer;">
            <img class="yd-food-img yd-img-lazy" 
                 src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=20&amp;q=10"
                 data-src="${food.imageUrl}"
                 data-fallback="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&amp;q=80"
                 alt="${food.name}">
            <c:if test="${not food.available}"><div style="position:absolute;inset:0;background:rgba(0,0,0,.55);z-index:5;display:flex;align-items:center;justify-content:center;"><span style="background:rgba(0,0,0,.75);color:white;padding:8px 16px;border-radius:20px;font-size:.82rem;font-weight:700;backdrop-filter:blur(4px);">⏸ Temporarily Unavailable</span></div></c:if>
          <c:if test="${food.popular}"><span class="yd-badge yd-badge-pop">⭐ Popular</span></c:if>
            <span class="yd-badge yd-badge-cat">${food.category}</span>
            <%-- Smart tag from ingredients/name --%>
            <c:if test="${fn:containsIgnoreCase(food.ingredients,'chili') or fn:containsIgnoreCase(food.name,'spicy') or fn:containsIgnoreCase(food.ingredients,'pepper') or fn:containsIgnoreCase(food.name,'hot')}">
              <span class="yd-badge" style="bottom:10px;left:10px;top:auto;background:#FFEBEE;color:#C62828;">🌶️ Spicy</span>
            </c:if>
            <c:if test="${fn:containsIgnoreCase(food.ingredients,'tofu') or fn:containsIgnoreCase(food.name,'vegan') or fn:containsIgnoreCase(food.ingredients,'plant') or fn:containsIgnoreCase(food.name,'veggie')}">
              <span class="yd-badge" style="bottom:10px;left:10px;top:auto;background:#E8F5E9;color:#2E7D32;">🌿 Vegan</span>
            </c:if>
            <button class="yd-fav-btn"
                    data-fav-id="${food.id}"
                    data-fav-name="${food.name}"
                    data-fav-price="${food.price}"
                    data-fav-img="${food.imageUrl}"
                    onclick="event.stopPropagation();var b=this;var active=Favs.toggle(b.dataset.favId,b.dataset.favName,b.dataset.favPrice,b.dataset.favImg);b.textContent=active?'♥':'♡';b.classList.toggle('active',active);"
                    aria-label="Add to favourites">♡</button>
          </div>
          <div class="yd-food-body">
            <div class="d-flex justify-content-between align-items-start mb-1">
              <div class="yd-food-name" onclick="location.href='/menu/item/${food.id}'" style="cursor:pointer;">${food.name}</div>
              <div class="yd-food-price ms-1 text-nowrap">LKR&nbsp;<fmt:formatNumber value="${food.price}" pattern="#,##0"/></div>
            </div>
            <div class="d-flex align-items-center gap-2 mb-2">
              <div class="yd-stars" data-rating="${food.rating}"></div>
              <span style="font-size:.72rem;color:var(--c-muted);">(${food.reviewCount}) · ${food.calories} kcal</span>
            </div>
            <p class="yd-food-desc"><span class="fd-desc-el" data-desc="${food.description}"></span></p>
            <div class="d-flex align-items-center gap-2">
              <div class="yd-qty">
                <button class="yd-qty-btn" onclick="dec('q${food.id}')">−</button>
                <span class="yd-qty-val" id="q${food.id}">1</span>
                <button class="yd-qty-btn" onclick="inc('q${food.id}')">+</button>
              </div>
              <c:choose><c:when test="${food.available}">
                <button class="yd-btn yd-btn-primary yd-add-btn" style="flex:1;padding:10px;font-size:.82rem;"
                        data-food-id="${food.id}" data-food-name="${food.name}"
                        data-food-price="${food.price}" data-food-img="${food.imageUrl}"
                        data-food-qty="q${food.id}" onclick="doAddToCart(this)">
                  <i class="bi bi-cart-plus me-1"></i>Add
                </button>
              </c:when><c:otherwise>
                <button class="yd-btn" style="flex:1;padding:10px;font-size:.82rem;background:#f0f0f0;color:#aaa;border:none;cursor:not-allowed;" disabled>
                  ⏸ Unavailable
                </button>
              </c:otherwise></c:choose>
            </div>
          </div>
        </div>
      </div>
      </c:forEach>
      <c:if test="${empty foods}">
        <div class="col-12" style="text-align:center;padding:80px 0;">
          <div style="font-size:4rem;margin-bottom:16px;">🔍</div>
          <h4 style="color:var(--c-muted);">No items found</h4>
          <a href="/menu" class="yd-btn yd-btn-primary mt-3" style="width:auto;">Clear filters</a>
        </div>
      </c:if>
    </div>
  </div>
</div>

<!-- Floating cart -->
<a href="/cart" id="cartFloat" class="yd-float-cart">
  <span class="yd-float-badge" id="floatCount">0</span>
  <span style="font-weight:700;">View Cart</span>
  <span class="yd-float-total" id="floatTotal">LKR 0</span>
  <i class="bi bi-arrow-right ms-auto"></i>
</a>

<script>
// ── THE FIX: use data-* attributes — no quote escaping issues ─────
function doAddToCart(btn) {
  var id    = btn.dataset.foodId;
  var name  = btn.dataset.foodName;
  var price = parseFloat(btn.dataset.foodPrice);
  var img   = btn.dataset.foodImg || '';
  var qEl   = document.getElementById(btn.dataset.foodQty);
  var qty   = qEl ? (parseInt(qEl.textContent) || 1) : 1;
  Cart.add(id, name, price, qty, img);
  // Visual feedback on button
  btn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Added!';
  btn.style.background = 'linear-gradient(135deg,#22C55E,#16a34a)';
  setTimeout(function() {
    btn.innerHTML = '<i class="bi bi-cart-plus me-1"></i>Add';
    btn.style.background = '';
  }, 1200);
}

function inc(id){var e=document.getElementById(id);if(e)e.textContent=parseInt(e.textContent)+1;}
function dec(id){var e=document.getElementById(id);if(e&&parseInt(e.textContent)>1)e.textContent=parseInt(e.textContent)-1;}

// Star ratings
document.querySelectorAll('.yd-stars[data-rating]').forEach(function(el){
  var r = parseFloat(el.getAttribute('data-rating')) || 0;
  for(var i=1;i<=5;i++){
    var s=document.createElement('span');
    s.className='yd-star'+(i<=Math.floor(r)?' filled':'');
    s.textContent='★'; el.appendChild(s);
  }
});

// Offers
var activeOffer = null;
function applyOffer(code, pct) {
  document.querySelectorAll('.yd-offer').forEach(function(o){o.classList.remove('active');});
  if(activeOffer===code){activeOffer=null;localStorage.removeItem('ydOffer');showToast('Offer removed');return;}
  activeOffer=code;
  var el=document.getElementById('offer-'+code); if(el)el.classList.add('active');
  localStorage.setItem('ydOffer',JSON.stringify({code:code,discount:pct/100}));
  showToast('🎉 Offer "'+code+'" applied! '+Math.round(pct)+'% off');
}
var so=JSON.parse(localStorage.getItem('ydOffer')||'null');
if(so){activeOffer=so.code;var oe=document.getElementById('offer-'+so.code);if(oe)oe.classList.add('active');}

// ── Location system ───────────────────────────────────────────────
var locOpen=false, pinMap=null, pinMarker=null, pinAddr='', pinLatLng=null;
function getSaved(){try{return JSON.parse(localStorage.getItem('ydSavedLocs')||'[]');}catch(e){return[];}}
function setSaved(a){localStorage.setItem('ydSavedLocs',JSON.stringify(a));}

function toggleLocEdit(){
  locOpen=!locOpen;
  document.getElementById('locPanel').style.display=locOpen?'block':'none';
  var ch=document.getElementById('locChevron');
  if(ch)ch.style.transform=locOpen?'rotate(180deg)':'rotate(0)';
  if(locOpen){
    document.getElementById('locInput').value=localStorage.getItem('ydLocation')||'';
    renderSavedLocs();
    onMapsReady(function(){
      YDMaps.autocomplete('locInput',function(p){
        document.getElementById('locInput').value=p.formatted_address;
        setLocation(p.formatted_address);
      });
    });
  }
}
function closeLocEdit(){
  locOpen=false;
  document.getElementById('locPanel').style.display='none';
  var ch=document.getElementById('locChevron');
  if(ch)ch.style.transform='rotate(0)';
}

function setLocation(addr){
  localStorage.setItem('ydLocation',addr);
  document.getElementById('locDisplay').textContent=addr;
  showToast('📍 Location set!');
}

function useGPS(){
  showToast('📍 Getting location...');
  if(!navigator.geolocation){showToast('Geolocation not supported');return;}
  navigator.geolocation.getCurrentPosition(function(pos){
    var key=window.GOOGLE_MAPS_KEY||'';
    if(!key){setLocation(pos.coords.latitude.toFixed(5)+', '+pos.coords.longitude.toFixed(5));return;}
    fetch('https://maps.googleapis.com/maps/api/geocode/json?latlng='+pos.coords.latitude+','+pos.coords.longitude+'&key='+key)
      .then(function(r){return r.json();})
      .then(function(d){
        var addr=(d.results&&d.results[0])?d.results[0].formatted_address:(pos.coords.latitude.toFixed(5)+', '+pos.coords.longitude.toFixed(5));
        document.getElementById('locInput').value=addr;
        setLocation(addr);
        pinLatLng={lat:pos.coords.latitude,lng:pos.coords.longitude};
      }).catch(function(){setLocation(pos.coords.latitude.toFixed(5)+', '+pos.coords.longitude.toFixed(5));});
  },function(e){showToast('⚠️ '+e.message);},{enableHighAccuracy:true,timeout:8000});
}

function openPinDrop(){
  var w=document.getElementById('pinMapWrap');
  w.style.display=w.style.display==='none'?'block':'none';
  if(w.style.display==='block'){
    onMapsReady(function(){
      if(pinMap)return;
      var r=YDMaps.RESTAURANT;
      pinMap=YDMaps.initMap('pinMap',r.lat,r.lng,14);
      var kb=new google.maps.LatLngBounds(new google.maps.LatLng(7.22,80.57),new google.maps.LatLng(7.35,80.72));
      pinMap.setOptions({restriction:{latLngBounds:kb,strictBounds:false}});
      YDMaps.addMarker(pinMap,r.lat,r.lng,'YummyDish Kitchen','<div style="padding:4px 8px;font-size:13px;">🍽️ Kitchen</div>');
      pinMap.addListener('click',function(e){
        var lat=e.latLng.lat(), lng=e.latLng.lng();
        if(pinMarker)pinMarker.setMap(null);
        pinMarker=YDMaps.addMarker(pinMap,lat,lng,'Delivery Pin','<div style="padding:4px 8px;">📍 Delivery Here</div>');
        pinLatLng={lat:lat,lng:lng};
        document.getElementById('pinResult').style.display='flex';
        document.getElementById('pinAddr').textContent='Finding address...';
        YDMaps.reverseGeocode(lat,lng,function(addr){
          pinAddr=addr||(lat.toFixed(5)+', '+lng.toFixed(5));
          document.getElementById('pinAddr').textContent=pinAddr;
        });
      });
    });
  }
}

function usePinAddr(){
  if(!pinAddr){showToast('Drop a pin first');return;}
  document.getElementById('locInput').value=pinAddr;
  setLocation(pinAddr);
  document.getElementById('pinMapWrap').style.display='none';
}

function saveCurrentLoc(){
  var addr=document.getElementById('locInput').value.trim();
  if(!addr){showToast('Enter an address first');return;}
  var name=prompt('Name this location (e.g. Home, Work, University):');
  if(!name)return;
  var locs=getSaved();
  locs=locs.filter(function(l){return l.name.toLowerCase()!==name.toLowerCase();});
  locs.unshift({name:name,address:addr,lat:pinLatLng?pinLatLng.lat:null,lng:pinLatLng?pinLatLng.lng:null});
  if(locs.length>8)locs=locs.slice(0,8);
  setSaved(locs);
  setLocation(addr);
  renderSavedLocs();
  showToast('📌 "'+name+'" saved!');
}

function renderSavedLocs(){
  var locs=getSaved(), c=document.getElementById('savedLocsWrap');
  if(!locs.length){c.innerHTML='<p style="font-size:.75rem;color:var(--c-muted);margin:8px 0 0;">No saved locations yet. Use GPS or drop a pin, then save.</p>';return;}
  var icons={'Home':'🏠','Work':'🏢','Office':'🏢','University':'🎓','Uni':'🎓','School':'🏫'};
  var html='<div style="font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--c-muted);margin-bottom:8px;margin-top:8px;">📌 Saved Locations</div>';
  locs.forEach(function(loc,i){
    var icon=icons[loc.name]||'📍';
    html+='<div class="saved-loc-row" onclick="useSavedLoc('+i+')">'
      +'<div style="width:34px;height:34px;border-radius:50%;background:var(--c-orange-l);color:var(--c-orange);display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.9rem;">'+icon+'</div>'
      +'<div style="flex:1;min-width:0;"><div style="font-weight:700;font-size:.88rem;color:var(--c-text);">'+loc.name+'</div>'
      +'<div style="font-size:.72rem;color:var(--c-muted);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">'+loc.address+'</div></div>'
      +'<button onclick="event.stopPropagation();deleteSavedLoc('+i+')" style="background:none;border:none;color:#f44336;padding:4px 8px;font-size:.85rem;cursor:pointer;">✕</button>'
      +'</div>';
  });
  c.innerHTML=html;
}
function useSavedLoc(i){var l=getSaved()[i];if(!l)return;document.getElementById('locInput').value=l.address;setLocation(l.address);closeLocEdit();}
function deleteSavedLoc(i){var l=getSaved();l.splice(i,1);setSaved(l);renderSavedLocs();}

// Init location display
var sl=localStorage.getItem('ydLocation');
if(sl)document.getElementById('locDisplay').textContent=sl;


// Truncate food descriptions
document.querySelectorAll('.fd-desc-el').forEach(function(el) {
  var d = el.getAttribute('data-desc') || '';
  el.textContent = d.length > 68 ? d.substring(0, 68) + '…' : d;
});


// ── Live AJAX search ──────────────────────────────────────────────
var searchTimer = null;
var searchInput = document.querySelector('input[name="search"]');
if (searchInput) {
  searchInput.addEventListener('input', function() {
    clearTimeout(searchTimer);
    var val = this.value.trim();
    searchTimer = setTimeout(function() {
      if (val.length < 2 && val.length > 0) return; // wait for 2+ chars
      fetch('/api/foods?search=' + encodeURIComponent(val) + '&category=${category}')
        .then(function(r){ return r.json(); })
        .then(function(foods) { renderLiveResults(foods, val); })
        .catch(function(){});
    }, 320);
  });
}

function renderLiveResults(foods, query) {
  var grid = document.getElementById('foodGrid');
  if (!grid) return;
  if (!foods || !foods.length) {
    grid.innerHTML = '<div class="col-12" style="text-align:center;padding:60px 0;">'
      + '<div style="font-size:3.5rem;margin-bottom:12px;">🔍</div>'
      + '<h4 style="color:var(--c-muted);">No results for "' + query + '"</h4>'
      + '<button onclick="location.href='/menu'" class="yd-btn yd-btn-primary mt-3" style="width:auto;padding:11px 24px;">Clear Search</button>'
      + '</div>';
    return;
  }
  grid.innerHTML = foods.map(function(food) {
    var available = food.available !== false;
    return '<div class="col-6 col-md-4 col-lg-3 yd-fade yd-visible">'
      + '<div class="yd-food-card" onclick="location.href='/menu/item/' + food.id + ''" style="cursor:pointer;">'
      + '<div class="yd-food-img-wrap" style="position:relative;">'
      + '<img class="yd-food-img" src="' + (food.imageUrl||'') + '" loading="lazy" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'">'
      + (food.popular ? '<span class="yd-badge yd-badge-pop">⭐ Popular</span>' : '')
      + '<span class="yd-badge yd-badge-cat">' + food.category + '</span>'
      + (!available ? '<div style="position:absolute;inset:0;background:rgba(0,0,0,.55);z-index:5;display:flex;align-items:center;justify-content:center;"><span style="background:rgba(0,0,0,.75);color:white;padding:6px 14px;border-radius:20px;font-size:.78rem;font-weight:700;">⏸ Unavailable</span></div>' : '')
      + '<button class="yd-fav-btn" data-fav-id="' + food.id + '" data-fav-name="' + food.name + '" data-fav-price="' + food.price + '" data-fav-img="' + (food.imageUrl||'') + '"'
      + ' onclick="event.stopPropagation();var b=this;var a=Favs.toggle(b.dataset.favId,b.dataset.favName,b.dataset.favPrice,b.dataset.favImg);b.textContent=a?'♥':'♡';b.classList.toggle('active',a);">'
      + (Favs.has(food.id) ? '♥' : '♡') + '</button>'
      + '</div>'
      + '<div class="yd-food-body">'
      + '<div class="d-flex justify-content-between align-items-start mb-1">'
      + '<div class="yd-food-name">' + food.name + '</div>'
      + '<div class="yd-food-price text-nowrap">LKR ' + Math.round(food.price).toLocaleString() + '</div>'
      + '</div>'
      + '<p class="yd-food-desc">' + (food.description||'').substring(0,65) + (food.description&&food.description.length>65?'…':'') + '</p>'
      + '<div class="d-flex align-items-center gap-2">'
      + '<div class="yd-qty"><button class="yd-qty-btn" onclick="event.stopPropagation();dec('lq' + food.id + '')">−</button><span class="yd-qty-val" id="lq' + food.id + '">1</span><button class="yd-qty-btn" onclick="event.stopPropagation();inc('lq' + food.id + '')">+</button></div>'
      + (available
        ? '<button class="yd-btn yd-btn-primary yd-add-btn" style="flex:1;padding:9px;font-size:.82rem;" data-food-id="' + food.id + '" data-food-name="' + food.name + '" data-food-price="' + food.price + '" data-food-img="' + (food.imageUrl||'') + '" data-food-qty="lq' + food.id + '" onclick="event.stopPropagation();doAddToCart(this)"><i class="bi bi-cart-plus me-1"></i>Add</button>'
        : '<button class="yd-btn" style="flex:1;padding:9px;font-size:.82rem;background:#f0f0f0;color:#aaa;border:none;cursor:not-allowed;" disabled>⏸ Unavailable</button>')
      + '</div></div></div></div>';
  }).join('');
}

// Restore fav hearts
document.querySelectorAll('[data-fav-id]').forEach(function(btn){
  if(Favs.has(btn.getAttribute('data-fav-id'))){btn.textContent='♥';btn.classList.add('active');}
});

// ── Offer countdown timers ────────────────────────────────────────
document.querySelectorAll('.offer-countdown[data-created]').forEach(function(el) {
  var created = el.getAttribute('data-created');
  if (!created) return;
  // Offers expire 7 days after creation
  try {
    var parts = created.split(' ');
    var dateParts = (parts[0]||'').split('-');
    var timeParts = (parts[1]||'00:00').split(':');
    var exp = new Date(
      parseInt(dateParts[0]), parseInt(dateParts[1])-1, parseInt(dateParts[2]),
      parseInt(timeParts[0]||0), parseInt(timeParts[1]||0)
    );
    exp = new Date(exp.getTime() + 7 * 24 * 60 * 60 * 1000); // +7 days
    function update() {
      var diff = exp - Date.now();
      if (diff <= 0) { el.textContent = 'Expired'; return; }
      var d = Math.floor(diff / 86400000);
      var h = Math.floor((diff % 86400000) / 3600000);
      var m = Math.floor((diff % 3600000) / 60000);
      el.textContent = d > 0 ? 'Expires in ' + d + 'd ' + h + 'h' : 'Expires in ' + h + 'h ' + m + 'm';
    }
    update();
    setInterval(update, 60000);
  } catch(e) {}
});

</script>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
