<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Order Placed!"/>
<c:set var="pageId"    value="thankyou"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.ty-wrap{min-height:calc(100vh - 66px);display:flex;align-items:center;justify-content:center;padding:32px 16px;background:var(--c-bg);}
.ty-card{max-width:520px;width:100%;animation:scaleIn .5s var(--ease) both;}
.confetti{position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:1;overflow:hidden;}
.confetti-piece{position:absolute;width:10px;height:10px;border-radius:2px;animation:confettiFall linear forwards;}
@keyframes confettiFall{from{transform:translateY(-20px) rotate(0);opacity:1}to{transform:translateY(100vh) rotate(720deg);opacity:0}}
.eta-timer{font-size:2.4rem;font-weight:800;color:var(--c-orange);font-family:monospace;}
.step-row{display:flex;align-items:center;gap:14px;padding:11px 0;border-bottom:1px solid var(--c-border);transition:all .4s;}
.step-row:last-child{border-bottom:none;}
.step-dot{width:36px;height:36px;border-radius:50%;border:2.5px solid var(--c-border);display:flex;align-items:center;justify-content:center;font-size:1rem;flex-shrink:0;transition:all .4s var(--ease);}
.step-row.done .step-dot{background:var(--c-orange);border-color:var(--c-orange);color:white;}
.step-row.active .step-dot{border-color:var(--c-orange);background:var(--c-orange-l);animation:pulse 2s ease-in-out infinite;}
.step-row.pending{opacity:.4;}
</style>

<div class="confetti" id="confettiCanvas"></div>
<div class="ty-wrap">
  <div class="ty-card">
    <!-- Success -->
    <div class="yd-card mb-4" style="text-align:center;">
      <div class="yd-card-body" style="padding:36px 28px;">
        <div class="yd-success-icon" style="font-size:5rem;margin-bottom:16px;">🎉</div>
        <h1 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:8px;">Order Placed!</h1>
        <p style="color:var(--c-muted);margin-bottom:20px;">Your food is being prepared with love 🍳</p>
        <!-- ETA countdown -->
        <div style="background:var(--c-orange-l);border-radius:16px;padding:16px;border:1px solid rgba(255,107,53,.2);">
          <div style="font-size:.75rem;font-weight:700;color:var(--c-orange);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;">Estimated Delivery</div>
          <div class="eta-timer" id="etaDisplay">--:--</div>
          <div style="font-size:.8rem;color:var(--c-muted);margin-top:4px;">arrives in approx. 25–35 minutes</div>
        </div>
      </div>
    </div>

    <!-- Order details -->
    <div class="yd-card mb-3">
      <div class="yd-card-body">
        <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--c-border);font-size:.9rem;">
          <span style="color:var(--c-muted);">Order ID</span>
          <strong style="color:var(--c-text);font-family:monospace;" id="tyOrderId">#---</strong>
        </div>
        <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--c-border);font-size:.9rem;">
          <span style="color:var(--c-muted);">Total Paid</span>
          <strong style="color:var(--c-orange);" id="tyTotal">LKR 0</strong>
        </div>
        <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--c-border);font-size:.9rem;">
          <span style="color:var(--c-muted);">Payment</span>
          <strong id="tyPayment">—</strong>
        </div>
        <div style="display:flex;justify-content:space-between;padding:8px 0;font-size:.9rem;">
          <span style="color:var(--c-muted);">Loyalty Points Earned</span>
          <strong style="color:#FFB800;" id="tyPoints">⭐ —</strong>
        </div>
      </div>
    </div>

    <!-- Live tracking steps -->
    <div class="yd-card mb-3">
      <div class="yd-card-body">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 style="font-weight:700;margin:0;">Live Order Status</h6>
          <span class="yd-live-badge"><span class="yd-live-dot"></span>Tracking</span>
        </div>
        <div id="trackSteps">
          <div class="step-row done" id="s1"><div class="step-dot">✓</div><div><div style="font-weight:600;font-size:.875rem;">Order confirmed</div><div style="font-size:.75rem;color:var(--c-muted);">We got your order!</div></div></div>
          <div class="step-row active" id="s2"><div class="step-dot">🍳</div><div><div style="font-weight:600;font-size:.875rem;">Kitchen preparing</div><div style="font-size:.75rem;color:var(--c-muted);">Your food is being cooked</div></div></div>
          <div class="step-row pending" id="s3"><div class="step-dot">📦</div><div><div style="font-weight:600;font-size:.875rem;">Ready for pickup</div><div style="font-size:.75rem;color:var(--c-muted);">Packed and waiting for driver</div></div></div>
          <div class="step-row pending" id="s4"><div class="step-dot">🛵</div><div><div style="font-weight:600;font-size:.875rem;">On the way</div><div style="font-size:.75rem;color:var(--c-muted);">Driver heading to you</div></div></div>
          <div class="step-row pending" id="s5"><div class="step-dot">🏠</div><div><div style="font-weight:600;font-size:.875rem;">Delivered!</div><div style="font-size:.75rem;color:var(--c-muted);">Enjoy your meal</div></div></div>
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div class="d-flex gap-2 mb-3">
      <a href="/activity" class="yd-btn yd-btn-primary" style="flex:1;"><i class="bi bi-map me-2"></i>Track Live</a>
      <button class="yd-wa-btn" id="waBtn" style="flex:1;justify-content:center;"><span>📱</span> Share</button>
    </div>
    <a href="/menu" class="yd-btn yd-btn-outline" style="display:flex;justify-content:center;color:var(--c-muted);">
      <i class="bi bi-arrow-left me-2"></i>Back to Menu
    </a>
  </div>
