<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Reset Password"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="kg-auth-wrap kg-page">
  <div class="kg-auth-bg-pattern"></div>
  <div class="kg-auth-card">
    <div class="kg-auth-logo">
      <img src="/images/logo-main.png" alt="කටගැස්ම" onerror="this.style.display='none'">
      <div class="kg-auth-logo-name" style="font-family:'UN-Gurulugomi','Noto Serif Sinhala',serif;font-size:2.8rem;font-weight:400;letter-spacing:.02em;">කටගැස්ම</div>
      <div class="kg-auth-logo-sub">Authentic Sri Lankan Eats</div>
    </div>

    <div class="text-center mb-4">
      <div style="font-size:3rem;margin-bottom:12px;">🔑</div>
      <h2 style="font-family:var(--font-serif);font-size:1.5rem;margin-bottom:4px;">Forgot Password?</h2>
      <p style="color:var(--c-text3);font-size:.875rem;">Enter your email and we'll send a reset link</p>
    </div>

    <c:if test="${not empty error}">
      <div class="mb-3 p-3 rounded-3" style="background:rgba(192,57,43,.08);border:1px solid rgba(192,57,43,.2);color:var(--spice-red);font-size:.85rem;">
        <i class="bi bi-exclamation-circle-fill me-2"></i><c:out value="${error}"/>
      </div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="mb-3 p-3 rounded-3" style="background:rgba(46,125,50,.08);border:1px solid rgba(46,125,50,.2);color:var(--leaf-green);font-size:.85rem;">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${success}"/>
      </div>
    </c:if>

    <div class="kg-card mb-3">
      <div class="kg-card-body">
        <form action="/forgot-password" method="post">
          <div class="kg-form-group">
            <label class="kg-label">Email Address</label>
            <div class="kg-input-icon">
              <i class="bi bi-envelope kg-icon"></i>
              <input type="email" name="email" class="kg-input" placeholder="you@example.com" required autofocus>
            </div>
          </div>
          <button type="submit" class="kg-btn kg-btn-primary">
            <i class="bi bi-send me-2"></i>Send Reset Link
          </button>
        </form>
      </div>
    </div>

    <div class="text-center mt-3">
      <a href="/login" style="color:var(--copper);font-weight:600;font-size:.875rem;">
        <i class="bi bi-arrow-left me-1"></i>Back to Sign In
      </a>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
