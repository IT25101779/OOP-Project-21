/* ═══════════════════════════════════════════════════════════════
   YummyDish — Notification & Sound System
   - Web Push Notifications (user permission)
   - Sound alerts (Web Audio API - no external files needed)
   - Admin/Driver auto-polling (SSE-like polling)
═══════════════════════════════════════════════════════════════ */

// ── Sound Engine (Web Audio API — zero external files) ────────────
const YDSound = (() => {
    let ctx = null;
    function getCtx() {
        if (!ctx) ctx = new (window.AudioContext || window.webkitAudioContext)();
        if (ctx.state === 'suspended') ctx.resume();
        return ctx;
    }

    function playTone(freq, duration, type, vol) {
        try {
            var c  = getCtx();
            var osc = c.createOscillator();
            var gain = c.createGain();
            osc.connect(gain); gain.connect(c.destination);
            osc.type = type || 'sine';
            osc.frequency.setValueAtTime(freq, c.currentTime);
            gain.gain.setValueAtTime(vol || 0.3, c.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, c.currentTime + duration);
            osc.start(c.currentTime);
            osc.stop(c.currentTime + duration);
        } catch(e) {}
    }

    function playChime() {
        // Pleasant order notification chime
        playTone(523, 0.15, 'sine', 0.25);
        setTimeout(function(){ playTone(659, 0.15, 'sine', 0.22); }, 150);
        setTimeout(function(){ playTone(784, 0.25, 'sine', 0.2); },  300);
        setTimeout(function(){ playTone(1047, 0.4, 'sine', 0.18); }, 500);
    }

    function playAlert() {
        // Urgent admin new-order alert
        playTone(880, 0.12, 'square', 0.18);
        setTimeout(function(){ playTone(1100, 0.12, 'square', 0.16); }, 130);
        setTimeout(function(){ playTone(880, 0.12, 'square', 0.14); },  260);
        setTimeout(function(){ playTone(1100, 0.3, 'square', 0.12); },  390);
    }

    function playSuccess() {
        // Order delivered
        playTone(784, 0.15, 'sine', 0.2);
        setTimeout(function(){ playTone(988, 0.15, 'sine', 0.18); }, 160);
        setTimeout(function(){ playTone(1175, 0.4, 'sine', 0.15); }, 320);
    }

    function playNearby() {
        // Driver nearby ping
        playTone(1047, 0.08, 'sine', 0.22);
        setTimeout(function(){ playTone(1047, 0.08, 'sine', 0.18); }, 200);
        setTimeout(function(){ playTone(1319, 0.3, 'sine', 0.15); },  400);
    }

    return { playChime, playAlert, playSuccess, playNearby };
})();

// ── Push Notification helper ──────────────────────────────────────
const YDPush = (() => {
    var permission = 'default';

    async function requestPermission() {
        if (!('Notification' in window)) return false;
        if (Notification.permission === 'granted') { permission = 'granted'; return true; }
        if (Notification.permission === 'denied')  { permission = 'denied';  return false; }
        var result = await Notification.requestPermission();
        permission = result;
        return result === 'granted';
    }

    function send(title, body, icon, tag) {
        if (!('Notification' in window) || Notification.permission !== 'granted') return;
        var n = new Notification(title, {
            body:  body  || '',
            icon:  icon  || '/favicon.ico',
            tag:   tag   || 'yummydish',
            badge: '/favicon.ico',
            vibrate: [200, 100, 200]
        });
        n.onclick = function(){ window.focus(); n.close(); };
        setTimeout(function(){ n.close(); }, 8000);
    }

    function orderPlaced(orderId) {
        send('🎉 Order Placed!', 'Your order #' + orderId + ' is being prepared.', null, 'order-placed');
        YDSound.playChime();
    }
    function orderReady(orderId) {
        send('📦 Order Ready!', '#' + orderId + ' is ready for pickup.', null, 'order-ready');
        YDSound.playChime();
    }
    function driverOnWay(orderId, driverName) {
        send('🛵 Driver On the Way!', (driverName||'Your driver') + ' is heading to you for order #' + orderId, null, 'driver-onway');
        YDSound.playChime();
    }
    function driverNearby(orderId) {
        send('📍 Driver Nearby!', 'Your driver is less than 1 km away for order #' + orderId + '. Get ready!', null, 'driver-nearby');
        YDSound.playNearby();
    }
    function orderDelivered(orderId) {
        send('✅ Order Delivered!', '#' + orderId + ' has been delivered. Enjoy your meal!', null, 'delivered');
        YDSound.playSuccess();
    }
    function newOrderAdmin(orderId, customerName) {
        send('🔔 New Order!', '#' + orderId + ' from ' + (customerName||'a customer'), null, 'new-order');
        YDSound.playAlert();
    }

    // Auto-request permission on first interaction
    document.addEventListener('click', function() { requestPermission(); }, { once: true });

    return { requestPermission, send, orderPlaced, orderReady, driverOnWay, driverNearby, orderDelivered, newOrderAdmin };
})();

