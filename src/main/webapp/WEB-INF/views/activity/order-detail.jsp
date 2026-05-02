<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Receipt #${order.orderId}"/>
<c:set var="pageId"    value="activity"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
@media print {
  .yd-nav,.yd-bottom-nav,.no-print,#yd-toast,#notif-container,#yd-cursor,#yd-cursor-ring,.page-transition{display:none!important;}
  body{background:white!important;}
  .receipt-wrap{box-shadow:none!important;border:none!important;max-width:100%!important;}
}
.receipt-wrap{max-width:560px;margin:0 auto;padding:0 16px 40px;}
.receipt-header{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:28px;border-radius:20px 20px 0 0;position:relative;overflow:hidden;}
.receipt-header::before{content:'';position:absolute;top:-30px;right:-30px;width:120px;height:120px;border-radius:50%;background:rgba(255,107,53,.12);}
.receipt-body{background:var(--c-surface);border:1px solid var(--c-border);border-top:none;border-radius:0 0 20px 20px;padding:24px;}
.receipt-divider{border:none;border-top:2px dashed var(--c-border);margin:18px 0;}
.item-row{display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--c-border);}
.item-row:last-child{border-bottom:none;}
.receipt-line{display:flex;justify-content:space-between;padding:6px 0;font-size:.875rem;}
.receipt-total{display:flex;justify-content:space-between;font-weight:800;font-size:1.1rem;padding:12px 0 0;border-top:2px solid var(--c-border);margin-top:8px;}
.status-timeline{padding:16px 0;}
.tl-step{display:flex;align-items:center;gap:14px;padding:8px 0;position:relative;}
.tl-step:not(:last-child)::after{content:'';position:absolute;left:15px;top:38px;width:2px;height:calc(100% - 12px);background:var(--c-border);}
.tl-step.done::after{background:var(--c-orange);}
.tl-dot{width:32px;height:32px;border-radius:50%;border:2.5px solid var(--c-border);display:flex;align-items:center;justify-content:center;font-size:.9rem;flex-shrink:0;}
.tl-step.done .tl-dot{background:var(--c-orange);border-color:var(--c-orange);color:white;}
.tl-step.active .tl-dot{border-color:var(--c-orange);background:var(--c-orange-l);}
</style>

