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
class MenuController {
    private final FoodItemService foodService;
    @Autowired MenuController(FoodItemService fs) { this.foodService = fs; }

    @GetMapping("/menu")
    public String menu(@RequestParam(defaultValue = "All")     String category,
                       @RequestParam(defaultValue = "")        String search,
                       @RequestParam(defaultValue = "default") String sort,
                       HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        List<FoodItem> foods;
        if (!search.isBlank())           foods = foodService.search(search);
        else if (!"All".equals(category)) foods = foodService.getByCategory(category);
        else if ("asc".equals(sort))     foods = foodService.sorted(true);
        else if ("desc".equals(sort))    foods = foodService.sorted(false);
        else                             foods = foodService.getAvailable();
        m.addAttribute("foods", foods); m.addAttribute("category", category);
        m.addAttribute("search", search); m.addAttribute("sort", sort);
        m.addAttribute("user", s.getAttribute("user"));
        return "menu/index";
    }

    @GetMapping("/menu/item/{id}")
    public String detail(@PathVariable String id, HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        FoodItem f = foodService.getById(id); if (f == null) return "redirect:/menu";
        m.addAttribute("food", f); m.addAttribute("user", s.getAttribute("user"));
        return "menu/food-detail";
    }
}

// ═══════════════════════════════════════════════════════════════════
// CHECKOUT
// ═══════════════════════════════════════════════════════════════════
@RestController @RequestMapping("/api") class ApiMenuController {
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


// ── Custom Error Controller — replaces Spring white-label page ────
@org.springframework.stereotype.Controller
}
