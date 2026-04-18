<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign In"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<!-- Google Identity Services -->
<script src="https://accounts.google.com/gsi/client" async defer onload="window.onGsiLoad && window.onGsiLoad()"></script>
<style>
.auth-wrap{min-height:calc(100vh - 66px);display:grid;grid-template-columns:1fr 500px;}
@media(max-width:900px){.auth-wrap{grid-template-columns:1fr}.auth-left-panel{display:none!important}}
.auth-left-panel{
  background:linear-gradient(155deg,#0F0F0F 0%,#1a1a1a 100%);
  position:relative;overflow:hidden;
  display:flex;flex-direction:column;align-items:center;justify-content:center;padding:60px;
}
.auth-left-panel::before{
  content:'';position:absolute;inset:0;
  background:radial-gradient(circle at 18% 82%,rgba(255,107,53,.25) 0%,transparent 55%),
             radial-gradient(circle at 82% 18%,rgba(255,107,53,.12) 0%,transparent 50%);
}
.particle-dot{position:absolute;border-radius:50%;background:var(--c-orange);pointer-events:none;}
.auth-right-panel{
  display:flex;flex-direction:column;justify-content:center;
  padding:52px 56px;background:var(--c-bg);overflow-y:auto;
}
@media(max-width:540px){.auth-right-panel{padding:36px 24px;}}
.social-btn{
  width:100%;padding:12px 16px;border-radius:12px;border:1.5px solid var(--c-border);
  background:var(--c-surface);font-family:'Inter',sans-serif;font-weight:600;font-size:.9rem;
  display:flex;align-items:center;justify-content:center;gap:12px;
  cursor:pointer;transition:all .22s var(--ease);color:var(--c-text);
}
.social-btn:hover{border-color:var(--c-orange);background:var(--c-orange-l);transform:translateY(-2px);}
.google-btn:hover{border-color:#4285F4;background:#F0F4FF;}
.divider{display:flex;align-items:center;gap:12px;color:var(--c-muted);font-size:.78rem;margin:18px 0;}
.divider::before,.divider::after{content:'';flex:1;height:1px;background:var(--c-border);}
/* Google One Tap override */
#g_id_onload{position:absolute;top:0;left:0;}
.g_id_signin{margin-bottom:4px;}
</style>

<div class="auth-wrap yd-page">
  <!-- Brand left -->
  <div class="auth-left-panel">
    <div id="ptcls" style="position:absolute;inset:0;overflow:hidden;pointer-events:none;"></div>
    <div style="position:relative;z-index:1;text-align:center;color:white;max-width:360px;">
      <div style="font-size:5rem;margin-bottom:14px;animation:float 3s ease-in-out infinite;">🍽️</div>
      <h1 style="font-family:var(--font-display);font-size:3rem;color:white;margin-bottom:10px;">YummyDish</h1>
      <p style="color:rgba(255,255,255,.6);margin-bottom:32px;">Sri Lanka's finest food, delivered fast.</p>
      <div style="display:flex;flex-direction:column;gap:10px;">
        <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:13px 18px;text-align:left;display:flex;align-items:center;gap:12px;">
          <span style="font-size:1.3rem;">⚡</span>
          <div><div style="font-weight:700;font-size:.9rem;">Lightning Fast</div><div style="font-size:.78rem;opacity:.65;">Avg delivery under 30 min</div></div>
        </div>
        <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:13px 18px;text-align:left;display:flex;align-items:center;gap:12px;">
          <span style="font-size:1.3rem;">📍</span>
          <div><div style="font-weight:700;font-size:.9rem;">Live Tracking</div><div style="font-size:.78rem;opacity:.65;">Watch your driver in real time</div></div>
        </div>
        <div style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);border-radius:12px;padding:13px 18px;text-align:left;display:flex;align-items:center;gap:12px;">
          <span style="font-size:1.3rem;">⭐</span>
          <div><div style="font-weight:700;font-size:.9rem;">Loyalty Rewards</div><div style="font-size:.78rem;opacity:.65;">Earn points on every order</div></div>
        </div>
      </div>
    </div>
  </div>

  <!-- Form right -->
  <div class="auth-right-panel">
    <div style="max-width:400px;width:100%;margin:0 auto;">
      <a href="/" style="display:inline-flex;align-items:center;gap:6px;color:var(--c-muted);font-size:.85rem;margin-bottom:28px;text-decoration:none;">
        <i class="bi bi-arrow-left"></i> Back
      </a>
      <h2 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:4px;">Welcome back 👋</h2>
      <p style="color:var(--c-muted);margin-bottom:24px;">Sign in to your YummyDish account</p>

      <c:if test="${not empty param.error}">
        <div style="background:#FFEBEE;border:1px solid #FFCDD2;border-radius:12px;padding:12px 16px;margin-bottom:18px;font-size:.875rem;color:#C62828;">
          <i class="bi bi-exclamation-circle me-2"></i>Invalid email or password.
        </div>
      </c:if>
      <c:if test="${not empty error}">
        <div style="background:#FFEBEE;border:1px solid #FFCDD2;border-radius:12px;padding:12px 16px;margin-bottom:18px;font-size:.875rem;color:#C62828;">
          <i class="bi bi-exclamation-circle me-2"></i><c:out value="${error}"/>
        </div>
      </c:if>

      <!-- Google Sign-In Button (real GSI) -->
      <div id="g_id_onload"
           data-client_id="${googleOAuthClientId}"
           data-callback="handleGoogleSignIn"
           data-auto_prompt="false">
      </div>
      <button class="social-btn google-btn mb-2" onclick="startGoogleSignIn()">
        <svg width="20" height="20" viewBox="0 0 48 48">
          <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
          <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
          <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
          <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
        </svg>
        Continue with Google
      </button>

      <div class="divider">or sign in with email</div>

      <!-- Email form -->
      <form action="/login" method="post" id="loginForm">
        <div class="yd-form-group">
          <label class="yd-label">Email Address</label>
          <input type="email" name="email" class="yd-input" placeholder="you@example.com" required autofocus>
        </div>
        <div class="yd-form-group">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:7px;">
            <label class="yd-label" style="margin:0;">Password</label>
            <a href="/forgot-password" style="font-size:.78rem;color:var(--c-orange);">Forgot password?</a>
          </div>
          <div style="position:relative;">
            <input type="password" name="password" id="pwdField" class="yd-input" placeholder="••••••••" required>
            <button type="button" onclick="var f=document.getElementById('pwdField');f.type=f.type==='password'?'text':'password';" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--c-muted);cursor:pointer;font-size:1rem;"><i class="bi bi-eye"></i></button>
          </div>
        </div>
        <label style="display:flex;align-items:center;gap:8px;font-size:.82rem;color:var(--c-muted);margin-bottom:18px;cursor:pointer;">
          <input type="checkbox" name="stayLoggedIn" style="accent-color:var(--c-orange);"> Stay signed in
        </label>
        <button type="submit" class="yd-btn yd-btn-primary">
          <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
        </button>
      </form>

      <p style="text-align:center;color:var(--c-muted);font-size:.875rem;margin-top:20px;">
        Don't have an account? <a href="/signup" style="color:var(--c-orange);font-weight:700;">Sign up free</a>
      </p>
    </div>
  </div>
