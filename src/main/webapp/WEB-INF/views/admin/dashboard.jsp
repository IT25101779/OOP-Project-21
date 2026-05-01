<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Admin Dashboard"/>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin Dashboard — YummyDish</title>
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,700;9..144,900&amp;family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="/css/yummydish.css" rel="stylesheet">
<script>(function(){var t=localStorage.getItem('ydTheme');if(t==='dark')document.documentElement.setAttribute('data-theme','dark');})();</script>
<script src="/js/app.js"></script>
</head>
<body>
<div id="yd-toast"></div>
<style>
.adm-hero{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:24px 0;margin-bottom:0;}
.stat-box{background:var(--c-surface);border-radius:16px;border:1px solid var(--c-border);padding:18px 20px;transition:all .25s var(--ease);}
.stat-box:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);}
.stat-num{font-size:2rem;font-weight:800;line-height:1;}
.kanban-col{background:var(--c-bg);border-radius:16px;padding:12px;min-height:140px;border:1px solid var(--c-border);}
.kanban-hd{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.8px;margin-bottom:12px;padding:6px 10px;border-radius:8px;}
.kanban-card{background:var(--c-surface);border-radius:12px;padding:12px 14px;margin-bottom:8px;border:1px solid var(--c-border);transition:all .22s var(--ease);cursor:pointer;}
.kanban-card:hover{box-shadow:var(--shadow-md);transform:translateY(-2px);}
.food-img-sm{width:42px;height:42px;border-radius:10px;object-fit:cover;flex-shrink:0;}
#adminNewAlert{position:fixed;top:80px;right:16px;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;padding:16px 22px;border-radius:16px;font-weight:700;z-index:9999;box-shadow:0 8px 32px rgba(255,107,53,.5);cursor:pointer;animation:slideLeft .4s var(--ease);}
</style>

