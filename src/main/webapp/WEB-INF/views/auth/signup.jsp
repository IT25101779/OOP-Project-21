<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Account"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<script src="https://accounts.google.com/gsi/client" async defer onload="window.onGsiLoad && window.onGsiLoad()"></script>

<div class="kg-auth-wrap kg-page">
  <div class="kg-auth-bg-pattern"></div>

  <!-- Decorative panel (hidden on mobile) -->
  <div style="display:none;" class="d-lg-flex flex-column align-items-center justify-content-center"
       style="background:linear-gradient(155deg,var(--copper-d),var(--copper));min-height:100vh;width:400px;padding:60px;position:relative;overflow:hidden;">
    <div style="position:absolute;top:-60px;right:-60px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.07);"></div>
    <div style="position:relative;z-index:1;text-align:center;color:var(--parchment);">
      <img src="/images/logo-main.png" alt="කටගැස්ම" style="width:100px;height:100px;object-fit:contain;margin:0 auto 20px;" onerror="this.style.display='none'">
      <h2 style="font-family:'UN-Gurulugomi','Noto Serif Sinhala',serif;font-size:2.8rem;font-weight:400;margin-bottom:8px;letter-spacing:.02em;">කටගැස්ම</h2>
      <p style="opacity:.75;margin-bottom:28px;font-size:.9rem;">Join thousands of food lovers</p>
      <div style="background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.2);border-radius:16px;padding:20px;text-align:left;">
        <div style="font-weight:700;margin-bottom:10px;">🏷️ New member perks</div>
        <div style="font-size:.85rem;opacity:.85;line-height:2;">
          ✓ Use code <strong>WELCOME20</strong> for 20% off<br>
          ✓ Earn loyalty points every order<br>
          ✓ Live GPS order tracking<br>
          ✓ Group &amp; scheduled orders
        </div>
      </div>
    </div>
  </div>

  <div class="kg-auth-card">
    <div class="kg-auth-logo">
      <img src="/images/logo-main.png" alt="කටගැස්ම" onerror="this.style.display='none'">
      <div class="kg-auth-logo-name" style="font-family:'UN-Gurulugomi','Noto Serif Sinhala',serif;font-size:2.8rem;font-weight:400;letter-spacing:.02em;">කටගැස්ම</div>
      <div class="kg-auth-logo-sub">Authentic Sri Lankan Eats</div>
    </div>

    <div class="text-center mb-4">
      <h2 style="font-family:var(--font-serif);font-size:1.5rem;color:var(--c-text);margin-bottom:4px;">Create Account</h2>
      <p style="font-size:.85rem;color:var(--c-text3);">Free to join. Ready to eat in 60 seconds.</p>
    </div>

    <c:if test="${not empty error}">
      <div class="mb-3 p-3 rounded-3" style="background:rgba(192,57,43,.08);border:1px solid rgba(192,57,43,.2);color:var(--spice-red);font-size:.85rem;">
        <i class="bi bi-exclamation-circle-fill me-2"></i><c:out value="${error}"/>
      </div>
    </c:if>

    <!-- Google signup -->
    <button class="kg-social-btn kg-social-google mb-2" onclick="startGoogleSignUp()">
      <svg width="18" height="18" viewBox="0 0 48 48">
        <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
        <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
        <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
        <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
      </svg>
      Continue with Google
    </button>

    <div class="kg-divider">or sign up with email</div>

    <form action="/signup" method="post">
      <div class="row g-3">
        <div class="col-12 kg-form-group">
          <label class="kg-label">Full Name</label>
          <input type="text" name="name" class="kg-input" placeholder="Saman Perera" required autofocus>
        </div>
        <div class="col-12 kg-form-group">
          <label class="kg-label">Email Address</label>
          <input type="email" name="email" class="kg-input" placeholder="you@example.com" required>
        </div>
        <div class="col-6 kg-form-group">
          <label class="kg-label">Phone</label>
          <input type="text" name="phone" class="kg-input" placeholder="07X XXX XXXX">
        </div>
        <div class="col-6 kg-form-group">
          <label class="kg-label">Password</label>
          <div style="position:relative;">
            <input type="password" name="password" id="pwdInput" class="kg-input" placeholder="Min 6 chars"
                   required minlength="6" oninput="checkPwdStrength(this.value)" style="padding-right:44px;">
            <button type="button"
                    onclick="var f=document.getElementById('pwdInput');f.type=f.type==='password'?'text':'password';"
                    style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--c-text3);cursor:pointer;">
              <i class="bi bi-eye"></i>
            </button>
          </div>
          <div style="margin-top:6px;">
            <div style="height:4px;background:var(--c-border);border-radius:99px;overflow:hidden;">
              <div id="strengthBar" style="height:100%;width:0%;border-radius:99px;transition:all .3s;"></div>
            </div>
            <div id="strengthLbl" style="font-size:.7rem;margin-top:3px;color:var(--c-text3);"></div>
          </div>
        </div>
        <div class="col-12 kg-form-group">
          <label class="kg-label">Delivery Address</label>
          <input type="text" name="address" class="kg-input" placeholder="e.g. 15 Dalada Veediya, Kandy">
        </div>
      </div>
      <div style="font-size:.75rem;color:var(--c-text3);margin-bottom:16px;">
        By signing up you agree to our <a href="/about" style="color:var(--copper);">Terms</a>.
      </div>
      <button type="submit" class="kg-btn kg-btn-primary">
        <i class="bi bi-person-plus me-2"></i>Create Account
      </button>
    </form>

    <p class="text-center mt-3" style="font-size:.85rem;color:var(--c-text3);">
      Already have an account?
      <a href="/login" style="color:var(--copper);font-weight:600;">Sign in</a>
    </p>
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
    var parts = response.credential.split('.');
    var payload = JSON.parse(atob(parts[1] + '=='.slice((parts[1].length * 3) & 3)));
    document.getElementById('sl_name').value  = payload.name    || '';
    document.getElementById('sl_email').value = payload.email   || '';
    document.getElementById('sl_pic').value   = payload.picture || '';
    document.getElementById('socialForm').submit();
  } catch(e) { kgToast('Google error. Please use email signup.','error'); }
}
function startGoogleSignUp() {
  var clientId = GOOGLE_CLIENT_ID ? GOOGLE_CLIENT_ID.trim() : '';
  if (!clientId || clientId.indexOf('YOUR_') >= 0) {
    var email = prompt('Demo Mode: Enter your email to simulate Google Sign-Up');
    if (!email || email.indexOf('@') < 0) return;
    var name = email.split('@')[0].replace(/[._]/g,' ').replace(/\b\w/g,function(c){return c.toUpperCase();});
    document.getElementById('sl_name').value  = name;
    document.getElementById('sl_email').value = email;
    document.getElementById('sl_pic').value   = '';
    document.getElementById('socialForm').submit();
    return;
  }
  if (typeof google !== 'undefined' && google.accounts && google.accounts.id) {
    google.accounts.id.prompt();
  }
}
window.onGsiLoad = function() {
  var clientId = GOOGLE_CLIENT_ID ? GOOGLE_CLIENT_ID.trim() : '';
  if (!clientId || clientId.indexOf('YOUR_') >= 0) return;
  if (typeof google === 'undefined' || !google.accounts) return;
  google.accounts.id.initialize({ client_id: clientId, callback: handleGoogleSignIn, auto_select: false, ux_mode: 'popup' });
};
function checkPwdStrength(pwd) {
  var bar = document.getElementById('strengthBar'), lbl = document.getElementById('strengthLbl');
  if (!bar || !lbl) return;
  var score = 0;
  if (pwd.length >= 6)  score++;
  if (pwd.length >= 10) score++;
  if (/[A-Z]/.test(pwd)) score++;
  if (/[0-9]/.test(pwd)) score++;
  if (/[^A-Za-z0-9]/.test(pwd)) score++;
  var cfg = [{w:'0%',bg:'',t:''},{w:'25%',bg:'#C0392B',t:'Weak'},{w:'50%',bg:'#DAA520',t:'Fair'},{w:'75%',bg:'#CD853F',t:'Good'},{w:'90%',bg:'#2E7D32',t:'Strong'},{w:'100%',bg:'#1B5E20',t:'Very Strong ✓'}];
  var c = cfg[Math.min(score,5)];
  bar.style.width = c.w; bar.style.background = c.bg;
  lbl.textContent = c.t; lbl.style.color = c.bg || 'var(--c-text3)';
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
