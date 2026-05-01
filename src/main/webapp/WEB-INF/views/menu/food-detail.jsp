<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="${fn:length(food.name) > 0 ? food.name : 'Food Detail'}"/>
<c:set var="pageId"    value="menu"/>
<%@ include file="/WEB-INF/views/layout/header.jsp" %>
<style>
.fd-hero{position:relative;height:clamp(240px,38vw,360px);overflow:hidden;background:#111;}
.fd-hero img{width:100%;height:100%;object-fit:cover;transition:transform .8s ease;}
.fd-hero:hover img{transform:scale(1.06);}
.fd-overlay{position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,.85) 0%,rgba(0,0,0,.15) 55%,transparent 100%);}
.fd-back{position:absolute;top:16px;left:16px;background:rgba(0,0,0,.5);color:white;border:none;border-radius:50%;width:40px;height:40px;display:flex;align-items:center;justify-content:center;cursor:pointer;backdrop-filter:blur(8px);font-size:1.1rem;transition:all .2s;text-decoration:none;}
.fd-back:hover{background:rgba(255,255,255,.2);color:white;}
.fd-fav{position:absolute;top:16px;right:16px;background:rgba(0,0,0,.5);border:none;border-radius:50%;width:42px;height:42px;display:flex;align-items:center;justify-content:center;cursor:pointer;backdrop-filter:blur(8px);font-size:1.2rem;transition:all .2s;}
.fd-fav:hover,.fd-fav.active{background:var(--c-orange);color:white;}
.fd-info{position:absolute;bottom:20px;left:20px;right:20px;color:white;}
.nutr-pill{background:var(--c-bg);border:1px solid var(--c-border);border-radius:12px;padding:14px 12px;text-align:center;}
.nutr-val{font-size:1.3rem;font-weight:800;color:var(--c-orange);}
.nutr-lbl{font-size:.65rem;color:var(--c-muted);margin-top:3px;text-transform:uppercase;letter-spacing:.5px;}
.add-sticky{position:sticky;top:80px;}
.qty-lg{display:flex;align-items:center;gap:12px;background:var(--c-bg);border-radius:12px;padding:10px 14px;border:1.5px solid var(--c-border);width:fit-content;}
.qty-lg button{width:34px;height:34px;border-radius:50%;border:2px solid var(--c-orange);background:none;color:var(--c-orange);font-size:1.2rem;font-weight:700;transition:all .2s;cursor:pointer;line-height:1;}
.qty-lg button:hover{background:var(--c-orange);color:white;}
.qty-lg span{font-size:1.1rem;font-weight:800;min-width:24px;text-align:center;}
.tag-chip{display:inline-flex;align-items:center;gap:4px;padding:4px 12px;border-radius:20px;font-size:.72rem;font-weight:700;margin:2px;}
.rv-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:16px;padding:18px;margin-bottom:12px;transition:transform .25s var(--ease),box-shadow .25s;}
.rv-card:hover{transform:translateX(4px);box-shadow:var(--shadow-md);}
.star-i{font-size:2rem;cursor:pointer;color:#D0D0D0;transition:all .18s;user-select:none;padding:2px;}
.star-i:hover,.star-i.on{color:#FFB800;transform:scale(1.2);}
.related-card{background:var(--c-surface);border:1px solid var(--c-border);border-radius:16px;overflow:hidden;transition:all .3s var(--ease);cursor:pointer;}
.related-card:hover{transform:translateY(-5px);box-shadow:var(--shadow-lg);}
.related-card:hover img{transform:scale(1.08);}
</style>

<div class="yd-page">
  <!-- Hero image -->
  <div class="fd-hero">
    <img src="${food.imageUrl}" alt="${food.name}"
         onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&amp;q=80'">
    <div class="fd-overlay"></div>
    <a href="/menu" class="fd-back"><i class="bi bi-arrow-left"></i></a>
    <button class="fd-fav" id="favBtn"
            onclick="toggleFav()" title="Add to favourites">♡</button>
    <div class="fd-info">
      <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;">
        <span class="yd-badge" style="background:rgba(0,0,0,.6);color:white;backdrop-filter:blur(8px);position:static;">${food.category}</span>
        <span class="yd-badge" style="background:rgba(0,0,0,.6);color:white;backdrop-filter:blur(8px);position:static;">${food.foodType}</span>
        <c:if test="${food.popular}"><span class="yd-badge yd-badge-pop" style="position:static;">⭐ Popular</span></c:if>
        <c:if test="${not food.available}"><span class="yd-badge" style="background:#f44336;color:white;position:static;">⏸ Unavailable</span></c:if>
      </div>
      <h1 style="font-family:var(--font-display);font-size:clamp(1.6rem,4vw,2.2rem);margin-bottom:6px;line-height:1.15;">${food.name}</h1>
      <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
        <span style="font-size:1.6rem;font-weight:800;color:var(--c-orange);">LKR <fmt:formatNumber value="${food.price}" pattern="#,##0"/></span>
        <div id="heroRating" style="display:flex;align-items:center;gap:5px;color:white;font-size:.85rem;opacity:.9;"></div>
      </div>
    </div>
  </div>

  <div class="container py-4" style="max-width:960px;">
    <div class="row g-4">

      <!-- Left column: details + reviews -->
      <div class="col-lg-7">

        <!-- Description -->
        <div class="yd-card mb-3 yd-fade">
          <div class="yd-card-body">
            <p style="font-size:.95rem;line-height:1.8;color:var(--c-text2);margin-bottom:14px;">${food.description}</p>
            <!-- Tags -->
            <div>
              <c:if test="${fn:containsIgnoreCase(food.ingredients,'chili') or fn:containsIgnoreCase(food.name,'spicy') or fn:containsIgnoreCase(food.name,'hot')}">
                <span class="tag-chip" style="background:#FFEBEE;color:#C62828;">🌶️ Spicy</span>
              </c:if>
              <c:if test="${fn:containsIgnoreCase(food.ingredients,'tofu') or fn:containsIgnoreCase(food.name,'vegan') or fn:containsIgnoreCase(food.name,'veggie')}">
                <span class="tag-chip" style="background:#E8F5E9;color:#2E7D32;">🌿 Vegan</span>
              </c:if>
              <c:if test="${fn:containsIgnoreCase(food.foodType,'Beverage')}">
                <span class="tag-chip" style="background:#E3F2FD;color:#1565C0;">🥤 Drink</span>
              </c:if>
              <c:if test="${fn:containsIgnoreCase(food.foodType,'Dessert')}">
                <span class="tag-chip" style="background:#F3E8FF;color:#7C3AED;">🍰 Dessert</span>
              </c:if>
            </div>
          </div>
        </div>

        <!-- Nutrition -->
        <div class="yd-card mb-3 yd-fade">
          <div class="yd-card-body">
            <h6 class="fw-bold mb-3" style="color:var(--c-text);">📊 Nutrition</h6>
            <div class="row g-2 mb-3">
              <div class="col-4"><div class="nutr-pill"><div class="nutr-val">${food.calories}</div><div class="nutr-lbl">Calories</div></div></div>
              <div class="col-4"><div class="nutr-pill"><div class="nutr-val">${food.portionSize}</div><div class="nutr-lbl">Portion</div></div></div>
              <div class="col-4"><div class="nutr-pill"><div class="nutr-val">${food.nutritionalInfo}</div><div class="nutr-lbl">Info</div></div></div>
            </div>
            <c:if test="${fn:length(food.ingredients) > 0}">
              <div style="font-size:.75rem;font-weight:700;color:var(--c-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;">Ingredients</div>
              <div style="font-size:.85rem;color:var(--c-text2);line-height:1.7;">${food.ingredients}</div>
            </c:if>
          </div>
        </div>

        <!-- Reviews -->
        <div class="yd-card mb-3 yd-fade">
          <div class="yd-card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h6 class="fw-bold mb-0">💬 Customer Reviews</h6>
              <div id="avgStarsDisplay"></div>
            </div>
            <div id="reviewsList">
              <div style="text-align:center;padding:28px;color:var(--c-muted);">
                <div class="yd-skeleton" style="height:14px;width:80%;border-radius:6px;margin:0 auto 10px;"></div>
                <div class="yd-skeleton" style="height:14px;width:60%;border-radius:6px;margin:0 auto;"></div>
              </div>
            </div>

            <!-- Write review -->
            <c:choose>
              <c:when test="${user != null}">
                <div style="margin-top:20px;padding-top:18px;border-top:1px solid var(--c-border);" id="writeReview">
                  <h6 class="fw-bold mb-3" style="font-size:.88rem;">Write a Review</h6>
                  <div style="display:flex;gap:3px;margin-bottom:12px;" id="starPicker">
                    <span class="star-i" data-val="1">★</span>
                    <span class="star-i" data-val="2">★</span>
                    <span class="star-i" data-val="3">★</span>
                    <span class="star-i" data-val="4">★</span>
                    <span class="star-i" data-val="5">★</span>
                  </div>
                  <textarea id="reviewText" class="yd-input" rows="3"
                            placeholder="Share your honest opinion about this dish..."
                            style="resize:none;margin-bottom:12px;"></textarea>
                  <button onclick="submitReview()" class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:10px 24px;">
                    <i class="bi bi-send me-2"></i>Post Review
                  </button>
                </div>
              </c:when>
              <c:otherwise>
                <div style="text-align:center;padding:16px;margin-top:12px;background:var(--c-bg);border-radius:12px;">
                  <a href="/login" style="color:var(--c-orange);font-weight:700;font-size:.875rem;">
                    Sign in to leave a review →
                  </a>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div><!-- /col-lg-7 -->

      <!-- Right column: sticky add to cart -->
      <div class="col-lg-5">
        <div class="add-sticky">
          <div class="yd-card mb-3 yd-fade">
            <div class="yd-card-body">
              <div style="font-size:1.7rem;font-weight:800;color:var(--c-orange);margin-bottom:4px;">
                LKR <fmt:formatNumber value="${food.price}" pattern="#,##0"/>
              </div>
              <div style="font-size:.78rem;color:var(--c-muted);margin-bottom:18px;">
                <c:if test="${food.calories > 0}">${food.calories} kcal · ${food.portionSize}</c:if>
              </div>

              <label class="yd-label" style="margin-bottom:8px;">Quantity</label>
              <div class="qty-lg mb-4">
                <button onclick="qtyChange(-1)">−</button>
                <span id="detailQty">1</span>
                <button onclick="qtyChange(1)">+</button>
              </div>

              <c:choose>
                <c:when test="${food.available}">
                  <button onclick="addToCartDetail()" class="yd-btn yd-btn-primary" id="addBtn">
                    <i class="bi bi-cart-plus me-2"></i>Add to Cart · LKR <span id="totalPrice"><fmt:formatNumber value="${food.price}" pattern="#,##0"/></span>
                  </button>
                </c:when>
                <c:otherwise>
                  <button class="yd-btn" style="background:#f0f0f0;color:#aaa;border:none;cursor:not-allowed;width:100%;padding:14px;" disabled>
                    ⏸ Temporarily Unavailable
                  </button>
                </c:otherwise>
              </c:choose>

              <div class="d-flex gap-2 mt-2">
                <a href="/cart" class="yd-btn yd-btn-outline yd-btn-sm" style="flex:1;color:var(--c-muted);">
                  <i class="bi bi-cart3 me-1"></i>View Cart (<span id="cartCountDetail">0</span>)
                </a>
              </div>
            </div>
          </div>

          <!-- Related items -->
          <div class="yd-card yd-fade">
            <div class="yd-card-body">
              <h6 class="fw-bold mb-3">🍽️ More from ${food.category}</h6>
              <div id="relatedItems">
                <div class="yd-skeleton" style="height:80px;border-radius:12px;margin-bottom:8px;"></div>
                <div class="yd-skeleton" style="height:80px;border-radius:12px;"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div><!-- /row -->
  </div><!-- /container -->
</div><!-- /yd-page -->

<script>
var foodId    = '${food.id}';
var foodName  = '${fn:replace(food.name, "'", "\\'")}';
var foodPrice = ${food.price};
var foodImg   = '${food.imageUrl}';
var myRating  = 0;
var detailQty = 1;

// Quantity controls
function qtyChange(d) {
  detailQty = Math.max(1, detailQty + d);
  document.getElementById('detailQty').textContent = detailQty;
  var tp = document.getElementById('totalPrice');
  if (tp) tp.textContent = 'LKR ' + Math.round(foodPrice * detailQty).toLocaleString();
}

function addToCartDetail() {
  Cart.add(foodId, foodName, foodPrice, detailQty, foodImg);
  var btn = document.getElementById('addBtn');
  if (btn) {
    btn.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>Added! ✓';
    btn.style.background = 'var(--c-success)';
    setTimeout(function() {
      btn.innerHTML = '<i class="bi bi-cart-plus me-2"></i>Add to Cart · LKR ' + Math.round(foodPrice * detailQty).toLocaleString();
      btn.style.background = '';
    }, 1800);
  }
  var cnt = document.getElementById('cartCountDetail');
  if (cnt) cnt.textContent = Cart.count();
}

// Favourites
var _isFav = Favs.has(foodId);
(function() {
  var btn = document.getElementById('favBtn');
  if (!btn) return;
  btn.textContent = _isFav ? '♥' : '♡';
  if (_isFav) btn.classList.add('active');
})();
function toggleFav() {
  _isFav = Favs.toggle(foodId, foodName, foodPrice, foodImg);
  var btn = document.getElementById('favBtn');
  if (!btn) return;
  btn.textContent = _isFav ? '♥' : '♡';
  btn.classList.toggle('active', _isFav);
}

// Cart count
document.addEventListener('DOMContentLoaded', function() {
  var cnt = document.getElementById('cartCountDetail');
  if (cnt) cnt.textContent = Cart.count();
});

// Star picker for review
document.querySelectorAll('.star-i').forEach(function(star) {
  star.addEventListener('mouseover', function() {
    var v = parseInt(this.dataset.val);
    document.querySelectorAll('.star-i').forEach(function(s, i) { s.classList.toggle('on', i < v); });
  });
  star.addEventListener('mouseout', function() {
    document.querySelectorAll('.star-i').forEach(function(s, i) { s.classList.toggle('on', i < myRating); });
  });
  star.addEventListener('click', function() {
    myRating = parseInt(this.dataset.val);
    document.querySelectorAll('.star-i').forEach(function(s, i) { s.classList.toggle('on', i < myRating); });
  });
});

// Submit review
async function submitReview() {
  var text = document.getElementById('reviewText').value.trim();
  if (!myRating) { showToast('Please select a star rating ⭐'); return; }
  if (!text)     { showToast('Please write a short review 📝'); return; }
  try {
    var r = await fetch('/api/feedback', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        text: text, type: 'REVIEW', rating: myRating,
        foodItemId: foodId, foodItemName: foodName, orderId: ''
      })
    });
    var d = await r.json();
    if (d.success) {
      showToast('Review posted! Thank you ⭐');
      document.getElementById('reviewText').value = '';
      myRating = 0;
      document.querySelectorAll('.star-i').forEach(function(s){ s.classList.remove('on'); });
      loadReviews();
    } else { showToast('Could not post review. Try again.'); }
  } catch(e) { showToast('Network error. Try again.'); }
}