<div class="yd-page">
  <!-- Hero header -->
  <div class="adm-hero">
    <div class="container-xl">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <h2 style="font-family:var(--font-display);color:white;font-size:1.8rem;margin:0;">⚙️ Admin Dashboard</h2>
          <p style="color:rgba(255,255,255,.5);font-size:.82rem;margin-top:4px;">YummyDish Kandy</p>
        </div>
        <div class="d-flex align-items-center gap-3">
          <div class="yd-live-badge" style="border-color:rgba(255,255,255,.3);color:white;background:rgba(255,255,255,.1);">
            <span class="yd-live-dot" style="background:white;"></span>
            <span id="adminNewBadge" style="font-weight:800;"></span> Live
          </div>
          <a href="/admin/logout" style="color:rgba(255,255,255,.6);font-size:.82rem;"><i class="bi bi-box-arrow-right me-1"></i>Logout</a>
        </div>
      </div>
    </div>
  </div>

  <!-- Stats -->
  <div class="container-xl py-4">
    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3 yd-fade">
        <div class="stat-box"><div style="font-size:.7rem;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;">Menu Items</div>
        <div class="stat-num" style="color:var(--c-orange);">${fn:length(foods)}</div></div>
      </div>
      <div class="col-6 col-md-3 yd-fade">
        <div class="stat-box"><div style="font-size:.7rem;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;">Customers</div>
        <div class="stat-num" style="color:#667eea;">${fn:length(customers)}</div></div>
      </div>
      <div class="col-6 col-md-3 yd-fade">
        <div class="stat-box"><div style="font-size:.7rem;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;">Total Orders</div>
        <div class="stat-num" style="color:var(--c-success);">${fn:length(orders)}</div></div>
      </div>
      <div class="col-6 col-md-3 yd-fade">
        <div class="stat-box"><div style="font-size:.7rem;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;">Revenue</div>
        <div class="stat-num" style="color:var(--c-orange);font-size:1.3rem;">LKR <fmt:formatNumber value="${revenue}" pattern="#,##0"/></div></div>
      </div>
    </div>

    <!-- Tabs -->
    <div style="display:flex;gap:2px;border-bottom:2px solid var(--c-border);margin-bottom:24px;overflow-x:auto;">
      <button class="yd-admin-tab active" id="atKanban"   onclick="admTab('Kanban')">📊 Live Orders</button>
      <button class="yd-admin-tab"        id="atFood"     onclick="admTab('Food')">🍽️ Food</button>
      <button class="yd-admin-tab"        id="atOrders"   onclick="admTab('Orders')">📦 All Orders</button>
      <button class="yd-admin-tab"        id="atUsers"    onclick="admTab('Users')">👥 Users</button>
      <button class="yd-admin-tab"        id="atDrivers"  onclick="admTab('Drivers')">🛵 Drivers</button>
      <button class="yd-admin-tab"        id="atOffers"   onclick="admTab('Offers')">🎁 Offers</button>
      <button class="yd-admin-tab"        id="atFeedback" onclick="admTab('Feedback')">💬 Reviews</button>
    </div>

    <!-- KANBAN -->
    <div class="adm-pane" id="paneKanban">
      <div class="row g-3">
        <div class="col-md-3">
          <div class="kanban-col">
            <div class="kanban-hd" style="background:#FFF3E0;color:#E65100;">🍳 Cooking (${fn:length(cookingOrders)})</div>
            <c:forEach items="${cookingOrders}" var="o">
            <div class="kanban-card">
              <div style="font-family:monospace;font-weight:700;font-size:.82rem;color:var(--c-text);margin-bottom:5px;">#${o.orderId}</div>
              <div style="font-size:.78rem;color:var(--c-muted);">${o.customerName}</div>
              <div style="font-size:.78rem;color:var(--c-text2);margin-top:4px;">LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/></div>
              <form action="/admin/order/status" method="post" class="mt-2">
                <input type="hidden" name="orderId" value="${o.orderId}">
                <input type="hidden" name="status" value="READY">
                <button type="submit" class="yd-btn yd-btn-sm" style="background:#E8F5E9;color:#2E7D32;border:none;padding:5px 12px;font-size:.72rem;width:100%;">✓ Mark Ready</button>
              </form>
            </div>
            </c:forEach>
          </div>
        </div>
        <div class="col-md-3">
          <div class="kanban-col">
            <div class="kanban-hd" style="background:#E8F5E9;color:#2E7D32;">📦 Ready (${fn:length(readyOrders)})</div>
            <c:forEach items="${readyOrders}" var="o">
            <div class="kanban-card">
              <div style="font-family:monospace;font-weight:700;font-size:.82rem;color:var(--c-text);margin-bottom:5px;">#${o.orderId}</div>
              <div style="font-size:.78rem;color:var(--c-muted);">${o.customerName}</div>
              <div style="font-size:.72rem;color:var(--c-muted);margin-top:2px;">${o.deliveryAddress}</div>
            </div>
            </c:forEach>
          </div>
        </div>
        <div class="col-md-3">
          <div class="kanban-col">
            <div class="kanban-hd" style="background:#E3F2FD;color:#1565C0;">🛵 On the Way (${fn:length(onwayOrders)})</div>
            <c:forEach items="${onwayOrders}" var="o">
            <div class="kanban-card">
              <div style="font-family:monospace;font-weight:700;font-size:.82rem;color:var(--c-text);margin-bottom:5px;">#${o.orderId}</div>
              <div style="font-size:.78rem;color:var(--c-muted);">${o.customerName}</div>
              <div style="font-size:.78rem;color:var(--c-text2);margin-top:4px;">${o.driverName}</div>
            </div>
            </c:forEach>
          </div>
        </div>
        <div class="col-md-3">
          <div class="kanban-col">
            <div class="kanban-hd" style="background:#F3E8FF;color:#7C3AED;">✅ Delivered Today (${fn:length(deliveredToday)})</div>
            <c:forEach items="${deliveredToday}" var="o">
            <div class="kanban-card" style="border-color:rgba(124,58,237,.15);">
              <div style="font-family:monospace;font-weight:700;font-size:.82rem;color:var(--c-text);">#${o.orderId}</div>
              <div style="font-size:.78rem;color:var(--c-muted);">${o.customerName}</div>
            </div>
            </c:forEach>
          </div>
        </div>
      </div>
    </div>

    <!-- FOOD -->
    <div class="adm-pane" id="paneFood" style="display:none;">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">Menu Items</h5>
        <button onclick="document.getElementById('addFoodModal').style.display='flex'" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;"><i class="bi bi-plus-lg me-1"></i>Add Item</button>
      </div>
      <div style="overflow-x:auto;">
        <table class="yd-table">
          <thead><tr><th>Item</th><th>Category</th><th>Price</th><th>Status</th><th>Rating</th><th>Actions</th></tr></thead>
          <tbody>
            <c:forEach items="${foods}" var="f">
            <tr>
              <td><div class="d-flex align-items-center gap-2"><img src="${f.imageUrl}" class="food-img-sm" onerror="this.style.display='none'"><div><div style="font-weight:600;font-size:.88rem;">${f.name}</div><div style="font-size:.72rem;color:var(--c-muted);">${f.foodType} · ${f.calories} kcal</div></div></div></td>
              <td style="font-size:.82rem;">${f.category}</td>
              <td style="font-weight:700;color:var(--c-orange);">LKR <fmt:formatNumber value="${f.price}" pattern="#,##0"/></td>
              <td>
                <form action="/admin/food/toggle" method="post" style="display:inline;">
                  <input type="hidden" name="id" value="${f.id}">
                  <button type="submit" style="background:${f.available?'#E8F5E9':'#FFEBEE'};border:1px solid ${f.available?'#A5D6A7':'#FFCDD2'};color:${f.available?'#2E7D32':'#C62828'};border-radius:20px;padding:3px 12px;font-size:.72rem;font-weight:700;cursor:pointer;">
                    ${f.available ? '✅ Available' : '❌ Off Menu'}
                  </button>
                </form>
              </td>
              <td style="font-size:.82rem;color:#FFB800;">★ ${f.rating} (${f.reviewCount})</td>
              <td><div class="d-flex gap-1">
                <a href="/menu/item/${f.id}" target="_blank" class="yd-btn yd-btn-outline yd-btn-sm" style="padding:6px 10px;"><i class="bi bi-eye"></i></a>
                <button onclick="editFood('${f.id}')" class="yd-btn yd-btn-sm" style="background:#E3F2FD;color:#1565C0;border:none;padding:6px 10px;"><i class="bi bi-pencil"></i></button>
                <form action="/admin/food/delete" method="post" style="display:inline;" onsubmit="return confirm('Delete ${f.name}?')">
                  <input type="hidden" name="id" value="${f.id}">
                  <button type="submit" class="yd-btn yd-btn-sm" style="background:#FFEBEE;color:#C62828;border:none;padding:6px 10px;"><i class="bi bi-trash3"></i></button>
                </form>
              </div></td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ALL ORDERS -->
    <div class="adm-pane" id="paneOrders" style="display:none;">
      <h5 class="fw-bold mb-3">All Orders</h5>
      <div style="overflow-x:auto;">
        <table class="yd-table">
          <thead><tr><th>Order</th><th>Customer</th><th>Total</th><th>Payment</th><th>Status</th><th>Update</th></tr></thead>
          <tbody>
            <c:forEach items="${orders}" var="o">
            <tr>
              <td style="font-family:monospace;font-weight:700;">#${o.orderId}<br><span style="font-size:.7rem;color:var(--c-muted);font-family:sans-serif;">${o.createdAt}</span></td>
              <td><div style="font-weight:600;font-size:.85rem;">${o.customerName}</div><div style="font-size:.72rem;color:var(--c-muted);">${o.deliveryAddress}</div></td>
              <td style="font-weight:700;color:var(--c-orange);">LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/></td>
              <td style="font-size:.78rem;">${o.paymentMethod}</td>
              <td>
                <c:choose>
                  <c:when test="${o.status=='COOKING'}"><span class="yd-status yd-s-cooking">${o.statusBadge}</span></c:when>
                  <c:when test="${o.status=='READY'}"><span class="yd-status yd-s-ready">${o.statusBadge}</span></c:when>
                  <c:when test="${o.status=='ON_WAY' or o.status=='HANDOVER'}"><span class="yd-status yd-s-onway">${o.statusBadge}</span></c:when>
                  <c:when test="${o.status=='DELIVERED'}"><span class="yd-status yd-s-delivered">${o.statusBadge}</span></c:when>
                  <c:when test="${o.status=='CANCELLED'}"><span class="yd-status yd-s-cancelled">${o.statusBadge}</span></c:when>
                  <c:otherwise><span class="yd-status yd-s-pending">${o.statusBadge}</span></c:otherwise>
                </c:choose>
              </td>
              <td><form action="/admin/order/status" method="post">
                <input type="hidden" name="orderId" value="${o.orderId}">
                <select name="status" class="yd-input" style="padding:6px 10px;font-size:.78rem;border-radius:8px;min-width:148px;" onchange="this.form.submit()">
                  <option value="COOKING"   ${o.status=='COOKING'?'selected':''}>🍳 Cooking</option>
                  <option value="READY"     ${o.status=='READY'?'selected':''}>📦 Ready for Driver</option>
                  <option value="HANDOVER"  ${o.status=='HANDOVER'?'selected':''}>🤝 Picked Up</option>
                  <option value="ON_WAY"    ${o.status=='ON_WAY'?'selected':''}>🛵 On the Way</option>
                  <option value="DELIVERED" ${o.status=='DELIVERED'?'selected':''}>✅ Delivered</option>
                  <option value="CANCELLED" ${o.status=='CANCELLED'?'selected':''}>❌ Cancelled</option>
                </select>
              </form></td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- USERS -->
    <div class="adm-pane" id="paneUsers" style="display:none;">
      <h5 class="fw-bold mb-3">Customers</h5>
      <div style="overflow-x:auto;">
        <table class="yd-table">
          <thead><tr><th>Customer</th><th>Email</th><th>Phone</th><th>Loyalty</th><th>Actions</th></tr></thead>
          <tbody>
            <c:forEach items="${customers}" var="cu">
            <tr>
              <td><div class="d-flex align-items-center gap-2">
                <c:choose><c:when test="${fn:length(cu.profilePicUrl)>0}"><img src="${cu.profilePicUrl}" style="width:36px;height:36px;border-radius:50%;object-fit:cover;" onerror="this.style.display='none'"></c:when>
                <c:otherwise><div style="width:36px;height:36px;border-radius:50%;background:var(--c-orange-l);color:var(--c-orange);display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;">${fn:substring(cu.name,0,1)}</div></c:otherwise></c:choose>
                <div><div style="font-weight:600;font-size:.88rem;">${cu.name}</div><div style="font-size:.72rem;color:var(--c-muted);">${cu.createdAt}</div></div>
              </div></td>
              <td style="font-size:.82rem;">${cu.email}</td>
              <td style="font-size:.82rem;">${cu.phone}</td>
              <td style="font-size:.82rem;color:#FFB800;">⭐ ${cu.loyaltyPoints}</td>
              <td><div class="d-flex gap-1">
                <button onclick="editUser('${cu.id}','${cu.name}','${cu.phone}','${cu.address}','')" class="yd-btn yd-btn-sm" style="background:#E3F2FD;color:#1565C0;border:none;padding:6px 10px;"><i class="bi bi-pencil"></i></button>
                <form action="/admin/user/delete" method="post" style="display:inline;" onsubmit="return confirm('Delete ${cu.name}?')"><input type="hidden" name="id" value="${cu.id}"><button type="submit" class="yd-btn yd-btn-sm" style="background:#FFEBEE;color:#C62828;border:none;padding:6px 10px;"><i class="bi bi-person-x"></i></button></form>
              </div></td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- DRIVERS -->
    <div class="adm-pane" id="paneDrivers" style="display:none;">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">Drivers</h5>
        <button onclick="document.getElementById('addDriverModal').style.display='flex'" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;"><i class="bi bi-plus-lg me-1"></i>Add Driver</button>
      </div>
      <div style="overflow-x:auto;">
        <table class="yd-table">
          <thead><tr><th>Driver</th><th>Email</th><th>Phone</th><th>Status</th><th>Actions</th></tr></thead>
          <tbody>
            <c:forEach items="${drivers}" var="dr">
            <tr>
              <td><div class="d-flex align-items-center gap-2">
                <c:choose><c:when test="${fn:length(dr.profilePicUrl)>0}"><img src="${dr.profilePicUrl}" style="width:36px;height:36px;border-radius:50%;object-fit:cover;" onerror="this.style.display='none'"></c:when>
                <c:otherwise><div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;display:flex;align-items:center;justify-content:center;font-weight:800;flex-shrink:0;">${fn:substring(dr.name,0,1)}</div></c:otherwise></c:choose>
                <div style="font-weight:600;font-size:.88rem;">${dr.name}</div>
              </div></td>
              <td style="font-size:.82rem;">${dr.email}</td>
              <td style="font-size:.82rem;">${dr.phone}</td>
              <td><span class="yd-status yd-s-ready" style="font-size:.72rem;">Active</span></td>
              <td><div class="d-flex gap-1">
                <button onclick="editUser('${dr.id}','${dr.name}','${dr.phone}','${dr.address}','${dr.profilePicUrl}')" class="yd-btn yd-btn-sm" style="background:#E3F2FD;color:#1565C0;border:none;padding:6px 10px;"><i class="bi bi-pencil"></i></button>
                <form action="/admin/user/delete" method="post" style="display:inline;" onsubmit="return confirm('Remove ${dr.name}?')"><input type="hidden" name="id" value="${dr.id}"><button type="submit" class="yd-btn yd-btn-sm" style="background:#FFEBEE;color:#C62828;border:none;padding:6px 10px;"><i class="bi bi-person-x"></i></button></form>
              </div></td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- OFFERS -->
    <div class="adm-pane" id="paneOffers" style="display:none;">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">Promo Offers</h5>
        <button onclick="document.getElementById('addOfferModal').style.display='flex'" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;"><i class="bi bi-plus-lg me-1"></i>Add Offer</button>
      </div>
      <div class="row g-3">
        <c:forEach items="${offers}" var="o">
        <div class="col-md-4 yd-fade">
          <div class="yd-card" style="border-top:4px solid var(--c-orange);">
            <div class="yd-card-body">
              <div style="font-size:1.4rem;font-weight:800;color:var(--c-orange);letter-spacing:2px;">${o.code}</div>
              <div style="font-weight:700;margin:6px 0 4px;">${o.title}</div>
              <div style="font-size:.78rem;color:var(--c-muted);">${o.description}</div>
              <div style="margin-top:10px;display:flex;justify-content:space-between;align-items:center;">
                <span style="font-size:.78rem;background:var(--c-orange-l);color:var(--c-orange);padding:3px 10px;border-radius:20px;font-weight:700;">${o.discountPercent}% OFF</span>
                <form action="/admin/offer/delete" method="post" style="display:inline;" onsubmit="return confirm('Delete offer ${o.code}?')"><input type="hidden" name="id" value="${o.id}"><button type="submit" style="background:none;border:none;color:#f44336;cursor:pointer;font-size:.85rem;">✕ Delete</button></form>
              </div>
            </div>
          </div>
        </div>
        </c:forEach>
      </div>
    </div>

    <!-- FEEDBACK / REVIEWS -->
    <div class="adm-pane" id="paneFeedback" style="display:none;">
      <h5 class="fw-bold mb-3">Customer Reviews</h5>
      <c:forEach items="${feedback}" var="fb">
      <div class="yd-card mb-3 yd-fade">
        <div class="yd-card-body">
          <div class="d-flex justify-content-between align-items-start mb-2">
            <div><div style="font-weight:700;font-size:.9rem;">${fb.customerName}</div><div style="font-size:.72rem;color:var(--c-muted);">${fb.createdAt} · ${fb.foodItemName}</div></div>
            <div style="color:#FFB800;">★★★★★</div>
          </div>
          <p style="font-size:.875rem;color:var(--c-text2);font-style:italic;margin-bottom:12px;">"${fb.text}"</p>
          <c:if test="${fn:length(fb.adminReply)>0}"><div style="background:var(--c-orange-l);padding:8px 12px;border-radius:10px;font-size:.82rem;color:var(--c-text2);margin-bottom:12px;border-left:3px solid var(--c-orange);"><strong>Your reply:</strong> ${fb.adminReply}</div></c:if>
          <form action="/admin/feedback/reply" method="post" class="d-flex gap-2">
            <input type="hidden" name="feedbackId" value="${fb.id}">
            <input type="text" name="reply" class="yd-input" placeholder="Reply to this review..." value="${fb.adminReply}" style="flex:1;padding:9px 14px;border-radius:10px;">
            <button type="submit" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:9px 18px;"><i class="bi bi-send"></i></button>
          </form>
        </div>
      </div>
      </c:forEach>
    </div>
  </div>
