<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Schedule Order"/>
<c:set var="pageId"    value="schedule"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.sched-hero{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:48px 0;position:relative;overflow:hidden;}
.sched-hero::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 30% 70%,rgba(255,107,53,.15) 0%,transparent 55%);}
.time-slot{padding:11px 16px;border:1.5px solid var(--c-border);border-radius:10px;cursor:pointer;font-size:.85rem;font-weight:600;transition:all .2s;text-align:center;background:var(--c-surface);}
.time-slot:hover,.time-slot.active{background:var(--c-orange);color:white;border-color:var(--c-orange);}
.time-slot.disabled{opacity:.4;cursor:not-allowed;background:var(--c-bg);}
.sched-food{display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid var(--c-border);}
.sched-food:last-child{border-bottom:none;}
.sched-row{background:var(--c-surface);border:1px solid var(--c-border);border-radius:14px;padding:14px 16px;margin-bottom:10px;}
</style>

<div class="yd-page">
  <!-- Hero -->
  <div class="sched-hero">
    <div class="container" style="position:relative;z-index:1;max-width:720px;">
      <div style="display:flex;align-items:center;gap:20px;">
        <div style="font-size:4rem;animation:float 3s ease-in-out infinite;">📅</div>
        <div>
          <h1 style="font-family:var(--font-display);color:white;font-size:2.2rem;margin-bottom:6px;">Schedule Orders</h1>
          <p style="color:rgba(255,255,255,.6);font-size:.95rem;margin:0;">Plan ahead. Order now, deliver later. Perfect for meetings and events.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="container py-4" style="max-width:720px;">

    <!-- Card required notice -->
    <c:if test="${not user.hasCard()}">
    <div class="yd-card mb-4" style="border:2px solid #FFB800;background:#FFF8E1;">
      <div class="yd-card-body" style="display:flex;align-items:center;gap:14px;">
        <span style="font-size:2rem;">💳</span>
        <div style="flex:1;">
          <div style="font-weight:700;margin-bottom:3px;">Card Required for Scheduled Orders</div>
          <div style="font-size:.82rem;color:var(--c-muted);">A 50% deposit is charged at booking. Add a payment card to your account first.</div>
        </div>
        <a href="/account" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;white-space:nowrap;">Add Card →</a>
      </div>
    </div>
    </c:if>

    <!-- Tabs -->
    <div style="display:flex;gap:3px;background:var(--c-bg);border:1px solid var(--c-border);border-radius:14px;padding:4px;margin-bottom:24px;">
      <button class="tab-btn active" id="stNew" onclick="showSchedTab('new',this)" style="flex:1;padding:11px;border:none;background:var(--c-surface);font-weight:700;font-size:.875rem;color:var(--c-orange);border-radius:10px;cursor:pointer;">📅 New Schedule</button>
      <button class="tab-btn"        id="stMy"  onclick="showSchedTab('my',this)"  style="flex:1;padding:11px;border:none;background:none;font-weight:500;font-size:.875rem;color:var(--c-muted);cursor:pointer;">📋 My Schedules</button>
    </div>

    <!-- NEW SCHEDULE -->
    <div id="paneNew">

      <!-- Step 1: Date & Time -->
      <div class="yd-card mb-3 yd-fade">
        <div class="yd-card-body">
          <h6 class="fw-bold mb-3">1️⃣ Pick Date &amp; Time</h6>
          <div class="row g-3 mb-3">
            <div class="col-md-6 yd-form-group">
              <label class="yd-label">Delivery Date</label>
              <input type="date" id="schedDate" class="yd-input" onchange="updateTimeSlots()">
            </div>
            <div class="col-md-6 yd-form-group">
              <label class="yd-label">Preferred Time</label>
              <div class="row g-2" id="timeSlots">
                <div class="col-4"><div class="time-slot disabled">9:00 AM</div></div>
                <div class="col-4"><div class="time-slot disabled">11:00 AM</div></div>
                <div class="col-4"><div class="time-slot disabled">1:00 PM</div></div>
                <div class="col-4"><div class="time-slot disabled">3:00 PM</div></div>
                <div class="col-4"><div class="time-slot disabled">6:00 PM</div></div>
                <div class="col-4"><div class="time-slot disabled">8:00 PM</div></div>
              </div>
            </div>
          </div>
          <div class="yd-form-group">
            <label class="yd-label">Delivery Address</label>
            <input type="text" id="schedAddress" class="yd-input"
                   value="${user.address}" placeholder="Your delivery address in Kandy">
          </div>
          <div class="yd-form-group mb-0">
            <label class="yd-label">Special Instructions (optional)</label>
            <textarea id="schedNote" class="yd-input" rows="2" placeholder="E.g. Leave at door, ring bell twice..." style="resize:none;"></textarea>
          </div>
        </div>
      </div>

      <!-- Step 2: Select Food -->
      <div class="yd-card mb-3 yd-fade">
        <div class="yd-card-body">
          <h6 class="fw-bold mb-3">2️⃣ Choose Items</h6>
          <c:choose>
            <c:when test="${not empty foods}">
              <div style="max-height:320px;overflow-y:auto;" id="schedFoodList">
                <c:forEach items="${foods}" var="f">
                <c:if test="${f.available}">
                <div class="sched-food">
                  <img src="${f.imageUrl}" style="width:52px;height:52px;border-radius:10px;object-fit:cover;flex-shrink:0;" onerror="this.style.display='none'">
                  <div style="flex:1;">
                    <div style="font-weight:600;font-size:.875rem;">${f.name}</div>
                    <div style="font-size:.78rem;color:var(--c-orange);font-weight:700;">LKR <fmt:formatNumber value="${f.price}" pattern="#,##0"/></div>
                  </div>
                  <div style="display:flex;align-items:center;gap:8px;">
                    <button onclick="schedQty('${f.id}',-1)" style="width:28px;height:28px;border-radius:50%;border:1.5px solid var(--c-orange);background:none;color:var(--c-orange);font-size:1rem;cursor:pointer;font-weight:700;transition:all .15s;" onmouseover="this.style.background='var(--c-orange)';this.style.color='white'" onmouseout="this.style.background='none';this.style.color='var(--c-orange)'">−</button>
                    <span id="sq${f.id}" style="font-weight:800;min-width:20px;text-align:center;font-size:.9rem;">0</span>
                    <button onclick="schedQty('${f.id}',1,'${fn:replace(f.name,\"'\",\"\")}',${f.price},'${f.imageUrl}')" style="width:28px;height:28px;border-radius:50%;border:1.5px solid var(--c-orange);background:none;color:var(--c-orange);font-size:1rem;cursor:pointer;font-weight:700;transition:all .15s;" onmouseover="this.style.background='var(--c-orange)';this.style.color='white'" onmouseout="this.style.background='none';this.style.color='var(--c-orange)'">+</button>
                  </div>
                </div>
                </c:if>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <p style="color:var(--c-muted);text-align:center;padding:20px;">No food items available right now.</p>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- Summary & Place -->
      <div class="yd-card mb-3 yd-fade">
        <div class="yd-card-body">
          <h6 class="fw-bold mb-3">3️⃣ Review &amp; Book</h6>
          <div id="schedSummary" style="margin-bottom:16px;color:var(--c-muted);font-size:.875rem;">No items selected yet</div>
          <div style="background:var(--c-orange-l);border:1px solid rgba(255,107,53,.2);border-radius:12px;padding:12px 16px;margin-bottom:18px;font-size:.82rem;">
            <i class="bi bi-info-circle me-2" style="color:var(--c-orange);"></i>
            A <strong>50% deposit</strong> will be charged to your saved card at booking. Remaining balance on delivery.
          </div>
          <button onclick="placeScheduled()" class="yd-btn yd-btn-primary" id="schedBtn"
                  ${not user.hasCard() ? 'disabled style="opacity:.6;cursor:not-allowed;"' : ''}>
            <i class="bi bi-calendar-check me-2"></i>Book Scheduled Order
          </button>
        </div>
      </div>
    </div>

    <!-- MY SCHEDULES -->
    <div id="paneMy" style="display:none;">
      <c:choose>
        <c:when test="${not empty scheduledOrders}">
          <c:forEach items="${scheduledOrders}" var="so">
          <div class="sched-row yd-fade">
            <div class="d-flex justify-content-between align-items-start mb-2">
              <div>
                <div style="font-family:monospace;font-weight:700;color:var(--c-text);">#${so.orderId}</div>
                <div style="font-size:.75rem;color:var(--c-muted);">${so.scheduledFor}</div>
              </div>
              <div class="d-flex align-items-center gap-2">
                <span style="background:${so.status=='PENDING'?'#FFF3E0':'#E8F5E9'};color:${so.status=='PENDING'?'#E65100':'#2E7D32'};padding:3px 10px;border-radius:20px;font-size:.72rem;font-weight:700;">${so.status}</span>
                <span style="font-weight:700;color:var(--c-orange);">LKR <fmt:formatNumber value="${so.totalAmount}" pattern="#,##0"/></span>
              </div>
            </div>
            <div style="font-size:.78rem;color:var(--c-muted);">📍 ${so.deliveryAddress}</div>
            <c:if test="${so.status == 'PENDING'}">
            <form action="/api/scheduled-orders/${so.orderId}/cancel" method="post" style="margin-top:10px;" onsubmit="return confirm('Cancel this scheduled order?')">
              <button type="submit" style="background:#FFEBEE;color:#C62828;border:none;border-radius:8px;padding:6px 14px;font-size:.75rem;font-weight:700;cursor:pointer;">✕ Cancel</button>
            </form>
            </c:if>
          </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div style="text-align:center;padding:48px 20px;color:var(--c-muted);">
            <div style="font-size:3.5rem;margin-bottom:14px;">📭</div>
            <h5 style="color:var(--c-text);margin-bottom:8px;">No Scheduled Orders</h5>
            <p style="font-size:.875rem;">Plan ahead — schedule a delivery for a specific date and time.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</div>

