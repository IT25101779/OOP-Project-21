<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Group Order"/>
<c:set var="pageId"    value="group"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.group-hero{background:linear-gradient(135deg,#1a1a2e,#16213e,#0f3460);padding:52px 0;position:relative;overflow:hidden;}
.group-hero::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 70% 50%,rgba(255,107,53,.15) 0%,transparent 55%);}
.room-code-display{font-size:3.2rem;font-weight:800;letter-spacing:10px;font-family:monospace;color:var(--c-orange);text-align:center;padding:24px 20px;background:var(--c-orange-l);border-radius:16px;border:2px dashed rgba(255,107,53,.4);animation:pulse 2.5s ease-in-out infinite;}
.member-chip{display:flex;align-items:center;gap:8px;padding:8px 14px;background:var(--c-bg);border-radius:20px;border:1px solid var(--c-border);font-size:.82rem;}
.food-pick{display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid var(--c-border);}
.food-pick:last-child{border-bottom:none;}
.tab-btn{flex:1;padding:12px 8px;border:none;background:none;font-weight:600;font-size:.875rem;color:var(--c-muted);border-radius:12px;cursor:pointer;transition:all .22s;}
.tab-btn.active{background:var(--c-surface);color:var(--c-orange);box-shadow:var(--shadow);}
</style>

