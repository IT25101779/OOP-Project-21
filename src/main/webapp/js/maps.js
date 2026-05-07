/*
 * YummyDish — maps.js  (Leaflet + OpenStreetMap edition)
 * 100% free — no API key, no billing, works on localhost
 * Drop-in replacement: same YDMaps.* public API as before
 */
var YDMaps = (function () {

  var RESTAURANT = { lat: 7.2937, lng: 80.6340, name: 'YummyDish Kitchen — Kandy Town' };
  var KANDY_SW   = { lat: 7.200,  lng: 80.550 };
  var KANDY_NE   = { lat: 7.380,  lng: 80.750 };

  // Geocode cache
  var geocodeCache = {};

  // Nominatim rate-limit queue (1 req / 1.2s)
  var _geoQueue = [], _geoRunning = false;
  function _enqueue(fn) {
    _geoQueue.push(fn);
    if (!_geoRunning) _drain();
  }
  function _drain() {
    if (!_geoQueue.length) { _geoRunning = false; return; }
    _geoRunning = true;
    _geoQueue.shift()();
    setTimeout(_drain, 1200);
  }

  function _haversine(lat1,lng1,lat2,lng2) {
    var R=6371, r=Math.PI/180;
    var a=Math.sin((lat2-lat1)*r/2)*Math.sin((lat2-lat1)*r/2)
        +Math.cos(lat1*r)*Math.cos(lat2*r)*Math.sin((lng2-lng1)*r/2)*Math.sin((lng2-lng1)*r/2);
    return R*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
  }

  function _tiles(map) {
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19
    }).addTo(map);
  }

  // ── initMap ──────────────────────────────────────────────────────
  function initMap(elementId, lat, lng, zoom) {
    var el = document.getElementById(elementId);
    if (!el) return null;
    if (el._ydmap) { try { el._ydmap.remove(); } catch(e){} }
    var m = L.map(el, { center:[+lat,+lng], zoom:zoom||14, zoomControl:true });
    _tiles(m);
    el._ydmap = m;
    return m;
  }

  // ── addMarker ────────────────────────────────────────────────────
  function addMarker(map, lat, lng, title, popupHtml) {
    if (!map) return null;
    var icon = L.divIcon({ className:'',
      html:'<div style="width:34px;height:34px;background:#FF6B35;border-radius:50% 50% 50% 0;'
          +'transform:rotate(-45deg);border:3px solid white;box-shadow:0 3px 10px rgba(255,107,53,.4);">'
          +'</div>', iconSize:[34,34], iconAnchor:[11,34] });
    var mkr = L.marker([+lat,+lng],{icon:icon,title:title||''}).addTo(map);
    if (popupHtml) mkr.bindPopup(popupHtml,{maxWidth:260});
    return mkr;
  }

  // ── kitchen marker ───────────────────────────────────────────────
  function _kitchenMarker(map) {
    var icon = L.divIcon({ className:'',
      html:'<div style="width:44px;height:44px;background:#FF6B35;border-radius:50% 50% 50% 0;'
          +'transform:rotate(-45deg);border:3px solid white;box-shadow:0 4px 12px rgba(255,107,53,.5);">'
          +'<span style="transform:rotate(45deg);display:block;text-align:center;font-size:20px;line-height:38px;">🍽️</span>'
          +'</div>', iconSize:[44,44], iconAnchor:[22,44] });
    return L.marker([RESTAURANT.lat,RESTAURANT.lng],{icon:icon}).addTo(map)
      .bindPopup('<div style="padding:10px 14px;font-family:Inter,sans-serif;">'
        +'<strong style="color:#FF6B35;">🍽️ YummyDish Kitchen</strong><br>'
        +'<span style="font-size:12px;color:#666;">Queens Hotel Area, Kandy</span></div>');
  }

  // ── driver marker (bike) ─────────────────────────────────────────
  function createDriverMarker(map, lat, lng) {
    if (!map) return null;
    var icon = L.divIcon({ className:'',
      html:'<div style="width:48px;height:48px;background:#1565C0;border-radius:50%;border:3px solid white;'
          +'box-shadow:0 4px 16px rgba(21,101,192,.5);display:flex;align-items:center;justify-content:center;font-size:22px;">🛵</div>',
      iconSize:[48,48], iconAnchor:[24,24] });
    return L.marker([+lat,+lng],{icon:icon,zIndexOffset:1000}).addTo(map);
  }

  // ── drawRoute (OSRM free routing) ────────────────────────────────
  function drawRoute(map, oLat, oLng, dLat, dLng, callback) {
    if (!map) return null;
    if (typeof L.Routing !== 'undefined') {
      var ctrl = L.Routing.control({
        waypoints:[L.latLng(+oLat,+oLng),L.latLng(+dLat,+dLng)],
        routeWhileDragging:false, addWaypoints:false,
        fitSelectedRoutes:true, show:false,
        lineOptions:{styles:[{color:'#FF6B35',weight:6,opacity:.85}]},
        createMarker:function(){return null;}
      }).addTo(map);
      ctrl.on('routesfound',function(e){
        if(callback){var s=e.routes[0].summary;callback({distance:s.totalDistance,duration:s.totalTime});}
      });
      ctrl.on('routingerror',function(){if(callback)callback(null);});
      return ctrl;
    }
    // Fallback: straight dashed line
    var line = L.polyline([[+oLat,+oLng],[+dLat,+dLng]],{color:'#FF6B35',weight:5,opacity:.7,dashArray:'10,8'}).addTo(map);
    map.fitBounds([[+oLat,+oLng],[+dLat,+dLng]],{padding:[50,50]});
    if (callback) callback({distance:_haversine(+oLat,+oLng,+dLat,+dLng)*1000,duration:0});
    return line;
  }

  // ── geocode (Nominatim) ──────────────────────────────────────────
  function geocode(address, callback) {
    var key = (address||'').trim().toLowerCase();
    if (geocodeCache[key]) { callback(L.latLng(geocodeCache[key].lat,geocodeCache[key].lng)); return; }
    _enqueue(function(){
      fetch('https://nominatim.openstreetmap.org/search?q='+encodeURIComponent(address+', Kandy, Sri Lanka')
        +'&format=json&limit=1&countrycodes=lk',{headers:{'Accept-Language':'en'}})
        .then(function(r){return r.json();})
        .then(function(d){
          var lat=d&&d[0]?+d[0].lat:RESTAURANT.lat, lng=d&&d[0]?+d[0].lon:RESTAURANT.lng;
          geocodeCache[key]={lat:lat,lng:lng};
          callback(L.latLng(lat,lng));
        }).catch(function(){callback(L.latLng(RESTAURANT.lat,RESTAURANT.lng));});
    });
  }

  // ── reverseGeocode (Nominatim) ───────────────────────────────────
  function reverseGeocode(lat, lng, callback) {
    fetch('https://nominatim.openstreetmap.org/reverse?lat='+lat+'&lon='+lng+'&format=json&zoom=18',
      {headers:{'Accept-Language':'en'}})
      .then(function(r){return r.json();})
      .then(function(d){
        var addr=(d.display_name||lat.toFixed(5)+', '+lng.toFixed(5))
          .replace(/, Sri Lanka$/,'').replace(/\d{5},\s*/g,'');
        callback(addr);
      }).catch(function(){callback(lat.toFixed(5)+', '+lng.toFixed(5));});
  }

  // ── initStaticPinMap (Uber-style — map moves under fixed pin) ────
  function initStaticPinMap(elementId, lat, lng, zoom, onAddressChange) {
    var map = initMap(elementId, lat, lng, zoom||14);
    if (!map) return null;
    _kitchenMarker(map);
    // Fixed 📍 pin in center
    var el = document.getElementById(elementId);
    if (el) {
      el.style.position='relative';
      var pin=document.createElement('div');
      pin.id=elementId+'_pin';
      pin.style.cssText='position:absolute;top:50%;left:50%;transform:translate(-50%,-100%);'
        +'pointer-events:none;z-index:1000;font-size:36px;'
        +'filter:drop-shadow(0 3px 6px rgba(0,0,0,.4));transition:transform .12s;';
      pin.textContent='📍';
      el.appendChild(pin);
    }
    var timer=null;
    map.on('movestart',function(){
      var p=document.getElementById(elementId+'_pin');
      if(p) p.style.transform='translate(-50%,-120%)';
    });
    map.on('moveend',function(){
      var p=document.getElementById(elementId+'_pin');
      if(p) p.style.transform='translate(-50%,-100%)';
      clearTimeout(timer);
      timer=setTimeout(function(){
        var c=map.getCenter();
        reverseGeocode(c.lat,c.lng,function(addr){
          if(addr&&onAddressChange) onAddressChange(addr,c.lat,c.lng);
        });
      },700);
    });
    return map;
  }

  // ── animateMarkerTo ──────────────────────────────────────────────
  function animateMarkerTo(marker, newLat, newLng, steps) {
    if (!marker) return;
    steps=steps||25;
    var from=marker.getLatLng(), dLat=(+newLat-from.lat)/steps, dLng=(+newLng-from.lng)/steps, i=0;
    var iv=setInterval(function(){
      i++; marker.setLatLng([from.lat+dLat*i,from.lng+dLng*i]);
      if(i>=steps) clearInterval(iv);
    },35);
  }

  // ── fitBounds ────────────────────────────────────────────────────
  function fitBounds(map, positions) {
    if(!map||!positions||!positions.length) return;
    map.fitBounds(L.latLngBounds(positions.map(function(p){return[p.lat||p[0],p.lng||p[1]];})),{padding:[50,50]});
  }

  // ── GPS helpers ──────────────────────────────────────────────────
  function getLiveLocation(cb) {
    if(!navigator.geolocation){cb(null,'Not supported');return;}
    navigator.geolocation.getCurrentPosition(
      function(p){cb({lat:p.coords.latitude,lng:p.coords.longitude});},
      function(e){cb(null,e.message);},{enableHighAccuracy:true,timeout:10000,maximumAge:30000});
  }
  function watchLocation(cb) {
    if(!navigator.geolocation) return null;
    return navigator.geolocation.watchPosition(
      function(p){cb({lat:p.coords.latitude,lng:p.coords.longitude});},
      function(){},{enableHighAccuracy:true,maximumAge:4000,timeout:15000});
  }

  // ── openNavigation (OSM directions) ─────────────────────────────
  function openNavigation(dLat, dLng) {
    window.open('https://www.openstreetmap.org/directions?engine=fossgis_osrm_car'
      +'&route='+RESTAURANT.lat+'%2C'+RESTAURANT.lng+';'+dLat+'%2C'+dLng,'_blank');
  }

  // ── autocomplete (Nominatim search-as-you-type) ──────────────────
  function autocomplete(inputId, callback) {
    var input=document.getElementById(inputId);
    if(!input) return null;
    var timer=null;
    var dd=document.createElement('div');
    dd.style.cssText='position:absolute;background:#fff;border:1px solid #ddd;border-radius:10px;'
      +'z-index:9999;width:100%;box-shadow:0 4px 16px rgba(0,0,0,.15);'
      +'max-height:220px;overflow-y:auto;display:none;top:100%;left:0;';
    var wrap=input.parentElement;
    wrap.style.position='relative';
    wrap.appendChild(dd);
    input.addEventListener('input',function(){
      clearTimeout(timer);
      var val=input.value.trim();
      if(val.length<3){dd.style.display='none';return;}
      timer=setTimeout(function(){
        fetch('https://nominatim.openstreetmap.org/search?q='+encodeURIComponent(val+', Kandy, Sri Lanka')
          +'&format=json&limit=5&countrycodes=lk',{headers:{'Accept-Language':'en'}})
          .then(function(r){return r.json();})
          .then(function(results){
            dd.innerHTML='';
            if(!results.length){dd.style.display='none';return;}
            results.forEach(function(r){
              var item=document.createElement('div');
              item.style.cssText='padding:9px 13px;cursor:pointer;font-size:.83rem;border-bottom:1px solid #f3f3f3;';
              item.textContent='📍 '+r.display_name.replace(', Sri Lanka','');
              item.onmouseenter=function(){item.style.background='#FFF0EB';};
              item.onmouseleave=function(){item.style.background='';};
              item.onclick=function(){
                input.value=r.display_name.replace(', Sri Lanka','');
                dd.style.display='none';
                if(callback) callback({
                  formatted_address:input.value,
                  geometry:{location:L.latLng(+r.lat,+r.lon)}
                });
              };
              dd.appendChild(item);
            });
            dd.style.display='block';
          }).catch(function(){});
      },400);
    });
    document.addEventListener('click',function(e){if(!input.contains(e.target))dd.style.display='none';});
    return {dropdown:dd};
  }

  // Public API
  return {
    RESTAURANT:         RESTAURANT,
    KANDY_BOUNDS:       {sw:KANDY_SW,ne:KANDY_NE},
    initMap:            initMap,
    addMarker:          addMarker,
    drawRoute:          drawRoute,
    drawMultiStopRoute: drawRoute,
    geocode:            geocode,
    reverseGeocode:     reverseGeocode,
    initStaticPinMap:   initStaticPinMap,
    getLiveLocation:    getLiveLocation,
    watchLocation:      watchLocation,
    animateMarkerTo:    animateMarkerTo,
    createDriverMarker: createDriverMarker,
    fitBounds:          fitBounds,
    openNavigation:     openNavigation,
    autocomplete:       autocomplete,
    _kitchenMarker:     _kitchenMarker,
    haversine:          _haversine
  };
})();
