<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Cart"/>
<c:set var="pageId"    value="cart"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.pay-lbl{display:flex;align-items:center;gap:10px;padding:13px 16px;border-radius:12px;border:1.5px solid var(--c-border);cursor:pointer;margin-bottom:8px;transition:all .2s;background:var(--c-surface);}
.pay-lbl.sel{border-color:var(--c-orange);background:var(--c-orange-l);}
#deliveryMap{width:100%;height:260px;border-radius:16px;border:1px solid var(--c-border);background:#f0f0f0;position:relative;}
.map-pin-overlay{position:absolute;top:50%;left:50%;transform:translate(-50%,-100%);z-index:10;pointer-events:none;font-size:2.2rem;filter:drop-shadow(0 3px 6px rgba(0,0,0,.4));}
.weather-bar{display:flex;align-items:center;gap:10px;padding:10px 14px;border-radius:12px;border:1px solid var(--c-border);background:var(--c-surface);font-size:.82rem;margin-top:8px;}
.saved-loc-chip{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;border-radius:20px;border:1.5px solid var(--c-border);background:var(--c-surface);font-size:.8rem;font-weight:600;cursor:pointer;transition:all .2s;margin:3px;}
.saved-loc-chip:hover,.saved-loc-chip.sel{background:var(--c-orange);color:white;border-color:var(--c-orange);}
.tip-btn{padding:8px 18px;border-radius:20px;border:1.5px solid var(--c-border);background:var(--c-surface);font-size:.82rem;font-weight:600;cursor:pointer;transition:all .2s;margin:3px;}
.tip-btn.sel{background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;border-color:var(--c-orange);}
</style>