<div class="yd-page">
  <!-- Hero -->
  <div class="group-hero">
    <div class="container" style="position:relative;z-index:1;max-width:720px;text-align:center;">
      <div style="font-size:3.5rem;margin-bottom:16px;animation:float 3s ease-in-out infinite;">👥</div>
      <h1 style="font-family:var(--font-display);color:white;font-size:2.4rem;margin-bottom:10px;">Group Orders</h1>
      <p style="color:rgba(255,255,255,.6);font-size:1rem;max-width:480px;margin:0 auto;">Perfect for office lunches. Create a room, share the code, everyone picks their food — one delivery, one payment.</p>
    </div>
  </div>

  <div class="container py-4" style="max-width:720px;">

    <!-- Tabs -->
    <div style="display:flex;gap:3px;background:var(--c-bg);border:1px solid var(--c-border);border-radius:16px;padding:4px;margin-bottom:24px;">
      <button class="tab-btn active" id="tabCreate" onclick="showGrpTab('create',this)">➕ Create Room</button>
      <button class="tab-btn"        id="tabJoin"   onclick="showGrpTab('join',this)">🔑 Join Room</button>
      <button class="tab-btn"        id="tabMy"     onclick="showGrpTab('my',this)">📋 My Rooms</button>
    </div>

    <!-- CREATE -->
    <div id="paneCreate" class="yd-fade yd-visible">
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <h5 class="fw-bold mb-2">Start a Group Order</h5>
          <p style="color:var(--c-muted);font-size:.875rem;margin-bottom:20px;">You'll get a 6-digit room code to share with your colleagues.</p>
          <c:if test="${not user.hasCard()}">
            <div style="background:#FFF8E1;border:1px solid #FFE082;border-radius:12px;padding:14px 16px;margin-bottom:18px;font-size:.875rem;">
              <i class="bi bi-exclamation-triangle-fill me-2" style="color:#E65100;"></i>
              Group orders require a saved card. <a href="/account" style="color:var(--c-orange);font-weight:700;">Add card →</a>
            </div>
          </c:if>
          <button onclick="createRoom()" class="yd-btn yd-btn-primary" id="createBtn"
                  ${not user.hasCard() ? 'disabled style="opacity:.6;cursor:not-allowed;"' : ''}>
            <i class="bi bi-plus-circle me-2"></i>Create Room
          </button>
        </div>
      </div>

      <!-- Room code display (shown after creation) -->
      <div id="roomCreated" style="display:none;" class="yd-card mb-3">
        <div class="yd-card-body" style="text-align:center;">
          <div style="font-size:.75rem;font-weight:700;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:12px;">Your Room Code</div>
          <div class="room-code-display" id="createdCode">------</div>
          <p style="color:var(--c-muted);font-size:.82rem;margin:14px 0 18px;">Share this code with your team. They can join at <strong>yummydish.lk/group</strong></p>
          <div class="d-flex gap-2 justify-content-center">
            <button onclick="copyCode()" class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;"><i class="bi bi-clipboard me-1"></i>Copy Code</button>
            <button onclick="shareWhatsApp()" class="yd-wa-btn" style="font-size:.82rem;padding:8px 16px;">📱 Share via WhatsApp</button>
          </div>
        </div>
      </div>
    </div>

    <!-- JOIN -->
    <div id="paneJoin" style="display:none;" class="yd-fade">
      <div class="yd-card mb-3">
        <div class="yd-card-body">
          <h5 class="fw-bold mb-3">Join a Room</h5>
          <div class="yd-form-group">
            <label class="yd-label">Room Code</label>
            <input type="text" id="joinCode" class="yd-input"
                   placeholder="Enter 6-digit code (e.g. ABC123)"
                   maxlength="6" style="text-transform:uppercase;letter-spacing:4px;font-size:1.2rem;font-weight:700;font-family:monospace;"
                   oninput="this.value=this.value.toUpperCase()">
          </div>
          <button onclick="joinRoom()" class="yd-btn yd-btn-primary" id="joinBtn">
            <i class="bi bi-door-open me-2"></i>Join Room
          </button>
          <div id="joinResult" style="margin-top:14px;"></div>
        </div>
      </div>

      <!-- Room details after joining -->
      <div id="joinedRoom" style="display:none;" class="yd-card mb-3">
        <div class="yd-card-body">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
              <h5 class="fw-bold mb-1" id="joinedTitle">Room ---</h5>
              <div style="font-size:.78rem;color:var(--c-muted);" id="joinedHost"></div>
            </div>
            <span class="yd-status yd-s-ready" style="font-size:.72rem;">Active</span>
          </div>

          <h6 class="fw-bold mb-3" style="font-size:.82rem;color:var(--c-muted);text-transform:uppercase;letter-spacing:.5px;">Add Your Items</h6>
          <div id="groupFoodList" style="max-height:280px;overflow-y:auto;">
            <div class="yd-skeleton" style="height:64px;border-radius:12px;margin-bottom:8px;"></div>
            <div class="yd-skeleton" style="height:64px;border-radius:12px;margin-bottom:8px;"></div>
            <div class="yd-skeleton" style="height:64px;border-radius:12px;"></div>
          </div>

          <div style="margin-top:14px;padding:12px 14px;background:var(--c-bg);border-radius:12px;border:1px solid var(--c-border);">
            <div style="font-size:.75rem;font-weight:700;color:var(--c-muted);margin-bottom:6px;">YOUR SELECTION</div>
            <div id="myGroupItems" style="font-size:.82rem;color:var(--c-muted);">Nothing added yet</div>
          </div>

          <div class="d-flex gap-2 mt-3">
            <button onclick="addGroupItemsToCart()" class="yd-btn yd-btn-primary" style="flex:1;">
              <i class="bi bi-cart-plus me-2"></i>Add to Main Cart
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- MY ROOMS -->
    <div id="paneMy" style="display:none;" class="yd-fade">
      <div id="myRoomsList">
        <div class="yd-skeleton" style="height:80px;border-radius:14px;margin-bottom:10px;"></div>
        <div class="yd-skeleton" style="height:80px;border-radius:14px;"></div>
      </div>
    </div>

  </div>
</div>

<script>
var currentRoom  = '';
var groupItems   = [];
var myGroupSel   = [];

function showGrpTab(name, btn) {
  ['Create','Join','My'].forEach(function(t) {
    document.getElementById('pane'+t).style.display = 'none';
    document.getElementById('tab'+t).classList.remove('active');
  });
  document.getElementById('pane'+name.charAt(0).toUpperCase()+name.slice(1)).style.display = 'block';
  btn.classList.add('active');
  if (name === 'my') loadMyRooms();
}

