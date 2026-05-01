<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="My Orders"/>
<c:set var="pageId"    value="activity"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.track-hero{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:28px 0 20px;}
.order-card{background:var(--c-surface);border-radius:18px;border:1px solid var(--c-border);overflow:hidden;margin-bottom:16px;transition:box-shadow .3s;}
.order-card:hover{box-shadow:var(--shadow-lg);}
.order-head{padding:16px 18px;border-bottom:1px solid var(--c-border);display:flex;justify-content:space-between;align-items:center;}
.order-body{padding:16px 18px;}
.step-bar{display:flex;gap:0;margin-bottom:14px;}
.step-seg{flex:1;height:5px;background:var(--c-border);border-radius:99px;margin:0 2px;transition:background 1s;}
.step-seg.done{background:linear-gradient(90deg,var(--c-orange),#f7971e);}
.step-seg.pulse{background:var(--c-orange);animation:segPulse 1.5s ease-in-out infinite;}
@keyframes segPulse{0%,100%{opacity:1}50%{opacity:.5}}
.eta-box{background:var(--c-orange-l);border:1px solid rgba(255,107,53,.2);border-radius:14px;padding:14px 16px;margin-bottom:14px;display:flex;align-items:center;gap:12px;}
.eta-time{font-size:2rem;font-weight:800;color:var(--c-orange);font-family:monospace;line-height:1;}
.live-map{width:100%;height:250px;border-radius:14px;overflow:hidden;border:1px solid var(--c-border);background:var(--c-bg);margin-top:12px;}
.driver-chip{display:flex;align-items:center;gap:10px;background:var(--c-bg);border-radius:12px;padding:10px 14px;border:1px solid var(--c-border);margin-top:10px;}
.hist-row{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid var(--c-border);}
.hist-row:last-child{border-bottom:none;}
.tab-strip{display:flex;gap:3px;background:var(--c-bg);border:1px solid var(--c-border);border-radius:14px;padding:4px;margin-bottom:22px;}
.tab-s{flex:1;padding:10px;border:none;background:none;font-weight:600;font-size:.85rem;color:var(--c-muted);border-radius:10px;cursor:pointer;transition:all .2s;}
.tab-s.on{background:var(--c-surface);color:var(--c-orange);box-shadow:var(--shadow);}
</style>

<div class="yd-page">
  <!-- Hero -->
  <div class="track-hero">
    <div class="container" style="max-width:720px;">
      <div class="d-flex align-items-center gap-3">
        <h2 style="font-family:var(--font-display);color:white;font-size:1.8rem;margin:0;">My Orders</h2>
        <span class="yd-live-badge" style="border-color:rgba(255,255,255,.2);color:rgba(255,255,255,.8);background:rgba(255,255,255,.08);">
          <span class="yd-live-dot"></span>Live Tracking
        </span>
      </div>
      <p style="color:rgba(255,255,255,.5);font-size:.82rem;margin-top:4px;">Real-time updates — your driver's location is updated every 8 seconds</p>
    </div>
  </div>

  <div class="container py-4" style="max-width:720px;">

    <!-- Tabs -->
    <div class="tab-strip">
      <button class="tab-s on" id="tabA" onclick="showTab('ongoing',this)">🔴 Ongoing</button>
      <button class="tab-s"    id="tabB" onclick="showTab('history',this)">✅ History</button>
    </div>

    <!-- ONGOING -->
    <div id="paneOngoing">
      <c:choose>
        <c:when test="${empty ongoing}">
          <div class="yd-card yd-fade" style="text-align:center;padding:48px 24px;">
            <div style="font-size:4rem;margin-bottom:16px;animation:float 3s ease-in-out infinite;">📭</div>
            <h4 style="margin-bottom:8px;">No Active Orders</h4>
            <p style="color:var(--c-muted);font-size:.9rem;margin-bottom:20px;">Place an order and track it live right here</p>
            <a href="/menu" class="yd-btn yd-btn-primary" style="width:auto;padding:12px 28px;"><i class="bi bi-bag me-2"></i>Order Now</a>
          </div>
        </c:when>
        <c:otherwise>
          <c:forEach items="${ongoing}" var="o">
          <div class="order-card yd-fade" id="card_${o.orderId}">
            <!-- Header -->
            <div class="order-head">
              <div>
                <div style="font-family:monospace;font-weight:800;font-size:.95rem;">#${o.orderId}</div>
                <div style="font-size:.72rem;color:var(--c-muted);margin-top:2px;">${o.createdAt}</div>
              </div>
              <div class="d-flex align-items-center gap-2">
                <span class="yd-status" id="badge_${o.orderId}"
                  style="background:${o.status=='COOKING'?'#FFF3E0':o.status=='READY'?'#E8F5E9':'#E3F2FD'};color:${o.status=='COOKING'?'#E65100':o.status=='READY'?'#2E7D32':'#1565C0'};">
                  ${o.statusBadge}
                </span>
                <span style="font-weight:800;color:var(--c-orange);">LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/></span>
              </div>
            </div>

            <div class="order-body">
              <!-- Progress bar -->
              <div class="step-bar" id="prog_${o.orderId}">
                <div class="step-seg ${o.statusProgress>=20?'done':''}"></div>
                <div class="step-seg ${o.statusProgress>=40?'done':''}"></div>
                <div class="step-seg ${o.statusProgress>=60?'done':''}"></div>
                <div class="step-seg ${o.statusProgress>=82?'done':''}"></div>
              </div>
              <div class="d-flex justify-content-between" style="font-size:.68rem;color:var(--c-muted);margin-bottom:12px;">
                <span>Confirmed</span><span>Cooking</span><span>Ready</span><span>On Way</span><span>Delivered</span>
              </div>

              <!-- ETA box -->
              <div class="eta-box" id="etaBox_${o.orderId}">
                <div>
                  <div style="font-size:.7rem;font-weight:700;color:var(--c-orange);text-transform:uppercase;letter-spacing:.5px;margin-bottom:3px;">Estimated Arrival</div>
                  <div class="eta-time" id="etaTimer_${o.orderId}">--:--</div>
                </div>
                <div style="flex:1;">
                  <div style="font-size:.78rem;color:var(--c-text2);" id="etaLabel_${o.orderId}">
                    Preparing your order...
                  </div>
                  <div style="font-size:.7rem;color:var(--c-muted);margin-top:2px;" id="trafficLabel_${o.orderId}"></div>
                </div>
              </div>

              <!-- Items preview -->
              <div style="margin-bottom:12px;">
                <c:forEach items="${o.items}" var="item" varStatus="st">
                  <c:if test="${st.index < 3}">
                  <div style="display:flex;align-items:center;gap:8px;margin-bottom:5px;">
                    <img src="${item.imageUrl}" style="width:36px;height:36px;border-radius:8px;object-fit:cover;flex-shrink:0;" onerror="this.style.display='none'">
                    <div style="flex:1;font-size:.82rem;">${item.foodName}</div>
                    <div style="font-size:.78rem;font-weight:600;color:var(--c-orange);">×${item.quantity}</div>
                  </div>
                  </c:if>
                </c:forEach>
                <c:if test="${fn:length(o.items) > 3}">
                  <div style="font-size:.72rem;color:var(--c-muted);">+${fn:length(o.items) - 3} more items</div>
                </c:if>
              </div>

              <!-- Driver chip -->
              <c:if test="${fn:length(o.driverName) > 0}">
              <div class="driver-chip" id="driverChip_${o.orderId}">
                <div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;">${fn:substring(o.driverName,0,1)}</div>
                <div style="flex:1;">
                  <div style="font-weight:700;font-size:.85rem;">${o.driverName}</div>
                  <div style="font-size:.72rem;color:var(--c-muted);">Your delivery driver</div>
                </div>
                <a href="tel:${o.driverContact}" class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;padding:7px 12px;"><i class="bi bi-telephone-fill"></i></a>
              </div>
              </c:if>

              <!-- Live map (shown when driver assigned) -->
              <c:if test="${o.status=='ON_WAY' || o.status=='HANDOVER'}">
              <div class="live-map" id="liveMap_${o.orderId}"></div>
              </c:if>

              <!-- Actions -->
              <div class="d-flex gap-2 mt-3">
                <c:if test="${o.status=='COOKING' || o.status=='PENDING'}">
                <button onclick="cancelOrder('${o.orderId}',this)" class="yd-btn yd-btn-sm" style="background:#FFEBEE;color:#C62828;border:none;width:auto;">
                  <i class="bi bi-x-circle me-1"></i>Cancel
                </button>
                </c:if>
                <a href="/activity/order/${o.orderId}" class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;"><i class="bi bi-receipt me-1"></i>Receipt</a>
                <button onclick="shareOnWhatsApp('${o.orderId}',[],${o.totalAmount})" class="yd-wa-btn" style="width:auto;padding:7px 14px;font-size:.75rem;">📱 Share</button>
              </div>
            </div>
          </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </div><!-- /ongoing -->

    <!-- HISTORY -->
    <div id="paneHistory" style="display:none;">
      <c:choose>
        <c:when test="${empty history}">
          <div class="yd-card yd-fade" style="text-align:center;padding:40px 24px;">
            <div style="font-size:3.5rem;margin-bottom:12px;">📋</div>
            <h4 style="margin-bottom:8px;">No order history</h4>
            <a href="/menu" class="yd-btn yd-btn-primary mt-2" style="width:auto;padding:11px 28px;">Start Ordering</a>
          </div>
        </c:when>
        <c:otherwise>
          <div class="yd-card yd-fade">
            <div class="yd-card-body">
              <c:forEach items="${history}" var="o">
              <div class="hist-row">
                <div style="flex:1;">
                  <div style="font-family:monospace;font-weight:700;font-size:.875rem;">#${o.orderId}</div>
                  <div style="font-size:.7rem;color:var(--c-muted);">${o.createdAt}</div>
                </div>
                <span style="padding:3px 10px;border-radius:20px;font-size:.72rem;font-weight:700;
                  background:${o.status=='DELIVERED'?'#E8F5E9':'#FFEBEE'};
                  color:${o.status=='DELIVERED'?'#2E7D32':'#C62828'};">${o.statusBadge}</span>
                <div style="text-align:right;min-width:90px;">
                  <div style="font-weight:700;color:var(--c-orange);font-size:.875rem;">LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/></div>
                  <button onclick="reorder('${o.orderId}')" class="yd-btn yd-btn-sm" style="background:var(--c-orange-l);color:var(--c-orange);border:none;margin-top:4px;padding:4px 10px;font-size:.7rem;width:auto;">🔄 Reorder</button>
                </div>
              </div>
              </c:forEach>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div><!-- /history -->

    <!-- Loyalty bar -->
    <div class="yd-card mt-3 yd-fade">
      <div class="yd-card-body">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <span style="font-weight:700;font-size:.9rem;">⭐ Loyalty Points</span>
          <span style="font-size:1.6rem;font-weight:800;color:#FFB800;" id="loyaltyPts">—</span>
        </div>
        <div class="loyalty-bar"><div class="loyalty-fill" id="loyaltyFill" style="width:0%;"></div></div>
        <div style="font-size:.72rem;color:var(--c-muted);margin-top:5px;">1 point per LKR 10 spent · 100 pts = LKR 10 off</div>
      </div>
    </div>
  </div>
</div>

<!-- Rating modal -->
<div id="ratingModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.65);z-index:9999;align-items:center;justify-content:center;padding:16px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:32px;max-width:360px;width:100%;text-align:center;animation:scaleIn .3s var(--ease);">
    <div style="font-size:3.5rem;margin-bottom:12px;">🍽️</div>
    <h4 style="font-family:var(--font-display);margin-bottom:6px;">How was your meal?</h4>
    <p style="color:var(--c-muted);font-size:.875rem;margin-bottom:18px;" id="ratingLabel">Rate your order</p>
    <div style="display:flex;justify-content:center;gap:6px;margin-bottom:16px;" id="ratingStars">
      <span class="rstar" data-v="1" style="font-size:2.5rem;cursor:pointer;filter:grayscale(1);transition:all .18s;">⭐</span>
      <span class="rstar" data-v="2" style="font-size:2.5rem;cursor:pointer;filter:grayscale(1);transition:all .18s;">⭐</span>
      <span class="rstar" data-v="3" style="font-size:2.5rem;cursor:pointer;filter:grayscale(1);transition:all .18s;">⭐</span>
      <span class="rstar" data-v="4" style="font-size:2.5rem;cursor:pointer;filter:grayscale(1);transition:all .18s;">⭐</span>
      <span class="rstar" data-v="5" style="font-size:2.5rem;cursor:pointer;filter:grayscale(1);transition:all .18s;">⭐</span>
    </div>
    <textarea id="ratingTxt" class="yd-input" rows="2" placeholder="Tell us what you think..." style="resize:none;margin-bottom:14px;text-align:left;"></textarea>
    <div class="d-flex gap-2">
      <button onclick="submitRating()" class="yd-btn yd-btn-primary" style="flex:1;" id="ratingBtn">Submit</button>
      <button onclick="document.getElementById('ratingModal').style.display='none'" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Skip</button>
    </div>
  </div>
</div>

<script>
// ── Tabs ───────────────────────────────────────────────────────────
function showTab(name, btn) {
  document.getElementById('paneOngoing').style.display = name==='ongoing' ? 'block' : 'none';
  document.getElementById('paneHistory').style.display = name==='history' ? 'block' : 'none';
  document.getElementById('tabA').className = 'tab-s' + (name==='ongoing' ? ' on' : '');
  document.getElementById('tabB').className = 'tab-s' + (name==='history' ? ' on' : '');
}

// ── Cancel ─────────────────────────────────────────────────────────
async function cancelOrder(id, btn) {
  if (!confirm('Cancel this order?')) return;
  btn.disabled = true;
  var r = await fetch('/api/order/' + id + '/cancel', { method: 'POST' });
  var d = await r.json();
  if (d.success) { showToast('Order cancelled'); setTimeout(function(){ location.reload(); }, 1200); }
  else { showToast(d.error || 'Cannot cancel now'); btn.disabled = false; }
}

// ── ETA countdown with traffic delays ─────────────────────────────
var etaStates = {};  // orderId -> { mins, timer }

function startEta(orderId, initialMins) {
  var state = etaStates[orderId] = { mins: initialMins, secs: 0, delayed: false };
  var el    = document.getElementById('etaTimer_' + orderId);
  var label = document.getElementById('etaLabel_' + orderId);
  var traf  = document.getElementById('trafficLabel_' + orderId);

  state.iv = setInterval(function() {
    if (state.secs > 0) {
      state.secs--;
    } else if (state.mins > 0) {
      state.mins--;
      state.secs = 59;
    } else {
      // Time up — add 10 min and show delay message
      if (!state.delayed) {
        state.delayed  = true;
        state.mins     = 10;
        state.secs     = 0;
        if (traf) traf.textContent = '⚠️ Traffic delay — adding 10 min. Sorry for the inconvenience!';
        if (traf) traf.style.color = '#E65100';
        showNotif('⚠️','Delivery Delayed','Heavy traffic. Updated ETA +10 min. Sorry!','rgba(230,81,0,.12)');
        YDSound && YDSound.statusUpdate && YDSound.statusUpdate();
      } else {
        clearInterval(state.iv);
        if (label) label.textContent = 'Arriving very soon...';
        if (el)    el.textContent = '0:00';
        return;
      }
    }
    if (el) el.textContent = state.mins + ':' + (state.secs < 10 ? '0' : '') + state.secs;
  }, 1000);
}

// ── Live driver map (polls every 8s) ──────────────────────────────
var trackMaps    = {};
var driverMkrs   = {};
var destMkrs     = {};

function initTrackMap(orderId, destAddress) {
  var el = document.getElementById('liveMap_' + orderId);
  if (!el || !window.google) return;

  var m = new google.maps.Map(el, {
    center: { lat: 7.2937, lng: 80.6340 },
    zoom: 13,
    mapTypeControl: false, streetViewControl: false, fullscreenControl: false,
    gestureHandling: 'cooperative',
    styles: [
      { featureType:'poi', stylers:[{visibility:'off'}] },
      { featureType:'road', elementType:'geometry', stylers:[{color:'#f5f5f5'}] },
      { featureType:'water', elementType:'geometry', stylers:[{color:'#c9e8f0'}] }
    ]
  });
  trackMaps[orderId] = m;

  // Driver marker
  driverMkrs[orderId] = new google.maps.Marker({
    map: m,
    position: { lat: 7.2937, lng: 80.6340 },
    title: 'Driver',
    icon: {
      url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" width="44" height="44" viewBox="0 0 44 44">'
        +'<circle cx="22" cy="22" r="20" fill="#1565C0" stroke="white" stroke-width="3"/>'
        +'<text x="22" y="30" text-anchor="middle" font-size="22">🛵</text></svg>'
      ),
      scaledSize: new google.maps.Size(44,44), anchor: new google.maps.Point(22,22)
    }
  });

  // Destination from geocoding
  new google.maps.Geocoder().geocode({ address: destAddress + ', Kandy, Sri Lanka' }, function(results, status) {
    if (status==='OK' && results[0]) {
      var loc = results[0].geometry.location;
      destMkrs[orderId] = new google.maps.Marker({
        map: m, position: loc, title: 'Your Location',
        icon: {
          url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
            '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="46" viewBox="0 0 36 46">'
            +'<path d="M18 0C8 0 0 8 0 18c0 12 18 28 18 28S36 30 36 18C36 8 28 0 18 0z" fill="#FF6B35"/>'
            +'<circle cx="18" cy="18" r="9" fill="white"/></svg>'
          ),
          scaledSize: new google.maps.Size(36,46), anchor: new google.maps.Point(18,46)
        }
      });
      // Fit bounds
      var bounds = new google.maps.LatLngBounds();
      bounds.extend({ lat: 7.2937, lng: 80.6340 });
      bounds.extend(loc);
      m.fitBounds(bounds, { padding: 40 });
    }
  });

  // Start polling
  pollDriverLocation(orderId);
}