<script>
var schedSelected = {};  // foodId -> {name, price, img, qty}
var selectedTime  = '';

function showSchedTab(name, btn) {
  document.getElementById('paneNew').style.display = name==='new' ? 'block' : 'none';
  document.getElementById('paneMy').style.display  = name==='my'  ? 'block' : 'none';
  document.getElementById('stNew').style.cssText = 'flex:1;padding:11px;border:none;background:'+(name==='new'?'var(--c-surface)':'none')+';font-weight:'+(name==='new'?'700':'500')+';font-size:.875rem;color:'+(name==='new'?'var(--c-orange)':'var(--c-muted)')+';cursor:pointer;border-radius:10px;';
  document.getElementById('stMy').style.cssText  = 'flex:1;padding:11px;border:none;background:'+(name==='my'?'var(--c-surface)':'none')+';font-weight:'+(name==='my'?'700':'500')+';font-size:.875rem;color:'+(name==='my'?'var(--c-orange)':'var(--c-muted)')+';cursor:pointer;border-radius:10px;';
}

// Set min date to tomorrow
(function() {
  var d = new Date(); d.setDate(d.getDate() + 1);
  var dateInput = document.getElementById('schedDate');
  if (dateInput) {
    dateInput.min = d.toISOString().split('T')[0];
    dateInput.value = d.toISOString().split('T')[0];
    updateTimeSlots();
  }
})();

