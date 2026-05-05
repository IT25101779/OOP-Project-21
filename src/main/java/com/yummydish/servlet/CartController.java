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

// REST API endpoints for Cart & Orders
@RestController @RequestMapping("/api")
class ApiCartController {
    @PostMapping("/order")
    public ResponseEntity<?> placeOrder(@RequestBody Map<String, Object> body, HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).body(Map.of("error", "Not logged in"));
        try {
            Order o = buildOrder(body, u);
            fsu.appendLine(fsu.getOrdersFile(), o.toFileLine());
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

}
