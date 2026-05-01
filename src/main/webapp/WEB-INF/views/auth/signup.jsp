<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Account"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<script src="https://accounts.google.com/gsi/client" async defer onload="window.onGsiLoad && window.onGsiLoad()"></script>
<style>
.auth-wrap{min-height:calc(100vh - 66px);display:grid;grid-template-columns:1fr 540px;}
@media(max-width:900px){.auth-wrap{grid-template-columns:1fr}.auth-left-panel{display:none!important}}
.auth-left-panel{background:linear-gradient(155deg,#0F0F0F,#1a1a1a);position:relative;overflow:hidden;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:60px;}
.auth-left-panel::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 18% 82%,rgba(255,107,53,.25) 0%,transparent 55%);}
.auth-right-panel{display:flex;flex-direction:column;justify-content:center;padding:48px 52px;background:var(--c-bg);overflow-y:auto;}
@media(max-width:540px){.auth-right-panel{padding:32px 20px;}}
.social-btn{width:100%;padding:12px 16px;border-radius:12px;border:1.5px solid var(--c-border);background:var(--c-surface);font-family:'Inter',sans-serif;font-weight:600;font-size:.9rem;display:flex;align-items:center;justify-content:center;gap:12px;cursor:pointer;transition:all .22s var(--ease);color:var(--c-text);}
.social-btn:hover{border-color:#4285F4;background:#F0F4FF;transform:translateY(-2px);}
.divider{display:flex;align-items:center;gap:12px;color:var(--c-muted);font-size:.78rem;margin:16px 0;}
.divider::before,.divider::after{content:'';flex:1;height:1px;background:var(--c-border);}
</style>

<div class="auth-wrap yd-page">
  <div class="auth-left-panel">
    <div style="position:relative;z-index:1;text-align:center;color:white;max-width:340px;">
      <div style="font-size:4.5rem;margin-bottom:14px;animation:float 3s ease-in-out infinite;">🎉</div>
      <h1 style="font-family:var(--font-display);font-size:2.6rem;color:white;margin-bottom:10px;">Join YummyDish</h1>
      <p style="color:rgba(255,255,255,.6);margin-bottom:24px;">Your first order awaits!</p>
      <div style="background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:18px 20px;text-align:left;">
        <div style="font-weight:700;margin-bottom:8px;font-size:.9rem;">🏷️ New member perks</div>
        <div style="font-size:.82rem;opacity:.8;line-height:1.9;">
          ✓ Use code <strong>WELCOME20</strong> for 20% off<br>
          ✓ Earn loyalty points on every order<br>
          ✓ Live GPS order tracking<br>
          ✓ Group &amp; scheduled orders
        </div>
      </div>
    </div>
  </div>

  <div class="auth-right-panel">
    <div style="max-width:440px;width:100%;margin:0 auto;">
      <a href="/login" style="display:inline-flex;align-items:center;gap:6px;color:var(--c-muted);font-size:.85rem;margin-bottom:24px;text-decoration:none;"><i class="bi bi-arrow-left"></i> Sign in instead</a>
      <h2 style="font-family:var(--font-display);font-size:2rem;margin-bottom:4px;">Create Account</h2>
      <p style="color:var(--c-muted);margin-bottom:20px;font-size:.875rem;">Free to join. Ready to eat in 60 seconds.</p>

      <c:if test="${not empty error}">
        <div style="background:#FFEBEE;border:1px solid #FFCDD2;border-radius:12px;padding:12px 16px;margin-bottom:16px;font-size:.875rem;color:#C62828;">
          <i class="bi bi-exclamation-circle me-2"></i><c:out value="${error}"/>
        </div>
      </c:if>

      <!-- Google sign-up -->
      <button class="social-btn mb-2" onclick="startGoogleSignUp()">
        <svg width="20" height="20" viewBox="0 0 48 48">
          <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
          <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
          <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
          <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
        </svg>
        Sign up with Google
      </button>

      <div class="divider">or sign up with email</div>

      <form action="/signup" method="post">
        <div class="row g-3">
          <div class="col-12 yd-form-group">
            <label class="yd-label">Full Name</label>
            <input type="text" name="name" class="yd-input" placeholder="Saman Perera" required autofocus>
          </div>
          <div class="col-12 yd-form-group">
            <label class="yd-label">Email Address</label>
            <input type="email" name="email" class="yd-input" placeholder="you@example.com" required>
          </div>
          <div class="col-6 yd-form-group">
            <label class="yd-label">Phone</label>
            <input type="text" name="phone" class="yd-input" placeholder="07X XXX XXXX">
          </div>
          <div class="col-6 yd-form-group">
            <label class="yd-label">Password</label>
            <div style="position:relative;">
              <input type="password" name="password" id="pwdInput" class="yd-input" placeholder="Min 6 chars" required minlength="6" oninput="checkPwdStrength(this.value)">
              <button type="button" onclick="var f=document.getElementById('pwdInput');f.type=f.type==='password'?'text':'password';" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--c-muted);cursor:pointer;"><i class="bi bi-eye"></i></button>
            </div>
            <div style="margin-top:6px;">
              <div style="height:4px;background:var(--c-border);border-radius:99px;overflow:hidden;"><div id="strengthBar" style="height:100%;width:0%;border-radius:99px;transition:all .3s;"></div></div>
              <div id="strengthLbl" style="font-size:.7rem;margin-top:3px;color:var(--c-muted);"></div>
            </div>
          </div>
          <div class="col-12 yd-form-group">
            <label class="yd-label">Delivery Address (Kandy area)</label>
            <input type="text" name="address" class="yd-input" placeholder="e.g. 15 Dalada Veediya, Kandy">
          </div>
        </div>
        <div style="font-size:.75rem;color:var(--c-muted);margin-bottom:14px;">
          By signing up you agree to our <a href="/about" style="color:var(--c-orange);">Terms</a>.
        </div>
        <button type="submit" class="yd-btn yd-btn-primary">
          <i class="bi bi-person-plus me-2"></i>Create Account
        </button>
      </form>
    </div>
  </div>