function updateTimeSlots() {
  var slots = document.querySelectorAll('#timeSlots .time-slot');
  slots.forEach(function(s) {
    s.classList.remove('disabled','active');
    s.onclick = function() {
      document.querySelectorAll('#timeSlots .time-slot').forEach(function(x){ x.classList.remove('active'); });
      s.classList.add('active');
      selectedTime = s.textContent.trim();
    };
  });
}

function schedQty(id, delta, name, price, img) {
  if (!schedSelected[id] && delta > 0)
    schedSelected[id] = { name: name, price: price, img: img, qty: 0 };
  if (!schedSelected[id]) return;
  schedSelected[id].qty = Math.max(0, schedSelected[id].qty + delta);
  if (schedSelected[id].qty === 0) delete schedSelected[id];
  var el = document.getElementById('sq' + id);
  if (el) el.textContent = schedSelected[id] ? schedSelected[id].qty : 0;
  updateSchedSummary();
}

function updateSchedSummary() {
  var items = Object.values(schedSelected);
  var total = items.reduce(function(s,i){ return s + i.price * i.qty; }, 0);
  var el = document.getElementById('schedSummary');
  if (!items.length) { el.innerHTML = '<span style="color:var(--c-muted);">No items selected yet</span>'; return; }
  el.innerHTML = items.map(function(i){
    return '<div style="display:flex;justify-content:space-between;padding:4px 0;font-size:.875rem;">'
      + '<span>' + i.name + ' ×' + i.qty + '</span>'
      + '<span style="font-weight:700;">LKR ' + Math.round(i.price*i.qty).toLocaleString() + '</span>'
      + '</div>';
  }).join('')
  + '<div style="display:flex;justify-content:space-between;border-top:2px solid var(--c-border);padding-top:8px;margin-top:8px;font-weight:800;">'
  + '<span>Total</span><span style="color:var(--c-orange);">LKR ' + Math.round(total).toLocaleString() + '</span></div>'
  + '<div style="color:var(--c-muted);font-size:.75rem;margin-top:4px;">50% deposit: LKR ' + Math.round(total*0.5).toLocaleString() + '</div>';
}

async function placeScheduled() {
  var items  = Object.keys(schedSelected).map(function(id){ return { foodId:id, foodName:schedSelected[id].name, price:schedSelected[id].price, quantity:schedSelected[id].qty }; });
  var date   = document.getElementById('schedDate').value;
  var addr   = document.getElementById('schedAddress').value.trim();
  var note   = document.getElementById('schedNote').value.trim();
  if (!items.length)  { showToast('Add at least one item'); return; }
  if (!date)          { showToast('Select a delivery date'); return; }
  if (!selectedTime)  { showToast('Select a delivery time'); return; }
  if (!addr)          { showToast('Enter delivery address'); return; }

  var btn = document.getElementById('schedBtn');
  btn.innerHTML = '<span class="spin me-2">⏳</span>Booking...'; btn.disabled = true;

  try {
    var r = await fetch('/api/order', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        items: items, deliveryAddress: addr, chefNote: note,
        paymentMethod: 'CARD', orderType: 'SCHEDULED',
        scheduledFor: date + ' ' + selectedTime
      })
    });
    var d = await r.json();
    if (d.orderId) {
      showToast('✅ Scheduled! Order #' + d.orderId);
      setTimeout(function(){ location.href = '/activity'; }, 1500);
    } else { showToast(d.error || 'Booking failed. Try again.'); }
  } catch(e) { showToast('Network error.'); }

  btn.innerHTML = '<i class="bi bi-calendar-check me-2"></i>Book Scheduled Order';
  btn.disabled = false;
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
