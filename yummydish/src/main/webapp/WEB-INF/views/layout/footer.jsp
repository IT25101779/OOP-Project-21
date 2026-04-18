<%@ page contentType="text/html;charset=UTF-8" %>

<!-- Mobile bottom navigation -->
<nav class="yd-bottom-nav" id="mobileNav">
  <a href="/menu"     id="mnMenu"    ><i class="bi bi-house-door"></i>Menu</a>
  <a href="/activity" id="mnOrders"  ><i class="bi bi-bag-check"></i>Orders</a>
  <a href="/cart"     id="mnCart"    style="position:relative;">
    <i class="bi bi-cart3"></i>
    <span id="mobileCartBadge" class="notif-badge" style="display:none;"></span>
    Cart
  </a>
  <a href="/account"  id="mnAccount" ><i class="bi bi-person-circle"></i>Account</a>
</nav>
<script>
// Highlight active mobile nav
(function() {
  var path = location.pathname;
  var map = { '/menu':'mnMenu', '/activity':'mnOrders', '/cart':'mnCart', '/account':'mnAccount' };
  Object.keys(map).forEach(function(k) {
    if (path.startsWith(k)) {
      var el = document.getElementById(map[k]);
      if (el) el.classList.add('active');
    }
  });
  // Show cart badge
  document.addEventListener('DOMContentLoaded', function() {
    var cnt = Cart.count();
    var badge = document.getElementById('mobileCartBadge');
    if (badge) {
      badge.textContent = cnt;
      badge.style.display = cnt > 0 ? 'flex' : 'none';
    }
  });
})();
</script>


<!-- Onboarding tour (first visit only) -->
<div id="tourOverlay" style="display:none;position:fixed;inset:0;z-index:99990;pointer-events:none;">
  <div style="position:absolute;inset:0;background:rgba(0,0,0,.65);pointer-events:all;" id="tourBackdrop"></div>
</div>
<div id="tourCard" style="display:none;position:fixed;z-index:99995;max-width:300px;background:var(--c-surface);border-radius:20px;padding:24px;box-shadow:0 24px 64px rgba(0,0,0,.4);pointer-events:all;border:2px solid var(--c-orange);">
  <div id="tourIcon" style="font-size:2.5rem;margin-bottom:10px;"></div>
  <div id="tourTitle" style="font-weight:800;font-size:1rem;margin-bottom:6px;"></div>
  <div id="tourText"  style="font-size:.875rem;color:var(--c-muted);line-height:1.65;margin-bottom:18px;"></div>
  <div style="display:flex;justify-content:space-between;align-items:center;">
    <div id="tourDots" style="display:flex;gap:5px;"></div>
    <div style="display:flex;gap:8px;">
      <button onclick="Tour.skip()" style="background:none;border:none;color:var(--c-muted);font-size:.82rem;cursor:pointer;padding:8px;">Skip</button>
      <button onclick="Tour.next()" class="yd-btn yd-btn-primary" style="width:auto;padding:9px 20px;" id="tourBtn">Next →</button>
    </div>
  </div>
</div>

