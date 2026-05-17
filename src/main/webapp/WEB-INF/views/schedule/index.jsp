<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Schedule Order"/>
<c:set var="pageId"    value="schedule"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<style>
/* ── Schedule Page Styles ── */
.sched-hero {
  background: linear-gradient(135deg, #0F0F0F 0%, #1a1a2e 100%);
  padding: 52px 0 44px;
  position: relative;
  overflow: hidden;
}
.sched-hero::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 20% 80%, rgba(255,107,53,.18) 0%, transparent 55%),
              radial-gradient(circle at 80% 20%, rgba(255,107,53,.10) 0%, transparent 50%);
}

/* Step pills */
.step-pills {
  display: flex;
  align-items: center;
  gap: 0;
  margin-bottom: 28px;
}
.step-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  background: var(--c-bg);
  border: 1.5px solid var(--c-border);
  font-size: .8rem;
  font-weight: 600;
  color: var(--c-muted);
  cursor: pointer;
  transition: all .2s;
  white-space: nowrap;
}
.step-pill:first-child { border-radius: 12px 0 0 12px; }
.step-pill:last-child  { border-radius: 0 12px 12px 0; }
.step-pill.active {
  background: var(--copper);
  border-color: var(--copper);
  color: white;
}
.step-pill .pill-num {
  width: 22px; height: 22px;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: .72rem; font-weight: 800;
  background: rgba(255,255,255,.25);
}
.step-pill.done .pill-num::after { content: '✓'; }
.step-pill.done .pill-num span   { display: none; }

/* Date + Time selection */
.time-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
}
.time-chip {
  padding: 10px 6px;
  border: 1.5px solid var(--c-border);
  border-radius: 10px;
  text-align: center;
  cursor: pointer;
  font-size: .8rem;
  font-weight: 600;
  transition: all .18s;
  background: var(--c-surface);
  user-select: none;
}
.time-chip:hover  { border-color: var(--copper); color: var(--copper); }
.time-chip.active { background: var(--copper); border-color: var(--copper); color: white; }
.time-chip.past   { opacity: .35; cursor: not-allowed; pointer-events: none; }

/* Food selector */
.sf-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--c-border);
}
.sf-item:last-child { border-bottom: none; }
.sf-img {
  width: 58px; height: 58px;
  border-radius: 12px;
  object-fit: cover;
  flex-shrink: 0;
  background: var(--c-bg);
}
.sf-qty-wrap {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}
.sf-qty-btn {
  width: 30px; height: 30px;
  border-radius: 50%;
  border: 1.5px solid var(--copper);
  background: none;
  color: var(--copper);
  font-size: 1.1rem;
  font-weight: 700;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: all .15s;
  line-height: 1;
}
.sf-qty-btn:hover { background: var(--copper); color: white; }
.sf-qty-num {
  min-width: 24px;
  text-align: center;
  font-weight: 800;
  font-size: .9rem;
}

/* Summary card */
.sum-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 5px 0;
  font-size: .875rem;
}
.sum-row.total {
  border-top: 2px solid var(--c-border);
  margin-top: 8px;
  padding-top: 10px;
  font-weight: 800;
  font-size: 1rem;
}

/* My schedules list */
.my-sched-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: 16px;
  padding: 16px 18px;
  margin-bottom: 12px;
  transition: box-shadow .2s;
}
.my-sched-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,.08); }

