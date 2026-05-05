<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Error"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<div style="min-height:70vh;display:flex;align-items:center;justify-content:center;padding:40px 16px;">
  <div style="text-align:center;max-width:480px;">
    <div style="font-size:5rem;margin-bottom:20px;">&#x1F37D;&#xFE0F;</div>
    <h1 style="font-family:var(--font-display);font-size:2.2rem;margin-bottom:12px;color:var(--c-text);">
      <c:out value="${errorCode}"/> &mdash; <c:out value="${errorMessage}"/>
    </h1>
    <p style="color:var(--c-muted);margin-bottom:32px;line-height:1.7;">
      Something went wrong. Please try again or go back to the menu.
    </p>
    <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">
      <a href="/menu" class="yd-btn yd-btn-primary" style="width:auto;padding:12px 28px;"><i class="bi bi-house me-2"></i>Go to Menu</a>
      <a href="javascript:history.back()" class="yd-btn" style="width:auto;padding:12px 28px;background:var(--c-surface);border:1px solid var(--c-border);">&#8592; Go Back</a>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
