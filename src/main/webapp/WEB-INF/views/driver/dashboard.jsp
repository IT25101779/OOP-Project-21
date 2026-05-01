<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<title>Driver — YummyDish</title>
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="/css/yummydish.css" rel="stylesheet">
<script>(function(){var t=localStorage.getItem('ydTheme');if(t==='dark')document.documentElement.setAttribute('data-theme','dark');})();</script>
<script src="/js/app.js"></script>
<script src="/js/maps.js"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&amp;libraries=places,geometry,directions&amp;callback=googleMapsReady&amp;loading=async" async defer></script>
<style>
*{font-family:'Inter',system-ui,sans-serif;}
body{overflow:hidden;background:#0F0F0F;}
#mainMap{position:fixed;inset:0;z-index:0;}
#sidebar{
  position:fixed;top:0;left:0;width:360px;height:100vh;
  background:var(--c-surface);border-right:1px solid var(--c-border);
  overflow-y:auto;z-index:100;
  transition:transform .35s cubic-bezier(.4,0,.2,1);
  box-shadow:4px 0 32px rgba(0,0,0,.25);
  display:flex;flex-direction:column;
}
#sidebar.hidden{transform:translateX(-360px);}
#mapControls{
  position:fixed;top:16px;right:16px;z-index:200;
  display:flex;flex-direction:column;gap:8px;
}
#togBtn{
  position:fixed;top:50%;left:0;transform:translateY(-50%);z-index:200;
  background:var(--c-surface);border:1px solid var(--c-border);
  border-radius:0 12px 12px 0;padding:14px 10px;cursor:pointer;
  box-shadow:4px 0 16px rgba(0,0,0,.2);transition:left .35s cubic-bezier(.4,0,.2,1);
}
#togBtn.shifted{left:360px;}
.map-ctrl-btn{
  background:var(--c-surface);border:1px solid var(--c-border);border-radius:12px;
  padding:10px 14px;font-size:.85rem;font-weight:600;cursor:pointer;
  box-shadow:0 2px 12px rgba(0,0,0,.15);transition:all .2s;display:flex;align-items:center;gap:7px;
  color:var(--c-text);white-space:nowrap;
}
.map-ctrl-btn:hover{background:var(--c-orange);color:white;border-color:var(--c-orange);}
.drv-hdr{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:14px 16px;flex-shrink:0;}
.order-tile{
  padding:14px 16px;border-bottom:1px solid var(--c-border);
  cursor:pointer;transition:background .18s;position:relative;
}
.order-tile:hover{background:var(--c-orange-l);}
.order-tile.active{background:var(--c-orange-l);border-left:4px solid var(--c-orange);}
.order-tile.active-nav{background:#E3F2FD;border-left:4px solid #1565C0;}
.dist-badge{
  display:inline-flex;align-items:center;gap:4px;
  background:var(--c-bg);border:1px solid var(--c-border);
  padding:3px 9px;border-radius:20px;font-size:.7rem;font-weight:700;
  color:var(--c-muted);margin-top:5px;
}
.act-row{display:flex;gap:6px;margin-top:10px;flex-wrap:wrap;}
.act-btn{
  padding:7px 12px;border-radius:9px;border:none;font-weight:600;font-size:.75rem;
  cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:5px;
}
.btn-nav    {background:#1565C0;color:white;}
.btn-nav:hover{background:#0D47A1;}
.btn-pickup {background:#E8F5E9;color:#2E7D32;}
.btn-pickup:hover{background:#2E7D32;color:white;}
.btn-onway  {background:#E3F2FD;color:#1565C0;}
.btn-onway:hover{background:#1565C0;color:white;}
.btn-done   {background:#F3E8FF;color:#7C3AED;}
.btn-done:hover{background:#7C3AED;color:white;}
.nav-bar{
  background:linear-gradient(135deg,#1565C0,#1976D2);color:white;
  padding:12px 16px;font-size:.82rem;font-weight:600;
  display:none;align-items:center;gap:10px;flex-shrink:0;
}
.nav-bar.active{display:flex;}
.weather-pill{
  display:inline-flex;align-items:center;gap:5px;
  background:rgba(255,255,255,.1);border-radius:20px;
  padding:4px 10px;font-size:.72rem;font-weight:600;color:rgba(255,255,255,.9);
}
.gps-dot{width:9px;height:9px;border-radius:50%;background:#4CAF50;animation:pulse 1.5s ease-in-out infinite;}
@media(max-width:768px){
  #sidebar{width:100%;}
  #sidebar.hidden{transform:translateX(-100%);}
  #togBtn.shifted{left:100%;}
}
</style>
</head>
<body>

<!-- Full-screen map -->
<div id="mainMap"></div>

<!-- Sidebar toggle -->
<button id="togBtn" onclick="toggleSidebar()" title="Toggle orders">
  <i class="bi bi-list" style="font-size:1.2rem;color:var(--c-text);"></i>
</button>

<!-- Map control buttons -->
<div id="mapControls">
  <button class="map-ctrl-btn" onclick="locateMe()"><i class="bi bi-crosshair2" style="color:var(--c-orange);"></i>My Location</button>
  <button class="map-ctrl-btn" id="routeAllBtn" onclick="buildAllRoutes()"><i class="bi bi-map" style="color:#1565C0;"></i>Plan Route</button>
  <div class="map-ctrl-btn" id="weatherBadge"><span>⏳</span><span>Loading...</span></div>
</div>

<!-- Sidebar -->
<div id="sidebar">
  <!-- Driver header -->
  <div class="drv-hdr">
    <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px;">
      <div style="width:38px;height:38px;border-radius:50%;background:var(--c-orange);color:white;display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;font-size:1rem;">
        ${fn:substring(driver.name,0,1)}
      </div>
      <div style="flex:1;">
        <div style="font-weight:700;font-size:.9rem;color:white;">${driver.name}</div>
        <div style="display:flex;align-items:center;gap:6px;margin-top:2px;">
          <div class="gps-dot" id="gpsDot" style="background:#888;"></div>
          <span id="gpsStatus" style="font-size:.68rem;color:rgba(255,255,255,.55);">GPS inactive</span>
        </div>
      </div>
      <a href="/driver/logout" style="color:rgba(255,255,255,.5);font-size:.82rem;"><i class="bi bi-box-arrow-right"></i></a>
    </div>
    <!-- Active navigation banner -->
    <div class="nav-bar" id="navBar">
      <i class="bi bi-arrow-right-circle-fill" style="font-size:1.1rem;flex-shrink:0;"></i>
      <div style="flex:1;min-width:0;">
        <div id="navInstruction" style="font-size:.82rem;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Navigate to destination</div>
        <div id="navEta" style="font-size:.7rem;opacity:.8;"></div>
      </div>
      <button onclick="stopNavigation()" style="background:rgba(255,255,255,.15);border:none;color:white;padding:5px 10px;border-radius:8px;font-size:.75rem;cursor:pointer;flex-shrink:0;">✕ End</button>
    </div>
  </div>

  <!-- Orders list -->
  <div style="flex:1;overflow-y:auto;">
    <div style="padding:10px 16px;background:var(--c-bg);border-bottom:1px solid var(--c-border);display:flex;justify-content:space-between;align-items:center;">
      <div style="font-weight:700;font-size:.82rem;color:var(--c-text);">
        <i class="bi bi-bag-check me-1" style="color:var(--c-orange);"></i>
        Active Orders <span style="color:var(--c-orange);">(${fn:length(orders)})</span>
      </div>
      <button onclick="location.reload()" style="background:none;border:none;color:var(--c-muted);font-size:.75rem;cursor:pointer;"><i class="bi bi-arrow-clockwise me-1"></i>Refresh</button>
    </div>

    <c:choose>
      <c:when test="${empty orders}">
        <div style="text-align:center;padding:52px 20px;color:var(--c-muted);">
          <div style="font-size:3rem;margin-bottom:12px;">📭</div>
          <div style="font-weight:600;color:var(--c-text);margin-bottom:6px;">No active orders</div>
          <div style="font-size:.82rem;">Orders with "Ready" status appear here</div>
        </div>
      </c:when>
      <c:otherwise>
        <div id="orderList">
          <c:forEach items="${orders}" var="o" varStatus="st">
          <div class="order-tile" id="tile_${o.orderId}" onclick="focusOrder('${o.orderId}')">
            <!-- Priority badge -->
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:7px;">
              <div style="width:24px;height:24px;border-radius:50%;background:${st.index==0?'var(--c-orange)':'#888'};color:white;display:flex;align-items:center;justify-content:center;font-size:.7rem;font-weight:800;flex-shrink:0;">${st.index+1}</div>
              <span style="font-family:monospace;font-weight:800;font-size:.875rem;color:var(--c-text);">#${o.orderId}</span>
              <span yd-status yd-s-ready" style="font-size:.65rem;">${o.statusBadge}</span>
            </div>

            <div style="font-size:.8rem;color:var(--c-text2);margin-bottom:2px;">
              <i class="bi bi-person me-1" style="color:var(--c-orange);"></i>${o.customerName}
            </div>
            <div style="font-size:.78rem;color:var(--c-muted);margin-bottom:2px;">
              <i class="bi bi-geo-alt me-1"></i>${o.deliveryAddress}
            </div>
            <div style="font-size:.78rem;font-weight:700;color:var(--c-orange);margin-bottom:5px;">
              LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/>
            </div>

            <c:if test="${fn:length(o.chefNote)>0}">
              <div style="background:#FFF8E1;border-radius:8px;padding:4px 10px;font-size:.7rem;color:#E65100;margin-bottom:6px;border:1px solid #FFE082;">
                <i class="bi bi-chat-dots me-1"></i>${o.chefNote}
              </div>
            </c:if>

            <!-- Distance badge (filled by JS) -->
            <div class="dist-badge" id="dist_${o.orderId}">
              <i class="bi bi-ruler"></i> Calculating...
            </div>

            <!-- Action buttons -->
            <div class="act-row">
              <button onclick="event.stopPropagation();startNavigation('${o.orderId}')" class="act-btn btn-nav">
                <i class="bi bi-compass-fill"></i>Navigate
              </button>
              <c:choose>
                <c:when test="${o.status=='READY'}">
                  <form action="/driver/pickup/${o.orderId}" method="post" onclick="event.stopPropagation()">
                    <button type="submit" class="act-btn btn-pickup"><i class="bi bi-bag-check"></i>Picked Up</button>
                  </form>
                </c:when>
                <c:when test="${o.status=='HANDOVER'}">
                  <form action="/driver/delivering/${o.orderId}" method="post" onclick="event.stopPropagation()">
                    <button type="submit" class="act-btn btn-onway"><i class="bi bi-bicycle"></i>Out for Delivery</button>
                  </form>
                </c:when>
                <c:when test="${o.status=='ON_WAY'}">
                  <form action="/driver/delivered/${o.orderId}" method="post" onclick="event.stopPropagation()" onsubmit="return confirm('Confirm delivered to ${o.customerName}?')">
                    <button type="submit" class="act-btn btn-done"><i class="bi bi-check-circle"></i>Delivered!</button>
                  </form>
                </c:when>
              </c:choose>
            </div>
          </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div><!-- /sidebar -->

<script>
// ── Constants ─────────────────────────────────────────────────────
var KITCHEN = { lat: ${restaurant_lat}, lng: ${restaurant_lng} }; // Queens Hotel area, Kandy
var ORDERS = [
  <c:forEach items="${orders}" var="o" varStatus="st">
  {
    orderId: '${o.orderId}',
    address: '${fn:replace(o.deliveryAddress,"'","\\'")}',
    customer: '${fn:replace(o.customerName,"'","\\'")}',
    total: ${o.totalAmount},
    status: '${o.status}',
    idx: ${st.index}
  }${!st.last ? ',' : ''}
  </c:forEach>
];

// ── State ─────────────────────────────────────────────────────────
var map = null;
var driverMarker = null;
var driverPos    = { lat: KITCHEN.lat, lng: KITCHEN.lng };
var geocoded     = {};   // orderId -> {lat,lng}
var markers      = {};   // orderId -> marker
var navRenderer  = null; // active directions renderer
var activeNavId  = null;
var watchId      = null;
var gpsPushTimer = null;

// ── Sidebar toggle ─────────────────────────────────────────────────
function toggleSidebar() {
  var sb  = document.getElementById('sidebar');
  var btn = document.getElementById('togBtn');
  var hidden = sb.classList.toggle('hidden');
  btn.classList.toggle('shifted', !hidden);
  if (map) setTimeout(function(){ google.maps.event.trigger(map,'resize'); }, 360);
}

// ── Map initialisation ─────────────────────────────────────────────
function initDriverMap() {
  map = new google.maps.Map(document.getElementById('mainMap'), {
    center: KITCHEN,
    zoom: 14,
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: false,
    zoomControlOptions: { position: google.maps.ControlPosition.RIGHT_BOTTOM },
    gestureHandling: 'greedy',
    styles: [
      { featureType:'poi.business',      stylers:[{visibility:'off'}] },
      { featureType:'transit',           stylers:[{visibility:'simplified'}] },
      { featureType:'road',              elementType:'geometry', stylers:[{color:'#f5f5f5'}] },
      { featureType:'road.highway',      elementType:'geometry', stylers:[{color:'#ffe0b2'}] },
      { featureType:'water',             elementType:'geometry', stylers:[{color:'#c9e8f0'}] },
      { featureType:'landscape.natural', elementType:'geometry', stylers:[{color:'#e8f5e9'}] }
    ]
  });

  // Kitchen marker
  new google.maps.Marker({
    map: map,
    position: KITCHEN,
    title: 'YummyDish Kitchen',
    icon: {
      url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" width="44" height="56" viewBox="0 0 44 56">'
        + '<path d="M22 0C9.8 0 0 9.8 0 22c0 16 22 34 22 34S44 38 44 22C44 9.8 34.2 0 22 0z" fill="#FF6B35"/>'
        + '<circle cx="22" cy="22" r="14" fill="white"/>'
        + '<text x="22" y="27" text-anchor="middle" font-size="16">🍽️</text>'
        + '</svg>'
      ),
      scaledSize: new google.maps.Size(44, 56),
      anchor: new google.maps.Point(22, 56)
    }
  });

  // Driver marker
  driverMarker = new google.maps.Marker({
    map: map,
    position: KITCHEN,
    title: 'You',
    zIndex: 999,
    icon: {
      url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" width="56" height="56" viewBox="0 0 56 56">'
        + '<circle cx="28" cy="28" r="26" fill="#1565C0" stroke="white" stroke-width="3"/>'
        + '<text x="28" y="37" text-anchor="middle" font-size="28">🛵</text>'
        + '</svg>'
      ),
      scaledSize: new google.maps.Size(56, 56),
      anchor: new google.maps.Point(28, 28)
    }
  });

  startGPS();
  geocodeAllOrders();
  loadWeather();
  setInterval(loadWeather, 300000);
  // Auto-reload every 45s to pick up new orders
  setTimeout(function(){ location.reload(); }, 45000);
}

// ── GPS tracking ───────────────────────────────────────────────────
function startGPS() {
  if (!navigator.geolocation) return;
  // Initial fix
  navigator.geolocation.getCurrentPosition(onPosition, onGpsErr, {
    enableHighAccuracy: true, timeout: 10000, maximumAge: 5000
  });
  // Continuous watch
  watchId = navigator.geolocation.watchPosition(onPosition, onGpsErr, {
    enableHighAccuracy: true, maximumAge: 3000, timeout: 15000
  });
}

function onPosition(pos) {
  var lat = pos.coords.latitude, lng = pos.coords.longitude;
  driverPos = { lat: lat, lng: lng };
  // Smooth marker animation
  animateMarker(driverMarker, lat, lng);
  // Update GPS UI
  document.getElementById('gpsDot').style.background = '#4CAF50';
  document.getElementById('gpsStatus').textContent   = 'GPS Live · ±' + Math.round(pos.coords.accuracy) + 'm';
  // Update nav ETA if navigating
  if (activeNavId) updateNavEta();
  // Post to server every 10s
  if (!gpsPushTimer || (Date.now() - gpsPushTimer) > 10000) {
    gpsPushTimer = Date.now();
    fetch('/api/driver/location', {
      method: 'POST', headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ lat: lat, lng: lng })
    }).catch(function(){});
  }
}

function onGpsErr(e) {
  document.getElementById('gpsDot').style.background = '#f44336';
  document.getElementById('gpsStatus').textContent   = 'GPS: ' + e.message;
}

function animateMarker(marker, toLat, toLng) {
  if (!marker) return;
  var from = marker.getPosition();
  var steps = 25, i = 0;
  var dLat = (toLat - from.lat()) / steps;
  var dLng = (toLng - from.lng()) / steps;
  var iv = setInterval(function() {
    i++;
    marker.setPosition({ lat: from.lat() + dLat*i, lng: from.lng() + dLng*i });
    if (i >= steps) clearInterval(iv);
  }, 40);
}

// ── Geocode all order addresses ────────────────────────────────────
function geocodeAllOrders() {
  ORDERS.forEach(function(o) {
    var q = o.address + ', Kandy, Sri Lanka';
    new google.maps.Geocoder().geocode({ address: q }, function(results, status) {
      if (status !== 'OK' || !results.length) {
        // Fallback: small offset from kitchen
        geocoded[o.orderId] = { lat: KITCHEN.lat + (o.idx+1)*0.004, lng: KITCHEN.lng + (o.idx-1)*0.003 };
      } else {
        var loc = results[0].geometry.location;
        geocoded[o.orderId] = { lat: loc.lat(), lng: loc.lng() };
      }
      placeOrderMarker(o);
      updateDistanceBadge(o.orderId);
      sortOrdersByDistance();
    });
  });
}

function placeOrderMarker(o) {
  var g = geocoded[o.orderId]; if (!g) return;
  var colors = { READY:'#4CAF50', HANDOVER:'#2196F3', ON_WAY:'#FF9800' };
  var color  = colors[o.status] || '#888';
  var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="52" viewBox="0 0 40 52">'
    + '<path d="M20 0C9 0 0 9 0 20c0 14 20 32 20 32S40 34 40 20C40 9 31 0 20 0z" fill="' + color + '"/>'
    + '<circle cx="20" cy="20" r="11" fill="white"/>'
    + '<text x="20" y="24" text-anchor="middle" font-size="13" font-weight="bold" fill="' + color + '">' + (o.idx+1) + '</text>'
    + '</svg>';
  var marker = new google.maps.Marker({
    map: map,
    position: geocoded[o.orderId],
    icon: {
      url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg),
      scaledSize: new google.maps.Size(40,52),
      anchor: new google.maps.Point(20,52)
    },
    title: '#' + o.orderId + ' — ' + o.customer
  });
  var iw = new google.maps.InfoWindow({
    content: '<div style="font-family:Inter,sans-serif;padding:8px 12px;min-width:180px;">'
      + '<strong style="color:#FF6B35;">#' + o.orderId + '</strong><br>'
      + '<span style="font-size:12px;color:#555;">' + o.customer + '</span><br>'
      + '<span style="font-size:12px;color:#888;">' + o.address + '</span><br>'
      + '<button onclick="startNavigation(\'' + o.orderId + '\')" style="margin-top:8px;background:#1565C0;color:white;border:none;padding:6px 14px;border-radius:8px;font-size:12px;cursor:pointer;font-weight:600;">Navigate →</button>'
      + '</div>'
  });
  marker.addListener('click', function(){ iw.open(map, marker); });
  if (markers[o.orderId]) markers[o.orderId].setMap(null);
  markers[o.orderId] = marker;
}

// ── Haversine distance ─────────────────────────────────────────────
function haversine(lat1, lng1, lat2, lng2) {
  var R = 6371;
  var dLat = (lat2-lat1)*Math.PI/180;
  var dLng = (lng2-lng1)*Math.PI/180;
  var a = Math.sin(dLat/2)*Math.sin(dLat/2)
    + Math.cos(lat1*Math.PI/180)*Math.cos(lat2*Math.PI/180)*Math.sin(dLng/2)*Math.sin(dLng/2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}

function updateDistanceBadge(orderId) {
  var g = geocoded[orderId];
  if (!g) return;
  var d = haversine(KITCHEN.lat, KITCHEN.lng, g.lat, g.lng);
  var eta = Math.round(d / 0.35);  // 0.35 km/min average motorbike speed in Kandy traffic
  var el = document.getElementById('dist_' + orderId);
  if (el) el.innerHTML = '<i class="bi bi-ruler"></i> ' + d.toFixed(1) + ' km · ~' + eta + ' min ride';
}

// ── Sort orders by distance from driver ────────────────────────────
function sortOrdersByDistance() {
  var list = document.getElementById('orderList');
  if (!list) return;
  var tiles = Array.from(list.querySelectorAll('.order-tile'));
  tiles.sort(function(a, b) {
    var idA = a.id.replace('tile_',''), idB = b.id.replace('tile_','');
    var gA  = geocoded[idA], gB = geocoded[idB];
    var dA  = gA ? haversine(driverPos.lat, driverPos.lng, gA.lat, gA.lng) : 999;
    var dB  = gB ? haversine(driverPos.lat, driverPos.lng, gB.lat, gB.lng) : 999;
    return dA - dB;
  });
  tiles.forEach(function(t, i) {
    list.appendChild(t);
    // Update priority number
    var numEl = t.querySelector('[style*="border-radius:50%"]');
    if (numEl) {
      numEl.textContent = i + 1;
      numEl.style.background = i === 0 ? 'var(--c-orange)' : '#888';
    }
  });
}

// ── Navigation (in-map, not external) ─────────────────────────────
function startNavigation(orderId) {
  var g = geocoded[orderId];
  var order = ORDERS.find(function(o){ return o.orderId === orderId; });
  if (!g || !order) {
    showToast('Locating address...');
    return;
  }

  // Highlight tile
  document.querySelectorAll('.order-tile').forEach(function(t){ t.classList.remove('active-nav'); });
  var tile = document.getElementById('tile_' + orderId);
  if (tile) tile.classList.add('active-nav');

  // Clear previous route
  if (navRenderer) navRenderer.setMap(null);

  activeNavId = orderId;

  // Draw route from driver position to destination
  var directionsService = new google.maps.DirectionsService();
  navRenderer = new google.maps.DirectionsRenderer({
    map: map,
    suppressMarkers: false,
    polylineOptions: {
      strokeColor: '#1565C0',
      strokeWeight: 6,
      strokeOpacity: 0.9
    },
    markerOptions: {
      origin: { visible: false },  // driver marker already shown
      destination: { visible: true }
    }
  });

  directionsService.route({
    origin:      new google.maps.LatLng(driverPos.lat, driverPos.lng),
    destination: new google.maps.LatLng(g.lat, g.lng),
    travelMode:  google.maps.TravelMode.DRIVING,
    drivingOptions: {
      departureTime: new Date(),
      trafficModel:  google.maps.TrafficModel.BEST_GUESS
    }
  }, function(result, status) {
    if (status === 'OK') {
      navRenderer.setDirections(result);
      var leg = result.routes[0].legs[0];
      // Use duration_in_traffic if available, else duration
      var durSecs = (leg.duration_in_traffic || leg.duration).value;
      var durText = (leg.duration_in_traffic || leg.duration).text;
      var dist    = leg.distance.text;

      // Show nav bar
      var nb = document.getElementById('navBar');
      nb.classList.add('active');
      document.getElementById('navInstruction').textContent =
        '→ ' + order.address.substring(0, 45) + (order.address.length > 45 ? '...' : '');
      document.getElementById('navEta').textContent =
        dist + ' · ' + durText + ' · Arrival ~' + getArrivalTime(durSecs);

      // Fit map to route
      var bounds = new google.maps.LatLngBounds();
      bounds.extend(new google.maps.LatLng(driverPos.lat, driverPos.lng));
      bounds.extend(new google.maps.LatLng(g.lat, g.lng));
      map.fitBounds(bounds, { padding: { top:80, right:80, bottom:80, left: window.innerWidth < 768 ? 20 : 380 } });

      showToast('Navigation started — ' + dist + ', ~' + durText);

      // Start step-by-step turn detection
      startTurnByTurn(result.routes[0].legs[0].steps);
    } else {
      showToast('Route not found: ' + status);
    }
  });
}

function getArrivalTime(durationSeconds) {
  var arr = new Date(Date.now() + durationSeconds * 1000);
  return arr.toLocaleTimeString('en-LK', { hour:'2-digit', minute:'2-digit' });
}

function updateNavEta() {
  if (!activeNavId) return;
  var g = geocoded[activeNavId];
  if (!g) return;
  var distKm = haversine(driverPos.lat, driverPos.lng, g.lat, g.lng);
  var etaMins = Math.round(distKm / 0.35);
  var el = document.getElementById('navEta');
  if (el) el.textContent = distKm.toFixed(1) + ' km remaining · ~' + etaMins + ' min';

  // Check if arrived (< 50m)
  if (distKm < 0.05) {
    showNotif('✅', 'Arrived!', 'You are at the delivery location.');
    stopNavigation();
  }
}

// Turn-by-turn: update instruction as driver moves
function startTurnByTurn(steps) {
  var stepIdx = 0;
  var stepTimer = setInterval(function() {
    if (!activeNavId || !steps[stepIdx]) { clearInterval(stepTimer); return; }
    var step = steps[stepIdx];
    var sLat = step.end_location.lat(), sLng = step.end_location.lng();
    var dist = haversine(driverPos.lat, driverPos.lng, sLat, sLng);
    if (dist < 0.05) {  // within 50m of step end — advance
      stepIdx++;
      if (steps[stepIdx]) {
        var inst = steps[stepIdx].instructions.replace(/<[^>]+>/g, '');
        document.getElementById('navInstruction').textContent = '→ ' + inst.substring(0, 55);
      }
    }
  }, 3000);
}

function stopNavigation() {
  activeNavId = null;
  if (navRenderer) { navRenderer.setMap(null); navRenderer = null; }
  document.getElementById('navBar').classList.remove('active');
  document.querySelectorAll('.order-tile').forEach(function(t){ t.classList.remove('active-nav'); });
}

function focusOrder(orderId) {
  document.querySelectorAll('.order-tile').forEach(function(t){ t.classList.remove('active'); });
  var tile = document.getElementById('tile_' + orderId);
  if (tile) tile.classList.add('active');
  var g = geocoded[orderId];
  if (g && map) {
    map.panTo(g);
    map.setZoom(16);
    var mk = markers[orderId];
    if (mk) google.maps.event.trigger(mk, 'click');
  }
}

function locateMe() {
  if (driverPos && map) {
    map.panTo(driverPos);
    map.setZoom(16);
  }
}

// ── Build optimized multi-stop route ──────────────────────────────
function buildAllRoutes() {
  var geoList = ORDERS
    .filter(function(o){ return geocoded[o.orderId]; })
    .sort(function(a, b) {
      var dA = haversine(driverPos.lat, driverPos.lng, geocoded[a.orderId].lat, geocoded[a.orderId].lng);
      var dB = haversine(driverPos.lat, driverPos.lng, geocoded[b.orderId].lat, geocoded[b.orderId].lng);
      return dA - dB;
    });

  if (geoList.length === 0) { showToast('No orders to route yet'); return; }
  if (geoList.length === 1) { startNavigation(geoList[0].orderId); return; }

  if (navRenderer) navRenderer.setMap(null);
  var dest  = geoList[geoList.length - 1];
  var stops = geoList.slice(0, -1).map(function(o) {
    return { location: new google.maps.LatLng(geocoded[o.orderId].lat, geocoded[o.orderId].lng), stopover: true };
  });

  navRenderer = new google.maps.DirectionsRenderer({
    map: map,
    polylineOptions: { strokeColor: '#FF6B35', strokeWeight: 5, strokeOpacity: 0.85 }
  });

  new google.maps.DirectionsService().route({
    origin:            new google.maps.LatLng(driverPos.lat, driverPos.lng),
    destination:       new google.maps.LatLng(geocoded[dest.orderId].lat, geocoded[dest.orderId].lng),
    waypoints:         stops,
    optimizeWaypoints: true,
    travelMode:        google.maps.TravelMode.DRIVING
  }, function(result, status) {
    if (status === 'OK') {
      navRenderer.setDirections(result);
      var legs  = result.routes[0].legs;
      var totKm = (legs.reduce(function(s,l){ return s+l.distance.value; }, 0)/1000).toFixed(1);
      var totMin = Math.round(legs.reduce(function(s,l){ return s+(l.duration_in_traffic||l.duration).value; }, 0)/60);
      var nb = document.getElementById('navBar');
      nb.classList.add('active');
      document.getElementById('navInstruction').textContent = geoList.length + ' stops — optimized route';
      document.getElementById('navEta').textContent = totKm + ' km total · ~' + totMin + ' min';
      var bounds = new google.maps.LatLngBounds();
      legs.forEach(function(l){ bounds.extend(l.start_location); bounds.extend(l.end_location); });
      map.fitBounds(bounds, { padding: 80 });
      showToast('Route planned: ' + geoList.length + ' stops, ' + totKm + ' km');
    }
  });
}

// ── Weather ────────────────────────────────────────────────────────
async function loadWeather() {
  try {
    var r = await fetch('/api/weather');
    var w = await r.json();
    var el = document.getElementById('weatherBadge');
    if (!el) return;
    el.innerHTML = '<span>' + (w.condition||'').split(' ')[0] + '</span><span>' + w.temp + '</span>';
    if (w.isHeavy) {
      el.style.background = '#C62828'; el.style.color = 'white'; el.style.borderColor = '#C62828';
      showNotif('⛈️', 'Heavy Rain!', 'Drive carefully. Surcharge applied.');
    } else if (w.isRaining) {
      el.style.background = '#1565C0'; el.style.color = 'white'; el.style.borderColor = '#1565C0';
    }
  } catch(e) {}
}

onMapsReady(initDriverMap);
</script>
</body></html>
