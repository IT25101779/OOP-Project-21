package com.yummydish.servlet;

import com.yummydish.model.*;
import com.yummydish.service.*;
import com.yummydish.util.FileStorageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

// ── Global model attributes injected into every JSP ──────────────
@org.springframework.web.bind.annotation.ControllerAdvice
@Controller
class CheckoutController {
    @GetMapping("/cart") public String cart(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); return "checkout/cart";
    }
    @GetMapping("/thank-you") public String thanks(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); return "checkout/thank-you";
    }
}

@org.springframework.web.bind.annotation.RestController
@RequestMapping("/api")
class ApiController {
    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final String DRIVER_NAME    = "Kasun Perera";
    private static final String DRIVER_CONTACT = "071-456-7890";

    @Value("${openweather.api.key:}") private String openWeatherKey;

    private final FoodItemService foodService;
    private final FileStorageUtil fsu;
    private final OfferService offerService;
    private final UserService userService;

    /**
     * OrderQueue — Data Structure: Queue (FIFO)
     * Manages order processing in arrival sequence.
     * Injected as a Spring singleton so the same queue instance is shared
     * across all requests in the application lifecycle.
     */
    private final com.yummydish.util.OrderQueue orderQueue;

    @Autowired ApiController(FoodItemService f, FileStorageUtil fs, OfferService o,
                             UserService us, com.yummydish.util.OrderQueue oq) {
        this.foodService = f; this.fsu = fs; this.offerService = o;
        this.userService = us; this.orderQueue = oq;
        // Restore queue from persisted orders on startup
        restoreQueueFromStorage();
    }

    /** Rebuild the in-memory queue from saved PENDING orders on server start. */
    private void restoreQueueFromStorage() {
        try {
            List<Order> pending = fsu.readAll(fsu.getOrdersFile()).stream()
                .map(line -> { try { return Order.fromLine(line); } catch(Exception e) { return null; } })
                .filter(o -> o != null && Order.PENDING.equals(o.getStatus()))
                .sorted(java.util.Comparator.comparing(o -> o.getCreatedAt() != null ? o.getCreatedAt() : ""))
                .collect(Collectors.toList());
            orderQueue.restoreFromStorage(pending);
            System.out.println("[OrderQueue] Restored " + pending.size() + " pending order(s) from storage.");
        } catch (Exception e) {
            System.err.println("[OrderQueue] Could not restore from storage: " + e.getMessage());
        }
    }

    @GetMapping("/foods")
    public ResponseEntity<?> foods(
            @RequestParam(defaultValue = "All")  String category,
            @RequestParam(defaultValue = "")     String search,
            @RequestParam(defaultValue = "none") String sort) {

        List<FoodItem> items;
        if (!search.isBlank()) {
            items = foodService.search(search);
        } else {
            items = "All".equals(category)
                ? foodService.getAll()
                : foodService.getByCategory(category);
        }

        // ── QuickSort: sort by price when requested ────────────────────────
        // Uses custom QuickSort implementation (O(n log n) average-case)
        // instead of Java's built-in sort — see com.yummydish.util.QuickSort
        if ("price_asc".equals(sort)) {
            com.yummydish.util.QuickSort.sortByPriceAscending(items);
        } else if ("price_desc".equals(sort)) {
            com.yummydish.util.QuickSort.sortByPriceDescending(items);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (FoodItem f : items) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id",            f.getId());
            map.put("name",          f.getName());
            map.put("price",         f.getPrice());
            map.put("category",      f.getCategory());
            map.put("description",   f.getDescription());
            map.put("imageUrl",      f.getImageUrl() != null ? f.getImageUrl() : "");
            map.put("calories",      f.getCalories());
            map.put("portionSize",   f.getPortionSize() != null ? f.getPortionSize() : "");
            map.put("popular",       f.isPopular());
            map.put("rating",        f.getRating());
            map.put("ingredients",   f.getIngredients() != null ? f.getIngredients() : "");
            map.put("nutritionalInfo", f.getNutritionalInfo());
            map.put("foodType",      f.getFoodType());
            map.put("available",     f.isAvailable());
            map.put("reviewCount",   f.getReviewCount());
            result.add(map);
        }
        return ResponseEntity.ok(result);
    }

