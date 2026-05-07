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
@Controller class AdvancedOrderPageController {
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

// ═══════════════════════════════════════════════════════════════════
// REST API
// ═══════════════════════════════════════════════════════════════════
}
@RestController @RequestMapping("/api") class ApiAdvancedOrderController {
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
}