function pollDriverLocation(orderId) {
  fetch('/api/order/' + orderId + '/driver-location')
    .then(function(r){ return r.json(); })
    .then(function(d) {
      if (!d.lat || !d.lng) return;
      var newLat = parseFloat(d.lat), newLng = parseFloat(d.lng);
      var mkr = driverMkrs[orderId];
      if (mkr) {
        // Smooth animation
        var from = mkr.getPosition();
        var steps = 20; var i = 0;
        var dLat = (newLat - from.lat()) / steps;
        var dLng = (newLng - from.lng()) / steps;
        var iv = setInterval(function() {
          i++;
          mkr.setPosition({ lat: from.lat()+dLat*i, lng: from.lng()+dLng*i });
          if (i >= steps) clearInterval(iv);
        }, 40);
        // Pan map
        if (trackMaps[orderId]) {
          var bounds = new google.maps.LatLngBounds();
          bounds.extend({ lat: newLat, lng: newLng });
          if (destMkrs[orderId]) bounds.extend(destMkrs[orderId].getPosition());
          trackMaps[orderId].fitBounds(bounds, { padding: 40 });
        }
        // Nearby notification
        if (d.nearby) {
          showNotif('🛵','Driver Nearby!','Your order is less than 1 km away!','rgba(21,101,192,.1)');
          YDSound && YDSound.driverNearby && YDSound.driverNearby();
        }
      }
      if (d.status !== 'DELIVERED' && d.status !== 'CANCELLED') {
        setTimeout(function(){ pollDriverLocation(orderId); }, 8000);
      }
    }).catch(function(){ setTimeout(function(){ pollDriverLocation(orderId); }, 15000); });
}

