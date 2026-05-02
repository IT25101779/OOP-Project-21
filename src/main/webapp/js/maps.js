/*
 * YummyDish — maps.js  v3
 * Real Google Maps integration for Kandy, Sri Lanka
 * Handles: geocoding, reverse geocoding, routing, live tracking, static-pin map
 */
const YDMaps = (function() {

    // Kitchen location in Kandy
    const RESTAURANT = {
        lat:  7.2937,
        lng:  80.6340,
        name: 'YummyDish Kitchen — Queens Hotel Area, Kandy'
    };

    const KANDY_BOUNDS = new (function() {
        this.sw = { lat: 7.200, lng: 80.550 };
        this.ne = { lat: 7.380, lng: 80.750 };
        this.asLatLngBounds = function() {
            return new google.maps.LatLngBounds(
                new google.maps.LatLng(this.sw.lat, this.sw.lng),
                new google.maps.LatLng(this.ne.lat, this.ne.lng)
            );
        };
    })();

    // Minimal map style - clean, food-delivery look
    const MAP_STYLE = [
        { featureType: 'poi.business',       stylers: [{ visibility: 'off' }] },
        { featureType: 'poi.government',     stylers: [{ visibility: 'off' }] },
        { featureType: 'transit',            stylers: [{ visibility: 'simplified' }] },
        { featureType: 'road',               elementType: 'geometry', stylers: [{ color: '#f5f5f5' }] },
        { featureType: 'road.highway',       elementType: 'geometry', stylers: [{ color: '#ffe0b2' }] },
        { featureType: 'road.arterial',      elementType: 'geometry', stylers: [{ color: '#ffffff' }] },
        { featureType: 'water',              elementType: 'geometry', stylers: [{ color: '#c9e8f0' }] },
        { featureType: 'landscape.natural',  elementType: 'geometry', stylers: [{ color: '#e8f5e9' }] },
        { featureType: 'landscape.man_made', elementType: 'geometry', stylers: [{ color: '#f0ece4' }] }
    ];

    // Cache for geocode results to reduce API calls
    const geocodeCache = {};
    const geocoder = function() {
        return typeof google !== 'undefined' ? new google.maps.Geocoder() : null;
    };

    function initMap(elementId, lat, lng, zoom, options) {
        if (typeof google === 'undefined') { console.warn('Google Maps not loaded'); return null; }
        var el = document.getElementById(elementId);
        if (!el) { console.warn('Map element not found:', elementId); return null; }
        var opts = Object.assign({
            center:            { lat: parseFloat(lat), lng: parseFloat(lng) },
            zoom:              zoom || 14,
            mapTypeControl:    false,
            streetViewControl: false,
            fullscreenControl: true,
            zoomControlOptions: { position: google.maps.ControlPosition.RIGHT_CENTER },
            styles:            MAP_STYLE,
            gestureHandling:   'greedy'
        }, options || {});
        return new google.maps.Map(el, opts);
    }

    function restrictToKandy(map) {
        if (!map || typeof google === 'undefined') return;
        map.setOptions({ restriction: { latLngBounds: KANDY_BOUNDS.asLatLngBounds(), strictBounds: false } });
    }

    function addMarker(map, lat, lng, title, infoHtml, iconUrl) {
        if (!map || typeof google === 'undefined') return null;
        var opts = {
            map:       map,
            position:  { lat: parseFloat(lat), lng: parseFloat(lng) },
            title:     title || '',
            animation: google.maps.Animation.DROP
        };
        if (iconUrl) {
            opts.icon = typeof iconUrl === 'string'
                ? { url: iconUrl, scaledSize: new google.maps.Size(40, 40) }
                : iconUrl;
        }
        var marker = new google.maps.Marker(opts);
        if (infoHtml) {
            var iw = new google.maps.InfoWindow({ content: infoHtml, maxWidth: 280 });
            marker.addListener('click', function() { iw.open(map, marker); });
        }
        return marker;
    }

    function drawRoute(map, oLat, oLng, dLat, dLng, callback) {
        if (!map || typeof google === 'undefined') return null;
        var renderer = new google.maps.DirectionsRenderer({
            map: map,
            suppressMarkers: false,
            polylineOptions: { strokeColor: '#FF6B35', strokeWeight: 5, strokeOpacity: 0.85 }
        });
        new google.maps.DirectionsService().route({
            origin:      { lat: parseFloat(oLat), lng: parseFloat(oLng) },
            destination: { lat: parseFloat(dLat), lng: parseFloat(dLng) },
            travelMode:  google.maps.TravelMode.DRIVING
        }, function(result, status) {
            if (status === 'OK') {
                renderer.setDirections(result);
                if (callback) callback(result.routes[0].legs[0]);
            } else {
                console.warn('Directions failed:', status);
                if (callback) callback(null);
            }
        });
        return renderer;
    }

    function drawMultiStopRoute(map, originLat, originLng, waypoints, callback) {
        if (!map || typeof google === 'undefined' || !waypoints.length) return null;
        var dest   = waypoints[waypoints.length - 1];
        var midpts = waypoints.slice(0, -1).map(function(wp) {
            return { location: new google.maps.LatLng(wp.lat, wp.lng), stopover: true };
        });
        var renderer = new google.maps.DirectionsRenderer({
            map: map,
            suppressMarkers: false,
            polylineOptions: { strokeColor: '#FF6B35', strokeWeight: 5, strokeOpacity: 0.85 }
        });
        new google.maps.DirectionsService().route({
            origin:            { lat: parseFloat(originLat), lng: parseFloat(originLng) },
            destination:       { lat: parseFloat(dest.lat),  lng: parseFloat(dest.lng)  },
            waypoints:         midpts,
            optimizeWaypoints: true,
            travelMode:        google.maps.TravelMode.DRIVING
        }, function(result, status) {
            if (status === 'OK') {
                renderer.setDirections(result);
                if (callback) callback(result);
            } else {
                console.warn('Multi-stop directions failed:', status);
            }
        });
        return renderer;
    }

    function autocomplete(inputId, callback) {
        if (typeof google === 'undefined') return null;
        var input = document.getElementById(inputId);
        if (!input) return null;
        var ac = new google.maps.places.Autocomplete(input, {
            componentRestrictions: { country: 'lk' },
            bounds: KANDY_BOUNDS.asLatLngBounds(),
            strictBounds: false,
            fields: ['geometry', 'formatted_address', 'name', 'address_components']
        });
        ac.addListener('place_changed', function() {
            var place = ac.getPlace();
            if (place.geometry && callback) callback(place);
        });
        return ac;
    }

    // Geocode with caching and retry
    function geocode(address, callback) {
        if (typeof google === 'undefined') {
            callback(new google.maps.LatLng(RESTAURANT.lat, RESTAURANT.lng));
            return;
        }
        // Check cache
        var cacheKey = address.trim().toLowerCase();
        if (geocodeCache[cacheKey]) {
            callback(new google.maps.LatLng(geocodeCache[cacheKey].lat, geocodeCache[cacheKey].lng));
            return;
        }
        var queries = [
            address,
            address + ', Kandy, Sri Lanka',
            address + ', Central Province, Sri Lanka',
            'Kandy, Sri Lanka'  // final fallback
        ];
        var tried = 0;
        function tryNext() {
            if (tried >= queries.length) {
                callback(new google.maps.LatLng(RESTAURANT.lat, RESTAURANT.lng));
                return;
            }
            geocoder().geocode({ address: queries[tried] }, function(results, status) {
                tried++;
                if (status === 'OK' && results[0]) {
                    var loc = results[0].geometry.location;
                    geocodeCache[cacheKey] = { lat: loc.lat(), lng: loc.lng() };
                    callback(loc);
                } else if (status === 'OVER_QUERY_LIMIT') {
                    // Rate limited - wait and retry
                    setTimeout(tryNext, 1000);
                } else {
                    tryNext();
                }
            });
        }
        tryNext();
    }

    function reverseGeocode(lat, lng, callback) {
        if (typeof google === 'undefined') { callback(null); return; }
        geocoder().geocode({ location: { lat: parseFloat(lat), lng: parseFloat(lng) } },
            function(results, status) {
                if (status !== 'OK' || !results.length) { callback(null); return; }
                // Find best result - prefer street address or neighborhood
                var best = null;
                var priority = ['street_address','route','neighborhood','sublocality','locality'];
                for (var p = 0; p < priority.length && !best; p++) {
                    best = results.find(function(r) { return r.types.includes(priority[p]); });
                }
                best = best || results[0];
                // Remove Plus Code prefix if present (e.g. "XXXX+XX Kandy")
                var addr = best.formatted_address.replace(/^[A-Z0-9]{4,8}\+[A-Z0-9]{2,3}\s+/, '');
                callback(addr);
            }
        );
    }

    // Static-pin map (map moves, pin stays centered)
    function initStaticPinMap(elementId, lat, lng, zoom, onAddressChange) {
        var map = initMap(elementId, lat, lng, zoom || 14);
        if (!map) return null;
        restrictToKandy(map);
        // Add restaurant marker
        addMarker(map, RESTAURANT.lat, RESTAURANT.lng, 'YummyDish Kitchen',
            '<div style="font-family:sans-serif;padding:8px 12px;"><strong>🍽️ Kitchen</strong></div>');
        // On idle: reverse geocode center
        var idleTimer = null;
        map.addListener('idle', function() {
            clearTimeout(idleTimer);
            idleTimer = setTimeout(function() {
                var center = map.getCenter();
                reverseGeocode(center.lat(), center.lng(), function(addr) {
                    if (addr && onAddressChange) onAddressChange(addr, center.lat(), center.lng());
                });
            }, 600); // debounce 600ms
        });
        return map;
    }

    function getLiveLocation(callback) {
        if (!navigator.geolocation) { callback(null, 'Geolocation not supported'); return; }
        navigator.geolocation.getCurrentPosition(
            function(pos) { callback({ lat: pos.coords.latitude, lng: pos.coords.longitude }); },
            function(err) { callback(null, err.message); },
            { enableHighAccuracy: true, timeout: 10000, maximumAge: 30000 }
        );
    }

    function watchLocation(callback) {
        if (!navigator.geolocation) return null;
        return navigator.geolocation.watchPosition(
            function(pos) { callback({ lat: pos.coords.latitude, lng: pos.coords.longitude }); },
            function() {},
            { enableHighAccuracy: true, maximumAge: 5000, timeout: 15000 }
        );
    }

    // Smooth marker animation
    function animateMarkerTo(marker, newLat, newLng, steps) {
        if (!marker || typeof google === 'undefined') return;
        steps = steps || 30;
        var cur  = marker.getPosition();
        var dLat = (parseFloat(newLat) - cur.lat()) / steps;
        var dLng = (parseFloat(newLng) - cur.lng()) / steps;
        var i = 0;
        var iv = setInterval(function() {
            i++;
            marker.setPosition({ lat: cur.lat() + dLat * i, lng: cur.lng() + dLng * i });
            if (i >= steps) clearInterval(iv);
        }, 35);
    }

    function createDriverMarker(map, lat, lng) {
        if (!map || typeof google === 'undefined') return null;
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="56" height="56" viewBox="0 0 56 56">'
            + '<circle cx="28" cy="28" r="26" fill="#FF6B35" stroke="white" stroke-width="3" filter="drop-shadow(0 3px 6px rgba(0,0,0,0.4))"/>'
            + '<text x="28" y="37" text-anchor="middle" font-size="26">🛵</text>'
            + '</svg>';
        return addMarker(map, lat, lng, 'Driver', null, {
            url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg),
            scaledSize: new google.maps.Size(56, 56),
            anchor:     new google.maps.Point(28, 28)
        });
    }

    function fitBounds(map, positions) {
        if (!map || !positions || !positions.length) return;
        var bounds = new google.maps.LatLngBounds();
        positions.forEach(function(p) { bounds.extend(p); });
        map.fitBounds(bounds, { padding: 60 });
    }

    // Open Google Maps navigation
    function openNavigation(destLat, destLng, originLat, originLng) {
        var oLat = originLat || RESTAURANT.lat;
        var oLng = originLng || RESTAURANT.lng;
        var url  = 'https://www.google.com/maps/dir/?api=1'
                 + '&origin=' + oLat + ',' + oLng
                 + '&destination=' + destLat + ',' + destLng
                 + '&travelmode=driving';
        window.open(url, '_blank');
    }

    return {
        RESTAURANT,
        KANDY_BOUNDS,
        initMap,
        restrictToKandy,
        addMarker,
        drawRoute,
        drawMultiStopRoute,
        autocomplete,
        geocode,
        reverseGeocode,
        initStaticPinMap,
        getLiveLocation,
        watchLocation,
        animateMarkerTo,
        createDriverMarker,
        fitBounds,
        openNavigation
    };
})();
