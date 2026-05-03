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

    @GetMapping("/group")    public String group(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); m.addAttribute("foods", foodService.getAvailable());
        return "group/index";
    }
    @GetMapping("/schedule") public String schedule(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); m.addAttribute("foods", foodService.getAvailable());
        return "schedule/index";
    }
}


@RestController @RequestMapping("/api")
class ApiAdvancedOrderController {
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
}