</div>

<!-- Add Food Modal -->
<div id="addFoodModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;overflow-y:auto;padding:20px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:30px;max-width:560px;width:100%;animation:scaleIn .3s var(--ease);">
    <h4 style="font-family:var(--font-display);margin-bottom:20px;">➕ Add Food Item</h4>
    <form action="/admin/food/add" method="post">
      <div class="row g-3">
        <div class="col-12 yd-form-group"><label class="yd-label">Name *</label><input type="text" name="name" class="yd-input" required></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Description</label><textarea name="description" class="yd-input" rows="2" style="resize:none;"></textarea></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Price (LKR) *</label><input type="number" name="price" class="yd-input" step="0.01" required></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Category</label><select name="category" class="yd-input"><option>Breakfast</option><option>Lunch</option><option>Dinner</option><option>Others</option></select></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Food Type</label><select name="foodType" class="yd-input"><option>MainCourse</option><option>Beverage</option><option>Dessert</option></select></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Calories</label><input type="number" name="calories" class="yd-input" value="0"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Portion Size</label><input type="text" name="portionSize" class="yd-input" placeholder="e.g. 350g"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Ingredients</label><input type="text" name="ingredients" class="yd-input" placeholder="Rice, Chicken, Spices"></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Image URL</label><input type="text" name="imageUrl" class="yd-input" placeholder="https://..."></div>
      </div>
      <div class="d-flex gap-2 mt-2">
        <button type="submit" class="yd-btn yd-btn-primary" style="flex:1;">Add to Menu</button>
        <button type="button" onclick="document.getElementById('addFoodModal').style.display='none'" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- Edit Food Modal -->