<div class="yd-page container-xl py-4" style="max-width:1080px;">
  <h2 style="font-family:var(--font-display);font-size:2rem;margin-bottom:24px;">Your Cart 🛒</h2>

  <div id="emptyCart" style="display:none;text-align:center;padding:80px 0;">
    <div style="font-size:5rem;margin-bottom:16px;animation:float 3s ease-in-out infinite;">🛒</div>
    <h4 style="color:var(--c-muted);">Your cart is empty</h4>
    <a href="/menu" class="yd-btn yd-btn-primary mt-3" style="width:auto;padding:12px 28px;">Browse Menu</a>
  </div>

  <div id="cartContent">
    <div class="row g-4">
      <!-- LEFT -->
      <div class="col-lg-7">
        <!-- Cart items -->
        <div class="yd-card mb-4 yd-fade">
          <div class="yd-card-body">
            <h5 class="fw-bold mb-3">Order Items</h5>
            <div id="cartItems"></div>
          </div>
        </div>

        <!-- Delivery -->
        <div class="yd-card mb-4 yd-fade">
          <div class="yd-card-body">
            <h5 class="fw-bold mb-3">📍 Delivery Address</h5>

            <!-- Saved locations chips -->
            <div id="savedLocsChips" style="margin-bottom:12px;"></div>

            <!-- Address input -->
            <div class="position-relative mb-2">
              <i class="bi bi-geo-alt-fill" style="position:absolute;left:13px;top:50%;transform:translateY(-50%);color:var(--c-orange);pointer-events:none;"></i>
              <input type="text" id="deliveryAddress" class="yd-input" style="padding-left:38px!important;" placeholder="e.g. 15 Dalada Veediya, Kandy" value="${fn:length(user.address)>0 ? user.address : ''}">
            </div>
            <div class="d-flex gap-2 mb-3">
              <button onclick="useGPSCart()" class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;padding:7px 14px;"><i class="bi bi-crosshair me-1" style="color:var(--c-orange);"></i>Use My Location</button>
            </div>

            <!-- Single map with static pin -->
            <div style="position:relative;border-radius:16px;overflow:hidden;border:1px solid var(--c-border);">
              <div id="deliveryMap"></div>
              <div class="map-pin-overlay">📍</div>
              <div style="position:absolute;bottom:10px;left:50%;transform:translateX(-50%);background:rgba(0,0,0,.7);color:white;padding:5px 14px;border-radius:20px;font-size:.75rem;backdrop-filter:blur(6px);white-space:nowrap;">
                Move the map to position the pin
              </div>
            </div>
            <div id="mapAddressResult" style="margin-top:8px;padding:8px 12px;background:var(--c-orange-l);border-radius:10px;font-size:.82rem;color:var(--c-text2);display:none;border:1px solid rgba(255,107,53,.2);">
              <i class="bi bi-geo-alt-fill me-1" style="color:var(--c-orange);"></i><span id="mapAddrText"></span>
              <button onclick="applyMapAddress()" class="yd-btn yd-btn-primary yd-btn-sm" style="float:right;padding:3px 12px;width:auto;">Use this</button>
            </div>

            <!-- Weather info -->
            <div class="weather-bar" id="weatherBar">
              <span id="weatherIcon">⏳</span>
              <div style="flex:1;"><div id="weatherText" style="font-weight:600;color:var(--c-text);">Loading weather...</div><div id="weatherFee" style="font-size:.72rem;color:var(--c-muted);"></div></div>
              <span id="weatherTemp" style="font-weight:700;color:var(--c-orange);"></span>
            </div>

            <!-- Notes -->
            <div class="yd-form-group mt-3">
              <label class="yd-label">Note for Chef</label>
              <textarea id="chefNote" class="yd-input" rows="2" placeholder="Allergies, spice level, no onions..." style="resize:none;"></textarea>
            </div>
            <div class="yd-form-group">
              <label class="yd-label">Note for Driver</label>
              <textarea id="driverNote" class="yd-input" rows="2" placeholder="Ring doorbell, call on arrival..." style="resize:none;"></textarea>
            </div>

            <!-- Tip -->
            <div class="yd-form-group">
              <label class="yd-label">💝 Tip for Driver (optional)</label>
              <div class="d-flex flex-wrap gap-1">
                <button class="tip-btn" onclick="setTip(0,this)">No tip</button>
                <button class="tip-btn" onclick="setTip(50,this)">LKR 50</button>
                <button class="tip-btn" onclick="setTip(100,this)">LKR 100</button>
                <button class="tip-btn" onclick="setTip(200,this)">LKR 200</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- RIGHT: Summary -->
      <div class="col-lg-5 yd-fade">
        <div class="yd-card" style="position:sticky;top:80px;">
          <div class="yd-card-body">
            <h5 class="fw-bold mb-4">Order Summary</h5>
            <div style="display:flex;justify-content:space-between;font-size:.9rem;padding:6px 0;color:var(--c-muted);"><span>Subtotal</span><span id="sumSub">LKR 0</span></div>
            <div style="display:flex;justify-content:space-between;font-size:.9rem;padding:6px 0;color:var(--c-muted);"><span>Delivery Fee</span><span id="sumDelivery">LKR 250</span></div>
            <div id="weatherFeeRow" style="display:none;justify-content:space-between;font-size:.9rem;padding:6px 0;color:#E65100;"><span>Weather Surcharge</span><span id="sumWeatherFee">LKR 0</span></div>
            <div id="tipRow" style="display:none;justify-content:space-between;font-size:.9rem;padding:6px 0;color:var(--c-muted);"><span>Driver Tip</span><span id="sumTip">LKR 0</span></div>
            <div id="discRow" style="display:none;justify-content:space-between;font-size:.9rem;padding:6px 0;color:var(--c-success);"><span>Offer (<span id="offerLbl"></span>)</span><span id="sumDisc">- LKR 0</span></div>
            <div style="display:flex;justify-content:space-between;font-weight:800;font-size:1.1rem;border-top:1px solid var(--c-border);margin-top:8px;padding-top:12px;">
              <span>Total</span><span style="color:var(--c-orange);" id="sumTotal">LKR 0</span>
            </div>

            <!-- Promo -->
            <div class="mt-4">
              <label class="yd-label">Promo Code</label>
              <div class="yd-promo-wrap">
                <input type="text" id="promoInput" class="yd-input" placeholder="e.g. FIRST20" style="text-transform:uppercase;letter-spacing:2px;">
                <button onclick="applyPromo()" class="yd-btn yd-btn-dark yd-btn-sm" style="white-space:nowrap;">Apply</button>
              </div>
              <div id="promoMsg" style="display:none;" class="yd-promo-msg"></div>
            </div>

            <!-- Payment -->
            <h6 class="fw-bold mt-4 mb-3">Payment Method</h6>
            <label class="pay-lbl sel" id="lCOD" onclick="selPay('COD')">
              <input type="radio" name="pay" value="COD" checked style="accent-color:var(--c-orange);">
              <span>💵 Cash on Delivery</span>
            </label>
            <label class="pay-lbl" id="lCard" onclick="selPay('CARD')">
              <input type="radio" name="pay" value="CARD" style="accent-color:var(--c-orange);">
              <span>💳 Credit / Debit Card</span>
            </label>

            <button class="yd-btn yd-btn-primary mt-4" onclick="proceedPay()">
              <i class="bi bi-lock-fill me-2"></i>Proceed to Payment →
            </button>
            <a href="/menu" class="yd-btn yd-btn-outline mt-2 d-flex justify-content-center" style="color:var(--c-muted);">
              <i class="bi bi-arrow-left me-1"></i>Continue Shopping
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Payment Modal -->
<div class="modal fade" id="payModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered" style="max-width:440px;">
    <div class="modal-content" style="border-radius:24px;border:none;background:var(--c-surface);">
      <div class="modal-body p-4">
        <h4 style="font-family:var(--font-display);margin-bottom:4px;" id="payTitle">Confirm Order</h4>
        <p style="color:var(--c-muted);font-size:.875rem;margin-bottom:20px;">Total: <strong style="color:var(--c-orange);font-size:1.1rem;" id="payTotal">LKR 0</strong></p>
        <div id="cardFlds" style="display:none;">
          <div class="yd-form-group"><label class="yd-label">Card Number</label><input type="text" id="cNum" class="yd-input" placeholder="4242 4242 4242 4242" maxlength="19" oninput="fmtCard(this)"></div>
          <div class="yd-form-group"><label class="yd-label">Cardholder</label><input type="text" id="cName" class="yd-input" value="${user.name}"></div>
          <div class="row g-2">
            <div class="col-6 yd-form-group"><label class="yd-label">Expiry</label><input type="text" id="cExp" class="yd-input" placeholder="12/26" maxlength="5"></div>
            <div class="col-6 yd-form-group"><label class="yd-label">CVV</label><input type="password" id="cCvv" class="yd-input" placeholder="•••" maxlength="4"></div>
          </div>
          <div style="background:#f8f4f0;padding:8px 12px;border-radius:8px;font-size:.75rem;color:#888;margin-bottom:12px;"><i class="bi bi-lock-fill me-1" style="color:var(--c-success);"></i>Secured with 256-bit SSL</div>
        </div>
        <div id="codFlds" style="text-align:center;padding:16px 0;">
          <div style="font-size:3rem;margin-bottom:12px;">🛵</div>
          <p style="color:var(--c-text2);">Pay cash when your order arrives.</p>
        </div>
        <div id="procFlds" style="display:none;text-align:center;padding:20px 0;">
          <div style="width:48px;height:48px;border:4px solid var(--c-border);border-top-color:var(--c-orange);border-radius:50%;animation:spin 1s linear infinite;margin:0 auto 16px;"></div>
          <p style="font-weight:600;">Placing your order...</p>
        </div>
        <div class="d-flex gap-2 mt-2">
          <button class="yd-btn yd-btn-primary" id="payBtn" onclick="placeOrder()" style="flex:1;"><span id="payBtnLbl">Confirm Order</span></button>
          <button class="yd-btn yd-btn-outline" data-bs-dismiss="modal" style="color:var(--c-muted);">Cancel</button>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
