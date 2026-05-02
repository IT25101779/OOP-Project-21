<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Daily Report"/>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Daily Report — YummyDish</title>
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,700&amp;family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="/css/yummydish.css" rel="stylesheet">
<script>(function(){var t=localStorage.getItem('ydTheme');if(t==='dark')document.documentElement.setAttribute('data-theme','dark');})();</script>
<script src="/js/app.js"></script>
</head>
<body>
<div id="yd-toast"></div>
<style>
@media print {
  .yd-nav,.no-print,#yd-toast,#notif-container,.yd-bottom-nav,#yd-cursor,#yd-cursor-ring,.page-transition{display:none!important;}
  body{background:white!important;font-size:12px;}
  .report-wrap{box-shadow:none!important;padding:0!important;}
  .print-page-break{page-break-before:always;}
}
.report-wrap{max-width:900px;margin:0 auto;padding:32px 20px 60px;}
.stat-tile{background:var(--c-surface);border:1px solid var(--c-border);border-radius:14px;padding:20px 22px;text-align:center;}
.stat-big{font-size:2.2rem;font-weight:800;line-height:1;}
.report-table{width:100%;border-collapse:collapse;font-size:.85rem;}
.report-table th{background:var(--c-bg);padding:10px 14px;font-weight:700;font-size:.72rem;text-transform:uppercase;letter-spacing:.6px;color:var(--c-muted);text-align:left;border-bottom:2px solid var(--c-border);}
.report-table td{padding:10px 14px;border-bottom:1px solid var(--c-border);vertical-align:middle;}
.report-table tbody tr:hover td{background:var(--c-orange-l);}
</style>

<div class="yd-page report-wrap">
  <!-- Header -->
  <div class="d-flex justify-content-between align-items-center mb-4 no-print">
    <div>
      <a href="/admin/dashboard" class="yd-btn yd-btn-outline yd-btn-sm" style="width:auto;"><i class="bi bi-arrow-left me-1"></i>Dashboard</a>
    </div>
    <button onclick="window.print()" class="yd-btn yd-btn-primary" style="width:auto;padding:10px 24px;">
      <i class="bi bi-printer me-2"></i>Print Report
    </button>
  </div>

  <!-- Report header -->
  <div style="text-align:center;margin-bottom:32px;padding-bottom:24px;border-bottom:2px solid var(--c-border);">
    <div style="font-size:2.5rem;margin-bottom:8px;">🍽️</div>
    <h1 style="font-family:var(--font-display);font-size:2rem;margin-bottom:4px;">YummyDish Daily Report</h1>
    <div style="color:var(--c-muted);font-size:.9rem;">${reportDate} · Kandy, Sri Lanka</div>
  </div>

  <!-- Summary stats -->
  <div class="row g-3 mb-5">
    <div class="col-6 col-md-3">
      <div class="stat-tile">
        <div class="stat-big" style="color:var(--c-orange);">${todayOrders}</div>
        <div style="font-size:.78rem;color:var(--c-muted);margin-top:6px;">Orders Today</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-tile">
        <div class="stat-big" style="color:var(--c-success);">${deliveredCount}</div>
        <div style="font-size:.78rem;color:var(--c-muted);margin-top:6px;">Delivered</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-tile">
        <div class="stat-big" style="color:#1565C0;">${cancelledCount}</div>
        <div style="font-size:.78rem;color:var(--c-muted);margin-top:6px;">Cancelled</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-tile">
        <div class="stat-big" style="color:var(--c-orange);font-size:1.5rem;">LKR <fmt:formatNumber value="${todayRevenue}" pattern="#,##0"/></div>
        <div style="font-size:.78rem;color:var(--c-muted);margin-top:6px;">Revenue</div>
      </div>
    </div>
  </div>

  <!-- Today's orders table -->
  <h5 class="fw-bold mb-3">📦 Today's Orders</h5>
  <div style="overflow-x:auto;margin-bottom:40px;">
    <table class="report-table">
      <thead><tr>
        <th>Order ID</th><th>Customer</th><th>Items</th><th>Total</th><th>Payment</th><th>Status</th><th>Time</th>
      </tr></thead>
      <tbody>
        <c:forEach items="${todayOrdersList}" var="o">
        <tr>
          <td style="font-family:monospace;font-weight:700;">#${o.orderId}</td>
          <td>${o.customerName}</td>
          <td style="color:var(--c-muted);font-size:.8rem;">
            <c:forEach items="${o.items}" var="item" varStatus="st">
              ${item.foodName}<c:if test="${!st.last}">, </c:if>
            </c:forEach>
          </td>
          <td style="font-weight:700;color:var(--c-orange);">LKR <fmt:formatNumber value="${o.totalAmount}" pattern="#,##0"/></td>
          <td style="font-size:.8rem;">${o.paymentMethod}</td>
          <td>
            <span style="padding:3px 10px;border-radius:20px;font-size:.72rem;font-weight:700;
              background:${o.status=='DELIVERED'?'#E8F5E9':o.status=='CANCELLED'?'#FFEBEE':'#FFF3E0'};
              color:${o.status=='DELIVERED'?'#2E7D32':o.status=='CANCELLED'?'#C62828':'#E65100'};">
              ${o.statusBadge}
            </span>
          </td>
          <td style="font-size:.8rem;color:var(--c-muted);">${o.createdAt}</td>
        </tr>
        </c:forEach>
        <c:if test="${empty todayOrdersList}">
          <tr><td colspan="7" style="text-align:center;padding:32px;color:var(--c-muted);">No orders today yet</td></tr>
        </c:if>
      </tbody>
    </table>
  </div>

  <!-- Top items today -->
  <div class="row g-4">
    <div class="col-md-6">
      <h5 class="fw-bold mb-3">🍽️ Top Items Today</h5>
      <table class="report-table">
        <thead><tr><th>Item</th><th>Qty Sold</th><th>Revenue</th></tr></thead>
        <tbody>
          <c:forEach items="${topItems}" var="item">
          <tr>
            <td style="font-weight:600;">${item.name}</td>
            <td style="text-align:center;font-weight:700;color:var(--c-orange);">${item.qty}</td>
            <td style="font-weight:600;">LKR <fmt:formatNumber value="${item.revenue}" pattern="#,##0"/></td>
          </tr>
          </c:forEach>
          <c:if test="${empty topItems}">
            <tr><td colspan="3" style="color:var(--c-muted);padding:20px;text-align:center;">No data</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
    <div class="col-md-6">
      <h5 class="fw-bold mb-3">📊 Payment Breakdown</h5>
      <table class="report-table">
        <thead><tr><th>Method</th><th>Orders</th><th>Amount</th></tr></thead>
        <tbody>
          <c:forEach items="${paymentBreakdown}" var="pb">
          <tr>
            <td style="font-weight:600;">${pb.method}</td>
            <td style="text-align:center;font-weight:700;">${pb.count}</td>
            <td style="font-weight:600;">LKR <fmt:formatNumber value="${pb.amount}" pattern="#,##0"/></td>
          </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Footer -->
  <div style="text-align:center;margin-top:48px;padding-top:20px;border-top:1px solid var(--c-border);color:var(--c-muted);font-size:.78rem;">
    Generated by YummyDish Admin · ${reportDate} · Confidential
  </div>
</div>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