async function createRoom() {
  var btn = document.getElementById('createBtn');
  btn.innerHTML = '<span class="spin me-2">⏳</span>Creating...';
  btn.disabled = true;
  try {
    var r = await fetch('/api/group/create', { method: 'POST' });
    var d = await r.json();
    if (d.code) {
      currentRoom = d.code;
      document.getElementById('createdCode').textContent = d.code;
      document.getElementById('roomCreated').style.display = 'block';
      // Save to localStorage
      var rooms = JSON.parse(localStorage.getItem('ydRooms') || '[]');
      rooms.unshift({ code: d.code, created: new Date().toLocaleString(), role: 'host' });
      localStorage.setItem('ydRooms', JSON.stringify(rooms.slice(0, 10)));
      showToast('Room created! Share code: ' + d.code + ' 🎉');
    } else { showToast('Could not create room. Try again.'); }
  } catch(e) { showToast('Network error.'); }
  btn.innerHTML = '<i class="bi bi-plus-circle me-2"></i>Create Room';
  btn.disabled = false;
}

function copyCode() {
  navigator.clipboard.writeText(currentRoom || document.getElementById('createdCode').textContent)
    .then(function(){ showToast('Code copied! 📋'); })
    .catch(function(){ showToast('Code: ' + (currentRoom || '------')); });
}

function shareWhatsApp() {
  var code = currentRoom || document.getElementById('createdCode').textContent;
  var text = '🍽️ *YummyDish Group Order*\nJoin my room with code: *' + code + '*\n\nGo to yummydish.lk/group and enter the code to add your food order!';
  window.open('https://wa.me/?text=' + encodeURIComponent(text), '_blank');
}

async function joinRoom() {
  var code = document.getElementById('joinCode').value.trim().toUpperCase();
  if (code.length < 4) { showToast('Enter a valid room code'); return; }
  var btn  = document.getElementById('joinBtn');
  var res  = document.getElementById('joinResult');
  btn.innerHTML = '<span class="spin me-2">⏳</span>Joining...'; btn.disabled = true;
  try {
    var r = await fetch('/api/group/join/' + code, { method: 'POST' });
    var d = await r.json();
    if (r.ok && d.code) {
      currentRoom = d.code;
      document.getElementById('joinedTitle').textContent = 'Room ' + d.code;
      document.getElementById('joinedHost').textContent  = 'Hosted by ' + (d.creatorName || 'Team');
      document.getElementById('joinedRoom').style.display = 'block';
      res.innerHTML = '';
      // Save to localStorage
      var rooms = JSON.parse(localStorage.getItem('ydRooms') || '[]');
      rooms.unshift({ code: d.code, created: new Date().toLocaleString(), role: 'member', host: d.creatorName });
      localStorage.setItem('ydRooms', JSON.stringify(rooms.slice(0, 10)));
      loadGroupFoods();
    } else {
      res.innerHTML = '<div style="color:#C62828;padding:10px 14px;background:#FFEBEE;border-radius:10px;font-size:.875rem;">❌ ' + (d.error || 'Room not found') + '</div>';
    }
  } catch(e) { res.innerHTML = '<div style="color:#C62828;font-size:.875rem;">Network error.</div>'; }
  btn.innerHTML = '<i class="bi bi-door-open me-2"></i>Join Room';
  btn.disabled = false;
}

