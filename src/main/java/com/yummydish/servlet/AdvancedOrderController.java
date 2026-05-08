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
class AdvancedOrderController {
    private final FoodItemService foodService;
    private final FileStorageUtil fsu;

    @Autowired AdvancedOrderController(FoodItemService fs, FileStorageUtil fsu) {
        this.foodService = fs; this.fsu = fsu;
    }

    @GetMapping("/group")    public String group(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); m.addAttribute("foods", foodService.getAvailable());
        return "group/index";
    }
    @GetMapping("/schedule") public String schedule(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        User u = (User) s.getAttribute("user");
        List<Order> scheduledOrders = new java.util.ArrayList<>();
        try {
            scheduledOrders = fsu.readAll(fsu.getOrdersFile()).stream()
                .map(line -> { try { return Order.fromLine(line); } catch(Exception e) { return null; } })
                .filter(Objects::nonNull)
                .filter(o -> u.getId().equals(o.getCustomerId()) && "SCHEDULED".equals(o.getOrderType()))
                .sorted(Comparator.comparing(o -> o.getCreatedAt() != null ? o.getCreatedAt() : "", Comparator.reverseOrder()))
                .collect(Collectors.toList());
        } catch (Exception e) {
            System.err.println("[Schedule] Error loading scheduled orders: " + e.getMessage());
        }
        m.addAttribute("user",            u);
        m.addAttribute("foods",           foodService.getAvailable());
        m.addAttribute("scheduledOrders", scheduledOrders);
        return "schedule/index";
    }
}
