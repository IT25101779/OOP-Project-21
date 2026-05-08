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

@Controller
@RequestMapping("/activity")
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
