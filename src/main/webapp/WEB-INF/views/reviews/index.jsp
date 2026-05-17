<%@ page contentType="text/html;charset=UTF-8" buffer="128kb" autoFlush="true" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Reviews"/>
<c:set var="pageId"    value="reviews"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.kg-avg-circle{width:110px;height:110px;border-radius:50%;background:linear-gradient(135deg,var(--copper),var(--gold));display:flex;flex-direction:column;align-items:center;justify-content:center;box-shadow:0 8px 32px rgba(139,69,19,.4);}
.kg-bar-row{display:flex;align-items:center;gap:10px;margin-bottom:7px;}
.kg-bar-track{flex:1;height:8px;background:rgba(245,240,232,.2);border-radius:99px;overflow:hidden;}
.kg-bar-fill{height:100%;background:var(--gold);border-radius:99px;transition:width 1s var(--ease);}
.kg-rv-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:var(--r-lg);padding:20px;margin-bottom:14px;transition:all .28s var(--ease);}
.kg-rv-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-lg);}
.kg-av-circle{width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,var(--copper),var(--gold));color:var(--parchment);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1.1rem;flex-shrink:0;}
.kg-filter-pill{padding:8px 18px;border-radius:99px;border:1.5px solid var(--c-border-b);background:var(--c-surface);color:var(--c-text3);font-size:.82rem;font-weight:500;cursor:pointer;transition:all .22s;font-family:var(--font-body);}
.kg-filter-pill.active,.kg-filter-pill:hover{background:var(--copper);color:var(--parchment);border-color:var(--copper);}
</style>

<div class="kg-page">
  <!-- Hero -->
  <section style="background:linear-gradient(135deg,var(--brown-dark),#2C1810);padding:56px 0;position:relative;overflow:hidden;">
    <div style="position:absolute;right:8%;top:50%;transform:translateY(-50%);font-size:8rem;opacity:.06;">⭐</div>
    <div class="container" style="max-width:800px;position:relative;z-index:1;">
      <div class="row align-items-center g-4">
        <div class="col-auto">
          <div class="kg-avg-circle">
            <div style="font-size:2rem;font-weight:800;color:var(--parchment);line-height:1;" id="avgNum">—</div>
            <div style="font-size:.72rem;color:rgba(245,240,232,.75);">out of 5</div>
          </div>
        </div>
        <div class="col">
          <h1 style="font-family:var(--font-serif);color:var(--cream);font-size:2rem;margin-bottom:4px;">Customer Reviews</h1>
          <div style="color:rgba(245,240,232,.6);font-size:.875rem;" id="totalCount">Loading...</div>
          <div class="mt-3" id="ratingBars"></div>
        </div>
      </div>
    </div>
  </section>

  <div class="container py-4" style="max-width:800px;">
    <!-- CTA -->
    <c:if test="${user != null}">
    <div class="kg-card mb-4 kg-fade" style="border:1px solid rgba(139,69,19,.25);background:linear-gradient(135deg,var(--copper-l),var(--parchment));">
      <div class="kg-card-body d-flex align-items-center gap-4">
        <div style="font-size:2.5rem;">✍️</div>
        <div style="flex:1;">
          <div style="font-weight:700;margin-bottom:3px;font-family:var(--font-serif);">Enjoyed a meal? Leave a review!</div>
          <div style="font-size:.82rem;color:var(--c-text3);">Your honest feedback helps us improve and helps others choose.</div>
        </div>
        <a href="/menu" class="kg-btn kg-btn-primary kg-btn-sm" style="width:auto;white-space:nowrap;">Browse Menu</a>
      </div>
    </div>
    </c:if>

    <!-- Filter pills -->
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px;">
      <button class="kg-filter-pill active" onclick="filterReviews(0,this)">⭐ All</button>
      <button class="kg-filter-pill" onclick="filterReviews(5,this)">5 Stars</button>
      <button class="kg-filter-pill" onclick="filterReviews(4,this)">4 Stars</button>
      <button class="kg-filter-pill" onclick="filterReviews(3,this)">3 Stars</button>
      <button class="kg-filter-pill" onclick="filterReviews(2,this)">1-2 Stars</button>
    </div>

    <!-- Reviews list -->
    <div id="revList" class="kg-stagger">
      <div style="text-align:center;padding:48px;color:var(--c-text3);">
        <div style="font-size:3rem;margin-bottom:12px;animation:spin 2s linear infinite;">⭐</div>
        Loading reviews...
      </div>
    </div>
  </div>
</div>

<script>
var allReviews = [], filterStar = 0;

