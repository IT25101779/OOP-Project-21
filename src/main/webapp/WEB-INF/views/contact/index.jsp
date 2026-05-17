<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Contact Us"/>
<c:set var="pageId"    value="contact"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.kg-contact-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:var(--r-lg);padding:24px;text-align:center;transition:all var(--dur) var(--ease);}
.kg-contact-card:hover{transform:translateY(-5px);box-shadow:var(--shadow-lg);border-color:var(--c-border-b);}
.kg-faq-item{background:var(--c-surface);border:1px solid var(--c-border);border-radius:var(--r-lg);margin-bottom:10px;overflow:hidden;transition:border-color .2s;}
.kg-faq-item:hover{border-color:var(--c-border-b);}
.kg-faq-q{padding:16px 20px;font-weight:600;cursor:pointer;display:flex;justify-content:space-between;align-items:center;font-size:.9rem;color:var(--c-text);}
.kg-faq-a{padding:0 20px 16px;font-size:.875rem;color:var(--c-text3);line-height:1.7;display:none;}
.kg-faq-a.open{display:block;animation:fadeUp .25s var(--ease);}
</style>

<div class="kg-page">
  <!-- Hero -->
  <section style="background:linear-gradient(135deg,var(--brown-dark),#2C1810);padding:64px 0;position:relative;overflow:hidden;">
    <div style="position:absolute;inset:0;background:radial-gradient(circle at 70% 50%,rgba(139,69,19,.25) 0%,transparent 55%);"></div>
    <div class="container" style="max-width:760px;position:relative;z-index:1;text-align:center;">
      <div style="font-size:3.5rem;margin-bottom:16px;">💬</div>
      <h1 style="font-family:var(--font-serif);color:var(--cream);font-size:2.5rem;margin-bottom:8px;">We're here to help</h1>
      <p style="color:rgba(245,240,232,.6);font-size:1rem;">Questions, feedback, or issues? Our team replies within 2 hours.</p>
    </div>
  </section>

  <div class="container py-5" style="max-width:860px;">

    <!-- Contact methods -->
    <div class="row g-3 mb-5">
      <div class="col-md-4 kg-fade">
        <a href="tel:+94812345678" style="text-decoration:none;">
          <div class="kg-contact-card">
            <div style="font-size:2.5rem;margin-bottom:14px;">📞</div>
            <h6 class="kg-step-title">Call Us</h6>
            <p style="color:var(--c-text3);font-size:.82rem;margin:0;">+94 81 234 5678</p>
            <p style="color:var(--c-text3);font-size:.75rem;margin-top:4px;">Mon–Sun 7am–11pm</p>
          </div>
        </a>
      </div>
      <div class="col-md-4 kg-fade">
        <a href="mailto:hello@katagasma.lk" style="text-decoration:none;">
          <div class="kg-contact-card">
            <div style="font-size:2.5rem;margin-bottom:14px;">📧</div>
            <h6 class="kg-step-title">Email Us</h6>
            <p style="color:var(--c-text3);font-size:.82rem;margin:0;">hello@katagasma.lk</p>
            <p style="color:var(--c-text3);font-size:.75rem;margin-top:4px;">Reply within 2 hours</p>
          </div>
        </a>
      </div>
      <div class="col-md-4 kg-fade">
        <a href="https://wa.me/94812345678" target="_blank" style="text-decoration:none;">
          <div class="kg-contact-card" style="border-color:rgba(46,125,50,.3);">
            <div style="font-size:2.5rem;margin-bottom:14px;">📱</div>
            <h6 style="font-family:var(--font-serif);color:var(--leaf-green);margin-bottom:4px;">WhatsApp</h6>
            <p style="color:var(--c-text3);font-size:.82rem;margin:0;">+94 81 234 5678</p>
            <p style="color:var(--leaf-green);font-size:.75rem;margin-top:4px;font-weight:600;">Chat now →</p>
          </div>
        </a>
      </div>
    </div>

    <div class="row g-4">
      <!-- Contact form -->
      <div class="col-md-7 kg-fade">
        <div class="kg-card">
          <div class="kg-card-body">
            <h4 style="font-family:var(--font-serif);margin-bottom:4px;">Send a Message</h4>
            <p style="color:var(--c-text3);font-size:.875rem;margin-bottom:24px;">We'll get back to you within 2 hours.</p>

            <c:if test="${not empty success}">
              <div class="mb-3 p-3 rounded-3" style="background:rgba(46,125,50,.08);border:1px solid rgba(46,125,50,.2);color:var(--leaf-green);font-size:.875rem;">
                ✅ <c:out value="${success}"/>
              </div>
            </c:if>
            <c:if test="${not empty error}">
              <div class="mb-3 p-3 rounded-3" style="background:rgba(192,57,43,.08);border:1px solid rgba(192,57,43,.2);color:var(--spice-red);font-size:.875rem;">
                <c:out value="${error}"/>
              </div>
            </c:if>

            <form action="/contact" method="post">
              <div class="kg-form-group">
                <label class="kg-label">Your Name</label>
                <input type="text" name="contactName" class="kg-input" placeholder="Saman Perera" required value="${not empty user ? user.name : ''}">
              </div>
              <div class="kg-form-group">
                <label class="kg-label">Email Address</label>
                <input type="email" name="contactEmail" class="kg-input" placeholder="you@example.com" required value="${not empty user ? user.email : ''}">
              </div>
              <div class="kg-form-group">
                <label class="kg-label">Message</label>
                <textarea name="message" class="kg-input" rows="5" placeholder="How can we help you today?" required style="resize:vertical;"></textarea>
              </div>
              <button type="submit" class="kg-btn kg-btn-primary">
                <i class="bi bi-send me-2"></i>Send Message
              </button>
            </form>
          </div>
        </div>
      </div>

      <!-- FAQ -->
      <div class="col-md-5 kg-fade">
        <h5 style="font-family:var(--font-serif);margin-bottom:16px;">❓ Frequently Asked</h5>
        <div class="kg-faq-item"><div class="kg-faq-q" onclick="toggleFaq(this)"><span>How long does delivery take?</span><i class="bi bi-plus"></i></div><div class="kg-faq-a">Our average delivery time is 25–35 minutes within Kandy. Track your driver live on the map.</div></div>
        <div class="kg-faq-item"><div class="kg-faq-q" onclick="toggleFaq(this)"><span>Can I cancel my order?</span><i class="bi bi-plus"></i></div><div class="kg-faq-a">Yes! You can cancel within 2 minutes of placing from the Orders page. After that, cooking has started.</div></div>
        <div class="kg-faq-item"><div class="kg-faq-q" onclick="toggleFaq(this)"><span>What payment methods do you accept?</span><i class="bi bi-plus"></i></div><div class="kg-faq-a">Cash on Delivery and Credit/Debit cards. Save your card for faster checkout.</div></div>
        <div class="kg-faq-item"><div class="kg-faq-q" onclick="toggleFaq(this)"><span>How do loyalty points work?</span><i class="bi bi-plus"></i></div><div class="kg-faq-a">Earn 1 point per LKR 10 spent. 100 points = LKR 10 off your next order. Points never expire!</div></div>
        <div class="kg-faq-item"><div class="kg-faq-q" onclick="toggleFaq(this)"><span>Do you deliver outside Kandy?</span><i class="bi bi-plus"></i></div><div class="kg-faq-a">Currently Kandy city only. Expanding soon — stay tuned!</div></div>
        <div class="kg-faq-item"><div class="kg-faq-q" onclick="toggleFaq(this)"><span>What are group orders?</span><i class="bi bi-plus"></i></div><div class="kg-faq-a">Multiple people order together in one delivery. Create a room, share the 6-digit code, everyone adds items, creator places the order.</div></div>
      </div>
    </div>
  </div>
</div>

<script>
function toggleFaq(el) {
  var answer=el.nextElementSibling, icon=el.querySelector('i'), isOpen=answer.classList.contains('open');
  document.querySelectorAll('.kg-faq-a').forEach(function(a){a.classList.remove('open');});
  document.querySelectorAll('.kg-faq-q i').forEach(function(i){i.className='bi bi-plus';});
  if(!isOpen){answer.classList.add('open');icon.className='bi bi-dash';}
}
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