<div id="editFoodModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;overflow-y:auto;padding:20px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:30px;max-width:560px;width:100%;animation:scaleIn .3s var(--ease);">
    <h4 style="font-family:var(--font-display);margin-bottom:20px;">✏️ Edit Food Item</h4>
    <form action="/admin/food/update" method="post">
      <input type="hidden" name="id" id="ef_id">
      <div class="row g-3">
        <div class="col-12 yd-form-group"><label class="yd-label">Name</label><input type="text" name="name" id="ef_name" class="yd-input" required></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Description</label><textarea name="description" id="ef_desc" class="yd-input" rows="2" style="resize:none;"></textarea></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Price (LKR)</label><input type="number" name="price" id="ef_price" class="yd-input" step="0.01"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Category</label><select name="category" id="ef_cat" class="yd-input"><option>Breakfast</option><option>Lunch</option><option>Dinner</option><option>Others</option></select></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Calories</label><input type="number" name="calories" id="ef_calories" class="yd-input"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Portion Size</label><input type="text" name="portionSize" id="ef_portion" class="yd-input"></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Ingredients</label><input type="text" name="ingredients" id="ef_ingredients" class="yd-input"></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Image URL</label><input type="text" name="imageUrl" id="ef_img" class="yd-input"></div>
        <div class="col-12"><label style="display:flex;align-items:center;gap:10px;cursor:pointer;font-size:.9rem;font-weight:600;"><input type="checkbox" name="available" id="ef_avail" style="accent-color:var(--c-orange);width:18px;height:18px;"> Available on Menu</label></div>
      </div>
      <div class="d-flex gap-2 mt-3">
        <button type="submit" class="yd-btn yd-btn-primary" style="flex:1;">Save Changes</button>
        <button type="button" onclick="document.getElementById('editFoodModal').style.display='none'" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- Edit User/Driver Modal -->
