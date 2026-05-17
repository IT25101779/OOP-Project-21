<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign In" scope="request"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="kg-auth-wrap">
  <!-- Background pattern -->
  <div class="kg-auth-bg-pattern"></div>

  <!-- Decorative logo watermark -->
  <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);opacity:.03;pointer-events:none;z-index:0;">
    <img src="/images/logo-round.png" alt="" style="width:500px;height:500px;object-fit:contain;"
         onerror="this.style.display='none'">
  </div>

  <div class="kg-auth-card" style="position:relative;z-index:1;">
    <!-- Logo -->
    <div class="kg-auth-logo">
      <img src="/images/logo-main.png" alt="කටගැස්ම" onerror="this.style.display='none'">
      <div class="kg-auth-logo-name" style="font-family:'UN-Gurulugomi','Noto Serif Sinhala',serif;font-size:2.8rem;font-weight:400;letter-spacing:.02em;">කටගැස්ම</div>
      <div class="kg-auth-logo-sub">Authentic Sri Lankan Eats</div>
    </div>

    <div class="text-center mb-4">
      <h2 style="font-family:var(--font-serif);font-size:1.4rem;color:var(--c-text);margin-bottom:4px;">Welcome Back</h2>
      <p style="font-size:.85rem;color:var(--c-text3);">Sign in to continue your culinary journey</p>
    </div>

    <!-- Error message -->
    <c:if test="${not empty error}">
      <div class="mb-4 p-3 rounded-3" style="background:rgba(192,57,43,.08);border:1px solid rgba(192,57,43,.2);color:var(--spice-red);font-size:.85rem;display:flex;align-items:center;gap:8px;">
        <i class="bi bi-exclamation-circle-fill"></i>
        <span><c:out value="${error}"/></span>
      </div>
    </c:if>

    <form method="post" action="/login">
      <!-- Email -->
      <div class="kg-form-group">
        <label class="kg-label" for="email">Email Address</label>
        <div class="kg-input-icon">
          <i class="bi bi-envelope kg-icon"></i>
          <input id="email" name="email" type="email" class="kg-input" placeholder="your@email.com" required autocomplete="email">
        </div>
      </div>

      <!-- Password -->
      <div class="kg-form-group">
        <div class="d-flex justify-content-between align-items-center mb-1">
          <label class="kg-label mb-0" for="password">Password</label>
          <a href="/forgot-password" style="font-size:.75rem;color:var(--copper);">Forgot password?</a>
        </div>
        <div class="kg-input-icon" style="position:relative;">
          <i class="bi bi-lock kg-icon"></i>
          <input id="password" name="password" type="password" class="kg-input" placeholder="Enter your password" required autocomplete="current-password" style="padding-right:44px;">
          <button type="button" id="pwToggle" style="position:absolute;right:14px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--c-text3);padding:0;" onclick="togglePw()">
            <i class="bi bi-eye" id="pwIcon"></i>
          </button>
        </div>
      </div>

      <!-- Stay logged in -->
      <div class="d-flex align-items-center gap-2 mb-4">
        <input type="checkbox" name="stayLoggedIn" id="stayLoggedIn" value="true"
          style="width:16px;height:16px;accent-color:var(--copper);cursor:pointer;">
        <label for="stayLoggedIn" style="font-size:.83rem;color:var(--c-text3);cursor:pointer;margin:0;">
          Stay logged in for 30 days
        </label>
      </div>

      <!-- Submit -->
      <button type="submit" class="kg-btn kg-btn-primary mb-4">
        <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
      </button>
    </form>

    <div class="kg-divider">or continue with</div>

    <!-- Google sign-in -->
    <button type="button" class="kg-social-btn kg-social-google mb-4" id="googleSignInBtn">
      <svg width="18" height="18" viewBox="0 0 24 24">
        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
      </svg>
      Continue with Google
    </button>

    <p class="text-center" style="font-size:.85rem;color:var(--c-text3);">
      Don't have an account?
      <a href="/signup" style="color:var(--copper);font-weight:600;">Join Free</a>
    </p>
  </div>
</div>

<script>
function togglePw() {
  var inp = document.getElementById('password');
  var icon = document.getElementById('pwIcon');
  if(inp.type === 'password') {
    inp.type = 'text';
    icon.className = 'bi bi-eye-slash';
  } else {
    inp.type = 'password';
    icon.className = 'bi bi-eye';
  }
}

// Google OAuth (if configured)
var clientId = '${googleOAuthClientId}';
if(clientId) {
  var script = document.createElement('script');
  script.src = 'https://accounts.google.com/gsi/client';
  script.async = true;
  document.head.appendChild(script);
  script.onload = function() {
    google.accounts.id.initialize({
      client_id: clientId,
      callback: function(response) {
        var token = response.credential;
        var payload = JSON.parse(atob(token.split('.')[1]));
        var form = document.createElement('form');
        form.method = 'POST'; form.action = '/social-login';
        [['name', payload.name||''], ['email', payload.email||''], ['pic', payload.picture||'']].forEach(function(f){
          var inp = document.createElement('input');
          inp.type='hidden'; inp.name=f[0]; inp.value=f[1];
          form.appendChild(inp);
        });
        document.body.appendChild(form);
        form.submit();
      }
    });
    document.getElementById('googleSignInBtn').addEventListener('click', function(){
      google.accounts.id.prompt();
    });
  };
}
</script>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