async function loadGroupFoods() {
  try {
    var foods = await fetch('/api/foods').then(function(r){ return r.json(); });
    var avail = foods.filter(function(f){ return f.available; });
    groupItems = avail;
    var c = document.getElementById('groupFoodList');
    c.innerHTML = avail.map(function(f) {
      return '<div class="food-pick">'
        + '<img src="'+(f.imageUrl||'')+'" style="width:48px;height:48px;border-radius:10px;object-fit:cover;flex-shrink:0;" onerror="this.style.display=\'none\'">'
        + '<div style="flex:1;">'
        + '<div style="font-weight:600;font-size:.875rem;">' + f.name + '</div>'
        + '<div style="font-size:.78rem;color:var(--c-orange);">LKR ' + Math.round(f.price).toLocaleString() + '</div>'
        + '</div>'
        + '<button onclick="addGroupItem(\'' + f.id + '\',\'' + f.name.replace(/'/g,'') + '\',' + f.price + ',\''+(f.imageUrl||'')+'\')" '
        + 'style="background:var(--c-orange-l);color:var(--c-orange);border:1px solid rgba(255,107,53,.3);border-radius:8px;padding:5px 12px;font-size:.78rem;font-weight:700;cursor:pointer;transition:all .2s;" '
        + 'onmouseover="this.style.background=\'var(--c-orange)\';this.style.color=\'white\'" '
        + 'onmouseout="this.style.background=\'var(--c-orange-l)\';this.style.color=\'var(--c-orange)\'">Add</button>'
        + '</div>';
    }).join('');
  } catch(e) { document.getElementById('groupFoodList').innerHTML = '<p style="color:var(--c-muted);font-size:.875rem;">Could not load menu.</p>'; }
}

function addGroupItem(id, name, price, img) {
  var ex = myGroupSel.find(function(i){ return i.id === id; });
  if (ex) ex.qty++;
  else myGroupSel.push({ id: id, name: name, price: price, img: img, qty: 1 });
  var el = document.getElementById('myGroupItems');
  if (el) {
    el.innerHTML = myGroupSel.map(function(i){
      return '<div style="display:flex;justify-content:space-between;padding:3px 0;">'
        + '<span>' + i.name + ' ×' + i.qty + '</span>'
        + '<span style="color:var(--c-orange);">LKR ' + Math.round(i.price * i.qty).toLocaleString() + '</span></div>';
    }).join('');
  }
  showToast(name + ' added to group 🛒');
}

function addGroupItemsToCart() {
  if (!myGroupSel.length) { showToast('Add at least one item first'); return; }
  myGroupSel.forEach(function(i){ Cart.add(i.id, i.name, i.price, i.qty, i.img); });
  showToast('All items added to cart! 🎉');
  setTimeout(function(){ location.href = '/cart'; }, 1000);
}

function loadMyRooms() {
  var rooms = JSON.parse(localStorage.getItem('ydRooms') || '[]');
  var c = document.getElementById('myRoomsList');
  if (!rooms.length) {
    c.innerHTML = '<div style="text-align:center;padding:40px;color:var(--c-muted);"><div style="font-size:3rem;margin-bottom:12px;">📭</div><p>No rooms yet.<br>Create or join one!</p></div>';
    return;
  }
  c.innerHTML = rooms.map(function(r) {
    return '<div style="background:var(--c-surface);border:1px solid var(--c-border);border-radius:16px;padding:16px 18px;margin-bottom:10px;display:flex;align-items:center;gap:14px;">'
      + '<div style="width:44px;height:44px;border-radius:50%;background:' + (r.role==='host'?'linear-gradient(135deg,var(--c-orange),var(--c-orange-d))':'linear-gradient(135deg,#667eea,#764ba2)') + ';color:white;display:flex;align-items:center;justify-content:center;font-size:1.2rem;flex-shrink:0;">'+(r.role==='host'?'👑':'👤')+'</div>'
      + '<div style="flex:1;">'
      + '<div style="font-family:monospace;font-weight:800;font-size:1.1rem;letter-spacing:3px;color:var(--c-text);">' + r.code + '</div>'
      + '<div style="font-size:.75rem;color:var(--c-muted);">' + (r.role==='host'?'You created':'Joined · '+r.host) + ' · ' + r.created + '</div>'
      + '</div>'
      + '<button onclick="document.getElementById(\'joinCode\').value=\'' + r.code + '\';showGrpTab(\'join\',document.getElementById(\'tabJoin\'));joinRoom();" '
      + 'class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;">Rejoin</button>'
      + '</div>';
  }).join('');
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