<div id="editUserModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;padding:20px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:30px;max-width:460px;width:100%;animation:scaleIn .3s var(--ease);">
    <h4 style="font-family:var(--font-display);margin-bottom:20px;">✏️ Edit User / Driver</h4>
    <form action="/admin/user/update" method="post">
      <input type="hidden" name="id" id="eu_id">
      <div class="row g-3">
        <div class="col-12 yd-form-group"><label class="yd-label">Full Name</label><input type="text" name="name" id="eu_name" class="yd-input"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Phone</label><input type="text" name="phone" id="eu_phone" class="yd-input"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Address</label><input type="text" name="address" id="eu_addr" class="yd-input"></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Profile Photo URL</label><input type="text" name="profilePicUrl" id="eu_pic" class="yd-input" placeholder="https://... (for drivers)"></div>
      </div>
      <div class="d-flex gap-2 mt-2">
        <button type="submit" class="yd-btn yd-btn-primary" style="flex:1;">Save Changes</button>
        <button type="button" onclick="document.getElementById('editUserModal').style.display='none'" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- Add Driver Modal -->
<div id="addDriverModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;padding:20px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:30px;max-width:440px;width:100%;animation:scaleIn .3s var(--ease);">
    <h4 style="font-family:var(--font-display);margin-bottom:20px;">🛵 Add Driver</h4>
    <form action="/admin/driver/add" method="post">
      <div class="row g-3">
        <div class="col-12 yd-form-group"><label class="yd-label">Full Name</label><input type="text" name="name" class="yd-input" required></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Email</label><input type="email" name="email" class="yd-input" required></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Phone</label><input type="text" name="phone" class="yd-input"></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Password</label><input type="password" name="password" class="yd-input" required></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Profile Photo URL</label><input type="text" name="photoUrl" class="yd-input" placeholder="https://..."></div>
      </div>
      <div class="d-flex gap-2 mt-2">
        <button type="submit" class="yd-btn yd-btn-primary" style="flex:1;">Add Driver</button>
        <button type="button" onclick="document.getElementById('addDriverModal').style.display='none'" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- Add Offer Modal -->