async function loadAllReviews() {
  try {
    var foods = await fetch('/api/foods').then(function(r){ return r.json(); });
    var allPromises = foods.slice(0,20).map(function(f) {
      return fetch('/api/food/'+f.id+'/reviews').then(function(r){ return r.json(); })
        .then(function(revs){ return revs.map(function(rv){ rv.foodName=f.name; return rv; }); })
        .catch(function(){ return []; });
    });
    var nested = await Promise.all(allPromises);
    allReviews = nested.flat().sort(function(a,b){ return b.createdAt.localeCompare(a.createdAt); });
    updateStats(); renderReviews();
  } catch(e) {
    document.getElementById('revList').innerHTML = '<p style="text-align:center;color:var(--c-text3);padding:24px;">Could not load reviews.</p>';
  }
}

function updateStats() {
  if (!allReviews.length) { document.getElementById('totalCount').textContent='No reviews yet.'; return; }
  var avg = allReviews.reduce(function(s,r){ return s+(r.rating||5); },0)/allReviews.length;
  document.getElementById('avgNum').textContent = avg.toFixed(1);
  document.getElementById('totalCount').textContent = allReviews.length+' verified reviews';
  var counts=[0,0,0,0,0];
  allReviews.forEach(function(r){ var s=Math.min(5,Math.max(1,r.rating||5)); counts[5-s]++; });
  document.getElementById('ratingBars').innerHTML = [5,4,3,2,1].map(function(star,i){
    var pct = Math.round(counts[i]/allReviews.length*100);
    return '<div class="kg-bar-row"><span style="font-size:.72rem;color:rgba(245,240,232,.65);width:30px;">'+star+'★</span>'
      +'<div class="kg-bar-track"><div class="kg-bar-fill" style="width:0%" data-w="'+pct+'%"></div></div>'
      +'<span style="font-size:.72rem;color:rgba(245,240,232,.55);width:30px;text-align:right;">'+counts[i]+'</span></div>';
  }).join('');
  setTimeout(function(){ document.querySelectorAll('.kg-bar-fill').forEach(function(b){ b.style.width=b.getAttribute('data-w'); }); },300);
}

function renderReviews() {
  var shown = filterStar>0 ? allReviews.filter(function(r){ return filterStar===2?r.rating<=2:r.rating===filterStar; }) : allReviews;
  if (!shown.length) { document.getElementById('revList').innerHTML='<div style="text-align:center;padding:40px;color:var(--c-text3);"><div style="font-size:2.5rem;margin-bottom:10px;">🔍</div>No reviews for this filter.</div>'; return; }
  document.getElementById('revList').innerHTML = shown.slice(0,30).map(function(rv){
    var stars='';for(var i=1;i<=5;i++)stars+='<span style="color:'+(i<=(rv.rating||5)?'#DAA520':'var(--c-border-b)')+';">★</span>';
    return '<div class="kg-rv-card kg-fade">'
      +'<div class="d-flex gap-3 mb-3">'
      +'<div class="kg-av-circle">'+(rv.customerName||'?').charAt(0).toUpperCase()+'</div>'
      +'<div style="flex:1;">'
      +'<div class="d-flex justify-content-between align-items-start">'
      +'<div><div style="font-weight:700;font-size:.9rem;color:var(--c-text);">'+(rv.customerName||'Anonymous')+'</div>'
      +'<div style="font-size:.72rem;color:var(--c-text3);">'+rv.createdAt+'</div></div>'
      +'<span style="font-size:1rem;">'+stars+'</span></div>'
      +(rv.foodName?'<div style="margin-top:4px;"><span style="background:var(--copper-l);color:var(--copper);font-size:.72rem;font-weight:700;padding:2px 10px;border-radius:20px;">'+rv.foodName+'</span></div>':'')
      +'</div></div>'
      +'<p style="font-size:.9rem;color:var(--c-text2);line-height:1.75;margin:0;font-style:italic;">"'+rv.text+'"</p>'
      +(rv.adminReply?'<div style="margin-top:12px;padding:10px 14px;background:var(--copper-l);border-left:3px solid var(--copper);border-radius:0 10px 10px 0;font-size:.82rem;"><strong style="color:var(--copper);">🍛 කටගැස්ම replied:</strong><br>'+rv.adminReply+'</div>':'')
      +'</div>';
  }).join('');
  setTimeout(function(){ document.querySelectorAll('.kg-rv-card').forEach(function(el){ el.classList.add('kg-visible'); }); },100);
}

function filterReviews(star,btn) {
  filterStar=star;
  document.querySelectorAll('.kg-filter-pill').forEach(function(b){ b.classList.remove('active'); });
  btn.classList.add('active');
  renderReviews();
}

loadAllReviews();
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