// ── Order poller ───────────────────────────────────────────────────
var statusLabels = {
  PENDING:'⏳ Confirmed',COOKING:'🍳 Cooking',READY:'📦 Ready',
  HANDOVER:'🤝 Driver Picked Up',ON_WAY:'🛵 On the Way',
  DELIVERED:'✅ Delivered',CANCELLED:'❌ Cancelled'
};
var progMap = {PENDING:10,COOKING:25,READY:45,HANDOVER:60,ON_WAY:82,DELIVERED:100,CANCELLED:0};
var statusColors = {
  COOKING:{bg:'#FFF3E0',color:'#E65100'},
  READY:{bg:'#E8F5E9',color:'#2E7D32'},
  HANDOVER:{bg:'#E3F2FD',color:'#1565C0'},
  ON_WAY:{bg:'#E3F2FD',color:'#1565C0'},
  DELIVERED:{bg:'#F3E8FF',color:'#7C3AED'},
  CANCELLED:{bg:'#FFEBEE',color:'#C62828'}
};

function startPoller(orderId) {
  var prevStatus = null;
  var iv = setInterval(async function() {
    try {
      var r = await fetch('/api/order/' + orderId);
      var d = await r.json();
      if (!d || !d.status) return;

      // Update badge
      var badge = document.getElementById('badge_' + orderId);
      var sc = statusColors[d.status] || {bg:'#F5F5F5',color:'#666'};
      if (badge) {
        badge.textContent = statusLabels[d.status] || d.status;
        badge.style.background = sc.bg;
        badge.style.color      = sc.color;
      }

      // Update progress bar
      var prog = document.getElementById('prog_' + orderId);
      var pct  = progMap[d.status] || 0;
      if (prog) {
        prog.querySelectorAll('.step-seg').forEach(function(seg, i) {
          seg.classList.toggle('done',  (i+1)*25 <= pct && pct < 100);
          seg.classList.toggle('pulse', (i+1)*25 === Math.ceil(pct/25)*25 && pct < 100);
        });
      }

      // Update ETA label
      var etaLbl = document.getElementById('etaLabel_' + orderId);
      if (etaLbl) {
        var msgs = {
          COOKING:'Our chef is preparing your order 🍳',
          READY:'Packed and waiting for your driver 📦',
          HANDOVER:'Driver has your order — heading to you! 🛵',
          ON_WAY:'Your driver is on the way! 🛵',
          DELIVERED:'Delivered! Enjoy your meal 🍽️',
          CANCELLED:'This order was cancelled'
        };
        etaLbl.textContent = msgs[d.status] || 'Processing...';
      }

      // Status change notifications
      if (prevStatus && prevStatus !== d.status) {
        switch(d.status) {
          case 'READY':
            YDSound && YDSound.statusUpdate(); showToast('📦 Order is ready! Driver picking up soon.'); break;
          case 'HANDOVER': case 'ON_WAY':
            YDSound && YDSound.statusUpdate(); showToast('🛵 Driver is on the way!'); break;
          case 'DELIVERED':
            YDSound && YDSound.delivered(); showToast('✅ Delivered! Enjoy your meal 🍽️');
            clearInterval(iv);
            setTimeout(function(){ showRatingModal(orderId, d.items||[]); }, 3000);
            break;
        }
      }
      prevStatus = d.status;

      if (d.status === 'DELIVERED' || d.status === 'CANCELLED') clearInterval(iv);
    } catch(e) {}
  }, 6000);
}

