<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="My Account"/>
<c:set var="pageId"    value="account"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.acc-hero{background:linear-gradient(135deg,#FF6B35 0%,#f7971e 60%,#FF9A5C 100%);background-size:200% 200%;animation:gradMove 7s ease infinite;padding:36px 20px 60px;position:relative;overflow:hidden;}
.acc-hero::before{content:'';position:absolute;top:-50%;right:-8%;width:380px;height:380px;border-radius:50%;background:rgba(255,255,255,.07);pointer-events:none;}
.acc-hero::after{content:'';position:absolute;bottom:-40%;left:-5%;width:250px;height:250px;border-radius:50%;background:rgba(255,255,255,.05);pointer-events:none;}
.acc-avatar{width:76px;height:76px;border-radius:50%;overflow:hidden;border:4px solid rgba(255,255,255,.35);flex-shrink:0;box-shadow:0 8px 24px rgba(0,0,0,.25);}
.acc-tabs{display:flex;gap:3px;background:var(--c-bg);border:1px solid var(--c-border);border-radius:16px;padding:4px;margin-bottom:22px;}
.acc-tab{flex:1;padding:11px 6px;border:none;background:none;font-weight:600;font-size:.8rem;color:var(--c-muted);border-radius:12px;cursor:pointer;transition:all .25s;text-align:center;white-space:nowrap;}
.acc-tab.active{background:var(--c-surface);color:var(--c-orange);box-shadow:var(--shadow);}
.acc-pane{display:none;animation:fadeUp .3s var(--ease) both;}
.acc-pane.active{display:block;}
.info-row{display:flex;justify-content:space-between;align-items:center;padding:12px 0;border-bottom:1px solid var(--c-border);font-size:.875rem;}
.info-row:last-child{border-bottom:none;}
.card-3d{background:linear-gradient(135deg,#1a1a2e,#16213e,#0f3460);border-radius:18px;padding:20px 24px;color:white;position:relative;overflow:hidden;min-height:110px;}
.card-3d::before{content:'';position:absolute;top:-28px;right:-28px;width:110px;height:110px;border-radius:50%;background:rgba(255,255,255,.04);}
.loc-chip{display:inline-flex;align-items:center;gap:7px;padding:9px 14px;border-radius:12px;background:var(--c-bg);border:1px solid var(--c-border);margin-bottom:8px;transition:all .2s;}
.loc-chip:hover{border-color:var(--c-orange);background:var(--c-orange-l);}
.stat-mini{background:rgba(255,255,255,.15);backdrop-filter:blur(8px);border:1px solid rgba(255,255,255,.2);border-radius:12px;padding:12px 14px;text-align:center;color:white;flex:1;}
.stat-mini-num{font-size:1.4rem;font-weight:800;line-height:1;}
.stat-mini-lbl{font-size:.68rem;opacity:.78;margin-top:3px;}
.order-hist-row{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid var(--c-border);}
.order-hist-row:last-child{border-bottom:none;}
.fav-row{display:flex;align-items:center;gap:12px;padding:11px 0;border-bottom:1px solid var(--c-border);}
.fav-row:last-child{border-bottom:none;}
</style>

<div class="yd-page" style="padding-bottom:40px;max-width:680px;margin:0 auto;">

  <!-- Alerts -->
  <c:if test="${not empty success}">
    <div style="margin:14px 16px 0;padding:12px 16px;background:#E8F5E9;border-radius:12px;color:#2E7D32;font-size:.875rem;border:1px solid #A5D6A7;">
      <i class="bi bi-check-circle-fill me-2"></i><c:out value="${success}"/>
    </div>
  </c:if>
  <c:if test="${not empty error}">
    <div style="margin:14px 16px 0;padding:12px 16px;background:#FFEBEE;border-radius:12px;color:#C62828;font-size:.875rem;border:1px solid #FFCDD2;">
      <i class="bi bi-exclamation-circle-fill me-2"></i><c:out value="${error}"/>
    </div>
  </c:if>

  <!-- Hero banner -->
  <div class="acc-hero">
    <div style="display:flex;align-items:center;gap:16px;position:relative;z-index:1;margin-bottom:22px;">
      <div class="acc-avatar">
        <c:choose>
          <c:when test="${fn:length(user.profilePicUrl) > 0}">
            <img src="${user.profilePicUrl}" style="width:100%;height:100%;object-fit:cover;" onerror="this.style.display='none'">
          </c:when>
          <c:otherwise>
            <div style="width:100%;height:100%;background:rgba(255,255,255,.25);display:flex;align-items:center;justify-content:center;font-size:1.8rem;font-weight:800;color:white;">
              <c:choose><c:when test="${fn:length(user.name)>0}">${fn:substring(user.name,0,1)}</c:when><c:otherwise>U</c:otherwise></c:choose>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
      <div style="color:white;">
        <div style="font-family:var(--font-display);font-size:1.4rem;font-weight:700;"><c:out value="${user.name}"/></div>
        <div style="font-size:.82rem;opacity:.82;margin-top:2px;"><c:out value="${user.email}"/></div>
        <div style="font-size:.7rem;opacity:.6;margin-top:5px;">Member since <c:out value="${user.createdAt}"/></div>
      </div>
    </div>
    <!-- Stats row -->
    <div style="display:flex;gap:10px;position:relative;z-index:1;">
      <div class="stat-mini"><div class="stat-mini-num" id="heroOrders">—</div><div class="stat-mini-lbl">Orders</div></div>
      <div class="stat-mini"><div class="stat-mini-num" id="heroSpend" style="font-size:1rem;">—</div><div class="stat-mini-lbl">Spent</div></div>
      <div class="stat-mini"><div class="stat-mini-num" id="heroPoints">⭐ <c:out value="${user.loyaltyPoints}"/></div><div class="stat-mini-lbl">Points</div></div>
      <div class="stat-mini"><div class="stat-mini-num" id="heroFavs">—</div><div class="stat-mini-lbl">Favourites</div></div>
    </div>
  </div>

  <div style="padding:0 16px;margin-top:-20px;position:relative;z-index:10;">

    <!-- Loyalty card -->
    <div class="yd-card mb-3" style="border:2px solid rgba(255,184,0,.3);">
      <div class="yd-card-body" style="padding:18px 20px;">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <div style="font-weight:700;font-size:.9rem;">⭐ Loyalty Points</div>
          <div style="font-size:1.6rem;font-weight:800;color:#FFB800;" id="loyaltyBig"><c:out value="${user.loyaltyPoints}"/></div>
        </div>
        <div class="loyalty-bar"><div class="loyalty-fill" id="loyaltyFill" style="width:0%;transition:width 1.2s var(--ease);"></div></div>
        <div style="display:flex;justify-content:space-between;font-size:.72rem;color:var(--c-muted);margin-top:6px;">
          <span>Earn 1 pt per LKR 10 spent</span>
          <span id="loyaltyVal">Value: LKR <c:out value="${user.loyaltyPoints / 10}"/></span>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="acc-tabs">
      <button class="acc-tab active" onclick="switchTab('profile',this)"><i class="bi bi-person me-1"></i>Profile</button>
      <button class="acc-tab"        onclick="switchTab('orders',this)"><i class="bi bi-bag me-1"></i>Orders</button>
      <button class="acc-tab"        onclick="switchTab('places',this)"><i class="bi bi-geo-alt me-1"></i>Places</button>
      <button class="acc-tab"        onclick="switchTab('favs',this)"><i class="bi bi-heart me-1"></i>Favs</button>
    </div>

    <!-- ── PROFILE ── -->
    <div class="acc-pane active" id="pane-profile">
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <!-- VIEW -->
          <div id="profileView">
            <div class="info-row"><span style="color:var(--c-muted);font-size:.82rem;">Full Name</span><span style="font-weight:600;"><c:out value="${user.name}"/></span></div>
            <div class="info-row"><span style="color:var(--c-muted);font-size:.82rem;">Email</span><span style="font-weight:600;font-size:.875rem;"><c:out value="${user.email}"/></span></div>
            <div class="info-row"><span style="color:var(--c-muted);font-size:.82rem;">Phone</span><span style="font-weight:600;"><c:choose><c:when test="${fn:length(user.phone)>0}"><c:out value="${user.phone}"/></c:when><c:otherwise><span style="color:var(--c-muted);">—</span></c:otherwise></c:choose></span></div>
            <div class="info-row"><span style="color:var(--c-muted);font-size:.82rem;">Address</span><span style="font-weight:600;text-align:right;max-width:60%;font-size:.875rem;"><c:choose><c:when test="${fn:length(user.address)>0}"><c:out value="${user.address}"/></c:when><c:otherwise><span style="color:var(--c-muted);">Not set</span></c:otherwise></c:choose></span></div>
            <div class="d-flex gap-2 mt-4">
              <button onclick="toggleEdit(true)" class="yd-btn yd-btn-primary" style="flex:1;"><i class="bi bi-pencil-fill me-2"></i>Edit Profile</button>
              <button onclick="showModal('pwdModal')" class="yd-btn yd-btn-outline" style="padding:10px 14px;"><i class="bi bi-key me-1"></i>Password</button>
              <button onclick="showModal('delModal')" style="background:#FFEBEE;color:#C62828;border:none;padding:10px 14px;border-radius:10px;cursor:pointer;"><i class="bi bi-trash3"></i></button>
            </div>
          </div>
          <!-- EDIT FORM -->
          <div id="profileEdit" style="display:none;">
            <form action="/account/update" method="post">
              <div class="row g-3">
                <div class="col-12 yd-form-group"><label class="yd-label">Full Name</label><input type="text" name="name" class="yd-input" value="${user.name}" required></div>
                <div class="col-6 yd-form-group"><label class="yd-label">Phone</label><input type="text" name="phone" class="yd-input" value="${user.phone}"></div>
                <div class="col-6 yd-form-group"><label class="yd-label">Email (locked)</label><input class="yd-input" value="${user.email}" disabled style="opacity:.55;"></div>
                <div class="col-12 yd-form-group">
                  <label class="yd-label">Delivery Address</label>
                  <input type="text" name="address" id="addrInput" class="yd-input" value="${user.address}" placeholder="Kandy area">
                  <button type="button" onclick="fillGPS()" class="yd-btn yd-btn-outline yd-btn-sm mt-2" style="width:auto;padding:6px 14px;"><i class="bi bi-crosshair me-1" style="color:var(--c-orange);"></i>Use GPS</button>
                  <div id="addrMsg" style="font-size:.75rem;color:var(--c-muted);margin-top:4px;"></div>
                </div>
                <div class="col-12"><hr style="border-color:var(--c-border);"><p class="yd-label mb-3">Payment Card (optional)</p></div>
                <div class="col-12 yd-form-group"><label class="yd-label">Card Number</label><input type="text" name="cardNumber" class="yd-input" placeholder="Leave blank to keep" maxlength="19" oninput="fmtCard(this)"></div>
                <div class="col-6 yd-form-group"><label class="yd-label">Cardholder</label><input type="text" name="cardHolder" class="yd-input" value="${user.cardHolder}"></div>
                <div class="col-6 yd-form-group"><label class="yd-label">Expiry MM/YY</label><input type="text" name="cardExpiry" class="yd-input" value="${user.cardExpiry}" placeholder="12/26" maxlength="5"></div>
              </div>
              <div class="d-flex gap-2 mt-3">
                <button type="submit" class="yd-btn yd-btn-primary" style="flex:1;">✅ Save Changes</button>
                <button type="button" onclick="toggleEdit(false)" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Payment card display -->
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <h6 class="fw-bold mb-3" style="color:var(--c-text);">💳 Payment Card</h6>
          <c:choose>
            <c:when test="${user.hasCard()}">
              <div class="card-3d">
                <div style="font-size:.7rem;opacity:.6;letter-spacing:2px;text-transform:uppercase;margin-bottom:16px;">Credit / Debit Card</div>
                <div style="font-size:1.1rem;letter-spacing:3px;font-weight:700;margin-bottom:14px;"><c:out value="${user.maskedCard}"/></div>
                <div style="display:flex;justify-content:space-between;font-size:.8rem;opacity:.75;">
                  <span><c:out value="${user.cardHolder}"/></span>
                  <span>Expires <c:out value="${user.cardExpiry}"/></span>
                </div>
              </div>
            </c:when>
            <c:otherwise>
              <div style="text-align:center;padding:20px;color:var(--c-muted);">
                <i class="bi bi-credit-card" style="font-size:2.5rem;display:block;margin-bottom:8px;opacity:.4;"></i>
                <p style="font-size:.875rem;margin-bottom:12px;">No card saved. Add one for card payment, group orders &amp; scheduled orders.</p>
                <button onclick="toggleEdit(true)" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:8px 20px;">Add Card</button>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- Sign out -->
      <a href="/logout" class="yd-btn yd-btn-outline d-flex justify-content-center mb-2 yd-fade" style="color:var(--c-muted);">
        <i class="bi bi-box-arrow-right me-2"></i>Sign Out
      </a>
    </div>

    <!-- ── ORDERS ── -->
    <div class="acc-pane" id="pane-orders">
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <div class="row g-2 mb-4" id="orderStatsRow">
            <div class="col-4"><div style="background:var(--c-bg);border-radius:12px;padding:14px;text-align:center;border:1px solid var(--c-border);"><div style="font-size:1.6rem;font-weight:800;color:var(--c-orange);" id="stOrders">—</div><div style="font-size:.72rem;color:var(--c-muted);">Orders</div></div></div>
            <div class="col-4"><div style="background:var(--c-bg);border-radius:12px;padding:14px;text-align:center;border:1px solid var(--c-border);"><div style="font-size:1rem;font-weight:800;color:var(--c-orange);" id="stSpend">—</div><div style="font-size:.72rem;color:var(--c-muted);">Total Spent</div></div></div>
            <div class="col-4"><div style="background:var(--c-bg);border-radius:12px;padding:14px;text-align:center;border:1px solid var(--c-border);"><div style="font-size:1.6rem;font-weight:800;color:var(--c-success);" id="stDone">—</div><div style="font-size:.72rem;color:var(--c-muted);">Delivered</div></div></div>
          </div>
          <!-- Smart reorder suggestions -->
          <div id="reorderSuggestions" style="display:none;margin-bottom:18px;">
            <div style="font-size:.78rem;font-weight:700;color:var(--c-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:10px;">🔄 Order Again</div>
            <div id="reorderChips" style="display:flex;gap:8px;flex-wrap:wrap;"></div>
          </div>
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="fw-bold mb-0">Recent Orders</h6>
            <a href="/activity" class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;padding:6px 14px;font-size:.78rem;">View All</a>
          </div>
          <div id="ordersList"><div style="text-align:center;padding:20px;color:var(--c-muted);">Loading...</div></div>
        </div>
      </div>
    </div>

    <!-- ── PLACES ── -->
    <div class="acc-pane" id="pane-places">
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="fw-bold mb-0">📌 Saved Locations</h6>
            <span style="font-size:.75rem;color:var(--c-muted);">Save from Menu page</span>
          </div>
          <div id="savedLocsList"></div>
          <div style="margin-top:12px;padding:12px 14px;background:var(--c-orange-l);border-radius:12px;border:1px solid rgba(255,107,53,.18);">
            <p style="font-size:.8rem;color:var(--c-orange);margin:0;"><i class="bi bi-lightbulb me-1"></i>Go to Menu → click your address → save as "Home", "Work", etc.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- ── FAVOURITES ── -->
    <div class="acc-pane" id="pane-favs">
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <h6 class="fw-bold mb-3">❤️ My Favourites</h6>
          <div id="favsList"><div style="text-align:center;padding:20px;color:var(--c-muted);">Loading...</div></div>
        </div>
      </div>
    </div>

  </div><!-- /inner padding -->
</div>

<!-- Delete modal -->
<div id="delModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;padding:16px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:32px;max-width:340px;width:100%;text-align:center;animation:scaleIn .3s var(--ease);">
    <div style="font-size:3rem;margin-bottom:12px;">🗑️</div>
    <h4 style="font-family:var(--font-display);">Delete Account?</h4>
    <p style="color:var(--c-muted);font-size:.875rem;margin:10px 0 24px;">All your data, orders and loyalty points will be permanently deleted.</p>
    <div class="d-flex gap-2">
      <form action="/account/delete" method="post" style="flex:1;"><button type="submit" class="yd-btn" style="width:100%;background:#f44336;color:white;padding:12px;">Delete Forever</button></form>
      <button onclick="hideModal('delModal')" class="yd-btn yd-btn-outline" style="flex:1;padding:12px;color:var(--c-muted);">Cancel</button>
    </div>
  </div>
</div>

<!-- Password modal -->
<div id="pwdModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;padding:16px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:32px;max-width:400px;width:100%;animation:scaleIn .3s var(--ease);">
    <h4 style="font-family:var(--font-display);margin-bottom:20px;">🔑 Change Password</h4>
    <div id="pwdAlert"></div>
    <div class="yd-form-group"><label class="yd-label">Current Password</label><input type="password" id="cp1" class="yd-input" placeholder="Current password"></div>
    <div class="yd-form-group"><label class="yd-label">New Password</label><input type="password" id="cp2" class="yd-input" placeholder="Min 6 characters"></div>
    <div class="yd-form-group"><label class="yd-label">Confirm New Password</label><input type="password" id="cp3" class="yd-input" placeholder="Repeat new password"></div>
    <div class="d-flex gap-2">
      <button onclick="doChangePwd()" class="yd-btn yd-btn-primary" style="flex:1;">Update Password</button>
      <button onclick="hideModal('pwdModal')" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
    </div>
  </div>
</div>

<script>
function switchTab(name, btn) {
  document.querySelectorAll('.acc-pane').forEach(function(p){ p.classList.remove('active'); });
  document.querySelectorAll('.acc-tab').forEach(function(b){ b.classList.remove('active'); });
  document.getElementById('pane-' + name).classList.add('active');
  btn.classList.add('active');
  if (name === 'orders')  loadOrders();
  if (name === 'places')  loadPlaces();
  if (name === 'favs')    loadFavs();
}

function toggleEdit(show) {
  document.getElementById('profileView').style.display = show ? 'none' : 'block';
  document.getElementById('profileEdit').style.display = show ? 'block' : 'none';
}

function showModal(id) { document.getElementById(id).style.display = 'flex'; }
function hideModal(id) { document.getElementById(id).style.display = 'none'; }

function fillGPS() {
  var msg = document.getElementById('addrMsg');
  msg.textContent = 'Getting location...';
  if (!navigator.geolocation) { msg.textContent = 'Not supported'; return; }
  navigator.geolocation.getCurrentPosition(function(pos) {
    var key = window.GOOGLE_MAPS_KEY || '';
    if (!key) { document.getElementById('addrInput').value = pos.coords.latitude.toFixed(5)+','+pos.coords.longitude.toFixed(5); msg.textContent='Done'; return; }
    fetch('https://maps.googleapis.com/maps/api/geocode/json?latlng='+pos.coords.latitude+','+pos.coords.longitude+'&key='+key)
      .then(function(r){ return r.json(); })
      .then(function(d) {
        var addr = (d.results&&d.results[0]) ? d.results[0].formatted_address : pos.coords.latitude.toFixed(5)+','+pos.coords.longitude.toFixed(5);
        document.getElementById('addrInput').value = addr;
        msg.textContent = 'Location filled!';
        msg.style.color = 'var(--c-success)';
      }).catch(function(){ msg.textContent = 'Could not geocode'; });
  }, function(e){ msg.textContent = 'Error: '+e.message; }, { enableHighAccuracy:true, timeout:8000 });
}

function fmtCard(i){ var v=i.value.replace(/\s+/g,'').replace(/\D/g,''); var p=[]; for(var j=0;j<v.length;j+=4) p.push(v.substring(j,j+4)); i.value=p.join(' '); }

// ── Orders ───────────────────────────────────────────────────────
var ordersLoaded = false;
function loadOrders() {
  if (ordersLoaded) return; ordersLoaded = true;
  fetch('/api/my-orders?limit=30')
    .then(function(r){ return r.ok ? r.json() : []; }).catch(function(){ return []; })
    .then(function(orders) {
      if (!orders.length) {
        document.getElementById('ordersList').innerHTML = '<div style="text-align:center;padding:24px;color:var(--c-muted);">No orders yet. <a href="/menu" style="color:var(--c-orange);">Order now!</a></div>';
        return;
      }
      var total = orders.length;
      var spent = orders.reduce(function(s,o){ return s + (o.totalAmount||0); }, 0);
      var done  = orders.filter(function(o){ return o.status==='DELIVERED'; }).length;
      document.getElementById('stOrders').textContent = total;
      document.getElementById('stSpend').textContent  = 'LKR ' + Math.round(spent/1000) + 'k';
      document.getElementById('stDone').textContent   = done;
      document.getElementById('heroOrders').textContent = total;
      document.getElementById('heroSpend').textContent  = 'LKR ' + Math.round(spent/1000) + 'k';

      var sc = { COOKING:'#E65100',READY:'#2E7D32',HANDOVER:'#1565C0',ON_WAY:'#1565C0',DELIVERED:'#7C3AED',CANCELLED:'#C62828' };
      document.getElementById('ordersList').innerHTML = orders.slice(0,10).map(function(o) {
        var isActive = o.status!=='DELIVERED' && o.status!=='CANCELLED';
        return '<div class="order-hist-row">'
          +'<div style="flex:1;">'
          +'<div style="font-family:monospace;font-weight:700;font-size:.875rem;color:var(--c-text);">#'+o.orderId+'</div>'
          +'<div style="font-size:.72rem;color:var(--c-muted);">'+o.createdAt+'</div>'
          +'</div>'
          +'<div style="text-align:right;">'
          +'<div style="font-size:.75rem;font-weight:700;color:'+(sc[o.status]||'#888')+';">'+o.statusBadge+'</div>'
          +'<div style="font-size:.85rem;font-weight:700;color:var(--c-orange);">LKR '+Math.round(o.totalAmount).toLocaleString()+'</div>'
          +'</div>'
          +'<button onclick="reorder(\''+o.orderId+'\')" class="yd-btn yd-btn-sm" style="background:var(--c-orange-l);color:var(--c-orange);border:none;padding:6px 12px;font-size:.72rem;white-space:nowrap;margin-left:6px;">🔄 Again</button>'
          +'</div>';
      }).join('');
    });
}

// ── Places ───────────────────────────────────────────────────────
function loadPlaces() {
  var locs = []; try { locs = JSON.parse(localStorage.getItem('ydSavedLocs')||'[]'); } catch(e){}
  var c = document.getElementById('savedLocsList');
  var icons = { 'Home':'🏠','Work':'🏢','Office':'🏢','University':'🎓','Uni':'🎓','School':'🏫' };
  if (!locs.length) { c.innerHTML = '<p style="color:var(--c-muted);font-size:.875rem;text-align:center;padding:16px;">No saved locations yet.</p>'; return; }
  c.innerHTML = locs.map(function(loc) {
    return '<div class="loc-chip">'
      +'<span style="font-size:1.2rem;">'+(icons[loc.name]||'📍')+'</span>'
      +'<div><div style="font-weight:700;font-size:.875rem;color:var(--c-text);">'+loc.name+'</div>'
      +'<div style="font-size:.75rem;color:var(--c-muted);">'+loc.address+'</div></div>'
      +'</div>';
  }).join('');
}

// ── Favourites ───────────────────────────────────────────────────
function loadFavs() {
  var favs = Favs.getAll();
  document.getElementById('heroFavs').textContent = favs.length;
  var c = document.getElementById('favsList');
  if (!favs.length) { c.innerHTML = '<div style="text-align:center;padding:24px;color:var(--c-muted);"><i class="bi bi-heart" style="font-size:2rem;display:block;margin-bottom:8px;opacity:.3;"></i>No favourites yet. Tap ♡ on any food item.</div>'; return; }
  c.innerHTML = favs.map(function(f) {
    var id=String(f.id||''), name=String(f.name||''), img=String(f.img||''), price=Number(f.price||0);
    return '<div class="fav-row">'
      +'<img src="'+img+'" style="width:52px;height:52px;object-fit:cover;border-radius:12px;flex-shrink:0;" onerror="this.style.display=\'none\'">'
      +'<div style="flex:1;"><div style="font-weight:600;font-size:.9rem;color:var(--c-text);">'+name+'</div>'
      +'<div style="color:var(--c-orange);font-size:.82rem;font-weight:700;">LKR '+price.toLocaleString()+'</div></div>'
      +'<button data-fid="'+id+'" data-fname="'+name+'" data-fprice="'+price+'" data-fimg="'+img+'"'
      +' onclick="var b=this;Cart.add(b.dataset.fid,b.dataset.fname,parseFloat(b.dataset.fprice),1,b.dataset.fimg);showToast(\'Added! 🛒\');"'
      +' class="yd-btn yd-btn-primary yd-btn-sm" style="white-space:nowrap;width:auto;">Add to Cart</button>'
      +'</div>';
  }).join('');
}

// ── Change password ───────────────────────────────────────────────
async function doChangePwd() {
  var cur=document.getElementById('cp1').value, nw=document.getElementById('cp2').value, cf=document.getElementById('cp3').value;
  var al=document.getElementById('pwdAlert'); al.innerHTML='';
  if (!cur||!nw||!cf) { al.innerHTML='<div class="alert alert-danger mb-3" style="font-size:.83rem;">Fill all fields.</div>'; return; }
  if (nw!==cf)        { al.innerHTML='<div class="alert alert-danger mb-3" style="font-size:.83rem;">Passwords do not match.</div>'; return; }
  if (nw.length<6)    { al.innerHTML='<div class="alert alert-danger mb-3" style="font-size:.83rem;">Min 6 characters.</div>'; return; }
  try {
    var r = await fetch('/account/change-password', { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({currentPassword:cur,newPassword:nw}) });
    var d = await r.json();
    if (d.success) { al.innerHTML='<div class="alert alert-success mb-3" style="font-size:.83rem;">Password updated!</div>'; setTimeout(function(){hideModal('pwdModal');},1500); }
    else al.innerHTML='<div class="alert alert-danger mb-3" style="font-size:.83rem;">'+(d.error||'Wrong current password.')+'</div>';
  } catch(e) { al.innerHTML='<div class="alert alert-danger mb-3" style="font-size:.83rem;">Network error.</div>'; }
}

// ── Init ──────────────────────────────────────────────────────────
document.getElementById('heroFavs').textContent = Favs.getAll().length;
// Loyalty bar animation
setTimeout(function() {
  var pts = ${user.loyaltyPoints};
  var pct = Math.min((pts % 100), 100);
  document.getElementById('loyaltyFill').style.width = pct + '%';
}, 400);
// Load order stats in background
fetch('/api/my-orders?limit=100')
  .then(function(r){ return r.ok ? r.json() : []; }).catch(function(){ return []; })
  .then(function(orders) {
    if (!orders.length) return;
    var spent = orders.reduce(function(s,o){ return s+(o.totalAmount||0); }, 0);
    document.getElementById('heroOrders').textContent = orders.length;
    document.getElementById('heroSpend').textContent  = 'LKR ' + Math.round(spent/1000) + 'k';
  });
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
