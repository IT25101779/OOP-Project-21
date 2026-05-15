<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Authentic Sri Lankan Eats"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>

<style>
@font-face{font-family:'UN-Gurulugomi';src:url('/fonts/UN-Gurulugomi.ttf') format('truetype');font-weight:normal;font-style:normal;font-display:swap;}
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,400;1,700&family=Noto+Sans+Sinhala:wght@400;700&family=Cormorant+Garamond:ital,wght@0,300;0,600;1,300;1,600&display=swap');

.reveal{opacity:0;transform:translateY(40px);transition:opacity .8s cubic-bezier(.22,1,.36,1),transform .8s cubic-bezier(.22,1,.36,1);}
.reveal.left{transform:translateX(-60px);}
.reveal.right{transform:translateX(60px);}
.reveal.scale{transform:scale(.88);}
.reveal.visible{opacity:1!important;transform:none!important;}
.reveal-d1{transition-delay:.1s}.reveal-d2{transition-delay:.2s}.reveal-d3{transition-delay:.3s}
.reveal-d4{transition-delay:.4s}.reveal-d5{transition-delay:.5s}.reveal-d6{transition-delay:.6s}

#kg-cursor-glow{width:300px;height:300px;border-radius:50%;background:radial-gradient(circle,rgba(139,69,19,.12) 0%,transparent 70%);position:fixed;pointer-events:none;z-index:0;transform:translate(-50%,-50%);mix-blend-mode:multiply;}