var offer = JSON.parse(localStorage.getItem('ydOffer') || 'null');
var payMethod = 'COD';
var weatherExtraFee = 0;
var tipAmount = 0;
var deliveryMap = null;
var currentCenter = null; // lat/lng of map center = delivery location

// ── Render cart ───────────────────────────────────────────────────
function renderCart() {
  var items = Cart.get();
  if (!items.length) {
    document.getElementById('cartContent').style.display = 'none';
    document.getElementById('emptyCart').style.display  = 'block';
    return;
  }
  var html = '';
  items.forEach(function(item) {
    var img  = item.img  || '';
    var name = item.name || '';
    var id   = item.id   || '';
    var price = Number(item.price || 0), qty = Number(item.qty || 1);
    html += '<div class="yd-cart-row">'
      + '<img src="' + img + '" onerror="this.src=\'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&amp;q=80\'" style="width:68px;height:68px;object-fit:cover;border-radius:12px;flex-shrink:0;">'
      + '<div style="flex:1;"><div style="font-weight:600;font-size:.9rem;">' + name + '</div>'
      + '<div style="color:var(--c-orange);font-size:.82rem;font-weight:700;">LKR ' + price.toLocaleString() + '</div></div>'
      + '<div class="yd-qty">'
      + '<button class="yd-qty-btn" onclick="Cart.updateQty(\'' + id + '\',' + (qty-1) + ');renderCart();">−</button>'
      + '<span class="yd-qty-val">' + qty + '</span>'
      + '<button class="yd-qty-btn" onclick="Cart.updateQty(\'' + id + '\',' + (qty+1) + ');renderCart();">+</button>'
      + '</div>'
      + '<div style="font-weight:700;min-width:90px;text-align:right;">LKR ' + Math.round(price*qty).toLocaleString() + '</div>'
      + '<button onclick="Cart.remove(\'' + id + '\');renderCart();" style="background:none;border:none;color:#f44336;padding:4px 8px;font-size:1rem;cursor:pointer;">✕</button>'
      + '</div>';
  });
  document.getElementById('cartItems').innerHTML = html;
  updSum();
}

