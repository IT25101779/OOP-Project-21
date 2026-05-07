<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" buffer="128kb" autoFlush="true" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<title>Driver &mdash; YummyDish</title>
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.css"/>
<style>
*{font-family:'Inter',system-ui,sans-serif;box-sizing:border-box;margin:0;padding:0;}
:root{--c-orange:#FF6B35;--c-orange-l:#FFF0EB;--c-bg:#FDFAF7;--c-surface:#FFFFFF;
  --c-border:#EDE8E0;--c-text:#0F0F0F;--c-text2:#4A4A4A;--c-muted:#8A8078;}
body{overflow:hidden;background:#1a1a2e;}
#map{position:fixed;inset:0;z-index:0;}
#sidebar{position:fixed;top:0;left:0;width:340px;height:100vh;background:var(--c-surface);
  border-right:1px solid var(--c-border);overflow-y:auto;z-index:1000;
  transition:transform .3s cubic-bezier(.4,0,.2,1);box-shadow:4px 0 24px rgba(0,0,0,.2);
  display:flex;flex-direction:column;}
#sidebar.hidden{transform:translateX(-340px);}
#togBtn{position:fixed;top:50%;z-index:1001;left:340px;transform:translateY(-50%);
  background:var(--c-surface);border:1px solid var(--c-border);border-radius:0 12px 12px 0;
  padding:14px 8px;cursor:pointer;box-shadow:4px 0 16px rgba(0,0,0,.15);
  transition:left .3s cubic-bezier(.4,0,.2,1);}