</div>

<script>
var order = JSON.parse(localStorage.getItem('ydLastOrder') || '{}');

// Fill order details
if (order.orderId) {
  document.getElementById('tyOrderId').textContent = '#' + order.orderId;
  document.getElementById('tyTotal').textContent   = 'LKR ' + Math.round(order.total || 0).toLocaleString();
  document.getElementById('tyPayment').textContent = order.paymentMethod || 'COD';
  document.getElementById('tyPoints').textContent  = '⭐ +' + (order.loyaltyPoints || 0) + ' pts';
}

// WhatsApp share
document.getElementById('waBtn').onclick = function() {
  shareOnWhatsApp(order.orderId || '', Cart.get(), order.total || 0);
};

// ETA countdown
(function() {
  var mins = 30, secs = 0;
  var el = document.getElementById('etaDisplay');
  function update() {
    el.textContent = String(mins).padStart(2,'0') + ':' + String(secs).padStart(2,'0');
    if (secs > 0) secs--;
    else if (mins > 0) { mins--; secs = 59; }
  }
  update();
  setInterval(update, 1000);
})();

// Confetti
(function() {
  var canvas = document.getElementById('confettiCanvas');
  var colors = ['#FF6B35','#f7971e','#22C55E','#3B82F6','#FFB800','#f093fb'];
  for (var i = 0; i < 60; i++) {
    var p = document.createElement('div');
    p.className = 'confetti-piece';
    var size = 6 + Math.random() * 8;
    p.style.cssText = 'left:' + Math.random()*100 + '%;top:-20px;width:' + size + 'px;height:' + size + 'px;background:' + colors[Math.floor(Math.random()*colors.length)] + ';animation-duration:' + (2+Math.random()*3) + 's;animation-delay:' + Math.random()*2 + 's;border-radius:' + (Math.random()>0.5?'50%':'2px') + ';';
    canvas.appendChild(p);
  }
  setTimeout(function() { canvas.style.display = 'none'; }, 6000);
})();

// Live polling
var orderId = order.orderId;
if (orderId) {
  YDPush.request();
  YDPush.orderPlaced(orderId);
  YDPoller.lastState[orderId] = 'COOKING';
  YDPoller.start(orderId, function(data) {
    var statusMap = { PENDING:1, COOKING:2, READY:3, HANDOVER:4, ON_WAY:4, DELIVERED:5, CANCELLED:0 };
    var step = statusMap[data.status] || 2;
    ['s1','s2','s3','s4','s5'].forEach(function(id, i) {
      var el = document.getElementById(id);
      if (!el) return;
      el.className = 'step-row ' + (i+1 < step ? 'done' : i+1 === step ? 'active' : 'pending');
    });
  });
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