function updSum() {
  var sub   = Cart.total();
  var disc  = offer ? Math.round(sub * offer.discount) : 0;
  var total = sub + 250 + weatherExtraFee + tipAmount - disc;
  document.getElementById('sumSub').textContent = 'LKR ' + Math.round(sub).toLocaleString();
  document.getElementById('sumDelivery').textContent = 'LKR 250';
  document.getElementById('sumTotal').textContent = 'LKR ' + Math.round(total).toLocaleString();
  if (disc > 0) {
    document.getElementById('discRow').style.display = 'flex';
    document.getElementById('offerLbl').textContent  = offer.code;
    document.getElementById('sumDisc').textContent   = '- LKR ' + disc.toLocaleString();
  } else document.getElementById('discRow').style.display = 'none';
  if (weatherExtraFee > 0) {
    document.getElementById('weatherFeeRow').style.display = 'flex';
    document.getElementById('sumWeatherFee').textContent   = 'LKR ' + weatherExtraFee;
  } else document.getElementById('weatherFeeRow').style.display = 'none';
  if (tipAmount > 0) {
    document.getElementById('tipRow').style.display = 'flex';
    document.getElementById('sumTip').textContent   = 'LKR ' + tipAmount;
  } else document.getElementById('tipRow').style.display = 'none';
}

function selPay(m) {
  payMethod = m;
  document.getElementById('lCOD').classList.toggle('sel',  m === 'COD');
  document.getElementById('lCard').classList.toggle('sel', m === 'CARD');
}

function setTip(amount, btn) {
  tipAmount = amount;
  document.querySelectorAll('.tip-btn').forEach(function(b){ b.classList.remove('sel'); });
  btn.classList.add('sel');
  updSum();
}

async function applyPromo() {
  var code = document.getElementById('promoInput').value.trim().toUpperCase();
  if (!code) { showToast('Enter a promo code'); return; }
  var result = await validatePromo(code, Cart.total(), document.getElementById('promoMsg'));
  if (result) {
    offer = { code: code, discount: result.discount / Cart.total() };
    localStorage.setItem('ydOffer', JSON.stringify(offer));
    updSum();
  }
}

