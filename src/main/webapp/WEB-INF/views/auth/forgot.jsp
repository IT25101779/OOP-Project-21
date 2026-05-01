<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Reset Password"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div style="min-height:calc(100vh - 66px);display:flex;align-items:center;justify-content:center;padding:32px 16px;background:var(--c-bg);" class="yd-page">
  <div style="max-width:420px;width:100%;">
    <div style="text-align:center;margin-bottom:32px;">
      <div style="font-size:4rem;margin-bottom:12px;animation:float 3s ease-in-out infinite;">🔑</div>
      <h2 style="font-family:var(--font-display);font-size:2rem;margin-bottom:6px;">Forgot Password?</h2>
      <p style="color:var(--c-muted);font-size:.9rem;">Enter your email and we'll send a reset link</p>
    </div>

    <c:if test="${not empty error}">
      <div style="background:#FFEBEE;border:1px solid #FFCDD2;border-radius:12px;padding:12px 16px;margin-bottom:18px;font-size:.875rem;color:#C62828;">
        <i class="bi bi-exclamation-circle me-2"></i><c:out value="${error}"/>
      </div>
    </c:if>
    <c:if test="${not empty success}">
      <div style="background:#E8F5E9;border:1px solid #A5D6A7;border-radius:12px;padding:12px 16px;margin-bottom:18px;font-size:.875rem;color:#2E7D32;">
        <i class="bi bi-check-circle me-2"></i><c:out value="${success}"/>
      </div>
    </c:if>

    <div class="yd-card">
      <div class="yd-card-body">
        <form action="/forgot-password" method="post">
          <div class="yd-form-group">
            <label class="yd-label">Email Address</label>
            <input type="email" name="email" class="yd-input" placeholder="you@example.com" required autofocus>
          </div>
          <button type="submit" class="yd-btn yd-btn-primary">
            <i class="bi bi-send me-2"></i>Send Reset Link
          </button>
        </form>
      </div>
    </div>

    <div style="text-align:center;margin-top:20px;">
      <a href="/login" style="color:var(--c-orange);font-weight:600;font-size:.9rem;">
        <i class="bi bi-arrow-left me-1"></i>Back to login
      </a>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