</div>

<!-- Hidden social form -->
<form id="socialForm" action="/social-login" method="post" style="display:none;">
  <input type="hidden" name="name"  id="sl_name">
  <input type="hidden" name="email" id="sl_email">
  <input type="hidden" name="pic"   id="sl_pic">
</form>

<script>
var GOOGLE_CLIENT_ID = '${googleOAuthClientId}';

function handleGoogleSignIn(response) {
  if (!response || !response.credential) return;
  try {
    var payload = JSON.parse(atob(response.credential.split('.')[1]));
    document.getElementById('sl_name').value  = payload.name    || '';
    document.getElementById('sl_email').value = payload.email   || '';
    document.getElementById('sl_pic').value   = payload.picture || '';
    document.getElementById('socialForm').submit();
  } catch(e) { showToast('Google error. Use email signup.'); }
}

function startGoogleSignUp() {
  if (!GOOGLE_CLIENT_ID || GOOGLE_CLIENT_ID.trim() === '') {
    showToast('Google sign-in not configured. Please use email signup.');
    return;
  }
  if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
    google.accounts.id.prompt();
  } else {
    showToast('Loading Google Sign-In...'); setTimeout(startGoogleSignUp, 1000);
  }
}

function initGoogleSignIn() {
  if (!GOOGLE_CLIENT_ID || GOOGLE_CLIENT_ID.trim() === '') return;
  if (typeof google === 'undefined' || !google.accounts) return;
  google.accounts.id.initialize({
    client_id: GOOGLE_CLIENT_ID, callback: handleGoogleSignIn,
    auto_select: false, ux_mode: 'popup'
  });
}
window.onGsiLoad = function() { initGoogleSignIn(); };
document.addEventListener('DOMContentLoaded', function() {
  if (typeof google !== 'undefined') initGoogleSignIn();
});

// Password strength
function checkPwdStrength(pwd) {
  var bar = document.getElementById('strengthBar');
  var lbl = document.getElementById('strengthLbl');
  if (!bar || !lbl) return;
  var score = 0;
  if (pwd.length >= 6)  score++;
  if (pwd.length >= 10) score++;
  if (/[A-Z]/.test(pwd)) score++;
  if (/[0-9]/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  var cfg = [
    {w:'0%',bg:'',t:''},
    {w:'25%',bg:'#f44336',t:'Weak'},
    {w:'50%',bg:'#FF9800',t:'Fair'},
    {w:'75%',bg:'#FFC107',t:'Good'},
    {w:'90%',bg:'#4CAF50',t:'Strong'},
    {w:'100%',bg:'#2E7D32',t:'Very Strong ✓'}
  ];
  var c = cfg[Math.min(score,5)];
  bar.style.width = c.w; bar.style.background = c.bg;
  lbl.textContent = c.t; lbl.style.color = c.bg || 'var(--c-muted)';
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