// ── Admin auto-polling for new orders ────────────────────────────
const AdminPoller = (() => {
    var lastCount = -1;
    var intervalId = null;
    var badge = null;

    function start() {
        badge = document.getElementById('adminNewOrderBadge');
        intervalId = setInterval(poll, 10000); // every 10s
        poll(); // immediate
    }
    function stop() { if (intervalId) clearInterval(intervalId); }

    async function poll() {
        try {
            var r = await fetch('/api/orders/new-count');
            if (!r.ok) return;
            var d = await r.json();
            var count = d.count || 0;
            if (lastCount === -1) { lastCount = count; return; } // init
            if (count > lastCount) {
                var diff = count - lastCount;
                YDPush.newOrderAdmin('(+' + diff + ')', diff + ' new order' + (diff > 1 ? 's' : ''));
                showNewOrderBanner(diff);
            }
            lastCount = count;
            if (badge) {
                badge.textContent = count;
                badge.style.display = count > 0 ? 'inline-flex' : 'none';
            }
            // Update page title
            if (count > 0) document.title = '(' + count + ') New Orders — YummyDish Admin';
            else document.title = 'Admin Dashboard — YummyDish';
        } catch(e) {}
    }

    function showNewOrderBanner(count) {
        var banner = document.getElementById('newOrderBanner');
        if (!banner) return;
        banner.textContent = '🔔 ' + count + ' new order' + (count > 1 ? 's' : '') + ' arrived!';
        banner.style.display = 'flex';
        setTimeout(function(){ banner.style.display = 'none'; }, 6000);
    }

    return { start, stop };
})();

// ── Customer order tracking with notifications ────────────────────
const OrderTracker = (() => {
    var pollers = {};
    var nearbyAlerted = {};

    function start(orderId) {
        if (pollers[orderId]) return;
        pollers[orderId] = setInterval(function(){ poll(orderId); }, 7000);
    }
    function stop(orderId) {
        if (pollers[orderId]) { clearInterval(pollers[orderId]); delete pollers[orderId]; }
    }

    async function poll(orderId) {
        try {
            var r = await fetch('/api/order/' + orderId);
            if (!r.ok) return;
            var d = await r.json();
            updateOrderUI(orderId, d);
            // Notify on status change
            var prevStatus = localStorage.getItem('yd_status_' + orderId);
            if (prevStatus && prevStatus !== d.status) {
                notifyStatusChange(orderId, d.status, d.driverName);
            }
            localStorage.setItem('yd_status_' + orderId, d.status);
            // Check driver nearby
            if (d.status === 'ON_WAY' && !nearbyAlerted[orderId]) {
                checkNearby(orderId);
            }
            if (d.status === 'DELIVERED' || d.status === 'CANCELLED') stop(orderId);
        } catch(e) {}
    }

    function notifyStatusChange(orderId, status, driverName) {
        if (status === 'READY')     YDPush.orderReady(orderId);
        if (status === 'ON_WAY')    YDPush.driverOnWay(orderId, driverName);
        if (status === 'DELIVERED') YDPush.orderDelivered(orderId);
    }

    async function checkNearby(orderId) {
        try {
            var r = await fetch('/api/order/' + orderId + '/driver-nearby');
            var d = await r.json();
            if (d.nearby && !nearbyAlerted[orderId]) {
                nearbyAlerted[orderId] = true;
                YDPush.driverNearby(orderId);
                showToast('🏍️ Driver is less than 1km away! Get ready!', 5000);
            }
        } catch(e) {}
    }

    function updateOrderUI(orderId, d) {
        var badge = document.getElementById('badge-' + orderId);
        var prog  = document.getElementById('prog-'  + orderId);
        var pct   = document.getElementById('pct-'   + orderId);
        if (badge) badge.textContent = d.statusBadge;
        if (prog)  prog.style.width  = d.progress + '%';
        if (pct)   pct.textContent   = d.progress + '%';
        // Update step classes
        var stepMap = {COOKING:'cooking', READY:'ready', HANDOVER:'handover', ON_WAY:'onway'};
        var order   = ['cooking','ready','handover','onway'];
        var activeIdx = order.indexOf(stepMap[d.status] || '');
        order.forEach(function(step, i) {
            var el = document.getElementById('step-' + step + '-' + orderId);
            if (!el) return;
            el.classList.remove('done','active');
            if (i < activeIdx)       el.classList.add('done');
            else if (i === activeIdx) el.classList.add('active');
        });
        if (d.status === 'DELIVERED') {
            order.forEach(function(step){ var el=document.getElementById('step-'+step+'-'+orderId); if(el){el.classList.add('done');el.classList.remove('active');} });
        }
    }

    return { start, stop, poll };
})();