// ── Static pin map — map moves, pin stays centered ────────────────
function initDeliveryMap() {
  var saved = document.getElementById('deliveryAddress').value.trim();

  deliveryMap = YDMaps.initStaticPinMap('deliveryMap',
    YDMaps.RESTAURANT.lat, YDMaps.RESTAURANT.lng, 14,
    function(addr, lat, lng) {
      currentCenter = { lat: lat, lng: lng };
      document.getElementById('mapAddrText').textContent = addr;
      document.getElementById('mapAddressResult').style.display = 'block';
    }
  );

  // If saved address, geocode and pan there
  if (saved) {
    YDMaps.geocode(saved, function(loc) {
      if (loc && deliveryMap) {
        deliveryMap.panTo(loc);
        deliveryMap.setZoom(16);
      }
    });
  } else {
    useGPSCart(); // auto-locate
  }
}

function applyMapAddress() {
  var addr = document.getElementById('mapAddrText').textContent;
  if (addr) {
    document.getElementById('deliveryAddress').value = addr;
    localStorage.setItem('ydLocation', addr);
    showToast('📍 Delivery address set!');
  }
}

function useGPSCart() {
  if (!navigator.geolocation) { showToast('GPS not supported'); return; }
  showToast('📍 Getting your location...');
  navigator.geolocation.getCurrentPosition(function(pos) {
    var lat = pos.coords.latitude, lng = pos.coords.longitude;
    if (deliveryMap) {
      deliveryMap.setCenter({ lat: lat, lng: lng });
      deliveryMap.setZoom(16);
    }
    var key = window.GOOGLE_MAPS_KEY || '';
    if (key) {
      fetch('https://maps.googleapis.com/maps/api/geocode/json?latlng=' + lat + ',' + lng + '&key=' + key)
        .then(function(r){ return r.json(); })
        .then(function(d) {
          var addr = (d.results && d.results[0]) ? d.results[0].formatted_address : lat.toFixed(5)+', '+lng.toFixed(5);
          document.getElementById('deliveryAddress').value = addr;
          localStorage.setItem('ydLocation', addr);
          showToast('📍 Location set!');
        }).catch(function(){});
    }
  }, function(e){ showToast('⚠️ ' + e.message); }, { enableHighAccuracy: true, timeout: 8000 });
}

// ── Saved locations chips ─────────────────────────────────────────
function renderSavedChips() {
  var locs = [];
  try { locs = JSON.parse(localStorage.getItem('ydSavedLocs') || '[]'); } catch(e) {}
  var c = document.getElementById('savedLocsChips');
  if (!locs.length) { c.innerHTML = ''; return; }
  var icons = { 'Home':'🏠', 'Work':'🏢', 'Office':'🏢', 'University':'🎓', 'School':'🏫' };
  c.innerHTML = '<div style="font-size:.75rem;font-weight:700;color:var(--c-muted);margin-bottom:6px;text-transform:uppercase;letter-spacing:.5px;">📌 Saved Locations</div>'
    + locs.map(function(loc, i) {
        var icon = icons[loc.name] || '📍';
        return '<button class="saved-loc-chip" onclick="useSavedChip(' + i + ')">' + icon + ' ' + loc.name + '</button>';
      }).join('');
}

function useSavedChip(i) {
  var locs = [];
  try { locs = JSON.parse(localStorage.getItem('ydSavedLocs') || '[]'); } catch(e) {}
  var loc = locs[i];
  if (!loc) return;
  document.getElementById('deliveryAddress').value = loc.address;
  if (deliveryMap && loc.lat && loc.lng) {
    deliveryMap.setCenter({ lat: loc.lat, lng: loc.lng });
    deliveryMap.setZoom(16);
  } else if (deliveryMap) {
    YDMaps.geocode(loc.address + ', Kandy, Sri Lanka', function(pos) {
      if (pos) deliveryMap.setCenter(pos);
    });
  }
  document.querySelectorAll('.saved-loc-chip').forEach(function(b){ b.classList.remove('sel'); });
  document.querySelectorAll('.saved-loc-chip')[i] && document.querySelectorAll('.saved-loc-chip')[i].classList.add('sel');
  showToast(loc.name + ' selected 📍');
}