    /**
     * GET /api/queue/status — returns current OrderQueue state for admin dashboard.
     * Shows queue depth, next order to process, and all waiting orders in FIFO order.
     */
    @GetMapping("/queue/status")
    public ResponseEntity<?> queueStatus(HttpSession s) {
        if (s.getAttribute("admin") == null) return ResponseEntity.status(403).build();
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("queueDepth",  orderQueue.size());
        resp.put("isEmpty",     orderQueue.isEmpty());
        Order next = orderQueue.peek();
        resp.put("nextOrderId", next != null ? next.getOrderId() : null);
        resp.put("queue", orderQueue.snapshot().stream().map(o -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("orderId",   o.getOrderId());
            m.put("customer",  o.getCustomerName());
            m.put("total",     o.getTotalAmount());
            m.put("createdAt", o.getCreatedAt());
            return m;
        }).collect(Collectors.toList()));
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/validate-offer")
    public ResponseEntity<?> validateOffer(@RequestBody Map<String, Object> body, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        String code  = body.getOrDefault("code",    "").toString();
        double sub   = ((Number) body.getOrDefault("subtotal", 0)).doubleValue();
        return ResponseEntity.ok(offerService.validateCode(code, sub));
    }

    @PostMapping("/order")
    public ResponseEntity<?> placeOrder(@RequestBody Map<String, Object> body, HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).body(Map.of("error", "Not logged in"));
        try {
            Order o = buildOrder(body, u);
            fsu.appendLine(fsu.getOrdersFile(), o.toFileLine());

            // ── OrderQueue: enqueue new STANDARD orders for FIFO processing ──
            // Scheduled orders are queued when their scheduled time arrives,
            // not immediately at placement.
            if (!"SCHEDULED".equals(o.getOrderType())) {
                orderQueue.enqueue(o);
                System.out.println("[OrderQueue] Enqueued order " + o.getOrderId()
                    + " | Queue depth: " + orderQueue.size());
            }

            // For scheduled orders, also write to scheduled_orders.txt
            if ("SCHEDULED".equals(o.getOrderType()) && o.getScheduledFor() != null && !o.getScheduledFor().isEmpty()) {
                fsu.appendLine(fsu.getScheduledOrdersFile(), o.toFileLine());
            }
            // Award loyalty points to user
            try {
                User usr = userService.findById(u.getId());
                if (usr != null) {
                    usr.addLoyaltyPoints(o.getLoyaltyPoints());
                    fsu.update(fsu.getUsersFile(), u.getId(), usr.toFileLine());
                }
            } catch(Exception ignored) {}
            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success",        true);
            resp.put("orderId",        o.getOrderId());
            resp.put("total",          o.getTotalAmount());
            resp.put("loyaltyPoints",  o.getLoyaltyPoints());
            resp.put("estimatedEta",   o.getEstimatedEta());
            resp.put("driverName",     DRIVER_NAME);
            resp.put("driverContact",  DRIVER_CONTACT);
            resp.put("queuePosition",  orderQueue.size()); // tell customer their queue position
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/order/{id}")
    public ResponseEntity<?> getOrder(@PathVariable String id, HttpSession s) {
        if (s.getAttribute("user") == null && s.getAttribute("admin") == null
            && s.getAttribute("driver") == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("orderId",       o.getOrderId());
        resp.put("status",        o.getStatus());
        resp.put("statusBadge",   o.getStatusBadge());
        resp.put("progress",      o.getStatusProgress());
        resp.put("totalAmount",   o.getTotalAmount());
        resp.put("driverName",    o.getDriverName()    != null ? o.getDriverName()    : "");
        resp.put("driverContact", o.getDriverContact() != null ? o.getDriverContact() : "");
        resp.put("deliveryAddress", o.getDeliveryAddress() != null ? o.getDeliveryAddress() : "");
        // Include items so customer can reorder
        resp.put("items", o.getItems().stream().map(i -> {
            Map<String,Object> im = new LinkedHashMap<>();
            im.put("foodId",   i.getFoodId());
            im.put("foodName", i.getFoodName());
            im.put("price",    i.getPrice());
            im.put("quantity", i.getQuantity());
            im.put("imageUrl", i.getImageUrl() != null ? i.getImageUrl() : "");
            return im;
        }).collect(Collectors.toList()));
        return ResponseEntity.ok(resp);
    }

    // Driver updates order status via AJAX (from driver dashboard map)
    @PostMapping("/order/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable String id,
                                          @RequestParam String status,
                                          HttpSession s) throws IOException {
        // Allow driver or admin session
        boolean allowed = s.getAttribute("driver") != null || s.getAttribute("admin") != null;
        if (!allowed) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        o.setStatus(status);
        o.setUpdatedAt(LocalDateTime.now().format(DTF));
        fsu.update(fsu.getOrdersFile(), id, o.toFileLine());
        return ResponseEntity.ok(Map.of("success", true));
    }

    @PostMapping("/feedback")
    public ResponseEntity<?> feedback(@RequestBody Map<String, Object> body, HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        String fbId = "FB" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        String line = String.join("|",
            fbId, gs(body, "orderId"), u.getId(), u.getName(),
            gs(body, "text").replace("|", ""),
            gs(body, "foodItemId"), gs(body, "foodItemName"),
            "", LocalDateTime.now().format(DTF),
            gs(body, "type", "REVIEW"),
            String.valueOf(body.getOrDefault("rating", "5")));
        fsu.appendLine(fsu.getFeedbackFile(), line);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/food/{foodId}/reviews")
    public ResponseEntity<?> foodReviews(@PathVariable String foodId) {
        List<Map<String,Object>> reviews = fsu.readAll(fsu.getFeedbackFile()).stream()
            .filter(l -> { String[] p = l.split("\\|",-1); return p.length > 5 && foodId.equals(p[5]); })
            .map(l -> {
                String[] p = l.split("\\|",-1);
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id",           p.length>0?p[0]:"");
                m.put("customerName", p.length>3?p[3]:"");
                m.put("text",         p.length>4?p[4]:"");
                m.put("createdAt",    p.length>8?p[8]:"");
                m.put("adminReply",   p.length>7?p[7]:"");
                int rating = 5;
                try { if(p.length>10) rating = Integer.parseInt(p[10]); } catch(Exception ignored){}
                m.put("rating", rating);
                return m;
            })
            .sorted(Comparator.comparing((Map<String,Object> m) -> m.getOrDefault("createdAt","").toString(), Comparator.reverseOrder()))
            .collect(Collectors.toList());
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/weather")
    public ResponseEntity<?> getWeather() {
        Map<String,Object> result = new LinkedHashMap<>();
        try {
            String apiKey = openWeatherKey != null ? openWeatherKey.trim() : "";
            if (!apiKey.isEmpty()) {
                String url = "https://api.openweathermap.org/data/2.5/weather?lat=7.2906&lon=80.6337&appid=" + apiKey + "&units=metric";
                var conn = (java.net.HttpURLConnection) new java.net.URL(url).openConnection();
                conn.setConnectTimeout(4000); conn.setReadTimeout(4000);
                if (conn.getResponseCode() == 200) {
                    String json = new String(conn.getInputStream().readAllBytes());
                    double temp = 28.0; String desc = "partly cloudy"; String main = "Clouds";
                    try { int ti=json.indexOf("\"temp\":"); if(ti>=0){int end=json.indexOf(",",ti+7);if(end>ti)temp=Double.parseDouble(json.substring(ti+7,end).trim());} } catch(Exception ignored){}
                    try { int di=json.indexOf("\"description\":\""); if(di>=0){int s2=di+15;int e2=json.indexOf("\"",s2);if(e2>s2)desc=json.substring(s2,e2);} } catch(Exception ignored){}
                    try { int mi=json.indexOf("\"main\":\""); if(mi>=0){int s2=mi+8;int e2=json.indexOf("\"",s2);if(e2>s2)main=json.substring(s2,e2);} } catch(Exception ignored){}
                    boolean isRaining = main.equalsIgnoreCase("Rain")||main.equalsIgnoreCase("Drizzle")||main.equalsIgnoreCase("Thunderstorm");
                    boolean isHeavy   = main.equalsIgnoreCase("Thunderstorm")||desc.contains("heavy");
                    String icon = switch(main.toLowerCase()) {
                        case "rain"         -> "🌧️";
                        case "drizzle"      -> "🌦️";
                        case "thunderstorm" -> "⛈️";
                        case "clouds"       -> "⛅";
                        case "mist","fog","haze" -> "🌫️";
                        default             -> "☀️";
                    };
                    result.put("condition", icon + " " + desc.substring(0,1).toUpperCase() + desc.substring(1));
                    result.put("temp",      String.format("%.0f°C", temp));
                    result.put("extraFee",  isHeavy ? 100 : isRaining ? 50 : 0);
                    result.put("isRaining", isRaining);
                    result.put("isHeavy",   isHeavy);
                    result.put("source",    "live");
                    return ResponseEntity.ok(result);
                }
            }
        } catch (Exception ignored) { /* fall through to fast local simulation */ }

        // Fast local fallback — always returns immediately, no network call
        int hour = LocalDateTime.now().getHour();
        // Kandy climate: afternoon showers 14-17h, morning usually clear
        boolean afternoonRain = (hour >= 14 && hour <= 17);
        boolean morning = (hour >= 6 && hour <= 10);
        String icon, condition; int extraFee; boolean isRaining, isHeavy;
        if (afternoonRain && Math.random() < 0.55) {
            boolean heavy = Math.random() < 0.3;
            icon = heavy ? "⛈️" : "🌧️"; condition = heavy ? "Heavy rain" : "Light rain";
            extraFee = heavy ? 100 : 50; isRaining = true; isHeavy = heavy;
        } else if (morning) {
            icon = "☀️"; condition = "Clear sky"; extraFee = 0; isRaining = false; isHeavy = false;
        } else {
            icon = "⛅"; condition = "Partly cloudy"; extraFee = 0; isRaining = false; isHeavy = false;
        }
        int temp = 26 + (int)(Math.random() * 7);
        result.put("condition", icon + " " + condition);
        result.put("temp",      temp + "°C");
        result.put("extraFee",  extraFee);
        result.put("isRaining", isRaining);
        result.put("isHeavy",   isHeavy);
        result.put("source",    "local");
        result.put("updatedAt", LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm")));
        result.put("source",    "Estimated");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/scheduled-orders")
    public ResponseEntity<?> myScheduledOrders(HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        List<Map<String,Object>> result = fsu.readAll(fsu.getScheduledOrdersFile()).stream()
            .filter(l -> l.contains(u.getId()))
            .map(l -> {
                String[] p = l.split("\\|",-1);
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id",          p.length>0?p[0]:"");
                m.put("customerId",  p.length>1?p[1]:"");
                m.put("scheduledAt", p.length>2?p[2]:"");
                m.put("status",      p.length>3?p[3]:"PENDING");
                m.put("depositPaid", p.length>4?p[4]:"0");
                m.put("total",       p.length>5?p[5]:"0");
                m.put("notes",       p.length>6?p[6]:"");
                m.put("items",       p.length>7?p[7]:"");
                m.put("createdAt",   p.length>8?p[8]:"");
                return m;
            })
            .sorted(Comparator.comparing((Map<String,Object> m) -> m.getOrDefault("scheduledAt","").toString()))
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/scheduled-orders/{id}/cancel")
    public ResponseEntity<?> cancelScheduled(@PathVariable String id, HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getScheduledOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        String[] p = line.split("\\|",-1);
        if (p.length < 2 || !u.getId().equals(p[1])) return ResponseEntity.status(403).build();
        // Check cancellation window: must be >24h before scheduled time
        try {
            String schedAt = p.length>2?p[2]:"";
            if (!schedAt.isBlank()) {
                var scheduled = java.time.LocalDateTime.parse(schedAt, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
                var deadline  = scheduled.minusHours(24);
                if (LocalDateTime.now().isAfter(deadline))
                    return ResponseEntity.badRequest().body(Map.of("error","Cancellation window has passed. You must cancel at least 24 hours before the scheduled time."));
            }
        } catch(Exception e) { /* allow cancel if parse fails */ }
        // Mark as CANCELLED
        p[3] = "CANCELLED";
        fsu.update(fsu.getScheduledOrdersFile(), id, String.join("|", p));
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/group/room/{code}/details")
    public ResponseEntity<?> groupRoomDetails(@PathVariable String code, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getGroupRoomsFile(), code);
        if (line == null) return ResponseEntity.status(404).body(Map.of("error","Room not found"));
        String[] p = line.split("\\|",-1);
        Map<String,Object> r = new LinkedHashMap<>();
        r.put("code",        code);
        r.put("creatorId",   p.length>1?p[1]:"");
        r.put("creatorName", p.length>2?p[2]:"");
        r.put("status",      p.length>3?p[3]:"OPEN");
        r.put("createdAt",   p.length>4?p[4]:"");
        r.put("memberCount", p.length>5?Integer.parseInt(p[5].isBlank()?"1":p[5]):1);
        r.put("members",     p.length>6?p[6]:"");
        return ResponseEntity.ok(r);
    }

    @PostMapping("/group/room/{code}/join")
    public ResponseEntity<?> joinGroupRoom(@PathVariable String code, HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getGroupRoomsFile(), code);
        if (line == null) return ResponseEntity.status(404).body(Map.of("error","Room not found"));
        String[] p = line.split("\\|",-1);
        if (!"OPEN".equals(p.length>3?p[3]:"OPEN"))
            return ResponseEntity.badRequest().body(Map.of("error","Room is closed"));
        // Update member count and list
        int cnt = (p.length>5 && !p[5].isBlank()) ? Integer.parseInt(p[5]) + 1 : 2;
        String members = (p.length>6 ? p[6] : "") + (p.length>6&&!p[6].isBlank()?",":"") + u.getName();
        String[] newP = java.util.Arrays.copyOf(p, Math.max(7, p.length));
        newP[5] = String.valueOf(cnt);
        newP[6] = members;
        fsu.update(fsu.getGroupRoomsFile(), code, String.join("|", newP));
        return ResponseEntity.ok(Map.of("success",true,"memberCount",cnt,"members",members));
    }

    // ── New orders count for admin polling ──────────────────────────
    @GetMapping("/orders/new-count")
    public ResponseEntity<?> newOrdersCount(HttpSession s) {
        if (s.getAttribute("admin") == null && s.getAttribute("driver") == null)
            return ResponseEntity.status(401).build();
        long count = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(o -> o != null && Order.COOKING.equals(o.getStatus()))
            .count();
        return ResponseEntity.ok(Map.of("count", count));
    }

    @PostMapping("/group/create")
    public ResponseEntity<?> createRoom(HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user"); if (u == null) return ResponseEntity.status(401).build();
        String code = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        fsu.appendLine(fsu.getGroupRoomsFile(),
            code + "|" + u.getId() + "|" + u.getName() + "|OPEN|" + LocalDateTime.now().format(DTF));
        return ResponseEntity.ok(Map.of("code", code));
    }

    @GetMapping("/group/join/{code}")
    public ResponseEntity<?> joinRoom(@PathVariable String code, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getGroupRoomsFile(), code);
        if (line == null) return ResponseEntity.status(404).body(Map.of("error", "Room not found"));
        String[] p = line.split("\\|", -1);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("code", code); r.put("creatorName", p.length > 2 ? p[2] : "Host");
        r.put("status", p.length > 3 ? p[3] : "OPEN");
        return ResponseEntity.ok(r);
    }

    // ── Driver location update (from browser GPS) ─────────────────
    @PostMapping("/driver/location")
    public ResponseEntity<?> updateDriverLocation(@RequestBody Map<String, Object> body,
                                                  HttpSession s) throws IOException {
        if (s.getAttribute("driver") == null) return ResponseEntity.status(401).build();
        User driver = (User) s.getAttribute("driver");
        double lat = ((Number) body.getOrDefault("lat", 0)).doubleValue();
        double lng = ((Number) body.getOrDefault("lng", 0)).doubleValue();
        // Store driver location as a simple file entry (keyed by driver ID)
        String locationLine = driver.getId() + "|" + lat + "|" + lng + "|" + LocalDateTime.now().format(DTF);
        // Update or append
        if (!fsu.update("data/driver_locations.txt", driver.getId(), locationLine)) {
            fsu.appendLine("data/driver_locations.txt", locationLine);
        }
        return ResponseEntity.ok(Map.of("success", true));
    }

    // ── Get driver location (for customer tracking) ───────────────
    @GetMapping("/driver/location/{orderId}")
    public ResponseEntity<?> getDriverLocation(@PathVariable String orderId, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        // Try to find real driver location; fall back to restaurant as default
        String order = fsu.findById(fsu.getOrdersFile(), orderId);
        if (order != null) {
            Order o = Order.fromLine(order);
            if (o.getDriverId() != null && !o.getDriverId().isBlank()) {
                String loc = fsu.findById("data/driver_locations.txt", o.getDriverId());
                if (loc != null) {
                    String[] p = loc.split("\\|", -1);
                    if (p.length >= 3) {
                        try {
                            double lat = Double.parseDouble(p[1]);
                            double lng = Double.parseDouble(p[2]);
                            return ResponseEntity.ok(Map.of("lat", lat, "lng", lng, "available", true));
                        } catch (Exception ignored) {}
                    }
                }
            }
        }
        // Simulate driver moving around Kandy
        double baseLat = 7.2906 + (Math.random() - 0.5) * 0.015;
        double baseLng = 80.6337 + (Math.random() - 0.5) * 0.015;
        return ResponseEntity.ok(Map.of("lat", baseLat, "lng", baseLng, "available", true));
    }

    // ── My orders (for account page quick view) ───────────────────
    @GetMapping("/my-orders")
    public ResponseEntity<?> myOrders(@RequestParam(defaultValue = "5") int limit, HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        List<Map<String, Object>> result = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> u.getId().equals(o.getCustomerId()))
            .sorted(Comparator.comparing(
                (Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : "",
                Comparator.reverseOrder()))
            .limit(limit)
            .map(o -> {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("orderId",     o.getOrderId());
                m.put("status",      o.getStatus());
                m.put("statusBadge", o.getStatusBadge());
                m.put("totalAmount", o.getTotalAmount());
                m.put("createdAt",   o.getCreatedAt());
                m.put("items",       o.getItems().stream().map(i -> {
                    Map<String,Object> im = new LinkedHashMap<>();
                    im.put("foodId",   i.getFoodId());
                    im.put("foodName", i.getFoodName());
                    im.put("price",    i.getPrice());
                    im.put("quantity", i.getQuantity());
                    im.put("imageUrl", i.getImageUrl() != null ? i.getImageUrl() : "");
                    return im;
                }).collect(Collectors.toList()));
                return m;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    // ── Poll for new orders (admin/driver use for auto-refresh) ─────
    @GetMapping("/orders/poll")
    public ResponseEntity<?> pollOrders(@RequestParam(defaultValue = "0") long since, HttpSession s) {
        boolean isAdmin  = s.getAttribute("admin")  instanceof User;
        boolean isDriver = s.getAttribute("driver") instanceof User;
        boolean isUser   = s.getAttribute("user")   instanceof User;
        if (!isAdmin && !isDriver && !isUser) return ResponseEntity.status(401).build();

        List<Map<String,Object>> orders = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> {
                if (isUser) {
                    User u = (User) s.getAttribute("user");
                    return u.getId().equals(o.getCustomerId());
                }
                if (isDriver) return Order.READY.equals(o.getStatus()) || Order.HANDOVER.equals(o.getStatus()) || Order.ONWAY.equals(o.getStatus());
                return true; // admin sees all
            })
            .sorted(Comparator.comparing((Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : "", Comparator.reverseOrder()))
            .limit(50)
            .map(o -> {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("orderId",     o.getOrderId());
                m.put("status",      o.getStatus());
                m.put("statusBadge", o.getStatusBadge());
                m.put("progress",    o.getStatusProgress());
                m.put("customerName",o.getCustomerName());
                m.put("totalAmount", o.getTotalAmount());
                m.put("createdAt",   o.getCreatedAt());
                m.put("driverName",  o.getDriverName()    != null ? o.getDriverName()    : "");
                m.put("driverContact",o.getDriverContact() != null ? o.getDriverContact() : "");
                return m;
            }).collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("orders", orders, "timestamp", System.currentTimeMillis()));
    }

    // ── Cancel order within 2 minutes of placing ────────────────
    @PostMapping("/order/{id}/cancel")
    public ResponseEntity<?> cancelOrder(@PathVariable String id, HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        if (!u.getId().equals(o.getCustomerId())) return ResponseEntity.status(403).build();
        if (Order.DELIVERED.equals(o.getStatus()) || Order.CANCELLED.equals(o.getStatus()))
            return ResponseEntity.badRequest().body(Map.of("error", "Order cannot be cancelled."));
        if (Order.ONWAY.equals(o.getStatus()) || Order.HANDOVER.equals(o.getStatus()))
            return ResponseEntity.badRequest().body(Map.of("error", "Driver has already picked up your order."));
        // Check 2-minute window
        try {
            var placed = java.time.LocalDateTime.parse(o.getCreatedAt(), java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            if (java.time.LocalDateTime.now().isAfter(placed.plusMinutes(2)))
                return ResponseEntity.badRequest().body(Map.of("error", "Cancellation window (2 min) has passed."));
        } catch (Exception ignored) {}
        o.setStatus(Order.CANCELLED);
        o.setUpdatedAt(java.time.LocalDateTime.now().format(DTF));
        fsu.update(fsu.getOrdersFile(), id, o.toFileLine());
        return ResponseEntity.ok(Map.of("success", true));
    }

    // ── Loyalty points ────────────────────────────────────────────
    @GetMapping("/loyalty")
    public ResponseEntity<?> loyalty(HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        int points = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> u.getId().equals(o.getCustomerId()) && Order.DELIVERED.equals(o.getStatus()))
            .mapToInt(o -> (int)(o.getTotalAmount() / 10))
            .sum();
        return ResponseEntity.ok(Map.of("points", points, "discount", points >= 100 ? (points / 100) * 50 : 0, "nextReward", Math.max(0, 100 - (points % 100))));
    }

    // ── Real driver location + nearby check ──────────────────────
    @GetMapping("/order/{id}/driver-location")
    public ResponseEntity<?> orderDriverLocation(@PathVariable String id, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        String status = o.getStatus() != null ? o.getStatus() : "";
        double lat = 7.2906, lng = 80.6337; // restaurant default
        boolean realLocation = false;
        // Read actual driver GPS location from file
        if (o.getDriverId() != null && !o.getDriverId().isBlank()) {
            String locLine = fsu.findById(fsu.getDriverLocationsFile(), o.getDriverId());
            if (locLine != null) {
                String[] p = locLine.split("\\|", -1);
                if (p.length >= 3) {
                    try { lat = Double.parseDouble(p[1]); lng = Double.parseDouble(p[2]); realLocation = true; }
                    catch (Exception ignored) {}
                }
            }
        }
        // Check if driver is within 1km of delivery address (simplified: check status)
        boolean nearby = Order.ONWAY.equals(status) && realLocation;
        return ResponseEntity.ok(Map.of(
            "lat", lat, "lng", lng,
            "nearby", nearby,
            "status", status,
            "realLocation", realLocation
        ));
    }

    // ── Admin stats snapshot ──────────────────────────────────────
    @GetMapping("/admin/stats")
    public ResponseEntity<?> adminStats(HttpSession s) {
        if (!(s.getAttribute("admin") instanceof User)) return ResponseEntity.status(401).build();
        List<Order> orders = fsu.readAll(fsu.getOrdersFile()).stream().map(Order::fromLine).filter(Objects::nonNull).collect(Collectors.toList());
        long active    = orders.stream().filter(o -> !Order.DELIVERED.equals(o.getStatus()) && !Order.CANCELLED.equals(o.getStatus())).count();
        long today     = orders.stream().filter(o -> o.getCreatedAt() != null && o.getCreatedAt().startsWith(java.time.LocalDate.now().toString())).count();
        double revenue = orders.stream().filter(o -> Order.DELIVERED.equals(o.getStatus())).mapToDouble(Order::getTotalAmount).sum();
        return ResponseEntity.ok(Map.of("activeOrders", active, "todayOrders", today, "totalRevenue", revenue, "timestamp", System.currentTimeMillis()));
    }

        private Order buildOrder(Map<String, Object> body, User u) throws IOException {
        Order o = new Order();
        o.setOrderId("ORD" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase());
        o.setCustomerId(u.getId()); o.setCustomerName(u.getName());
        o.setCreatedAt(LocalDateTime.now().format(DTF)); o.setUpdatedAt(o.getCreatedAt());
        o.setStatus(Order.COOKING); // starts at COOKING — admin manually advances
        o.setDeliveryAddress(gs(body, "deliveryAddress", gs(body, "address", u.getAddress() != null ? u.getAddress() : "")));
        o.setChefNote(gs(body, "chefNote", ""));
        o.setDriverNote(gs(body, "driverNote", ""));
        o.setPaymentMethod(gs(body, "paymentMethod", "COD"));
        o.setOfferCode(gs(body, "offerCode", ""));
        o.setOrderType(gs(body, "orderType", "STANDARD"));
        o.setScheduledFor(gs(body, "scheduledFor", ""));
        o.setDriverName(DRIVER_NAME); o.setDriverContact(DRIVER_CONTACT);

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> rawItems = (List<Map<String, Object>>) body.get("items");
        if (rawItems != null) {
            for (Map<String, Object> i : rawItems) {
                o.getItems().add(new Order.CartItem(
                    gs(i, "foodId"), gs(i, "foodName"),
                    ((Number) i.getOrDefault("price", 0)).doubleValue(),
                    ((Number) i.getOrDefault("quantity", 1)).intValue(),
                    gs(i, "imageUrl")));
            }
        }
        double sub = o.getItems().stream().mapToDouble(Order.CartItem::getLineTotal).sum();
        o.setSubtotal(sub);
        String code = o.getOfferCode(); double disc = 0;
        if (!code.isBlank()) {
            Map<String, Object> v = offerService.validateCode(code, sub);
            if (Boolean.TRUE.equals(v.get("valid")))
                disc = ((Number) v.getOrDefault("discount", 0)).doubleValue();
        }
        o.setDiscount(disc);
        double tip        = ((Number) body.getOrDefault("tip", 0)).doubleValue();
        double weatherFee = ((Number) body.getOrDefault("weatherFee", 0)).doubleValue();
        o.setTip(tip);
        o.setWeatherFee(weatherFee);
        double total = sub + 250 + tip + weatherFee - disc;
        o.setTotalAmount(total);
        o.setLoyaltyPoints((int)(sub / 10)); // 1 point per LKR 10
        o.setEstimatedEta("25-35 min");
        return o;
    }

    private String gs(Map<String, Object> m, String k)            { return gs(m, k, ""); }
    private String gs(Map<String, Object> m, String k, String def) {
        Object v = m.get(k); return v instanceof String str ? str : def;
    }
}