<div id="addOfferModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;align-items:center;justify-content:center;padding:20px;">
  <div style="background:var(--c-surface);border-radius:24px;padding:30px;max-width:420px;width:100%;animation:scaleIn .3s var(--ease);">
    <h4 style="font-family:var(--font-display);margin-bottom:20px;">🎁 Add Promo Offer</h4>
    <form action="/admin/offer/add" method="post">
      <div class="row g-3">
        <div class="col-12 yd-form-group"><label class="yd-label">Code (e.g. FIRST20)</label><input type="text" name="code" class="yd-input" style="text-transform:uppercase;letter-spacing:2px;" required></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Title</label><input type="text" name="title" class="yd-input" placeholder="e.g. 20% Off Your First Order!" required></div>
        <div class="col-12 yd-form-group"><label class="yd-label">Description</label><input type="text" name="description" class="yd-input" placeholder="e.g. First-time customers only"></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Discount %</label><input type="number" name="discountPercent" class="yd-input" min="1" max="80" required></div>
        <div class="col-6 yd-form-group"><label class="yd-label">Min Order (LKR)</label><input type="number" name="minOrder" class="yd-input" value="0"></div>
      </div>
      <div class="d-flex gap-2 mt-2">
        <button type="submit" class="yd-btn yd-btn-primary" style="flex:1;">Add Offer</button>
        <button type="button" onclick="document.getElementById('addOfferModal').style.display='none'" class="yd-btn yd-btn-outline" style="color:var(--c-muted);">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script>
