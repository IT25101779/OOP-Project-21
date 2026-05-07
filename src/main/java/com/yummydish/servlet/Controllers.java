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
@RequestMapping("/driver")
class DriverController {
    private final UserService userService;
    private final FileStorageUtil fsu;

    @Autowired
    DriverController(UserService us, FileStorageUtil fsu) {
        this.userService = us; this.fsu = fsu;
    }

    private boolean isDriver(HttpSession s) {
        Object o = s.getAttribute("driver");
        return o instanceof User u && "DRIVER".equals(u.getRole());
    }

    @GetMapping("/login")
    public String driverLoginPage(HttpSession s) {
        return isDriver(s) ? "redirect:/driver/dashboard" : "driver/login";
    }

    @PostMapping("/login")
    public String doDriverLogin(@RequestParam String email,
                                @RequestParam String password,
                                HttpSession s, Model m) {
        User u = userService.authenticate(email, password);
        if (u == null || !"DRIVER".equals(u.getRole())) {
            m.addAttribute("error", "Invalid driver credentials.");
            return "driver/login";
        }
        s.setAttribute("driver", u);
        return "redirect:/driver/dashboard";
    }

    @GetMapping("/logout")
    public String driverLogout(HttpSession s) {
        s.removeAttribute("driver");
        return "redirect:/driver/login";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession s, Model m) {
        if (!isDriver(s)) return "redirect:/driver/login";

        // READY = admin approved pickup. HANDOVER + ON_WAY = already with driver.
        List<Order> queue = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> Order.READY.equals(o.getStatus())
                      || Order.HANDOVER.equals(o.getStatus())
                      || Order.ONWAY.equals(o.getStatus()))
            .sorted(Comparator.comparing(
                (Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : ""))
            .collect(Collectors.toList());

        m.addAttribute("driver",  s.getAttribute("driver"));
        m.addAttribute("restaurant_lat", 7.2937);  // Queens Hotel area, Kandy
        m.addAttribute("restaurant_lng", 80.6340);
        m.addAttribute("orders",  queue);
        return "driver/dashboard";
    }

    // Driver marks order as picked up (READY → HANDOVER)
    @PostMapping("/pickup/{orderId}")
    public String markPickedUp(@PathVariable String orderId, HttpSession s) throws IOException {
        if (!isDriver(s)) return "redirect:/driver/login";
        String line = fsu.findById(fsu.getOrdersFile(), orderId);
        if (line != null) {
            Order o = Order.fromLine(line);
            if (Order.READY.equals(o.getStatus())) {
                updateOrderStatus(orderId, Order.HANDOVER);
            }
        }
        return "redirect:/driver/dashboard";
    }

    // Driver marks order as out for delivery (HANDOVER → ON_WAY)
    @PostMapping("/delivering/{orderId}")
    public String markDelivering(@PathVariable String orderId, HttpSession s) throws IOException {
        if (!isDriver(s)) return "redirect:/driver/login";
        updateOrderStatus(orderId, Order.ONWAY);
        return "redirect:/driver/dashboard";
    }

    // Driver marks order as delivered (ON_WAY → DELIVERED)
    @PostMapping("/delivered/{orderId}")
    public String markDelivered(@PathVariable String orderId, HttpSession s) throws IOException {
        if (!isDriver(s)) return "redirect:/driver/login";
        updateOrderStatus(orderId, Order.DELIVERED);
        return "redirect:/driver/dashboard";
    }

    private void updateOrderStatus(String orderId, String status) throws IOException {
        String line = fsu.findById(fsu.getOrdersFile(), orderId);
        if (line != null) {
            Order o = Order.fromLine(line);
            o.setStatus(status);
            o.setUpdatedAt(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
            fsu.update(fsu.getOrdersFile(), orderId, o.toFileLine());
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// MENU
// ═══════════════════════════════════════════════════════════════════
@Controller @RequestMapping("/activity")
class ActivityController {
    private final FileStorageUtil fsu;
    @Autowired ActivityController(FileStorageUtil f) { this.fsu = f; }

    @GetMapping public String activity(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        User u = (User) s.getAttribute("user");
        List<Order> all = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> u.getId().equals(o.getCustomerId()))
            .sorted(Comparator.comparing(
                (Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : "",
                Comparator.reverseOrder()))
            .collect(Collectors.toList());
        List<Order> ongoing = all.stream()
            .filter(o -> !Order.DELIVERED.equals(o.getStatus()) && !Order.CANCELLED.equals(o.getStatus()))
            .collect(Collectors.toList());
        List<Order> history = all.stream()
            .filter(o -> Order.DELIVERED.equals(o.getStatus()) || Order.CANCELLED.equals(o.getStatus()))
            .collect(Collectors.toList());
        m.addAttribute("user",    u);
        m.addAttribute("orders",  all);
        m.addAttribute("ongoing", ongoing);
        m.addAttribute("history", history);
        return "activity/index";
    }

    @GetMapping("/order/{id}") public String detail(@PathVariable String id, HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        String l = fsu.findById(fsu.getOrdersFile(), id); if (l == null) return "redirect:/activity";
        m.addAttribute("order", Order.fromLine(l)); m.addAttribute("user", s.getAttribute("user"));
        return "activity/order-detail";
    }
}

// ═══════════════════════════════════════════════════════════════════
// EXTRA PAGES — about, contact, reviews, group, schedule
// ═══════════════════════════════════════════════════════════════════
@RestController @RequestMapping("/api") class ApiDriverController {
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
}