/* Tabs */
.sched-tabs {
  display: flex;
  gap: 4px;
  background: var(--c-bg);
  border: 1px solid var(--c-border);
  border-radius: 14px;
  padding: 4px;
  margin-bottom: 24px;
}
.sched-tab {
  flex: 1;
  padding: 11px;
  border: none;
  background: none;
  font-weight: 600;
  font-size: .875rem;
  color: var(--c-muted);
  border-radius: 10px;
  cursor: pointer;
  transition: all .2s;
}
.sched-tab.active {
  background: var(--c-surface);
  color: var(--copper);
  box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
</style>

<div class="kg-page">

  <!-- Hero -->
  <div class="sched-hero">
    <div class="container" style="position:relative;z-index:1;max-width:760px;">
      <div style="display:flex;align-items:center;gap:20px;">
        <div style="width:64px;height:64px;background:linear-gradient(135deg,var(--copper),var(--copper-d));border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:2rem;flex-shrink:0;box-shadow:0 8px 24px rgba(255,107,53,.4);">
          &#x1F4C5;
        </div>
        <div>
          <h1 style="font-family:var(--font-serif);color:white;font-size:2rem;margin-bottom:6px;line-height:1.2;">Schedule a Delivery</h1>
          <p style="color:rgba(255,255,255,.55);font-size:.9rem;margin:0;">Plan ahead. Order now, deliver on your schedule. Cancel free up to 24h before.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="container py-4" style="max-width:760px;">

    <!-- No card warning -->
    <c:if test="${empty user.cardNumber}">
    <div class="kg-card mb-4" style="border:2px solid #FFB800;background:#FFF8E1;">
      <div class="kg-card-body" style="display:flex;align-items:center;gap:14px;">
        <div style="font-size:2rem;flex-shrink:0;">&#x1F4B3;</div>
        <div style="flex:1;">
          <div style="font-weight:700;margin-bottom:3px;">Card Required for Scheduled Orders</div>
          <div style="font-size:.82rem;color:var(--c-muted);">A 50% deposit is charged at booking. Add a payment card to your account first.</div>
        </div>
        <a href="/account" class="kg-btn kg-btn-primary kg-btn-sm" style="width:auto;white-space:nowrap;">Add Card &#x2192;</a>
      </div>
    </div>
    </c:if>

    <!-- Tabs -->
    <div class="sched-tabs">
      <button class="sched-tab active" id="tabNew" onclick="showTab('new')">&#x1F4C5; New Schedule</button>
      <button class="sched-tab"        id="tabMy"  onclick="showTab('my')">&#x1F4CB; My Schedules <c:if test="${not empty scheduledOrders}"><span style="background:var(--copper);color:white;border-radius:20px;padding:1px 7px;font-size:.7rem;margin-left:4px;">${fn:length(scheduledOrders)}</span></c:if></button>
    </div>

    <!-- ════ NEW SCHEDULE PANE ════ -->
    <div id="paneNew">

      <!-- Step 1: Date & Time -->
      <div class="kg-card mb-3">
        <div class="kg-card-body">
          <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
            <div style="width:32px;height:32px;background:var(--copper);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-weight:800;font-size:.85rem;flex-shrink:0;">1</div>
            <h6 style="margin:0;font-weight:700;font-size:.95rem;">Pick Date &amp; Time</h6>
          </div>

          <div class="row g-3">
            <div class="col-md-5">
              <label class="kg-label">Delivery Date</label>
              <input type="date" id="schedDate" class="kg-input" onchange="updateSlots()">
            </div>
            <div class="col-md-7">
              <label class="kg-label">Preferred Time Slot</label>
              <div class="time-grid" id="timeGrid">
                <div class="time-chip" onclick="selectTime(this,'9:00 AM')">9:00 AM</div>
                <div class="time-chip" onclick="selectTime(this,'11:00 AM')">11:00 AM</div>
                <div class="time-chip" onclick="selectTime(this,'1:00 PM')">1:00 PM</div>
                <div class="time-chip" onclick="selectTime(this,'3:00 PM')">3:00 PM</div>
                <div class="time-chip" onclick="selectTime(this,'6:00 PM')">6:00 PM</div>
                <div class="time-chip" onclick="selectTime(this,'8:00 PM')">8:00 PM</div>
              </div>
            </div>
          </div>

          <div class="kg-form-group mt-3">
            <label class="kg-label">Delivery Address</label>
            <div style="position:relative;">
              <input type="text" id="schedAddress" class="kg-input" style="padding-right:48px;"
                     value="${fn:escapeXml(user.address)}" placeholder="Enter delivery address in Kandy District">
              <button onclick="schedGPS()" title="Use my location"
                style="position:absolute;right:10px;top:50%;transform:translateY(-50%);background:var(--copper);border:none;border-radius:8px;width:32px;height:32px;color:white;cursor:pointer;display:flex;align-items:center;justify-content:center;">
                <i class="bi bi-crosshair" style="font-size:.85rem;"></i>
              </button>
            </div>
          </div>

          <div class="kg-form-group mb-0">
            <label class="kg-label">Special Instructions <span style="color:var(--c-muted);font-weight:400;">(optional)</span></label>
            <textarea id="schedNote" class="kg-input" rows="2"
              placeholder="E.g. Ring bell, leave at door, extra napkins..." style="resize:none;"></textarea>
          </div>
        </div>
      </div>

      <!-- Step 2: Choose Items -->
      <div class="kg-card mb-3">
        <div class="kg-card-body">
          <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;">
            <div style="display:flex;align-items:center;gap:10px;">
              <div style="width:32px;height:32px;background:var(--copper);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-weight:800;font-size:.85rem;flex-shrink:0;">2</div>
              <h6 style="margin:0;font-weight:700;font-size:.95rem;">Choose Items</h6>
            </div>
            <span id="selCount" style="font-size:.78rem;color:var(--c-muted);">0 items selected</span>
          </div>

          <!-- Search -->
          <input type="text" id="sfSearch" class="kg-input" placeholder="&#x1F50D; Search menu items..."
            style="margin-bottom:12px;" oninput="filterSfItems()">

          <div style="max-height:340px;overflow-y:auto;padding-right:4px;" id="sfList">
            <c:choose>
              <c:when test="${not empty foods}">
                <c:forEach items="${foods}" var="f">
                <c:if test="${f.available}">
                <div class="sf-item" data-name="${fn:toLowerCase(f.name)}" data-cat="${fn:toLowerCase(f.category)}">
                  <img class="sf-img" src="${f.imageUrl}" alt="${f.name}"
                       onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120&q=80'">
                  <div style="flex:1;min-width:0;">
                    <div style="font-weight:700;font-size:.875rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${f.name}</div>
                    <div style="font-size:.75rem;color:var(--c-muted);">${f.category}</div>
                    <div style="font-size:.82rem;font-weight:700;color:var(--copper);">LKR <fmt:formatNumber value="${f.price}" pattern="#,##0"/></div>
                  </div>
                  <div class="sf-qty-wrap">
                    <button class="sf-qty-btn" onclick="sfQty('${f.id}',-1)">&#x2212;</button>
                    <span class="sf-qty-num" id="sq${f.id}">0</span>
                    <button class="sf-qty-btn"
                      data-fid="${f.id}"
                      data-fname="${fn:escapeXml(f.name)}"
                      data-fprice="${f.price}"
                      data-fimg="${f.imageUrl}"
                      onclick="sfQtyAdd(this)">+</button>
                  </div>
                </div>
                </c:if>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div style="text-align:center;padding:32px;color:var(--c-muted);">No items available right now.</div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>

      <!-- Step 3: Review & Book -->
      <div class="kg-card mb-4">
        <div class="kg-card-body">
          <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;">
            <div style="width:32px;height:32px;background:var(--copper);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-weight:800;font-size:.85rem;flex-shrink:0;">3</div>
            <h6 style="margin:0;font-weight:700;font-size:.95rem;">Review &amp; Book</h6>
          </div>

          <!-- Live summary -->
          <div id="schedSummary" style="min-height:48px;margin-bottom:16px;">
            <div style="color:var(--c-muted);font-size:.875rem;text-align:center;padding:16px 0;">
              &#x2197; Select items above to see your order summary
            </div>
          </div>

          <!-- Deposit notice -->
          <div style="background:var(--copper-l);border:1px solid rgba(255,107,53,.25);border-radius:12px;padding:12px 16px;margin-bottom:16px;font-size:.82rem;display:flex;align-items:flex-start;gap:10px;">
            <i class="bi bi-info-circle-fill" style="color:var(--copper);font-size:1rem;margin-top:1px;flex-shrink:0;"></i>
            <div>A <strong>50% deposit</strong> will be charged to your saved card at booking. The remaining balance is collected on delivery. <strong>Cancel free up to 24 hours before.</strong></div>
          </div>

          <button onclick="placeScheduled()" class="kg-btn kg-btn-primary" id="schedBtn"
            style="font-size:.95rem;padding:14px;">
            <i class="bi bi-calendar-check me-2"></i>Book Scheduled Order
          </button>
          <c:if test="${empty user.cardNumber}">
            <script>
              document.addEventListener('DOMContentLoaded', function(){
                var b = document.getElementById('schedBtn');
                if(b){ b.disabled=true; b.style.opacity='.5'; b.style.cursor='not-allowed'; b.title='Add a card to your account first'; }
              });
            </script>
          </c:if>
        </div>
      </div>
    </div><!-- /paneNew -->

    <!-- ════ MY SCHEDULES PANE ════ -->
    <div id="paneMy" style="display:none;">
      <c:choose>
        <c:when test="${not empty scheduledOrders}">
          <c:forEach items="${scheduledOrders}" var="so">
          <div class="my-sched-card">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;flex-wrap:wrap;">
              <div style="flex:1;min-width:0;">
                <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
                  <span style="font-family:monospace;font-weight:800;font-size:.9rem;color:var(--c-text);">#${so.orderId}</span>
                  <c:choose>
                    <c:when test="${so.status=='PENDING'}">
                      <span style="background:#FFF3E0;color:#E65100;padding:2px 10px;border-radius:20px;font-size:.68rem;font-weight:700;">&#x23F3; Pending</span>
                    </c:when>
                    <c:when test="${so.status=='CANCELLED'}">
                      <span style="background:#FFEBEE;color:#C62828;padding:2px 10px;border-radius:20px;font-size:.68rem;font-weight:700;">&#x274C; Cancelled</span>
                    </c:when>
                    <c:otherwise>
                      <span style="background:#E8F5E9;color:#2E7D32;padding:2px 10px;border-radius:20px;font-size:.68rem;font-weight:700;">&#x2705; ${so.status}</span>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div style="font-size:.82rem;color:var(--c-muted);margin-bottom:3px;">
                  <i class="bi bi-calendar3 me-1" style="color:var(--copper);"></i>
                  ${fn:length(so.scheduledFor) > 0 ? so.scheduledFor : 'Time not set'}
                </div>
                <div style="font-size:.78rem;color:var(--c-muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                  <i class="bi bi-geo-alt-fill me-1" style="color:var(--copper);"></i>${so.deliveryAddress}
                </div>
              </div>
              <div style="text-align:right;flex-shrink:0;">
                <div style="font-weight:800;color:var(--copper);font-size:.95rem;">LKR <fmt:formatNumber value="${so.totalAmount}" pattern="#,##0"/></div>
                <div style="font-size:.72rem;color:var(--c-muted);margin-top:2px;">${fn:length(so.items)} item(s)</div>
              </div>
            </div>

            <!-- Items preview -->
            <c:if test="${not empty so.items}">
            <div style="margin-top:10px;padding-top:10px;border-top:1px solid var(--c-border);display:flex;flex-wrap:wrap;gap:6px;">
              <c:forEach items="${so.items}" var="item" end="3">
                <span style="background:var(--c-bg);border:1px solid var(--c-border);border-radius:8px;padding:3px 10px;font-size:.72rem;font-weight:600;">${item.foodName} &#xD7;${item.quantity}</span>
              </c:forEach>
              <c:if test="${fn:length(so.items) > 4}">
                <span style="background:var(--c-bg);border:1px solid var(--c-border);border-radius:8px;padding:3px 10px;font-size:.72rem;color:var(--c-muted);">+${fn:length(so.items)-4} more</span>
              </c:if>
            </div>
            </c:if>

            <!-- Cancel button -->
            <c:if test="${so.status == 'PENDING'}">
            <div style="margin-top:12px;">
              <form action="/api/scheduled-orders/${so.orderId}/cancel" method="post"
                    onsubmit="return confirm('Cancel order #${so.orderId}? This cannot be undone.')">
                <button type="submit" class="kg-btn kg-btn-sm"
                  style="background:#FFEBEE;color:#C62828;border:1px solid #FFCDD2;width:auto;padding:7px 16px;">
                  <i class="bi bi-x-circle me-1"></i>Cancel Order
                </button>
              </form>
            </div>
            </c:if>
          </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div style="text-align:center;padding:56px 20px;color:var(--c-muted);">
            <div style="font-size:4rem;margin-bottom:16px;">&#x1F4EB;</div>
            <h5 style="color:var(--c-text);margin-bottom:8px;">No Scheduled Orders Yet</h5>
            <p style="font-size:.875rem;max-width:300px;margin:0 auto 20px;">Plan ahead &mdash; schedule a delivery for any date up to 7 days in advance.</p>
            <button onclick="showTab('new')" class="kg-btn kg-btn-primary" style="width:auto;padding:10px 24px;">
              <i class="bi bi-plus-lg me-1"></i>Create Schedule
            </button>
          </div>
        </c:otherwise>
      </c:choose>
    </div><!-- /paneMy -->

  </div>
</div>

<script>
var sfItems   = {};   // foodId -> {name, price, img, qty}
var selTime   = '';

// ── Tabs ─────────────────────────────────────────────────────────
function showTab(name) {
  document.getElementById('paneNew').style.display = name === 'new' ? 'block' : 'none';
  document.getElementById('paneMy').style.display  = name === 'my'  ? 'block' : 'none';
  document.getElementById('tabNew').classList.toggle('active', name === 'new');
  document.getElementById('tabMy').classList.toggle('active',  name === 'my');
}

// ── Set minimum date to tomorrow ─────────────────────────────────
(function() {
  var d = new Date();
  d.setDate(d.getDate() + 1);
  var inp = document.getElementById('schedDate');
  if (!inp) return;
  var iso = d.toISOString().split('T')[0];
  inp.min = iso;
  // Max 7 days ahead
  var max = new Date(); max.setDate(max.getDate() + 7);
  inp.max = max.toISOString().split('T')[0];
  inp.value = iso;
  updateSlots();
})();

// ── Time slots ───────────────────────────────────────────────────
var SLOTS = ['9:00 AM','11:00 AM','1:00 PM','3:00 PM','6:00 PM','8:00 PM'];

function updateSlots() {
  var grid = document.getElementById('timeGrid');
  if (!grid) return;
  // Regenerate all slots as selectable (date picker min is tomorrow, so never past)
  grid.innerHTML = SLOTS.map(function(slot) {
    return '<div class="time-chip" onclick="selectTime(this,\'' + slot + '\')">' + slot + '</div>';
  }).join('');
  selTime = '';
}

function selectTime(el, time) {
  document.querySelectorAll('#timeGrid .time-chip').forEach(function(c) {
    c.classList.remove('active');
  });
  el.classList.add('active');
  selTime = time;
}

// ── GPS for address ───────────────────────────────────────────────
function schedGPS() {
  if (!navigator.geolocation) { if(typeof showToast!=='undefined') showToast('GPS not supported'); return; }
  if(typeof showToast!=='undefined') showToast('Getting location...');
  navigator.geolocation.getCurrentPosition(function(p) {
    if (typeof YDMaps !== 'undefined') {
      YDMaps.reverseGeocode(p.coords.latitude, p.coords.longitude, function(addr) {
        document.getElementById('schedAddress').value = addr;
      });
    } else {
      document.getElementById('schedAddress').value = p.coords.latitude.toFixed(5) + ', ' + p.coords.longitude.toFixed(5);
    }
  }, function(){ if(typeof showToast!=='undefined') showToast('Location access denied'); });
}

// ── Food item quantity ────────────────────────────────────────────
function sfQtyAdd(btn) {
  sfQty(btn.dataset.fid, 1, btn.dataset.fname, parseFloat(btn.dataset.fprice), btn.dataset.fimg || '');
}

function sfQty(id, delta, name, price, img) {
  if (delta > 0 && !sfItems[id]) {
    sfItems[id] = { name: name || id, price: price || 0, img: img || '', qty: 0 };
  }
  if (!sfItems[id]) return;
  sfItems[id].qty = Math.max(0, sfItems[id].qty + delta);
  if (sfItems[id].qty === 0) delete sfItems[id];
  var el = document.getElementById('sq' + id);
  if (el) el.textContent = sfItems[id] ? sfItems[id].qty : 0;
  updateSummary();
}

function filterSfItems() {
  var q = document.getElementById('sfSearch').value.toLowerCase().trim();
  document.querySelectorAll('#sfList .sf-item').forEach(function(row) {
    var n = (row.dataset.name || '') + (row.dataset.cat || '');
    row.style.display = (!q || n.includes(q)) ? '' : 'none';
  });
}

// ── Summary ───────────────────────────────────────────────────────
function updateSummary() {
  var items = Object.values(sfItems);
  var count = items.reduce(function(s,i){ return s + i.qty; }, 0);
  var sub   = items.reduce(function(s,i){ return s + i.price * i.qty; }, 0);
  var dep   = sub * 0.5;

  // Update count chip
  var cc = document.getElementById('selCount');
  if (cc) cc.textContent = count + ' item' + (count !== 1 ? 's' : '') + ' selected';

  var el = document.getElementById('schedSummary');
  if (!el) return;

  if (!items.length) {
    el.innerHTML = '<div style="color:var(--c-muted);font-size:.875rem;text-align:center;padding:16px 0;">&#x2197; Select items above to see your order summary</div>';
    return;
  }

  var html = '<div style="margin-bottom:12px;">';
  items.forEach(function(i) {
    html += '<div class="sum-row">'
      + '<span style="color:var(--c-text2);">' + i.name + ' &times;' + i.qty + '</span>'
      + '<span style="font-weight:600;">LKR ' + Math.round(i.price * i.qty).toLocaleString() + '</span>'
      + '</div>';
  });
  html += '</div>'
    + '<div class="sum-row" style="color:var(--c-muted);"><span>Delivery Fee</span><span>LKR 250</span></div>'
    + '<div class="sum-row total"><span>Total</span><span style="color:var(--copper);">LKR ' + Math.round(sub + 250).toLocaleString() + '</span></div>'
    + '<div style="margin-top:8px;padding:8px 12px;background:var(--copper-l);border-radius:8px;font-size:.78rem;color:var(--copper);font-weight:600;">'
    + '&#x1F4B3; 50% deposit now: <strong>LKR ' + Math.round(dep).toLocaleString() + '</strong> &nbsp;|&nbsp; Remainder on delivery: LKR ' + Math.round(sub + 250 - dep).toLocaleString()
    + '</div>';

  el.innerHTML = html;
}

// ── Place order ───────────────────────────────────────────────────
async function placeScheduled() {
  var items   = Object.keys(sfItems).map(function(id) {
    return { foodId: id, foodName: sfItems[id].name, price: sfItems[id].price, quantity: sfItems[id].qty };
  });
  var date    = document.getElementById('schedDate').value;
  var addr    = document.getElementById('schedAddress').value.trim();
  var note    = document.getElementById('schedNote').value.trim();

  if (!items.length)  { if(typeof showToast!=='undefined') showToast('Add at least one item &#x26A0;&#xFE0F;'); return; }
  if (!date)          { if(typeof showToast!=='undefined') showToast('Select a delivery date &#x1F4C5;'); return; }
  if (!selTime)       { if(typeof showToast!=='undefined') showToast('Select a time slot &#x23F0;'); return; }
  if (!addr)          { if(typeof showToast!=='undefined') showToast('Enter delivery address &#x1F4CD;'); return; }

  var btn = document.getElementById('schedBtn');
  if (btn) { btn.innerHTML = '<span style="animation:spin .6s linear infinite;display:inline-block;">&#x23F3;</span> Booking...'; btn.disabled = true; }

  try {
    var r = await fetch('/api/order', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        items: items,
        deliveryAddress: addr,
        chefNote: note,
        paymentMethod: 'CARD',
        orderType: 'SCHEDULED',
        scheduledFor: date + ' ' + selTime
      })
    });
    var d = await r.json();
    if (d.orderId) {
      if(typeof showToast!=='undefined') showToast('&#x2705; Scheduled! Order #' + d.orderId);
      setTimeout(function(){ location.href = '/schedule?tab=my'; }, 1600);
    } else {
      if(typeof showToast!=='undefined') showToast(d.error || 'Booking failed. Try again.');
      if (btn) { btn.innerHTML = '<i class="bi bi-calendar-check me-2"></i>Book Scheduled Order'; btn.disabled = false; }
    }
  } catch(e) {
    if(typeof showToast!=='undefined') showToast('Network error. Please try again.');
    if (btn) { btn.innerHTML = '<i class="bi bi-calendar-check me-2"></i>Book Scheduled Order'; btn.disabled = false; }
  }
}

// ── Auto-switch tab from URL ─────────────────────────────────────
(function() {
  if (location.search.includes('tab=my')) showTab('my');
})();
</script>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