/* ── HERO ── */
.kg-hero-v2{min-height:100vh;position:relative;overflow:hidden;display:flex;align-items:center;}
.kg-hero-bg-v2{position:absolute;inset:0;z-index:0;background:#0F0A04;}
.kg-hero-img-v2{position:absolute;inset:0;background:url('https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=1600&q=85') center/cover no-repeat;opacity:.45;transition:transform 8s ease-out;transform-origin:center;}
.kg-hero-img-v2.loaded{transform:scale(1.06);}
.kg-hero-grad-v2{position:absolute;inset:0;background:linear-gradient(to right,rgba(15,10,4,.98) 35%,rgba(15,10,4,.7) 60%,rgba(15,10,4,.2) 100%),linear-gradient(to top,rgba(15,10,4,.8) 0%,transparent 40%);}
.kg-particle{position:absolute;border-radius:50%;pointer-events:none;z-index:1;animation:particleFloat linear infinite;}
@keyframes particleFloat{0%{transform:translateY(100vh) rotate(0);opacity:0}10%{opacity:1}90%{opacity:.6}100%{transform:translateY(-80px) rotate(720deg);opacity:0}}
.kg-hero-content-v2{position:relative;z-index:10;width:100%;padding:140px 0 80px;}
.kg-hero-badge-v2{display:inline-flex;align-items:center;gap:10px;background:rgba(245,240,232,.08);backdrop-filter:blur(16px);border:1px solid rgba(205,133,63,.3);border-radius:99px;padding:8px 20px;margin-bottom:28px;animation:badgePulseV2 3s ease-in-out infinite;}
@keyframes badgePulseV2{0%,100%{box-shadow:0 0 0 0 rgba(205,133,63,0)}50%{box-shadow:0 0 0 8px rgba(205,133,63,.08)}}
.kg-stars-v2{display:flex;gap:3px;}
.kg-star-v2{width:14px;height:14px;color:#DAA520;animation:starPop .4s cubic-bezier(.34,1.56,.64,1) both;}
.kg-star-v2:nth-child(1){animation-delay:.05s}.kg-star-v2:nth-child(2){animation-delay:.1s}.kg-star-v2:nth-child(3){animation-delay:.15s}.kg-star-v2:nth-child(4){animation-delay:.2s}.kg-star-v2:nth-child(5){animation-delay:.25s}
@keyframes starPop{from{transform:scale(0) rotate(-30deg)}to{transform:scale(1) rotate(0)}}
.kg-title-sinhala{font-family:'UN-Gurulugomi','Noto Serif Sinhala','Noto Sans Sinhala',serif;font-size:clamp(3.5rem,12vw,9rem);font-weight:400;color:#F5F0E8;line-height:1.05;margin-bottom:8px;letter-spacing:.02em;}
.kg-title-english{font-family:'Playfair Display',serif;font-size:clamp(2.8rem,9vw,6.5rem);font-weight:900;line-height:1;margin-bottom:12px;background:linear-gradient(135deg,#CD853F 0%,#DAA520 40%,#8B4513 70%,#CD853F 100%);background-size:300% 300%;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:goldShimmer 4s ease infinite;}
@keyframes goldShimmer{0%,100%{background-position:0% 50%}50%{background-position:100% 50%}}
.kg-title-sub{font-family:'Cormorant Garamond',serif;font-size:clamp(1.2rem,3vw,1.8rem);font-style:italic;color:#DAA520;margin-bottom:20px;}
.kg-hero-desc-v2{font-size:1.05rem;color:rgba(245,240,232,.7);line-height:1.8;max-width:520px;margin-bottom:36px;}
.kg-cta-primary{display:inline-flex;align-items:center;gap:10px;background:linear-gradient(135deg,#8B4513,#CD853F);color:#FAF7F0;padding:16px 36px;border-radius:99px;font-weight:700;font-size:1rem;text-decoration:none;transition:all .3s cubic-bezier(.34,1.56,.64,1);box-shadow:0 8px 32px rgba(139,69,19,.4);position:relative;overflow:hidden;}
.kg-cta-primary::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,#CD853F,#DAA520);opacity:0;transition:opacity .3s;}
.kg-cta-primary:hover{transform:translateY(-3px) scale(1.02);box-shadow:0 16px 48px rgba(139,69,19,.5);color:#FAF7F0;}
.kg-cta-primary:hover::before{opacity:1;}
.kg-cta-primary span,.kg-cta-primary .kg-arrow{position:relative;z-index:1;}
.kg-cta-primary .kg-arrow{transition:transform .3s;}
.kg-cta-primary:hover .kg-arrow{transform:translateX(4px);}
.kg-cta-secondary{display:inline-flex;align-items:center;gap:10px;background:transparent;color:rgba(245,240,232,.85);padding:16px 32px;border-radius:99px;font-weight:600;font-size:1rem;text-decoration:none;border:1.5px solid rgba(245,240,232,.25);transition:all .3s;backdrop-filter:blur(8px);}
.kg-cta-secondary:hover{background:rgba(245,240,232,.1);border-color:rgba(205,133,63,.5);color:#DAA520;transform:translateY(-2px);}
.kg-stats-v2{display:flex;gap:0;margin-top:48px;padding-top:32px;border-top:1px solid rgba(245,240,232,.1);}
.kg-stat-v2{flex:1;padding-right:28px;position:relative;}
.kg-stat-v2:not(:last-child)::after{content:'';position:absolute;right:0;top:10%;height:80%;width:1px;background:rgba(245,240,232,.1);}
.kg-stat-v2:not(:first-child){padding-left:28px;}
.kg-stat-num-v2{font-family:'Playfair Display',serif;font-size:2.4rem;font-weight:900;color:#CD853F;line-height:1;}
.kg-stat-lbl-v2{font-size:.78rem;color:rgba(245,240,232,.5);margin-top:4px;}
.kg-hero-floats{position:absolute;right:5%;top:50%;transform:translateY(-50%);width:380px;height:500px;z-index:5;}
.kg-float-card{position:absolute;border-radius:20px;overflow:hidden;box-shadow:0 24px 64px rgba(0,0,0,.6);border:2px solid rgba(205,133,63,.2);}
.kg-float-card img{width:100%;height:100%;object-fit:cover;display:block;}
.kg-fc1{width:200px;height:260px;top:0;right:60px;animation:floatA 6s ease-in-out infinite;}
.kg-fc2{width:160px;height:200px;top:80px;right:0;animation:floatB 7s ease-in-out infinite;}
.kg-fc3{width:180px;height:180px;bottom:20px;right:80px;animation:floatC 5s ease-in-out infinite;}
.kg-fc4{width:130px;height:160px;bottom:60px;right:0;animation:floatD 8s ease-in-out infinite;}
@keyframes floatA{0%,100%{transform:translateY(0) rotate(-2deg)}50%{transform:translateY(-18px) rotate(1deg)}}
@keyframes floatB{0%,100%{transform:translateY(0) rotate(3deg)}50%{transform:translateY(-12px) rotate(-1deg)}}
@keyframes floatC{0%,100%{transform:translateY(0) rotate(-1deg)}50%{transform:translateY(-20px) rotate(2deg)}}
@keyframes floatD{0%,100%{transform:translateY(0) rotate(2deg)}50%{transform:translateY(-14px) rotate(-2deg)}}
.kg-scroll-indicator{position:absolute;bottom:32px;left:50%;transform:translateX(-50%);z-index:10;display:flex;flex-direction:column;align-items:center;gap:8px;color:rgba(245,240,232,.4);font-size:.7rem;letter-spacing:.12em;text-transform:uppercase;animation:scrollBounce 2s ease-in-out infinite;}
@keyframes scrollBounce{0%,100%{transform:translateX(-50%) translateY(0)}50%{transform:translateX(-50%) translateY(8px)}}
.kg-scroll-line{width:1px;height:50px;background:linear-gradient(to bottom,rgba(205,133,63,.6),transparent);}

/* ── MARQUEE ── */
.kg-marquee-wrap{background:linear-gradient(135deg,#8B4513,#CD853F,#DAA520,#8B4513);background-size:300% 300%;animation:goldShimmer 5s ease infinite;padding:14px 0;overflow:hidden;position:relative;z-index:5;}
.kg-marquee-track{display:flex;width:max-content;animation:marqueeScroll 25s linear infinite;}
.kg-marquee-item{padding:0 32px;color:rgba(250,247,240,.85);font-size:.82rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;display:flex;align-items:center;gap:12px;white-space:nowrap;}
.kg-marquee-dot{width:4px;height:4px;background:rgba(250,247,240,.4);border-radius:50%;}
@keyframes marqueeScroll{from{transform:translateX(0)}to{transform:translateX(-50%)}}

/* ── DISHES ── */
.kg-dishes-section{padding:100px 0;background:#F5F0E8;position:relative;overflow:hidden;}
.kg-dishes-section::before{content:'';position:absolute;top:0;left:0;right:0;height:1px;background:linear-gradient(to right,transparent,rgba(139,69,19,.2),transparent);}
.kg-texture{position:absolute;inset:0;pointer-events:none;opacity:.025;background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");background-size:256px;}
.kg-section-label{font-size:.72rem;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:#8B4513;display:flex;align-items:center;gap:12px;margin-bottom:12px;}
.kg-section-label::before,.kg-section-label::after{content:'';flex:0 0 32px;height:1px;background:rgba(139,69,19,.3);}
.kg-section-title-v2{font-family:'Playfair Display',serif;font-size:clamp(2.2rem,5vw,3.5rem);font-weight:900;color:#3D2B1F;margin-bottom:14px;line-height:1.1;}
.kg-section-desc-v2{color:#6B4C3B;font-size:1rem;line-height:1.75;max-width:560px;margin:0 auto;}
.kg-food-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:24px;margin-top:60px;}
.kg-food-mag{border-radius:20px;overflow:hidden;background:#FAF7F0;border:1px solid rgba(139,69,19,.1);transition:transform .5s cubic-bezier(.22,1,.36,1),box-shadow .5s;position:relative;cursor:pointer;}
.kg-food-mag:hover{transform:translateY(-10px) scale(1.01);box-shadow:0 32px 80px rgba(61,43,31,.2);}
.kg-food-mag-img{position:relative;height:240px;overflow:hidden;}
.kg-food-mag-img img{width:100%;height:100%;object-fit:cover;transition:transform .7s cubic-bezier(.22,1,.36,1);display:block;}
.kg-food-mag:hover .kg-food-mag-img img{transform:scale(1.08);}
.kg-food-mag-overlay{position:absolute;inset:0;background:linear-gradient(to top,rgba(61,43,31,.7) 0%,transparent 50%);opacity:0;transition:opacity .4s;display:flex;align-items:flex-end;padding:16px;}
.kg-food-mag:hover .kg-food-mag-overlay{opacity:1;}
.kg-food-mag-quick{background:rgba(250,247,240,.95);color:#8B4513;border-radius:99px;padding:8px 18px;font-size:.8rem;font-weight:700;transform:translateY(10px);transition:transform .3s .1s;border:none;cursor:pointer;font-family:'Lato',sans-serif;white-space:nowrap;text-decoration:none;display:inline-block;}
.kg-food-mag:hover .kg-food-mag-quick{transform:translateY(0);}
.kg-ribbon{position:absolute;top:16px;left:-4px;background:#8B4513;color:#FAF7F0;font-size:.62rem;font-weight:800;padding:4px 14px 4px 10px;letter-spacing:.08em;text-transform:uppercase;clip-path:polygon(0 0,100% 0,calc(100% - 8px) 50%,100% 100%,0 100%);}
.kg-food-mag-body{padding:18px 20px 22px;}
.kg-food-mag-name{font-family:'Playfair Display',serif;font-size:1.1rem;font-weight:700;color:#3D2B1F;margin-bottom:2px;transition:color .2s;}
.kg-food-mag:hover .kg-food-mag-name{color:#8B4513;}
.kg-food-mag-sinhala{font-family:'UN-Gurulugomi','Noto Serif Sinhala','Noto Sans Sinhala',serif;font-size:.88rem;color:#9B7B6B;margin-bottom:8px;}
.kg-food-mag-desc{font-size:.82rem;color:#6B4C3B;line-height:1.6;margin-bottom:14px;}
.kg-food-mag-footer{display:flex;align-items:center;justify-content:space-between;padding-top:14px;border-top:1px solid rgba(139,69,19,.1);}
.kg-food-mag-price{font-family:'Playfair Display',serif;font-size:1.3rem;font-weight:700;color:#8B4513;}
.kg-food-mag-meta{display:flex;align-items:center;gap:8px;}
.kg-rating-v2{display:flex;align-items:center;gap:3px;font-size:.78rem;color:#DAA520;font-weight:700;}
.kg-spice-v2{display:flex;gap:2px;}
.kg-flame{font-size:.7rem;opacity:.3;}
.kg-flame.hot{opacity:1;}
.kg-food-feature{grid-column:span 2;}
.kg-food-feature .kg-food-mag-img{height:340px;}

/* ── HOW IT WORKS ── */
.kg-hiw-section{padding:100px 0;background:#3D2B1F;position:relative;overflow:hidden;}
.kg-hiw-section::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse at 10% 50%,rgba(139,69,19,.25) 0%,transparent 50%),radial-gradient(ellipse at 90% 50%,rgba(205,133,63,.15) 0%,transparent 50%);}
.kg-hiw-title{font-family:'Playfair Display',serif;color:#F5F0E8;}
.kg-step-v2{position:relative;padding:40px 32px;background:rgba(245,240,232,.05);border:1px solid rgba(245,240,232,.1);border-radius:24px;backdrop-filter:blur(8px);transition:all .4s cubic-bezier(.22,1,.36,1);overflow:hidden;height:100%;}
.kg-step-v2::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(139,69,19,.15),transparent);opacity:0;transition:opacity .4s;}
.kg-step-v2:hover{transform:translateY(-8px);border-color:rgba(205,133,63,.3);box-shadow:0 24px 60px rgba(0,0,0,.3);}
.kg-step-v2:hover::before{opacity:1;}
.kg-step-num-v2{position:absolute;top:20px;right:24px;font-family:'Playfair Display',serif;font-size:4rem;font-weight:900;line-height:1;color:rgba(245,240,232,.06);user-select:none;}
.kg-step-icon-v2{font-size:2.8rem;margin-bottom:20px;display:block;transition:transform .3s cubic-bezier(.34,1.56,.64,1);}
.kg-step-v2:hover .kg-step-icon-v2{transform:scale(1.15) rotate(-5deg);}
.kg-step-title-v2{font-family:'Playfair Display',serif;font-size:1.2rem;color:#F5F0E8;margin-bottom:4px;font-weight:700;}
.kg-step-sinhala-v2{font-family:'UN-Gurulugomi','Noto Serif Sinhala','Noto Sans Sinhala',serif;font-size:.9rem;color:#DAA520;margin-bottom:12px;}
.kg-step-desc-v2{font-size:.875rem;color:rgba(245,240,232,.6);line-height:1.7;}

/* ── REVIEWS ── */
.kg-review-section{padding:100px 0;background:#FAF7F0;position:relative;}
.kg-review-track{display:flex;overflow:hidden;position:relative;padding:8px 0 24px;}
.kg-review-slide{display:flex;gap:24px;min-width:100%;animation:reviewScroll 35s linear infinite;}
@keyframes reviewScroll{0%{transform:translateX(0)}100%{transform:translateX(-100%)}}
.kg-review-card{flex:0 0 340px;background:#F5F0E8;border:1px solid rgba(139,69,19,.12);border-radius:20px;padding:28px;position:relative;overflow:hidden;}
.kg-review-card::before{content:'"';position:absolute;top:-10px;left:20px;font-family:'Playfair Display',serif;font-size:8rem;color:rgba(139,69,19,.06);line-height:1;}
.kg-review-stars{color:#DAA520;font-size:1rem;margin-bottom:14px;}
.kg-review-text{font-size:.9rem;color:#3D2B1F;line-height:1.75;font-style:italic;margin-bottom:18px;}
.kg-review-author{display:flex;align-items:center;gap:12px;}
.kg-review-av{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#8B4513,#CD853F);color:#FAF7F0;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.9rem;flex-shrink:0;}
.kg-review-name{font-weight:700;font-size:.88rem;color:#3D2B1F;}
.kg-review-dish{font-size:.75rem;color:#8B4513;}

/* ── CTA ── */
.kg-cta-section{padding:120px 0;position:relative;overflow:hidden;background:#0F0A04;}
.kg-cta-bg{position:absolute;inset:0;background:url('https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=1200&q=70') center/cover no-repeat;opacity:.15;}
.kg-cta-grad{position:absolute;inset:0;background:linear-gradient(135deg,rgba(15,10,4,.95),rgba(61,43,31,.85));}
.kg-cta-content{position:relative;z-index:1;text-align:center;}
.kg-cta-sinhala{font-family:'UN-Gurulugomi','Noto Serif Sinhala','Noto Sans Sinhala',serif;font-size:clamp(2.5rem,7vw,5rem);font-weight:400;color:#CD853F;margin-bottom:8px;letter-spacing:.02em;}
.kg-cta-title-v2{font-family:'Cormorant Garamond',serif;font-size:clamp(1.8rem,4vw,3rem);color:#F5F0E8;font-style:italic;margin-bottom:16px;}
.kg-cta-sub{color:rgba(245,240,232,.6);font-size:1rem;margin-bottom:40px;}

@media(max-width:992px){.kg-hero-floats{display:none;}.kg-food-grid{grid-template-columns:repeat(2,1fr);}.kg-food-feature{grid-column:span 1;}.kg-food-feature .kg-food-mag-img{height:240px;}}
@media(max-width:640px){.kg-food-grid{grid-template-columns:1fr;}.kg-stats-v2{gap:0;}.kg-stat-v2{padding:0 16px;}}
</style>

<div id="kg-cursor-glow"></div>

<!-- ══ HERO ══ -->
<section class="kg-hero-v2">
  <div class="kg-hero-bg-v2">
    <div class="kg-hero-img-v2" id="heroImg"></div>
    <div class="kg-hero-grad-v2"></div>
  </div>
  <div id="kg-particles"></div>
  <div class="container-xl kg-hero-content-v2">
    <div class="row">
      <div class="col-lg-7 col-xl-6">
        <div class="kg-hero-badge-v2 reveal reveal-d1">
          <div class="kg-stars-v2">
            <svg class="kg-star-v2" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
            <svg class="kg-star-v2" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
            <svg class="kg-star-v2" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
            <svg class="kg-star-v2" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
            <svg class="kg-star-v2" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
          </div>
          <span style="font-size:.8rem;color:rgba(245,240,232,.75);">Rated 4.9 by 2,000+ food lovers</span>
        </div>
        <h1 class="reveal reveal-d2">
          <span class="kg-title-sinhala">කටගැස්ම</span>
          <span class="kg-title-english d-block">Katagasma</span>
        </h1>
        <p class="kg-title-sub reveal reveal-d3">Authentic Sri Lankan Eats</p>
        <p class="kg-hero-desc-v2 reveal reveal-d3">Experience the rich, aromatic flavors of Sri Lanka delivered straight to your doorstep. From traditional rice &amp; curry to crispy hoppers — taste the island's heritage in every bite.</p>
        <div class="d-flex gap-3 flex-wrap reveal reveal-d4">
          <a href="/menu" class="kg-cta-primary"><span>Explore Menu</span><svg class="kg-arrow" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg></a>
          <a href="#how-it-works" class="kg-cta-secondary">How It Works</a>
        </div>
        <div class="kg-stats-v2 reveal reveal-d5">
          <div class="kg-stat-v2"><div class="kg-stat-num-v2 count-up" data-target="50">0</div><div class="kg-stat-lbl-v2">Traditional Dishes</div></div>
          <div class="kg-stat-v2"><div class="kg-stat-num-v2">30<span style="font-size:1.2rem">min</span></div><div class="kg-stat-lbl-v2">Avg. Delivery</div></div>
          <div class="kg-stat-v2"><div class="kg-stat-num-v2">4.9<span style="font-size:1.2rem">★</span></div><div class="kg-stat-lbl-v2">Customer Rating</div></div>
        </div>
      </div>
    </div>
  </div>
  <div class="kg-hero-floats">
    <div class="kg-float-card kg-fc1"><img src="https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80" alt="Rice and Curry"></div>
    <div class="kg-float-card kg-fc2"><img src="https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=300&q=80" alt="Sri Lankan Food"></div>
    <div class="kg-float-card kg-fc3"><img src="https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&q=80" alt="Curry"></div>
    <div class="kg-float-card kg-fc4"><img src="https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=300&q=80" alt="Kottu"></div>
  </div>
  <div class="kg-scroll-indicator"><div class="kg-scroll-line"></div><span>Scroll</span></div>
</section>

<!-- ══ MARQUEE ══ -->
<div class="kg-marquee-wrap">
  <div class="kg-marquee-track">
    <c:forEach begin="0" end="1">
      <div class="kg-marquee-item">🍛 Rice &amp; Curry <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🫓 Kottu Roti <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🥚 Egg Hoppers <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🍜 String Hoppers <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🦐 Devilled Prawns <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🥘 Lamprais <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🍮 Watalappan <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🥥 Pol Roti <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🐟 Fish Curry <span class="kg-marquee-dot"></span></div>
      <div class="kg-marquee-item">🌿 Dhal Curry <span class="kg-marquee-dot"></span></div>
    </c:forEach>
  </div>
</div>

<!-- ══ DISHES ══ -->
<section id="menu" class="kg-dishes-section">
  <div class="kg-texture"></div>
  <div class="container-xl" style="position:relative;z-index:1;">
    <div class="text-center reveal">
      <div class="kg-section-label justify-content-center">Our Menu</div>
      <h2 class="kg-section-title-v2">Featured Dishes</h2>
      <p class="kg-section-desc-v2">Discover our most beloved Sri Lankan delicacies, crafted with authentic recipes passed down through generations</p>
    </div>
    <div class="kg-food-grid">
      <div class="kg-food-mag kg-food-feature reveal reveal-d1">
        <div class="kg-food-mag-img">
          <img src="https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=85" alt="Rice and Curry" loading="lazy">
          <span class="kg-ribbon">⭐ Most Loved</span>
          <div class="kg-food-mag-overlay"><a href="/menu" class="kg-food-mag-quick">Add to Cart →</a></div>
        </div>
        <div class="kg-food-mag-body">
          <div class="kg-food-mag-name">Rice &amp; Curry</div>
          <div class="kg-food-mag-sinhala">බත් සහ ව්‍යංජන</div>
          <div class="kg-food-mag-desc">Traditional rice with dhal curry, coconut sambol, papadam and your choice of chicken, fish or vegetable curries.</div>
          <div class="kg-food-mag-footer"><div class="kg-food-mag-price">Rs. 850</div><div class="kg-food-mag-meta"><div class="kg-rating-v2">★ 4.9</div><div class="kg-spice-v2"><span class="kg-flame hot">🌶</span><span class="kg-flame hot">🌶</span><span class="kg-flame">🌶</span></div></div></div>
        </div>
      </div>
      <div class="kg-food-mag reveal reveal-d2">
        <div class="kg-food-mag-img">
          <img src="https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80" alt="Kottu Roti" loading="lazy">
          <span class="kg-ribbon">Popular</span>
          <div class="kg-food-mag-overlay"><a href="/menu" class="kg-food-mag-quick">Add to Cart →</a></div>
        </div>
        <div class="kg-food-mag-body">
          <div class="kg-food-mag-name">Kottu Roti</div>
          <div class="kg-food-mag-sinhala">කොත්තු රොටි</div>
          <div class="kg-food-mag-desc">Chopped flatbread stir-fried with vegetables, egg, and spices. Kandy's street food king.</div>
          <div class="kg-food-mag-footer"><div class="kg-food-mag-price">Rs. 1,450</div><div class="kg-food-mag-meta"><div class="kg-rating-v2">★ 4.9</div><div class="kg-spice-v2"><span class="kg-flame hot">🌶</span><span class="kg-flame hot">🌶</span><span class="kg-flame hot">🌶</span></div></div></div>
        </div>
      </div>
      <div class="kg-food-mag reveal reveal-d3">
        <div class="kg-food-mag-img">
          <img src="https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&q=80" alt="Egg Hoppers" loading="lazy">
          <div class="kg-food-mag-overlay"><a href="/menu" class="kg-food-mag-quick">Add to Cart →</a></div>
        </div>
        <div class="kg-food-mag-body">
          <div class="kg-food-mag-name">Egg Hoppers</div>
          <div class="kg-food-mag-sinhala">බිත්තර ආප්ප</div>
          <div class="kg-food-mag-desc">Crispy bowl-shaped rice pancakes with a soft-cooked egg center, served with coconut sambol.</div>
          <div class="kg-food-mag-footer"><div class="kg-food-mag-price">Rs. 380</div><div class="kg-food-mag-meta"><div class="kg-rating-v2">★ 4.8</div><div class="kg-spice-v2"><span class="kg-flame hot">🌶</span><span class="kg-flame">🌶</span><span class="kg-flame">🌶</span></div></div></div>
        </div>
      </div>
      <div class="kg-food-mag reveal reveal-d1">
        <div class="kg-food-mag-img">
          <img src="https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&q=80" alt="String Hoppers" loading="lazy">
          <div class="kg-food-mag-overlay"><a href="/menu" class="kg-food-mag-quick">Add to Cart →</a></div>
        </div>
        <div class="kg-food-mag-body">
          <div class="kg-food-mag-name">String Hoppers</div>
          <div class="kg-food-mag-sinhala">ඉඳි ආප්ප</div>
          <div class="kg-food-mag-desc">Delicate steamed rice noodle nests, best with coconut milk curry and lunu miris.</div>
          <div class="kg-food-mag-footer"><div class="kg-food-mag-price">Rs. 650</div><div class="kg-food-mag-meta"><div class="kg-rating-v2">★ 4.7</div><div class="kg-spice-v2"><span class="kg-flame hot">🌶</span><span class="kg-flame">🌶</span><span class="kg-flame">🌶</span></div></div></div>
        </div>
      </div>
      <div class="kg-food-mag reveal reveal-d2">
        <div class="kg-food-mag-img">
          <img src="https://images.unsplash.com/photo-1562802378-063ec186a863?w=600&q=80" alt="Devilled Prawns" loading="lazy">
          <div class="kg-food-mag-overlay"><a href="/menu" class="kg-food-mag-quick">Add to Cart →</a></div>
        </div>
        <div class="kg-food-mag-body">
          <div class="kg-food-mag-name">Devilled Prawns</div>
          <div class="kg-food-mag-sinhala">ඩෙවල් ඉස්සෝ</div>
          <div class="kg-food-mag-desc">Succulent prawns in a fiery tangy sauce with capsicum, tomatoes and Sri Lankan spices.</div>
          <div class="kg-food-mag-footer"><div class="kg-food-mag-price">Rs. 2,200</div><div class="kg-food-mag-meta"><div class="kg-rating-v2">★ 4.8</div><div class="kg-spice-v2"><span class="kg-flame hot">🌶</span><span class="kg-flame hot">🌶</span><span class="kg-flame hot">🌶</span></div></div></div>
        </div>
      </div>
      <div class="kg-food-mag reveal reveal-d3">
        <div class="kg-food-mag-img">
          <img src="https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&q=80" alt="Watalappan" loading="lazy">
          <div class="kg-food-mag-overlay"><a href="/menu" class="kg-food-mag-quick">Add to Cart →</a></div>
        </div>
        <div class="kg-food-mag-body">
          <div class="kg-food-mag-name">Watalappan</div>
          <div class="kg-food-mag-sinhala">වටලප්පන්</div>
          <div class="kg-food-mag-desc">Sri Lanka's iconic coconut custard pudding with jaggery, cardamom and cashews.</div>
          <div class="kg-food-mag-footer"><div class="kg-food-mag-price">Rs. 350</div><div class="kg-food-mag-meta"><div class="kg-rating-v2">★ 4.9</div><div class="kg-spice-v2"><span class="kg-flame">🌶</span><span class="kg-flame">🌶</span><span class="kg-flame">🌶</span></div></div></div>
        </div>
      </div>
    </div>
    <div class="text-center mt-5 reveal">
      <a href="/menu" class="kg-cta-primary" style="display:inline-flex;"><span>View Full Menu</span><svg class="kg-arrow" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg></a>
    </div>
  </div>
</section>

<!-- ══ HOW IT WORKS ══ -->
<section id="how-it-works" class="kg-hiw-section">
  <div class="container-xl" style="position:relative;z-index:1;">
    <div class="text-center mb-5 reveal">
      <div class="kg-section-label justify-content-center" style="color:#DAA520;">Simple Process</div>
      <h2 class="kg-hiw-title kg-section-title-v2">How It Works</h2>
      <p class="kg-section-desc-v2" style="color:rgba(245,240,232,.55);">Getting your favourite Sri Lankan food delivered is as easy as 1-2-3</p>
    </div>
    <div class="row g-4">
      <div class="col-md-4 reveal reveal-d1"><div class="kg-step-v2"><span class="kg-step-num-v2">01</span><span class="kg-step-icon-v2">🔍</span><h3 class="kg-step-title-v2">Browse &amp; Choose</h3><p class="kg-step-sinhala-v2">තෝරාගන්න</p><p class="kg-step-desc-v2">Explore our curated menu. Filter by category, spice level, or dietary preference to find your perfect meal.</p></div></div>
      <div class="col-md-4 reveal reveal-d2"><div class="kg-step-v2"><span class="kg-step-num-v2">02</span><span class="kg-step-icon-v2">👨‍🍳</span><h3 class="kg-step-title-v2">We Prepare Fresh</h3><p class="kg-step-sinhala-v2">අපි ළෑස්ති කරමු</p><p class="kg-step-desc-v2">Our chefs use traditional recipes with ingredients sourced from Kandy's Central Market every morning.</p></div></div>
      <div class="col-md-4 reveal reveal-d3"><div class="kg-step-v2"><span class="kg-step-num-v2">03</span><span class="kg-step-icon-v2">🛵</span><h3 class="kg-step-title-v2">Swift Delivery</h3><p class="kg-step-sinhala-v2">ඉක්මනින් ලැබේ</p><p class="kg-step-desc-v2">Your meal arrives hot and fresh. Track your driver live on a real-time map and savour every bite.</p></div></div>
    </div>
  </div>
</section>

<!-- ══ REVIEWS ══ -->
<section class="kg-review-section">
  <div class="container-xl mb-4 reveal">
    <div class="text-center"><div class="kg-section-label justify-content-center">Customer Stories</div><h2 class="kg-section-title-v2">What People Say</h2></div>
  </div>
  <div class="kg-review-track">
    <div class="kg-review-slide">
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"The kottu roti tasted exactly like what my mother used to make in Kandy. Genuinely shocked a delivery service can match home cooking."</p><div class="kg-review-author"><div class="kg-review-av">S</div><div><div class="kg-review-name">Saman Perera</div><div class="kg-review-dish">Kottu Roti</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"Watalappan arrived perfectly chilled with the right jaggery sweetness. This is exactly what I missed from back home in Colombo."</p><div class="kg-review-author"><div class="kg-review-av">N</div><div><div class="kg-review-name">Nimasha Fernando</div><div class="kg-review-dish">Watalappan</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"Rice &amp; curry spread was AMAZING. Six curries, crispy papadam, fresh pol sambol. Delivery in 27 minutes. Absolutely unreal."</p><div class="kg-review-author"><div class="kg-review-av">A</div><div><div class="kg-review-name">Akila Weerasekara</div><div class="kg-review-dish">Rice &amp; Curry</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"String hoppers were the softest I've ever had outside a roadside kade. The coconut milk curry was rich and perfectly spiced."</p><div class="kg-review-author"><div class="kg-review-av">R</div><div><div class="kg-review-name">Rashmi Silva</div><div class="kg-review-dish">String Hoppers</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"Ordered lamprais for office lunch. Everyone was blown away — they thought we'd ordered from a proper restaurant!"</p><div class="kg-review-author"><div class="kg-review-av">D</div><div><div class="kg-review-name">Dinuka Jayawardena</div><div class="kg-review-dish">Lamprais</div></div></div></div>
    </div>
    <div class="kg-review-slide" aria-hidden="true">
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"The kottu roti tasted exactly like what my mother used to make in Kandy. Genuinely shocked a delivery service can match home cooking."</p><div class="kg-review-author"><div class="kg-review-av">S</div><div><div class="kg-review-name">Saman Perera</div><div class="kg-review-dish">Kottu Roti</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"Watalappan arrived perfectly chilled with the right jaggery sweetness."</p><div class="kg-review-author"><div class="kg-review-av">N</div><div><div class="kg-review-name">Nimasha Fernando</div><div class="kg-review-dish">Watalappan</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"Rice &amp; curry spread was AMAZING. Six curries, crispy papadam, fresh pol sambol. Delivery in 27 minutes."</p><div class="kg-review-author"><div class="kg-review-av">A</div><div><div class="kg-review-name">Akila Weerasekara</div><div class="kg-review-dish">Rice &amp; Curry</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"String hoppers were the softest I've ever had outside a roadside kade."</p><div class="kg-review-author"><div class="kg-review-av">R</div><div><div class="kg-review-name">Rashmi Silva</div><div class="kg-review-dish">String Hoppers</div></div></div></div>
      <div class="kg-review-card"><div class="kg-review-stars">★★★★★</div><p class="kg-review-text">"Ordered lamprais for office lunch. Everyone was blown away!"</p><div class="kg-review-author"><div class="kg-review-av">D</div><div><div class="kg-review-name">Dinuka Jayawardena</div><div class="kg-review-dish">Lamprais</div></div></div></div>
    </div>
  </div>
</section>

<!-- ══ CTA ══ -->
<section class="kg-cta-section">
  <div class="kg-cta-bg"></div>
  <div class="kg-cta-grad"></div>
  <div class="container-xl kg-cta-content">
    <div class="reveal">
      <p class="kg-cta-sinhala">රසකාමීන් සඳහා</p>
      <h2 class="kg-cta-title-v2">Ready to taste Sri Lanka?</h2>
      <p class="kg-cta-sub">Join thousands of food lovers enjoying authentic Sri Lankan cuisine delivered hot to their door.</p>
      <div class="d-flex gap-3 justify-content-center flex-wrap">
        <a href="/signup" class="kg-cta-primary"><span>Join Free</span><svg class="kg-arrow" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg></a>
        <a href="/menu" class="kg-cta-secondary">Browse Menu</a>
      </div>
    </div>
  </div>
</section>

<script>
// Cursor glow
(function(){var g=document.getElementById('kg-cursor-glow');if(!g)return;document.addEventListener('mousemove',function(e){g.style.left=e.clientX+'px';g.style.top=e.clientY+'px';});})();

// Hero parallax
(function(){var img=document.getElementById('heroImg');if(!img)return;setTimeout(function(){img.classList.add('loaded');},100);window.addEventListener('scroll',function(){img.style.transform='translateY('+(window.scrollY*.3)+'px)';},{passive:true});})();

// Particles
(function(){var c=document.getElementById('kg-particles');if(!c)return;var cols=['rgba(139,69,19,.4)','rgba(205,133,63,.35)','rgba(218,165,32,.3)','rgba(245,240,232,.15)'];for(var i=0;i<18;i++){var p=document.createElement('div');p.className='kg-particle';var s=4+Math.random()*8;p.style.cssText='width:'+s+'px;height:'+s+'px;left:'+Math.random()*100+'%;background:'+cols[Math.floor(Math.random()*cols.length)]+';animation-duration:'+(8+Math.random()*14)+'s;animation-delay:'+Math.random()*-20+'s;border-radius:'+Math.random()*50+'%';c.appendChild(p);}})();

// Scroll reveal
(function(){var obs=new IntersectionObserver(function(entries){entries.forEach(function(e){if(e.isIntersecting){e.target.classList.add('visible');obs.unobserve(e.target);}});},{threshold:.12});document.querySelectorAll('.reveal').forEach(function(el){obs.observe(el);});})();

// Count-up
(function(){var obs=new IntersectionObserver(function(entries){entries.forEach(function(e){if(!e.isIntersecting)return;var el=e.target,target=parseInt(el.getAttribute('data-target')),start=0,step=16,dur=1800;var timer=setInterval(function(){start+=Math.ceil(target/(dur/step));if(start>=target){el.textContent=target+'+';clearInterval(timer);}else{el.textContent=start;}},step);obs.unobserve(el);});},{threshold:.5});document.querySelectorAll('.count-up').forEach(function(el){obs.observe(el);});})();

// Navbar transparency
(function(){var nav=document.getElementById('mainNav');if(!nav)return;function upd(){var dark=document.documentElement.getAttribute('data-theme')==='dark';var scrolled=window.scrollY>60;nav.style.background=scrolled?(dark?'rgba(26,18,8,.96)':'rgba(245,240,232,.96)'):'transparent';nav.style.borderBottomColor=scrolled?'rgba(139,69,19,.15)':'transparent';}window.addEventListener('scroll',upd,{passive:true});upd();})();
</script>

<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
