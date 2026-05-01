<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin Login — YummyDish</title>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&amp;family=Plus+Jakarta+Sans:wght@400;500;600;700&amp;display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="/css/yummydish.css" rel="stylesheet">
<script>(function(){var t=localStorage.getItem('ydTheme');if(t==='dark')document.documentElement.setAttribute('data-theme','dark');})();</script>
<script src="/js/app.js"></script>
</head>
<body>
<div id="yd-cursor"></div><div id="yd-cursor-ring"></div><div id="yd-toast"></div>
<div class="yd-auth-split">
  <div class="yd-auth-brand" style="background:linear-gradient(160deg,#0a0a1a,#1a1a2e);">
    <div class="yd-auth-particles" id="parts"></div>
    <div class="yd-auth-brand-content yd-splash">
      <div style="font-size:5.5rem;margin-bottom:16px;animation:float 3s ease-in-out infinite;">⚙️</div>
      <h1 class="mb-2">Admin Portal</h1>
      <p style="opacity:.7;letter-spacing:3px;text-transform:uppercase;font-size:.85rem;margin-bottom:40px;">YummyDish Management</p>
      <div class="yd-auth-badge"><i class="bi bi-speedometer2 me-2" style="color:var(--c-orange)"></i>Full dashboard control</div>
      <div class="yd-auth-badge"><i class="bi bi-people me-2" style="color:var(--c-orange)"></i>Manage users & orders</div>
      <div class="yd-auth-badge"><i class="bi bi-graph-up me-2" style="color:var(--c-orange)"></i>Revenue analytics</div>
    </div>
  </div>
  <div class="yd-auth-form">
    <h2 class="mb-1">Admin Sign In</h2>
    <p style="color:var(--c-muted);font-size:.9rem;margin-bottom:28px;">Restricted to administrators only</p>
    <c:if test="${error != null}">
      <div class="alert alert-danger rounded-3 mb-3" style="font-size:.85rem;"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
    </c:if>
    <form action="/admin/login" method="post">
      <div class="yd-form-group">
        <label class="yd-label">Admin Email</label>
        <input type="email" name="email" class="yd-input" placeholder="admin@yummydish.com" required autocomplete="email">
      </div>
      <div class="yd-form-group">
        <label class="yd-label">Password</label>
        <div class="position-relative">
          <input type="password" name="password" id="pwd" class="yd-input" placeholder="••••••••" required>
          <button type="button" onclick="var i=document.getElementById('pwd');i.type=i.type==='password'?'text':'password';"
                  style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;color:#aaa;"><i class="bi bi-eye"></i></button>
        </div>
      </div>
      <button type="submit" class="yd-btn yd-btn-primary">
        <i class="bi bi-shield-lock me-2"></i>Sign In as Admin
      </button>
    </form>
    <div class="mt-4 p-3 rounded-3" style="background:var(--c-bg);font-size:.78rem;color:var(--c-muted);border:1px solid var(--c-border);">
      🔑 Default: <strong style="color:var(--c-text);">admin@yummydish.com</strong> / <strong style="color:var(--c-text);">admin123</strong>
    </div>
    <div class="mt-3 text-center">
      <a href="/login" style="color:var(--c-orange);font-size:.875rem;font-weight:600;">← Customer Login</a>
      &nbsp;·&nbsp;
      <a href="/driver/login" style="color:var(--c-muted);font-size:.875rem;">Driver Login</a>
    </div>
  </div>
</div>
<script>
(function(){var p=document.getElementById('parts');if(!p)return;for(var i=0;i<15;i++){var d=document.createElement('div');d.className='yd-particle';var sz=Math.random()*6+3;d.style.cssText='width:'+sz+'px;height:'+sz+'px;left:'+Math.random()*100+'%;opacity:'+(Math.random()*.4+.1)+';animation-duration:'+(Math.random()*8+6)+'s;animation-delay:'+(Math.random()*-10)+'s;';p.appendChild(d);}})();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body></html>