// ── Rating modal ───────────────────────────────────────────────────
var _ratingOid = '', _ratingItems = [], _ratingVal = 0;
function showRatingModal(oid, items) {
  var rated = JSON.parse(localStorage.getItem('ydRated')||'[]');
  if (rated.indexOf(oid) >= 0) return;
  _ratingOid = oid; _ratingItems = items; _ratingVal = 0;
  document.getElementById('ratingLabel').textContent = 'Rating order #' + oid;
  document.querySelectorAll('.rstar').forEach(function(s){ s.style.filter='grayscale(1)'; });
  document.getElementById('ratingModal').style.display = 'flex';
}
document.querySelectorAll('.rstar').forEach(function(s) {
  s.onclick = function() {
    _ratingVal = parseInt(this.dataset.v);
    document.querySelectorAll('.rstar').forEach(function(x,i){ x.style.filter=i<_ratingVal?'none':'grayscale(1)'; });
  };
});
async function submitRating() {
  if (!_ratingVal) { showToast('Please pick a star rating'); return; }
  document.getElementById('ratingBtn').innerHTML = '⏳ Submitting...';
  var tasks = (_ratingItems.length ? _ratingItems : [{foodId:'',foodName:''}]).map(function(item) {
    return fetch('/api/feedback', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ orderId:_ratingOid, foodItemId:item.foodId||'', foodItemName:item.foodName||'',
        text: document.getElementById('ratingTxt').value || 'Great order!', type:'REVIEW', rating:_ratingVal })
    });
  });
  await Promise.all(tasks).catch(function(){});
  var rated = JSON.parse(localStorage.getItem('ydRated')||'[]');
  rated.push(_ratingOid);
  localStorage.setItem('ydRated', JSON.stringify(rated));
  document.getElementById('ratingModal').style.display='none';
  showToast('Thanks for your review! ⭐');
}

// ── Loyalty ────────────────────────────────────────────────────────
fetch('/api/loyalty').then(function(r){ return r.json(); }).then(function(d) {
  if (d.points !== undefined) {
    document.getElementById('loyaltyPts').textContent = d.points;
    setTimeout(function(){ document.getElementById('loyaltyFill').style.width = Math.min(d.points%100,100)+'%'; }, 400);
  }
}).catch(function(){});

// ── Init all ongoing orders ────────────────────────────────────────
onMapsReady(function() {
  <c:forEach items="${ongoing}" var="o">
  (function() {
    var oid  = '${o.orderId}';
    var addr = '${fn:replace(o.deliveryAddress,"'","\\'")}';
    // Start status poller
    startPoller(oid);
    // Start ETA countdown
    var etaMins = ${o.status == 'ON_WAY' || o.status == 'HANDOVER' ? 15 : o.status == 'READY' ? 20 : 28};
    startEta(oid, etaMins);
    // Init live map if on way
    <c:if test="${o.status=='ON_WAY' || o.status=='HANDOVER'}">
    initTrackMap(oid, addr);
    </c:if>
  })();
  </c:forEach>
});
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