</div>

<div id="googleBtnContainer" style="display:none;"></div>
<!-- Hidden social login form -->
<form id="socialForm" action="/social-login" method="post" style="display:none;">
  <input type="hidden" name="name"  id="sl_name">
  <input type="hidden" name="email" id="sl_email">
  <input type="hidden" name="pic"   id="sl_pic">
</form>

<script>
// ── Google Sign-In via Identity Services ─────────────────────────
var GOOGLE_CLIENT_ID = '${googleOAuthClientId}';

function handleGoogleSignIn(response) {
  if (!response || !response.credential) return;
  try {
    var payload = JSON.parse(atob(response.credential.split('.')[1]));
    document.getElementById('sl_name').value  = payload.name    || '';
    document.getElementById('sl_email').value = payload.email   || '';
    document.getElementById('sl_pic').value   = payload.picture || '';
    document.getElementById('socialForm').submit();
  } catch(e) { showToast('Google sign-in error. Try email login.'); }
}

function startGoogleSignIn() {
  if (!GOOGLE_CLIENT_ID || GOOGLE_CLIENT_ID.trim() === '') {
    // No client ID configured - show helpful message
    showToast('Google sign-in not configured. Please use email login or contact admin.');
    return;
  }
  if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
    google.accounts.id.prompt(function(notification) {
      if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
        // One Tap not shown - trigger popup flow
        google.accounts.id.renderButton(
          document.getElementById('googleBtnContainer'),
          { theme: 'outline', size: 'large', width: 360 }
        );
        document.getElementById('googleBtnContainer').click();
      }
    });
  } else {
    showToast('Loading Google Sign-In...'); 
    setTimeout(startGoogleSignIn, 1000);
  }
}

// Init GSI when script loads
function initGoogleSignIn() {
  if (!GOOGLE_CLIENT_ID || GOOGLE_CLIENT_ID.trim() === '') return;
  if (typeof google === 'undefined' || !google.accounts) return;
  google.accounts.id.initialize({
    client_id:           GOOGLE_CLIENT_ID,
    callback:            handleGoogleSignIn,
    auto_select:         false,
    cancel_on_tap_outside: true,
    ux_mode:             'popup'
  });
}

// Try to init when GSI loads
document.addEventListener('DOMContentLoaded', function() {
  if (typeof google !== 'undefined' && google.accounts) initGoogleSignIn();
});
// GSI async callback
window.onGsiLoad = function() { initGoogleSignIn(); };

// ── Particles ─────────────────────────────────────────────────────
(function() {
  var c = document.getElementById('ptcls'); if (!c) return;
  for (var i = 0; i < 18; i++) {
    var p = document.createElement('div');
    p.className = 'particle-dot';
    var s = 3 + Math.random() * 7;
    p.style.cssText = 'width:'+s+'px;height:'+s+'px;left:'+Math.random()*100+'%;top:'+Math.random()*100+'%;opacity:'+(0.1+Math.random()*0.3)+';animation:drift '+(8+Math.random()*12)+'s linear '+(Math.random()*-10)+'s infinite;';
    c.appendChild(p);
  }
})();
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
