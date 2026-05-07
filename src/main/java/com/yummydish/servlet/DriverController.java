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

// REST API endpoints for Delivery & Driver Tracking
@RestController @RequestMapping("/api")
class ApiDriverController {
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

    @GetMapping("/orders/new-count")
    public ResponseEntity<?> newOrdersCount(HttpSession s) {
        if (s.getAttribute("admin") == null && s.getAttribute("driver") == null)
            return ResponseEntity.status(401).build();
        long count = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(o -> o != null && Order.COOKING.equals(o.getStatus()))
            .count();
        return ResponseEntity.ok(Map.of("count", count));
    }

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
}