// Load reviews from API
async function loadReviews() {
  var container = document.getElementById('reviewsList');
  try {
    var data = await fetch('/api/food/' + foodId + '/reviews').then(function(r){ return r.json(); });
    if (!data || !data.length) {
      container.innerHTML = '<div style="text-align:center;padding:28px;color:var(--c-muted);"><div style="font-size:2.5rem;margin-bottom:8px;">💬</div><p style="margin:0;">No reviews yet. Be the first!</p></div>';
      document.getElementById('avgStarsDisplay').innerHTML = '';
      document.getElementById('heroRating').innerHTML = '';
      return;
    }
    var avg = (data.reduce(function(s,r){ return s+(r.rating||5); }, 0) / data.length);
    var stars = '';
    for (var i=1; i<=5; i++) stars += '<span style="color:'+(i<=Math.round(avg)?'#FFB800':'#555')+';">★</span>';
    document.getElementById('avgStarsDisplay').innerHTML = '<span style="font-size:1.2rem;font-weight:800;color:var(--c-orange);">' + avg.toFixed(1) + '</span><span style="font-size:1rem;margin-left:3px;">' + stars + '</span><span style="font-size:.75rem;color:var(--c-muted);margin-left:5px;">(' + data.length + ')</span>';
    document.getElementById('heroRating').innerHTML = stars + '<span style="margin-left:4px;">' + avg.toFixed(1) + ' (' + data.length + ' reviews)</span>';
    container.innerHTML = data.slice(0, 8).map(function(rv) {
      var rstars = '';
      for (var i=1;i<=5;i++) rstars += '<span style="color:'+(i<=(rv.rating||5)?'#FFB800':'#D0D0D0')+';">★</span>';
      return '<div class="rv-card">'
        + '<div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:8px;">'
        + '<div style="display:flex;align-items:center;gap:10px;">'
        + '<div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,var(--c-orange),var(--c-orange-d));color:white;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.9rem;flex-shrink:0;">'+(rv.customerName||'?').charAt(0).toUpperCase()+'</div>'
        + '<div><div style="font-weight:700;font-size:.88rem;color:var(--c-text);">'+(rv.customerName||'Customer')+'</div>'
        + '<div style="font-size:.72rem;color:var(--c-muted);">'+(rv.createdAt||'')+'</div></div>'
        + '</div><div style="font-size:1rem;">' + rstars + '</div></div>'
        + '<p style="font-size:.875rem;color:var(--c-text2);line-height:1.75;margin:0;font-style:italic;">&ldquo;'+(rv.text||'Good!')+'&rdquo;</p>'
        + (rv.adminReply ? '<div style="margin-top:10px;padding:9px 13px;background:var(--c-orange-l);border-left:3px solid var(--c-orange);border-radius:0 10px 10px 0;font-size:.8rem;"><strong style="color:var(--c-orange);">YummyDish:</strong> '+ rv.adminReply +'</div>' : '')
        + '</div>';
    }).join('');
  } catch(e) {
    container.innerHTML = '<p style="color:var(--c-muted);text-align:center;padding:16px;">Could not load reviews.</p>';
  }
}