#togBtn.shifted{left:0;}
#mapControls{position:fixed;top:12px;right:12px;z-index:1000;display:flex;flex-direction:column;gap:8px;}
.map-btn{background:white;border:1px solid #ddd;border-radius:12px;padding:10px 16px;
  font-size:.82rem;font-weight:600;cursor:pointer;box-shadow:0 2px 12px rgba(0,0,0,.15);
  display:flex;align-items:center;gap:8px;color:#333;white-space:nowrap;transition:all .2s;min-width:130px;}
.map-btn:hover{background:var(--c-orange);color:white;border-color:var(--c-orange);}
.map-btn.active{background:#1565C0;color:white;border-color:#1565C0;}
.drv-hdr{background:linear-gradient(135deg,#0F0F0F 0%,#1e2a3a 100%);padding:16px;flex-shrink:0;}
.driver-avatar{width:42px;height:42px;border-radius:50%;background:var(--c-orange);color:white;
  display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1.1rem;
  flex-shrink:0;border:2px solid rgba(255,255,255,.3);}
.gps-dot{width:9px;height:9px;border-radius:50%;background:#888;display:inline-block;transition:background .5s;}
.gps-dot.live{background:#4CAF50;animation:gpsPulse 1.5s ease-in-out infinite;}
@keyframes gpsPulse{0%,100%{opacity:1;transform:scale(1);}50%{opacity:.6;transform:scale(1.3);}}
.nav-bar{background:linear-gradient(135deg,#1565C0,#1976D2);color:white;padding:10px 16px;
  display:none;align-items:center;gap:10px;flex-shrink:0;border-bottom:2px solid rgba(255,255,255,.2);}
.nav-bar.show{display:flex;}
.orders-hdr{padding:10px 16px;background:var(--c-bg);border-bottom:1px solid var(--c-border);
  display:flex;justify-content:space-between;align-items:center;flex-shrink:0;}
.order-tile{padding:14px 16px;border-bottom:1px solid var(--c-border);cursor:pointer;
  transition:background .18s;border-left:4px solid transparent;}
.order-tile:hover{background:#FFF8F5;}
.order-tile.selected{background:var(--c-orange-l);border-left-color:var(--c-orange);}
.order-tile.navigating{background:#E3F2FD;border-left-color:#1565C0;}
.priority-num{width:26px;height:26px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:.7rem;font-weight:800;color:white;flex-shrink:0;}
.dist-badge{display:inline-flex;align-items:center;gap:5px;background:var(--c-bg);
  border:1px solid var(--c-border);padding:3px 10px;border-radius:20px;
  font-size:.72rem;font-weight:600;color:var(--c-muted);margin-top:6px;}
.dist-badge.found{color:#1565C0;border-color:#BBDEFB;background:#E3F2FD;}
.act-row{display:flex;gap:6px;margin-top:10px;flex-wrap:wrap;}
.act-btn{padding:8px 13px;border-radius:9px;border:none;font-weight:600;font-size:.76rem;
  cursor:pointer;display:inline-flex;align-items:center;gap:5px;transition:all .2s;}
.btn-nav{background:#1565C0;color:white;} .btn-nav:hover{background:#0D47A1;}
.btn-pickup{background:#E8F5E9;color:#2E7D32;} .btn-pickup:hover{background:#2E7D32;color:white;}
.btn-onway{background:#E3F2FD;color:#1565C0;} .btn-onway:hover{background:#1565C0;color:white;}
.btn-done{background:#F3E8FF;color:#7C3AED;} .btn-done:hover{background:#7C3AED;color:white;}
.btn-stop{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.3);
  color:white;font-size:.72rem;padding:5px 10px;}
.status-chip{display:inline-flex;align-items:center;gap:4px;padding:2px 8px;
  border-radius:20px;font-size:.65rem;font-weight:700;}
.s-ready{background:#E8F5E9;color:#2E7D32;}
.s-handover{background:#E3F2FD;color:#1565C0;}
.s-onway{background:#FFF3E0;color:#E65100;}
.empty-state{text-align:center;padding:60px 20px;color:var(--c-muted);}
#toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#0F0F0F;
  color:white;padding:11px 22px;border-radius:24px;font-size:.83rem;font-weight:600;
  z-index:9999;opacity:0;transition:opacity .3s;pointer-events:none;white-space:nowrap;
  box-shadow:0 8px 24px rgba(0,0,0,.4);}
#toast.show{opacity:1;}
.leaflet-popup-content-wrapper{border-radius:16px!important;box-shadow:0 8px 32px rgba(0,0,0,.2)!important;padding:0!important;overflow:hidden;}
.leaflet-popup-content{margin:0!important;}
.leaflet-routing-container{display:none!important;}
@media(max-width:768px){
  #sidebar{width:100%;} #sidebar.hidden{transform:translateX(-100%);}
  #togBtn{left:0;} #togBtn.shifted{left:0;}
}
</style>
</head>
<body>

<div id="map"></div>

<button id="togBtn" onclick="toggleSidebar()" title="Toggle sidebar">
  <i class="bi bi-list" style="font-size:1.3rem;color:#555;"></i>
</button>

<div id="mapControls">
  <button class="map-btn" onclick="locateMe()">
    <i class="bi bi-crosshair2" style="color:var(--c-orange);"></i> My Location
  </button>
  <button class="map-btn" id="planBtn" onclick="planAllRoutes()">
    <i class="bi bi-map" style="color:#1565C0;"></i> Plan Route
  </button>
  <div class="map-btn" id="weatherBadge" style="cursor:default;">
    <span id="weatherIcon">&#x26C5;</span><span id="weatherText">--°C</span>
  </div>
</div>

<div id="sidebar">
  <div class="drv-hdr">
    <div style="display:flex;align-items:center;gap:12px;">
      <div class="driver-avatar">${fn:substring(driver.name,0,1)}</div>
      <div style="flex:1;">
        <div style="font-weight:700;color:white;font-size:.95rem;">${driver.name}</div>
        <div style="display:flex;align-items:center;gap:6px;margin-top:3px;">
          <div class="gps-dot" id="gpsDot"></div>
          <span id="gpsStatus" style="font-size:.68rem;color:rgba(255,255,255,.5);">Acquiring GPS...</span>
        </div>
      </div>
      <a href="/driver/logout" style="color:rgba(255,255,255,.4);font-size:.85rem;text-decoration:none;">
        <i class="bi bi-box-arrow-right"></i>
      </a>
    </div>
  </div>

  <div class="nav-bar" id="navBar">
    <i class="bi bi-arrow-right-circle-fill" style="font-size:1.2rem;flex-shrink:0;"></i>
    <div style="flex:1;min-width:0;">
      <div id="navDest" style="font-size:.82rem;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"></div>
      <div id="navEta"  style="font-size:.7rem;opacity:.8;margin-top:1px;"></div>
    </div>
    <button class="act-btn btn-stop" onclick="stopNav()">&#x2715; End</button>
  </div>

  <div class="orders-hdr">
    <div style="font-weight:700;font-size:.82rem;color:var(--c-text);">
      Active Orders <span style="color:var(--c-orange);">(${fn:length(orders)})</span>
    </div>
    <button onclick="location.reload()" style="background:none;border:none;color:var(--c-muted);font-size:.75rem;cursor:pointer;display:flex;align-items:center;gap:4px;">
      <i class="bi bi-arrow-clockwise"></i> Refresh
    </button>
  </div>

  <div style="flex:1;overflow-y:auto;" id="orderList">
    <c:choose>
      <c:when test="${empty orders}">
        <div class="empty-state">
          <div style="font-size:3.5rem;margin-bottom:14px;">&#x1F4EB;</div>
          <div style="font-weight:700;font-size:.95rem;color:var(--c-text);margin-bottom:6px;">No active orders</div>
          <div style="font-size:.82rem;">Orders assigned to you appear here</div>
          <button onclick="location.reload()" style="margin-top:16px;background:var(--c-orange);color:white;border:none;padding:9px 22px;border-radius:20px;font-weight:600;cursor:pointer;font-size:.82rem;">
            <i class="bi bi-arrow-clockwise"></i> Check Again
          </button>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach items="${orders}" var="o" varStatus="st">
        <div class="order-tile" id="tile_${o.orderId}" onclick="focusOrder('${o.orderId}')">
          <div style="display:flex;align-items:center;gap:9px;margin-bottom:8px;">
            <div class="priority-num" id="pnum_${o.orderId}" style="background:${st.index==0?'var(--c-orange)':'#aaa'};">${st.index+1}</div>
            <span style="font-family:monospace;font-weight:800;font-size:.875rem;color:var(--c-text);">#${o.orderId}</span>
            <c:choose>
              <c:when test="${o.status=='READY'}"><span class="status-chip s-ready">&#x1F4E6; Ready</span></c:when>
              <c:when test="${o.status=='HANDOVER'}"><span class="status-chip s-handover">&#x1F91D; Picked Up</span></c:when>
              <c:when test="${o.status=='ON_WAY'}"><span class="status-chip s-onway">&#x1F6F5; On the Way</span></c:when>
            </c:choose>
          </div>
          <div style="font-size:.82rem;color:var(--c-text2);margin-bottom:3px;">
            <i class="bi bi-person-fill" style="color:var(--c-orange);"></i> ${o.customerName}
          </div>
          <div style="font-size:.78rem;color:var(--c-muted);margin-bottom:3px;line-height:1.4;">
            <i class="bi bi-geo-alt-fill" style="color:var(--c-orange);"></i> ${o.deliveryAddress}
          </div>
          <div style="font-size:.82rem;font-weight:700;color:var(--c-orange);">
            LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/>
          </div>
          <c:if test="${fn:length(o.chefNote) > 0}">
            <div style="background:#FFF8E1;border-radius:8px;padding:5px 10px;font-size:.72rem;color:#E65100;margin-top:7px;border:1px solid #FFE082;">
              <i class="bi bi-chat-dots-fill"></i> ${o.chefNote}
            </div>
          </c:if>
          <div class="dist-badge" id="dist_${o.orderId}">
            <i class="bi bi-hourglass-split"></i> Locating...
          </div>
          <div class="act-row">
            <button class="act-btn btn-nav" onclick="event.stopPropagation();navigateTo('${o.orderId}')">
              <i class="bi bi-compass-fill"></i> Navigate
            </button>
            <c:choose>
              <c:when test="${o.status=='READY'}">
                <form action="/driver/pickup/${o.orderId}" method="post" onclick="event.stopPropagation()" style="display:inline;">
                  <button type="submit" class="act-btn btn-pickup"><i class="bi bi-bag-check-fill"></i> Picked Up</button>
                </form>
              </c:when>
              <c:when test="${o.status=='HANDOVER'}">
                <form action="/driver/delivering/${o.orderId}" method="post" onclick="event.stopPropagation()" style="display:inline;">
                  <button type="submit" class="act-btn btn-onway"><i class="bi bi-bicycle"></i> Out for Delivery</button>
                </form>
              </c:when>
              <c:when test="${o.status=='ON_WAY'}">
                <form action="/driver/delivered/${o.orderId}" method="post" onclick="event.stopPropagation()"
                      onsubmit="return confirm('Confirm delivered to ${o.customerName}?')" style="display:inline;">
                  <button type="submit" class="act-btn btn-done"><i class="bi bi-check-circle-fill"></i> Delivered!</button>
                </form>
              </c:when>
            </c:choose>
          </div>
        </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<div id="toast"></div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.js"></script>
<script src="/js/app.js"></script>

<script>
var KITCHEN = {
  lat: <fmt:formatNumber value="${restaurant_lat}" pattern="0.0000" groupingUsed="false"/>,
  lng: <fmt:formatNumber value="${restaurant_lng}" pattern="0.0000" groupingUsed="false"/>
};

var ORDERS = [
  <c:forEach items="${orders}" var="o" varStatus="st">
  {
    orderId:  '${o.orderId}',
    address:  '${fn:replace(o.deliveryAddress,"'","\\'")}',
    customer: '${fn:replace(o.customerName,"'","\\'")}',
    total:    ${o.totalAmount},
    status:   '${o.status}',
    idx:      ${st.index}
  }${!st.last ? ',' : ''}
  </c:forEach>
];

var map=null, driverMarker=null, driverPos={lat:KITCHEN.lat,lng:KITCHEN.lng};
var geocoded={}, orderMarkers={}, routeControl=null, activeNavId=null;
var gpsPushTimer=0, sidebarOpen=true;

function initMap(){
  map = L.map('map',{center:[KITCHEN.lat,KITCHEN.lng],zoom:14,zoomControl:false});
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
    attribution:'© OpenStreetMap contributors',maxZoom:19
  }).addTo(map);
  L.control.zoom({position:'bottomright'}).addTo(map);

  // Kitchen marker
  var kitchenIcon = L.divIcon({className:'',
    html:'<div style="width:44px;height:44px;background:#FF6B35;border-radius:50% 50% 50% 0;transform:rotate(-45deg);border:3px solid white;box-shadow:0 4px 12px rgba(255,107,53,.5);"></div>',
    iconSize:[44,44],iconAnchor:[22,44]});
  L.marker([KITCHEN.lat,KITCHEN.lng],{icon:kitchenIcon}).addTo(map)
   .bindPopup('<div style="padding:12px 16px;font-family:Inter,sans-serif;"><strong style="color:#FF6B35;">YummyDish Kitchen</strong><br><span style="font-size:12px;color:#666;">Queens Hotel Area, Kandy</span></div>');

  // Driver marker
  var drvIcon = L.divIcon({className:'',
    html:'<div id="driverDot" style="width:50px;height:50px;background:#1565C0;border-radius:50%;border:3px solid white;box-shadow:0 4px 16px rgba(21,101,192,.5);display:flex;align-items:center;justify-content:center;font-size:24px;">&#x1F6F5;</div>',
    iconSize:[50,50],iconAnchor:[25,25]});
  driverMarker = L.marker([KITCHEN.lat,KITCHEN.lng],{icon:drvIcon,zIndexOffset:1000}).addTo(map)
    .bindPopup('<div style="padding:8px 12px;font-family:Inter,sans-serif;"><strong>${driver.name}</strong><br><span style="font-size:11px;color:#888;">Your location</span></div>');

  startGPS();
  geocodeAllOrders();
  loadWeather();
  setInterval(loadWeather, 300000);
}

function toggleSidebar(){
  sidebarOpen=!sidebarOpen;
  var sb=document.getElementById('sidebar'), btn=document.getElementById('togBtn');
  if(sidebarOpen){sb.classList.remove('hidden');btn.classList.remove('shifted');}
  else{sb.classList.add('hidden');btn.classList.add('shifted');}
  setTimeout(function(){if(map)map.invalidateSize();},320);
}

function startGPS(){
  if(!navigator.geolocation){document.getElementById('gpsStatus').textContent='GPS unavailable';return;}
  navigator.geolocation.getCurrentPosition(onPos,onGpsErr,{enableHighAccuracy:true,timeout:12000});
  navigator.geolocation.watchPosition(onPos,onGpsErr,{enableHighAccuracy:true,maximumAge:3000,timeout:15000});
}

function onPos(pos){
  var lat=pos.coords.latitude, lng=pos.coords.longitude;
  driverPos={lat:lat,lng:lng};
  if(driverMarker) driverMarker.setLatLng([lat,lng]);
  var dot=document.getElementById('gpsDot');
  if(dot) dot.classList.add('live');
  document.getElementById('gpsStatus').textContent='GPS Live · ±'+Math.round(pos.coords.accuracy)+'m';
  if(activeNavId&&geocoded[activeNavId]) updateEta(geocoded[activeNavId]);
  var now=Date.now();
  if(now-gpsPushTimer>10000){
    gpsPushTimer=now;
    fetch('/api/driver/location',{method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({lat:lat,lng:lng})}).catch(function(){});
  }
}
function onGpsErr(){
  var dot=document.getElementById('gpsDot');
  if(dot) dot.style.background='#f44336';
  document.getElementById('gpsStatus').textContent='GPS unavailable';
}

function geocodeAllOrders(){
  ORDERS.forEach(function(o,i){
    setTimeout(function(){geocodeOrder(o);}, i*1300);
  });
}

function geocodeOrder(o){
  var q=encodeURIComponent(o.address+', Kandy, Sri Lanka');
  fetch('https://nominatim.openstreetmap.org/search?q='+q+'&format=json&limit=1&countrycodes=lk',
    {headers:{'Accept-Language':'en','User-Agent':'YummyDishApp/1.0'}})
    .then(function(r){return r.json();})
    .then(function(data){
      var lat,lng;
      if(data&&data.length>0){lat=parseFloat(data[0].lat);lng=parseFloat(data[0].lon);}
      else{lat=KITCHEN.lat+(o.idx-0.5)*0.008;lng=KITCHEN.lng+(o.idx-0.5)*0.006;}
      geocoded[o.orderId]={lat:lat,lng:lng};
      placeOrderMarker(o,lat,lng);
      updateDistBadge(o.orderId,lat,lng);
      sortByDistance();
    })
    .catch(function(){
      var lat=KITCHEN.lat+(o.idx-0.5)*0.008, lng=KITCHEN.lng+(o.idx-0.5)*0.006;
      geocoded[o.orderId]={lat:lat,lng:lng};
      placeOrderMarker(o,lat,lng);
      updateDistBadge(o.orderId,lat,lng);
    });
}

function placeOrderMarker(o,lat,lng){
  var colors={READY:'#4CAF50',HANDOVER:'#2196F3',ON_WAY:'#FF9800'};
  var color=colors[o.status]||'#888', num=o.idx+1;
  var icon=L.divIcon({className:'',
    html:'<div style="width:38px;height:38px;background:'+color+';border-radius:50% 50% 50% 0;transform:rotate(-45deg);border:2.5px solid white;box-shadow:0 3px 10px rgba(0,0,0,.3);">'
      +'<span style="transform:rotate(45deg);display:block;text-align:center;font-weight:800;font-size:14px;color:white;line-height:33px;">'+num+'</span></div>',
    iconSize:[38,38],iconAnchor:[12,38]});
  var popup='<div style="padding:12px 16px;font-family:Inter,sans-serif;min-width:200px;">'
    +'<div style="font-weight:800;color:#FF6B35;font-size:.9rem;margin-bottom:4px;">#'+o.orderId+'</div>'
    +'<div style="font-size:.82rem;color:#333;margin-bottom:2px;"><b>'+o.customer+'</b></div>'
    +'<div style="font-size:.75rem;color:#777;margin-bottom:8px;">'+o.address+'</div>'
    +'<button onclick="navigateTo(\''+o.orderId+'\')" style="background:#1565C0;color:white;border:none;padding:7px 16px;border-radius:8px;font-size:.78rem;font-weight:600;cursor:pointer;width:100%;">Navigate Here</button>'
    +'</div>';
  if(orderMarkers[o.orderId]) map.removeLayer(orderMarkers[o.orderId]);
  orderMarkers[o.orderId]=L.marker([lat,lng],{icon:icon}).addTo(map).bindPopup(popup,{maxWidth:240});
}

function haversine(lat1,lng1,lat2,lng2){
  var R=6371,r=Math.PI/180;
  var dLat=(lat2-lat1)*r, dLng=(lng2-lng1)*r;
  var a=Math.sin(dLat/2)*Math.sin(dLat/2)+Math.cos(lat1*r)*Math.cos(lat2*r)*Math.sin(dLng/2)*Math.sin(dLng/2);
  return R*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
}

function updateDistBadge(orderId,lat,lng){
  var d=haversine(driverPos.lat,driverPos.lng,lat,lng);
  var eta=Math.round(d/0.35);
  var el=document.getElementById('dist_'+orderId);
  if(el){el.className='dist-badge found';el.innerHTML='<i class="bi bi-map-fill"></i> '+d.toFixed(1)+' km · ~'+eta+' min ride';}
}

function sortByDistance(){
  var list=document.getElementById('orderList');
  if(!list) return;
  var tiles=Array.from(list.querySelectorAll('.order-tile'));
  tiles.sort(function(a,b){
    var idA=a.id.replace('tile_',''),idB=b.id.replace('tile_','');
    var gA=geocoded[idA],gB=geocoded[idB];
    var dA=gA?haversine(driverPos.lat,driverPos.lng,gA.lat,gA.lng):999;
    var dB=gB?haversine(driverPos.lat,driverPos.lng,gB.lat,gB.lng):999;
    return dA-dB;
  });
  tiles.forEach(function(t,i){
    list.appendChild(t);
    var p=document.getElementById('pnum_'+t.id.replace('tile_',''));
    if(p){p.textContent=i+1;p.style.background=i===0?'var(--c-orange)':'#aaa';}
  });
}

function navigateTo(orderId){
  var g=geocoded[orderId], o=ORDERS.find(function(x){return x.orderId===orderId;});
  if(!g){toast('Still locating address...');return;}
  document.querySelectorAll('.order-tile').forEach(function(t){t.classList.remove('navigating','selected');});
  var tile=document.getElementById('tile_'+orderId);
  if(tile) tile.classList.add('navigating');
  if(routeControl){map.removeControl(routeControl);routeControl=null;}
  activeNavId=orderId;

  routeControl=L.Routing.control({
    waypoints:[L.latLng(driverPos.lat,driverPos.lng),L.latLng(g.lat,g.lng)],
    routeWhileDragging:false,addWaypoints:false,fitSelectedRoutes:true,show:false,
    lineOptions:{styles:[{color:'#1565C0',weight:7,opacity:.85},{color:'#42A5F5',weight:3,opacity:.5}]},
    createMarker:function(i,wp){
      if(i===0) return null;
      var icon=L.divIcon({className:'',
        html:'<div style="width:40px;height:40px;background:#FF6B35;border-radius:50%;border:3px solid white;box-shadow:0 4px 12px rgba(255,107,53,.5);display:flex;align-items:center;justify-content:center;font-size:20px;">&#x1F4CD;</div>',
        iconSize:[40,40],iconAnchor:[20,20]});
      return L.marker(wp.latLng,{icon:icon});
    }
  }).addTo(map);

  routeControl.on('routesfound',function(e){
    var route=e.routes[0];
    var distKm=(route.summary.totalDistance/1000).toFixed(1);
    var mins=Math.round(route.summary.totalTime/60);
    var arrivalTime=new Date(Date.now()+route.summary.totalTime*1000)
      .toLocaleTimeString('en-LK',{hour:'2-digit',minute:'2-digit'});
    document.getElementById('navBar').classList.add('show');
    document.getElementById('navDest').textContent=(o?o.address:'').substring(0,55);
    document.getElementById('navEta').textContent=distKm+' km · ~'+mins+' min · Arrive ~'+arrivalTime;
    toast('Route: '+distKm+' km, ~'+mins+' min');
  });

  routeControl.on('routingerror',function(){
    var d=haversine(driverPos.lat,driverPos.lng,g.lat,g.lng);
    L.polyline([[driverPos.lat,driverPos.lng],[g.lat,g.lng]],
      {color:'#1565C0',weight:5,opacity:.7,dashArray:'10,8'}).addTo(map);
    map.fitBounds([[driverPos.lat,driverPos.lng],[g.lat,g.lng]],{padding:[60,60]});
    document.getElementById('navBar').classList.add('show');
    document.getElementById('navDest').textContent=(o?o.address:'').substring(0,55);
    document.getElementById('navEta').textContent=d.toFixed(1)+' km · ~'+Math.round(d/0.35)+' min (straight line)';
  });

  if(!sidebarOpen) toggleSidebar();
}

function planAllRoutes(){
  var ready=ORDERS.filter(function(o){return geocoded[o.orderId];});
  if(ready.length===0){toast('Still locating orders...');return;}
  if(ready.length===1){navigateTo(ready[0].orderId);return;}
  ready.sort(function(a,b){
    var dA=haversine(driverPos.lat,driverPos.lng,geocoded[a.orderId].lat,geocoded[a.orderId].lng);
    var dB=haversine(driverPos.lat,driverPos.lng,geocoded[b.orderId].lat,geocoded[b.orderId].lng);
    return dA-dB;
  });
  if(routeControl){map.removeControl(routeControl);routeControl=null;}
  var wps=[L.latLng(driverPos.lat,driverPos.lng)];
  ready.forEach(function(o){var g=geocoded[o.orderId];wps.push(L.latLng(g.lat,g.lng));});
  routeControl=L.Routing.control({
    waypoints:wps,routeWhileDragging:false,addWaypoints:false,fitSelectedRoutes:true,show:false,
    lineOptions:{styles:[{color:'#FF6B35',weight:6,opacity:.85}]},
    createMarker:function(i,wp){
      if(i===0) return null;
      var icon=L.divIcon({className:'',
        html:'<div style="width:36px;height:36px;background:#FF6B35;border-radius:50%;border:2px solid white;box-shadow:0 3px 10px rgba(255,107,53,.4);display:flex;align-items:center;justify-content:center;font-weight:800;color:white;font-size:14px;">'+i+'</div>',
        iconSize:[36,36],iconAnchor:[18,18]});
      return L.marker(wp.latLng,{icon:icon});
    }
  }).addTo(map);
  routeControl.on('routesfound',function(e){
    var r=e.routes[0];
    var distKm=(r.summary.totalDistance/1000).toFixed(1);
    var mins=Math.round(r.summary.totalTime/60);
    document.getElementById('navBar').classList.add('show');
    document.getElementById('navDest').textContent=ready.length+' stops &mdash; optimized route';
    document.getElementById('navEta').textContent=distKm+' km total · ~'+mins+' min';
    document.getElementById('planBtn').classList.add('active');
    toast('Planned: '+ready.length+' stops, '+distKm+' km');
  });
}

function stopNav(){
  activeNavId=null;
  if(routeControl){map.removeControl(routeControl);routeControl=null;}
  document.getElementById('navBar').classList.remove('show');
  document.getElementById('planBtn').classList.remove('active');
  document.querySelectorAll('.order-tile').forEach(function(t){t.classList.remove('navigating','selected');});
  toast('Navigation stopped');
}

function focusOrder(orderId){
  document.querySelectorAll('.order-tile').forEach(function(t){t.classList.remove('selected');});
  var tile=document.getElementById('tile_'+orderId);
  if(tile) tile.classList.add('selected');
  var g=geocoded[orderId];
  if(g&&map){map.flyTo([g.lat,g.lng],16,{duration:1.2});if(orderMarkers[orderId])orderMarkers[orderId].openPopup();}
}

function locateMe(){
  if(map) map.flyTo([driverPos.lat,driverPos.lng],16,{duration:1.2});
  if(driverMarker) driverMarker.openPopup();
}

function updateEta(g){
  var d=haversine(driverPos.lat,driverPos.lng,g.lat,g.lng);
  var el=document.getElementById('navEta');
  if(el&&activeNavId) el.textContent=d.toFixed(1)+' km remaining · ~'+Math.round(d/0.35)+' min';
  if(d<0.05){toast('You have arrived!');stopNav();}
}

function loadWeather(){
  fetch('/api/weather').then(function(r){return r.json();})
    .then(function(w){
      var el=document.getElementById('weatherText');
      if(el) el.textContent=w.temp||'--°C';
      var icon=document.getElementById('weatherIcon');
      if(icon) icon.textContent=w.isHeavy?'&#x26C8;':w.isRaining?'&#x1F327;':'&#x26C5;';
      var badge=document.getElementById('weatherBadge');
      if(badge&&w.isHeavy){badge.style.background='#C62828';badge.style.color='white';badge.style.borderColor='#C62828';}
    }).catch(function(){});
}

function toast(msg,dur){
  var el=document.getElementById('toast');
  if(!el) return;
  el.textContent=msg; el.classList.add('show');
  clearTimeout(el._t);
  el._t=setTimeout(function(){el.classList.remove('show');},dur||3000);
}

document.addEventListener('DOMContentLoaded',function(){ initMap(); });
</script>
</body>
</html>
