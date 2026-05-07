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

// ═══════════════════════════════════════════════════════════════════
// ACCOUNT — customer profile (no driver section)
// ═══════════════════════════════════════════════════════════════════
@RestController @RequestMapping("/api") class ApiCartController {
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
}