// Tab switching
function admTab(name) {
  document.querySelectorAll('.adm-pane').forEach(p => p.style.display='none');
  document.querySelectorAll('.yd-admin-tab').forEach(t => t.classList.remove('active'));
  document.getElementById('pane' + name).style.display = 'block';
  document.getElementById('at' + name).classList.add('active');
}
const urlTab = new URLSearchParams(location.search).get('tab');
if (urlTab) { const m={food:'Food',orders:'Orders',users:'Users',drivers:'Drivers',offers:'Offers',feedback:'Feedback',kanban:'Kanban'}; if(m[urlTab]) admTab(m[urlTab]); }

// Edit food
async function editFood(id) {
  var r = await fetch('/admin/food/get/' + id);
  var f = await r.json();
  document.getElementById('ef_id').value          = f.id;
  document.getElementById('ef_name').value        = f.name;
  document.getElementById('ef_desc').value        = f.description;
  document.getElementById('ef_price').value       = f.price;
  document.getElementById('ef_cat').value         = f.category;
  document.getElementById('ef_ingredients').value = f.ingredients || '';
  document.getElementById('ef_portion').value     = f.portionSize || '';
  document.getElementById('ef_calories').value    = f.calories;
  document.getElementById('ef_img').value         = f.imageUrl || '';
  document.getElementById('ef_avail').checked     = f.available;
  document.getElementById('editFoodModal').style.display = 'flex';
}