// ── Weather ───────────────────────────────────────────────────────
async function loadWeather() {
  try {
    var r = await fetch('/api/weather');
    var w = await r.json();
    weatherExtraFee = w.extraFee || 0;
    document.getElementById('weatherIcon').textContent = w.condition.split(' ')[0];
    document.getElementById('weatherTemp').textContent = w.temp;
    document.getElementById('weatherText').textContent = w.condition + ' — Kandy';
    document.getElementById('weatherFee').textContent  = weatherExtraFee > 0 ? 'Weather surcharge: LKR ' + weatherExtraFee : 'Normal delivery fee applies';
    updSum();
  } catch(e) {}
}

// ── Pay flow ──────────────────────────────────────────────────────
function proceedPay() {
  if (!Cart.count()) { showToast('Your cart is empty!'); return; }
  var addr = document.getElementById('deliveryAddress').value.trim() ||
             document.getElementById('mapAddrText').textContent.trim() || 'Kandy, Sri Lanka';
  var sub  = Cart.total(), disc = offer ? Math.round(sub * offer.discount) : 0;
  var total = sub + 250 + weatherExtraFee + tipAmount - disc;
  document.getElementById('payTotal').textContent = 'LKR ' + Math.round(total).toLocaleString();
  document.getElementById('payTitle').textContent = payMethod === 'CARD' ? '💳 Card Payment' : '💵 Cash on Delivery';
  document.getElementById('cardFlds').style.display = payMethod === 'CARD' ? 'block' : 'none';
  document.getElementById('codFlds').style.display  = payMethod === 'COD'  ? 'block' : 'none';
  document.getElementById('procFlds').style.display = 'none';
  document.getElementById('payBtn').disabled = false;
  document.getElementById('payBtnLbl').textContent = payMethod === 'CARD' ? 'Pay LKR ' + Math.round(total).toLocaleString() : 'Confirm Order';
  new bootstrap.Modal(document.getElementById('payModal')).show();
}

async function placeOrder() {
  if (payMethod === 'CARD' && (!document.getElementById('cNum').value || !document.getElementById('cCvv').value)) {
    showToast('Fill all card details ⚠️'); return;
  }
  var addr = document.getElementById('deliveryAddress').value.trim() ||
             document.getElementById('mapAddrText').textContent.trim() || 'Kandy, Sri Lanka';
  document.getElementById('cardFlds').style.display = 'none';
  document.getElementById('codFlds').style.display  = 'none';
  document.getElementById('procFlds').style.display = 'block';
  document.getElementById('payBtn').disabled = true;
  try {
    var res = await fetch('/api/order', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        items: Cart.get().map(function(i){ return { foodId:i.id, foodName:i.name, price:i.price, quantity:i.qty, imageUrl:i.img||'' }; }),
        address: addr,
        chefNote:   document.getElementById('chefNote').value,
        driverNote: document.getElementById('driverNote').value,
        paymentMethod: payMethod,
        offerCode: offer ? offer.code : '',
        orderType: 'STANDARD',
        tip: tipAmount,
        weatherFee: weatherExtraFee
      })
    });
    var data = await res.json();
    if (data.success) {
      Cart.clear(); localStorage.removeItem('ydOffer');
      localStorage.setItem('ydLastOrder', JSON.stringify(data));
      location.href = '/thank-you?orderId=' + data.orderId;
    } else {
      showToast('Order failed: ' + (data.error || 'Try again'));
      bootstrap.Modal.getInstance(document.getElementById('payModal'))?.hide();
    }
  } catch(e) {
    showToast('Network error. Try again.');
    bootstrap.Modal.getInstance(document.getElementById('payModal'))?.hide();
  }
}

function fmtCard(i) { var v=i.value.replace(/\s+/g,'').replace(/\D/g,'');var p=[];for(var j=0;j<v.length;j+=4)p.push(v.substring(j,j+4));i.value=p.join(' '); }

// ── Init ──────────────────────────────────────────────────────────
onMapsReady(initDeliveryMap);
renderCart();
renderSavedChips();
loadWeather();
if (offer) updSum();
// Refresh weather every 5 minutes
setInterval(loadWeather, 300000);
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