<script>
var Tour = (function() {
  var steps = [
    { icon:'🍽️', title:'Welcome to YummyDish!', text:'Sri Lanka's tastiest food delivered to your door in Kandy. Let us show you around!', anchor: null },
    { icon:'🛒', title:'Browse the Menu', text:'Browse by category, search live, or explore popular dishes. Tap any item to see details and reviews.', anchor: '.yd-brand' },
    { icon:'📍', title:'Set Your Location', text:'Click your address at the top of the menu page to set your delivery location. Use GPS or drop a pin on the map.', anchor: null },
    { icon:'⭐', title:'Earn Loyalty Points', text:'Every LKR 10 you spend earns 1 loyalty point. Collect 100 points for a LKR 10 discount on your next order!', anchor: null },
    { icon:'🔔', title:'Live Order Tracking', text:'Once you order, track your driver live on the map and get push notifications at every step. Enjoy your meal!', anchor: null }
  ];
  var cur = 0;

  function show(i) {
    cur = i;
    var step = steps[i];
    document.getElementById('tourOverlay').style.display = 'block';
    var card = document.getElementById('tourCard');
    card.style.display = 'block';
    // Center the card
    card.style.top  = '50%';
    card.style.left = '50%';
    card.style.transform = 'translate(-50%,-50%)';
    document.getElementById('tourIcon').textContent  = step.icon;
    document.getElementById('tourTitle').textContent = step.title;
    document.getElementById('tourText').textContent  = step.text;
    document.getElementById('tourBtn').textContent   = i < steps.length-1 ? 'Next →' : 'Get Started!';
    // Dots
    var dots = '';
    for (var d=0; d<steps.length; d++) {
      dots += '<div style="width:' + (d===i?'20':'7') + 'px;height:7px;border-radius:99px;background:' + (d===i?'var(--c-orange)':'var(--c-border)') + ';transition:all .3s;"></div>';
    }
    document.getElementById('tourDots').innerHTML = dots;
  }

  function next() {
    if (cur < steps.length - 1) { show(cur + 1); }
    else { skip(); }
  }

  function skip() {
    document.getElementById('tourOverlay').style.display = 'none';
    document.getElementById('tourCard').style.display    = 'none';
    localStorage.setItem('ydTourDone', '1');
  }

  function start() {
    if (localStorage.getItem('ydTourDone')) return;
    // Only show on menu page for logged-in users
    if (!document.querySelector('.yd-nav')) return;
    setTimeout(function() { show(0); }, 1200);
  }

  document.addEventListener('DOMContentLoaded', start);
  return { next: next, skip: skip, show: show };
})();
</script>

<div id="yd-cursor"></div>
<div id="yd-cursor-ring"></div>
<div id="notif-container" style="position:fixed;top:80px;right:16px;z-index:99999;display:flex;flex-direction:column;gap:8px;max-width:320px;pointer-events:none;"></div>

<script>
// ── In-app notification toasts ────────────────────────────────
function showNotif(icon, title, body, color) {
  var c = document.getElementById('notif-container');
  if (!c) return;
  var n = document.createElement('div');
  n.className = 'yd-notif';
  n.innerHTML =
    '<div class="yd-notif-icon" style="background:' + (color || 'var(--c-orange-l)') + ';">' + (icon || '🔔') + '</div>'
    + '<div style="flex:1;min-width:0;">'
    + '<div style="font-weight:700;font-size:.85rem;color:var(--c-text);">' + title + '</div>'
    + '<div style="font-size:.78rem;color:var(--c-muted);margin-top:2px;">' + body + '</div>'
    + '</div>'
    + '<button class="yd-notif-close" onclick="dismissNotif(this)">✕</button>';
  c.appendChild(n);
  setTimeout(function() { dismissNotif(n.querySelector('.yd-notif-close')); }, 7000);
}
function dismissNotif(btn) {
  var n = btn.closest ? btn.closest('.yd-notif') : btn;
  if (!n) return;
  n.classList.add('out');
  setTimeout(function() { if (n.parentNode) n.parentNode.removeChild(n); }, 320);
}

// ── Custom cursor (desktop only) ──────────────────────────────
(function() {
  if (!window.matchMedia('(pointer:fine)').matches) return;
  var cursor = document.getElementById('yd-cursor');
  var ring   = document.getElementById('yd-cursor-ring');
  if (!cursor || !ring) return;
  var mx = -200, my = -200, rx = -200, ry = -200;
  document.addEventListener('mousemove', function(e) {
    mx = e.clientX; my = e.clientY;
    cursor.style.left = mx + 'px';
    cursor.style.top  = my + 'px';
  });
  (function anim() {
    rx += (mx - rx) * 0.14;
    ry += (my - ry) * 0.14;
    ring.style.left = rx + 'px';
    ring.style.top  = ry + 'px';
    requestAnimationFrame(anim);
  })();
  document.addEventListener('mousedown', function() { cursor.style.transform = 'translate(-50%,-50%) scale(.7)'; });
  document.addEventListener('mouseup',   function() { cursor.style.transform = 'translate(-50%,-50%) scale(1)'; });
  document.addEventListener('mouseleave', function() { cursor.style.left = ring.style.left = '-200px'; });
  document.addEventListener('mouseover', function(e) {
    if (e.target.closest('a,button,[onclick],.yd-food-card,.yd-offer,.yd-quick-action')) {
      ring.style.width = ring.style.height = '54px';
      ring.style.borderColor = 'var(--c-orange)';
    }
  });
  document.addEventListener('mouseout', function(e) {
    if (e.target.closest('a,button,[onclick],.yd-food-card,.yd-offer,.yd-quick-action')) {
      ring.style.width = ring.style.height = '38px';
      ring.style.borderColor = '';
    }
  });
})();
</script>

<style>
#yd-cursor{position:fixed;width:12px;height:12px;background:var(--c-orange);border-radius:50%;pointer-events:none;z-index:99998;transform:translate(-50%,-50%);transition:transform .12s;mix-blend-mode:difference;}
#yd-cursor-ring{position:fixed;width:38px;height:38px;border:2px solid var(--c-orange);border-radius:50%;pointer-events:none;z-index:99997;transform:translate(-50%,-50%);opacity:.55;transition:width .2s,height .2s,border-color .2s;}
@media(pointer:coarse){#yd-cursor,#yd-cursor-ring{display:none;}}
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