function editUser(id, name, phone, address, pic) {
  document.getElementById('eu_id').value    = id;
  document.getElementById('eu_name').value  = name;
  document.getElementById('eu_phone').value = phone;
  document.getElementById('eu_addr').value  = address;
  document.getElementById('eu_pic').value   = pic || '';
  document.getElementById('editUserModal').style.display = 'flex';
}

// Start admin poller — plays sound + shows alert on new orders
YDAdminPoller.start();
YDPush.request();

// ── Live Kanban refresh every 15s without page reload ────────────
var kanbanLastHash = '';
async function refreshKanban() {
  try {
    var r = await fetch('/api/admin/stats');
    if (!r.ok) return;
    var d = await r.json();
    // Update stat counters
    var hash = JSON.stringify(d);
    if (hash === kanbanLastHash) return; // no change
    kanbanLastHash = hash;
    // Update order count badge in nav
    var badge = document.getElementById('adminNewBadge');
    if (badge && d.activeOrders !== undefined) {
      badge.textContent = d.activeOrders > 0 ? d.activeOrders : '';
    }
    // If on kanban tab, reload it silently
    if (document.getElementById('paneKanban').style.display !== 'none') {
      // Reload just kanban section via fetch
      var rk = await fetch('/admin/dashboard?tab=kanban&ajax=1');
      // Full reload is simplest - only do it if data changed
      location.reload();
    }
  } catch(e) {}
}
// Refresh kanban every 15 seconds (only if on kanban tab)
setInterval(function() {
  if (document.getElementById('paneKanban').style.display !== 'none') {
    location.reload();
  }
}, 20000);
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