<div class="yd-page py-4">
  <div class="receipt-wrap">

    <!-- Back button -->
    <a href="/activity" class="yd-btn yd-btn-outline yd-btn-sm mb-4 no-print" style="width:auto;">
      <i class="bi bi-arrow-left me-1"></i>Back to Orders
    </a>

    <!-- Receipt card -->
    <div class="yd-fade">
      <!-- Header -->
      <div class="receipt-header">
        <div style="position:relative;z-index:1;display:flex;justify-content:space-between;align-items:flex-start;">
          <div>
            <div style="font-family:var(--font-display);font-size:1.5rem;color:white;margin-bottom:2px;">YummyDish</div>
            <div style="font-size:.72rem;color:rgba(255,255,255,.5);letter-spacing:2px;text-transform:uppercase;">Digital Receipt</div>
          </div>
          <div style="text-align:right;">
            <div style="font-family:monospace;font-weight:800;font-size:1rem;color:white;">#${order.orderId}</div>
            <div style="font-size:.72rem;color:rgba(255,255,255,.5);margin-top:3px;">${order.createdAt}</div>
          </div>
        </div>
        <div style="position:relative;z-index:1;margin-top:20px;display:flex;align-items:center;gap:10px;">
          <span class="yd-status" id="statusBadgeEl" style="font-size:.8rem;">${order.statusBadge}</span>
          <span style="color:rgba(255,255,255,.5);font-size:.82rem;">${order.paymentMethod}</span>
          <c:if test="${fn:length(order.orderType)>0 && order.orderType != 'STANDARD'}">
            <span style="background:rgba(255,107,53,.2);color:var(--c-orange);padding:3px 10px;border-radius:20px;font-size:.72rem;font-weight:700;">${order.orderType}</span>
          </c:if>
        </div>
      </div>

      <!-- Body -->
      <div class="receipt-body">

        <!-- Items -->
        <div style="margin-bottom:8px;">
          <c:forEach items="${order.items}" var="item">
          <div class="item-row">
            <img src="${item.imageUrl}" style="width:44px;height:44px;border-radius:10px;object-fit:cover;flex-shrink:0;" onerror="this.style.display='none'">
            <div style="flex:1;">
              <div style="font-weight:600;font-size:.9rem;">${item.foodName}</div>
              <div style="font-size:.75rem;color:var(--c-muted);">LKR <fmt:formatNumber value="${item.price}" pattern="#,##0"/> × ${item.quantity}</div>
            </div>
            <div style="font-weight:700;color:var(--c-orange);">LKR <fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0"/></div>
          </div>
          </c:forEach>
        </div>

        <hr class="receipt-divider">

        <!-- Pricing breakdown -->
        <div class="receipt-line"><span style="color:var(--c-muted);">Subtotal</span><span>LKR <fmt:formatNumber value="${order.subtotal}" pattern="#,##0"/></span></div>
        <div class="receipt-line"><span style="color:var(--c-muted);">Delivery Fee</span><span>LKR <fmt:formatNumber value="${order.deliveryFee}" pattern="#,##0"/></span></div>
        <c:if test="${order.tip > 0}">
          <div class="receipt-line"><span style="color:var(--c-muted);">Driver Tip</span><span>LKR <fmt:formatNumber value="${order.tip}" pattern="#,##0"/></span></div>
        </c:if>
        <c:if test="${order.weatherFee > 0}">
          <div class="receipt-line"><span style="color:#E65100;">Weather Surcharge</span><span style="color:#E65100;">LKR <fmt:formatNumber value="${order.weatherFee}" pattern="#,##0"/></span></div>
        </c:if>
        <c:if test="${order.discount > 0}">
          <div class="receipt-line"><span style="color:var(--c-success);">Discount (${order.offerCode})</span><span style="color:var(--c-success);">- LKR <fmt:formatNumber value="${order.discount}" pattern="#,##0"/></span></div>
        </c:if>
        <div class="receipt-total">
          <span>Total Paid</span>
          <span style="color:var(--c-orange);">LKR <fmt:formatNumber value="${order.totalAmount}" pattern="#,##0"/></span>
        </div>

        <c:if test="${order.loyaltyPoints > 0}">
          <div style="margin-top:10px;padding:10px 14px;background:linear-gradient(135deg,#FFF8E1,#FFFDE7);border-radius:12px;border:1px solid #FFE082;display:flex;align-items:center;gap:8px;">
            <span style="font-size:1.2rem;">⭐</span>
            <span style="font-size:.82rem;color:#E65100;font-weight:600;">You earned <strong>${order.loyaltyPoints}</strong> loyalty points on this order!</span>
          </div>
        </c:if>

        <hr class="receipt-divider">

        <!-- Delivery info -->
        <c:if test="${fn:length(order.deliveryAddress) > 0}">
        <div style="margin-bottom:16px;">
          <div style="font-size:.72rem;font-weight:700;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:10px;">Delivery Details</div>
          <div style="font-size:.875rem;color:var(--c-text2);margin-bottom:6px;display:flex;align-items:flex-start;gap:7px;"><span>📍</span><span>${order.deliveryAddress}</span></div>
          <c:if test="${fn:length(order.driverName) > 0}">
            <div style="font-size:.875rem;color:var(--c-text2);display:flex;align-items:center;gap:7px;"><span>🛵</span><span>${order.driverName} — ${order.driverContact}</span></div>
          </c:if>
          <c:if test="${fn:length(order.chefNote) > 0}">
            <div style="margin-top:8px;padding:8px 12px;background:var(--c-orange-l);border-radius:10px;font-size:.8rem;color:var(--c-text2);">👨‍🍳 Note to Chef: ${order.chefNote}</div>
          </c:if>
        </div>
        </c:if>

        <!-- Status timeline -->
        <div style="font-size:.72rem;font-weight:700;color:var(--c-muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;">Order Journey</div>
        <div class="status-timeline">
          <c:set var="prog" value="${order.statusProgress}"/>
          <div class="tl-step done"><div class="tl-dot">✓</div><div><div style="font-weight:600;font-size:.875rem;">Order Placed</div><div style="font-size:.72rem;color:var(--c-muted);">${order.createdAt}</div></div></div>
          <div class="tl-step ${prog >= 25 ? 'done' : ''}"><div class="tl-dot">🍳</div><div><div style="font-weight:600;font-size:.875rem;">Cooking</div></div></div>
          <div class="tl-step ${prog >= 45 ? 'done' : ''}"><div class="tl-dot">📦</div><div><div style="font-weight:600;font-size:.875rem;">Ready for Pickup</div></div></div>
          <div class="tl-step ${prog >= 82 ? 'done' : ''}"><div class="tl-dot">🛵</div><div><div style="font-weight:600;font-size:.875rem;">On the Way</div></div></div>
          <div class="tl-step ${prog >= 100 ? 'done' : ''}"><div class="tl-dot">✅</div><div><div style="font-weight:600;font-size:.875rem;">Delivered</div></div></div>
        </div>

        <hr class="receipt-divider">

        <!-- Action buttons -->
        <div class="d-flex gap-2 no-print">
          <button onclick="window.print()" class="yd-btn yd-btn-outline" style="flex:1;color:var(--c-muted);">
            <i class="bi bi-printer me-1"></i>Print
          </button>
          <button onclick="shareOnWhatsApp('${order.orderId}',[],${order.totalAmount})" class="yd-wa-btn" style="flex:1;justify-content:center;">
            📱 Share
          </button>
          <c:if test="${order.status != 'CANCELLED'}">
          <button onclick="reorder('${order.orderId}')" class="yd-btn yd-btn-primary yd-btn-sm" style="flex:1;padding:10px;">
            🔄 Reorder
          </button>
          </c:if>
        </div>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
