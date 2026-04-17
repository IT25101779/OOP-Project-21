<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Contact Us"/>
<c:set var="pageId"    value="contact"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.contact-hero{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:56px 0;position:relative;overflow:hidden;}
.contact-hero::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 70% 50%,rgba(255,107,53,.18) 0%,transparent 55%);}
.contact-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:20px;padding:24px;text-align:center;transition:all .3s var(--ease);cursor:pointer;}
.contact-card:hover{transform:translateY(-5px);box-shadow:var(--shadow-lg);border-color:var(--c-orange);}
.contact-icon{width:56px;height:56px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:1.4rem;margin:0 auto 14px;}
.faq-item{background:var(--c-surface);border:1px solid var(--c-border);border-radius:14px;margin-bottom:10px;overflow:hidden;transition:border-color .2s;}
.faq-item:hover{border-color:var(--c-orange);}
.faq-q{padding:16px 20px;font-weight:600;cursor:pointer;display:flex;justify-content:space-between;align-items:center;font-size:.9rem;}
.faq-a{padding:0 20px 16px;font-size:.875rem;color:var(--c-muted);line-height:1.7;display:none;}
.faq-a.open{display:block;animation:fadeUp .25s var(--ease);}
</style>

<div class="yd-page">
  <!-- Hero -->
  <div class="contact-hero">
    <div class="container" style="max-width:760px;position:relative;z-index:1;text-align:center;">
      <div style="font-size:3.5rem;margin-bottom:16px;animation:float 3s ease-in-out infinite;">💬</div>
      <h1 style="font-family:var(--font-display);color:white;font-size:2.5rem;margin-bottom:8px;">We're here to help</h1>
      <p style="color:rgba(255,255,255,.6);font-size:1rem;">Questions, feedback, or issues? Our team replies within 2 hours.</p>
    </div>
  </div>

  <div class="container py-5" style="max-width:860px;">

    <!-- Contact methods -->
    <div class="row g-3 mb-5">
      <div class="col-md-4 yd-fade">
        <a href="tel:+94812345678" style="text-decoration:none;">
          <div class="contact-card">
            <div class="contact-icon" style="background:#E3F2FD;"><span style="font-size:1.4rem;">📞</span></div>
            <h6 class="fw-bold mb-1">Call Us</h6>
            <p style="color:var(--c-muted);font-size:.82rem;margin:0;">+94 81 234 5678</p>
            <p style="color:var(--c-muted);font-size:.75rem;margin-top:4px;">Mon–Sun 7am–11pm</p>
          </div>
        </a>
      </div>
      <div class="col-md-4 yd-fade">
        <a href="mailto:hello@yummydish.lk" style="text-decoration:none;">
          <div class="contact-card">
            <div class="contact-icon" style="background:#FFF3E0;"><span style="font-size:1.4rem;">📧</span></div>
            <h6 class="fw-bold mb-1">Email Us</h6>
            <p style="color:var(--c-muted);font-size:.82rem;margin:0;">hello@yummydish.lk</p>
            <p style="color:var(--c-muted);font-size:.75rem;margin-top:4px;">Reply within 2 hours</p>
          </div>
        </a>
      </div>
      <div class="col-md-4 yd-fade">
        <a href="https://wa.me/94812345678" target="_blank" style="text-decoration:none;">
          <div class="contact-card" style="border-color:rgba(37,211,102,.3);">
            <div class="contact-icon" style="background:#E8F5E9;"><span style="font-size:1.4rem;">📱</span></div>
            <h6 class="fw-bold mb-1" style="color:#2E7D32;">WhatsApp</h6>
            <p style="color:var(--c-muted);font-size:.82rem;margin:0;">+94 81 234 5678</p>
            <p style="color:#388E3C;font-size:.75rem;margin-top:4px;font-weight:600;">Chat now →</p>
          </div>
        </a>
      </div>
    </div>

    <div class="row g-4">
      <!-- Contact form -->
      <div class="col-md-7 yd-fade">
        <div class="yd-card">
          <div class="yd-card-body">
            <h4 style="font-family:var(--font-display);margin-bottom:4px;">Send a Message</h4>
            <p style="color:var(--c-muted);font-size:.875rem;margin-bottom:24px;">We'll get back to you within 2 hours.</p>

            <c:if test="${not empty success}">
              <div style="background:#E8F5E9;border:1px solid #A5D6A7;border-radius:12px;padding:14px 16px;margin-bottom:20px;display:flex;align-items:center;gap:10px;">
                <span style="font-size:1.2rem;">✅</span>
                <span style="color:#2E7D32;font-size:.875rem;"><c:out value="${success}"/></span>
              </div>
            </c:if>
            <c:if test="${not empty error}">
              <div style="background:#FFEBEE;border:1px solid #FFCDD2;border-radius:12px;padding:14px 16px;margin-bottom:20px;color:#C62828;font-size:.875rem;">
                <c:out value="${error}"/>
              </div>
            </c:if>

            <form action="/contact" method="post">
              <div class="yd-form-group">
                <label class="yd-label">Your Name</label>
                <input type="text" name="contactName" class="yd-input" placeholder="Saman Perera" required
                       value="${not empty user ? user.name : ""}">
              </div>
              <div class="yd-form-group">
                <label class="yd-label">Email Address</label>
                <input type="email" name="contactEmail" class="yd-input" placeholder="you@example.com" required
                       value="${not empty user ? user.email : ""}">
              </div>
              <div class="yd-form-group">
                <label class="yd-label">Subject</label>
                <select name="subject" class="yd-input">
                  <option>Order Issue</option>
                  <option>Food Quality</option>
                  <option>Delivery Problem</option>
                  <option>Account Help</option>
                  <option>Feedback &amp; Suggestions</option>
                  <option>Other</option>
                </select>
              </div>
              <div class="yd-form-group">
                <label class="yd-label">Message</label>
                <textarea name="message" class="yd-input" rows="5" placeholder="How can we help you today?" required style="resize:vertical;"></textarea>
              </div>
              <button type="submit" class="yd-btn yd-btn-primary">
                <i class="bi bi-send me-2"></i>Send Message
              </button>
            </form>
          </div>
        </div>
      </div>

      <!-- FAQ -->
      <div class="col-md-5 yd-fade">
        <h5 class="fw-bold mb-3">❓ Frequently Asked</h5>
        <div class="faq-item">
          <div class="faq-q" onclick="toggleFaq(this)"><span>How long does delivery take?</span><i class="bi bi-plus"></i></div>
          <div class="faq-a">Our average delivery time is 25–35 minutes within Kandy city. You can track your driver live on the map.</div>
        </div>
        <div class="faq-item">
          <div class="faq-q" onclick="toggleFaq(this)"><span>Can I cancel my order?</span><i class="bi bi-plus"></i></div>
          <div class="faq-a">Yes! You can cancel within 2 minutes of placing your order from the Orders page. After that, cancellation is not possible as cooking has begun.</div>
        </div>
        <div class="faq-item">
          <div class="faq-q" onclick="toggleFaq(this)"><span>What payment methods do you accept?</span><i class="bi bi-plus"></i></div>
          <div class="faq-a">We accept Cash on Delivery and Credit/Debit cards. You can save your card for faster checkout.</div>
        </div>
        <div class="faq-item">
          <div class="faq-q" onclick="toggleFaq(this)"><span>How do loyalty points work?</span><i class="bi bi-plus"></i></div>
          <div class="faq-a">Earn 1 point for every LKR 10 spent. 100 points = LKR 10 discount on your next order. Points never expire!</div>
        </div>
        <div class="faq-item">
          <div class="faq-q" onclick="toggleFaq(this)"><span>Do you deliver outside Kandy?</span><i class="bi bi-plus"></i></div>
          <div class="faq-a">Currently we deliver within Kandy city limits only. We're expanding soon — stay tuned!</div>
        </div>
        <div class="faq-item">
          <div class="faq-q" onclick="toggleFaq(this)"><span>What are group orders?</span><i class="bi bi-plus"></i></div>
          <div class="faq-a">Group orders let multiple people order together in one delivery. Create a room, share the 6-digit code, everyone adds their items, and the creator places the order.</div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
function toggleFaq(el) {
  var answer = el.nextElementSibling;
  var icon   = el.querySelector('i');
  var isOpen = answer.classList.contains('open');
  // Close all
  document.querySelectorAll('.faq-a').forEach(function(a){ a.classList.remove('open'); });
  document.querySelectorAll('.faq-q i').forEach(function(i){ i.className = 'bi bi-plus'; });
  if (!isOpen) {
    answer.classList.add('open');
    icon.className = 'bi bi-dash';
  }
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
