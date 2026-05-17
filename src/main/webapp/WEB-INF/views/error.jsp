<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Error"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<div class="kg-error-wrap kg-page">
  <img src="/images/logo-main.png" alt="" style="width:80px;height:80px;object-fit:contain;opacity:.3;" onerror="this.style.display='none'">
  <div class="kg-error-code"><c:out value="${errorCode}"/></div>
  <h2 style="font-family:var(--font-serif);font-size:1.8rem;color:var(--c-text);"><c:out value="${errorMessage}"/></h2>
  <p style="color:var(--c-text3);max-width:400px;line-height:1.7;">
    Something went wrong. Please try again or go back to the menu.
  </p>
  <div class="d-flex gap-3 justify-content-center flex-wrap">
    <a href="/menu" class="kg-btn kg-btn-primary" style="width:auto;padding:13px 28px;">
      <i class="bi bi-house me-2"></i>Go to Menu
    </a>
    <a href="javascript:history.back()" class="kg-btn kg-btn-ghost" style="width:auto;padding:13px 28px;">
      ← Go Back
    </a>
  </div>
</div>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
