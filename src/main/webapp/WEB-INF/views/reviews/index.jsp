<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Reviews"/>
<c:set var="pageId"    value="reviews"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.rev-hero{background:linear-gradient(135deg,#0F0F0F,#1a1a1a);padding:48px 0;position:relative;overflow:hidden;}
.rev-hero::before{content:'⭐';position:absolute;right:8%;top:50%;transform:translateY(-50%);font-size:8rem;opacity:.08;}
.avg-circle{width:110px;height:110px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));display:flex;flex-direction:column;align-items:center;justify-content:center;box-shadow:0 8px 32px rgba(255,107,53,.45);}
.bar-row{display:flex;align-items:center;gap:10px;margin-bottom:7px;}
.bar-track{flex:1;height:8px;background:var(--c-border);border-radius:99px;overflow:hidden;}
.bar-fill{height:100%;background:linear-gradient(90deg,#FFB800,var(--c-orange));border-radius:99px;transition:width 1s var(--ease);}
.rv-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:18px;padding:20px;margin-bottom:14px;transition:all .28s var(--ease);}
.rv-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-lg);}
.av-circle{width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1.1rem;flex-shrink:0;}
.star-disp{color:#FFB800;font-size:1rem;letter-spacing:2px;}
.filter-pill{padding:8px 18px;border-radius:99px;border:1.5px solid var(--c-border);background:var(--c-surface);color:var(--c-muted);font-size:.82rem;font-weight:500;cursor:pointer;transition:all .22s var(--ease);}
.filter-pill.active,.filter-pill:hover{background:var(--c-orange);color:white;border-color:var(--c-orange);}
</style>

<div class="yd-page">
  <!-- Hero -->
  <div class="rev-hero">
    <div class="container" style="max-width:800px;">
      <div class="row align-items-center g-4">
        <div class="col-auto">
          <div class="avg-circle">
            <div style="font-size:2rem;font-weight:800;color:white;line-height:1;" id="avgNum">—</div>
            <div style="font-size:.72rem;color:rgba(255,255,255,.75);">out of 5</div>
          </div>
        </div>
        <div class="col">
          <h1 style="font-family:var(--font-display);color:white;font-size:2rem;margin-bottom:4px;">Customer Reviews</h1>
          <div style="color:rgba(255,255,255,.6);font-size:.875rem;" id="totalCount">Loading...</div>
          <!-- Rating bars -->
          <div class="mt-3" id="ratingBars"></div>
        </div>
      </div>
    </div>
  </div>

  <div class="container py-4" style="max-width:800px;">
    <!-- Write review CTA -->
    <c:if test="${user != null}">
    <div class="yd-card mb-4 yd-fade" style="background:linear-gradient(135deg,var(--c-orange-l),#fff8f5);border-color:rgba(255,107,53,.2);">
      <div class="yd-card-body" style="display:flex;align-items:center;gap:16px;">
        <div style="font-size:2.5rem;">✍️</div>
        <div style="flex:1;">
          <div style="font-weight:700;margin-bottom:3px;">Enjoyed a meal? Leave a review!</div>
          <div style="font-size:.82rem;color:var(--c-muted);">Your honest feedback helps us improve and helps others choose.</div>
        </div>
        <a href="/menu" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:10px 20px;white-space:nowrap;">Browse Menu</a>
      </div>
    </div>
    </c:if>

    <!-- Filter pills -->
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px;" id="filterRow">
      <button class="filter-pill active" onclick="filterReviews(0,this)">⭐ All</button>
      <button class="filter-pill" onclick="filterReviews(5,this)">5 Stars</button>
      <button class="filter-pill" onclick="filterReviews(4,this)">4 Stars</button>
      <button class="filter-pill" onclick="filterReviews(3,this)">3 Stars</button>
      <button class="filter-pill" onclick="filterReviews(2,this)">1-2 Stars</button>
    </div>

    <!-- Reviews list -->
    <div id="revList" class="yd-stagger">
      <div style="text-align:center;padding:48px;color:var(--c-muted);">
        <div style="font-size:3rem;margin-bottom:12px;animation:spin 2s linear infinite;">⭐</div>
        Loading reviews...
      </div>
    </div>
  </div>
</div>

<script>
var allReviews = [];
var filterStar = 0;

async function loadAllReviews() {
  // Load reviews for all food items by fetching from feedback data via activity
  try {
    // We'll use the existing food list to get all reviews per food
    var foods = await fetch('/api/foods').then(function(r){ return r.json(); });
    var allPromises = foods.slice(0,20).map(function(f) {
      return fetch('/api/food/' + f.id + '/reviews').then(function(r){ return r.json(); })
        .then(function(revs) {
          return revs.map(function(rv){ rv.foodName = f.name; rv.foodImg = f.imageUrl; return rv; });
        }).catch(function(){ return []; });
    });
    var nested = await Promise.all(allPromises);
    allReviews = nested.flat().sort(function(a,b){ return b.createdAt.localeCompare(a.createdAt); });
    updateStats();
    renderReviews();
  } catch(e) {
    document.getElementById('revList').innerHTML = '<p style="text-align:center;color:var(--c-muted);padding:24px;">Could not load reviews.</p>';
  }
}

function updateStats() {
  if (!allReviews.length) { document.getElementById('totalCount').textContent = 'No reviews yet.'; return; }
  var avg = allReviews.reduce(function(s,r){ return s+(r.rating||5); }, 0) / allReviews.length;
  document.getElementById('avgNum').textContent = avg.toFixed(1);
  document.getElementById('totalCount').textContent = allReviews.length + ' verified reviews';
  // Rating bars
  var counts = [0,0,0,0,0];
  allReviews.forEach(function(r){ var s=Math.min(5,Math.max(1,r.rating||5)); counts[5-s]++; });
  var max = Math.max.apply(null,counts) || 1;
  document.getElementById('ratingBars').innerHTML = [5,4,3,2,1].map(function(star,i){
    var pct = Math.round(counts[i]/allReviews.length*100);
    return '<div class="bar-row">'
      +'<span style="font-size:.72rem;color:rgba(255,255,255,.6);width:30px;">'+star+'★</span>'
      +'<div class="bar-track"><div class="bar-fill" style="width:0%" data-w="'+pct+'%"></div></div>'
      +'<span style="font-size:.72rem;color:rgba(255,255,255,.55);width:30px;text-align:right;">'+counts[i]+'</span>'
      +'</div>';
  }).join('');
  // Animate bars
  setTimeout(function(){
    document.querySelectorAll('.bar-fill').forEach(function(b){ b.style.width = b.getAttribute('data-w'); });
  }, 300);
}

function renderReviews() {
  var shown = filterStar > 0 ? allReviews.filter(function(r){ return filterStar===2 ? r.rating<=2 : r.rating===filterStar; }) : allReviews;
  if (!shown.length) {
    document.getElementById('revList').innerHTML = '<div style="text-align:center;padding:40px;color:var(--c-muted);"><div style="font-size:2.5rem;margin-bottom:10px;">🔍</div>No reviews for this filter.</div>';
    return;
  }
  document.getElementById('revList').innerHTML = shown.slice(0,30).map(function(rv) {
    var stars = '';
    for (var i=1;i<=5;i++) stars += '<span style="color:'+(i<=(rv.rating||5)?'#FFB800':'#DDD')+';">★</span>';
    return '<div class="rv-card yd-fade">'
      +'<div class="d-flex gap-3 mb-3">'
      +'<div class="av-circle">'+(rv.customerName||'?').charAt(0).toUpperCase()+'</div>'
      +'<div style="flex:1;">'
      +'<div class="d-flex justify-content-between align-items-start">'
      +'<div><div style="font-weight:700;font-size:.9rem;color:var(--c-text);">'+(rv.customerName||'Anonymous')+'</div>'
      +'<div style="font-size:.72rem;color:var(--c-muted);">'+rv.createdAt+'</div></div>'
      +'<span style="font-size:1rem;">'+stars+'</span>'
      +'</div>'
      +(rv.foodName ? '<div style="margin-top:4px;"><span style="background:var(--c-orange-l);color:var(--c-orange);font-size:.72rem;font-weight:700;padding:2px 9px;border-radius:20px;">'+rv.foodName+'</span></div>' : '')
      +'</div></div>'
      +'<p style="font-size:.9rem;color:var(--c-text2);line-height:1.75;margin:0;font-style:italic;">"'+rv.text+'"</p>'
      +(rv.adminReply ? '<div style="margin-top:12px;padding:10px 14px;background:var(--c-orange-l);border-left:3px solid var(--c-orange);border-radius:0 12px 12px 0;font-size:.82rem;"><strong style="color:var(--c-orange);">🍽️ YummyDish replied:</strong><br>'+rv.adminReply+'</div>' : '')
      +'</div>';
  }).join('');
  // Trigger scroll observer
  setTimeout(function(){
    document.querySelectorAll('.yd-fade').forEach(function(el){
      if (!el.classList.contains('yd-visible')) el.classList.add('yd-visible');
    });
  }, 100);
}

function filterReviews(star, btn) {
  filterStar = star;
  document.querySelectorAll('.filter-pill').forEach(function(b){ b.classList.remove('active'); });
  btn.classList.add('active');
  renderReviews();
}

loadAllReviews();
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