// Load related items
async function loadRelated() {
  try {
    var data = await fetch('/api/foods?category=${food.category}').then(function(r){ return r.json(); });
    var others = data.filter(function(f){ return f.id !== foodId && f.available; }).slice(0, 3);
    var c = document.getElementById('relatedItems');
    if (!others.length) { c.innerHTML = '<p style="color:var(--c-muted);font-size:.82rem;">No related items</p>'; return; }
    c.innerHTML = others.map(function(f) {
      return '<div class="related-card mb-2" onclick="location.href=\'/menu/item/\'+\''+ f.id +'\'">'
        + '<div style="display:flex;align-items:center;gap:10px;padding:10px;">'
        + '<div style="width:56px;height:56px;border-radius:10px;overflow:hidden;flex-shrink:0;"><img src="'+(f.imageUrl||'')+'" style="width:100%;height:100%;object-fit:cover;transition:transform .4s;" onerror="this.style.display=\'none\'"></div>'
        + '<div style="flex:1;"><div style="font-weight:600;font-size:.875rem;color:var(--c-text);">'+f.name+'</div>'
        + '<div style="color:var(--c-orange);font-weight:700;font-size:.82rem;">LKR '+Math.round(f.price).toLocaleString()+'</div></div>'
        + '<button onclick="event.stopPropagation();Cart.add(\''+f.id+'\',\''+f.name.replace(/'/g,'')+'\','+f.price+',1,\''+(f.imageUrl||'\'')+')"'
        + ' class="yd-btn yd-btn-primary yd-btn-sm" style="width:auto;padding:6px 12px;flex-shrink:0;">'
        + '<i class="bi bi-cart-plus"></i></button>'
        + '</div></div>';
    }).join('');
  } catch(e) {}
}

loadReviews();
loadRelated();
</script>
<%@ include file="/WEB-INF/views/layout/footer.jsp" %>
