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

// REST API endpoints for Food & Menu
@RestController @RequestMapping("/api")
class ApiMenuController {
    @GetMapping("/foods")
    public ResponseEntity<?> foods(
            @RequestParam(defaultValue = "All") String category,
            @RequestParam(defaultValue = "") String search) {
        List<FoodItem> items;
        if (!search.isBlank()) {
            items = foodService.search(search);
        } else {
            items = "All".equals(category) ? foodService.getAll() : foodService.getByCategory(category);
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

    @PostMapping("/validate-offer")
    public ResponseEntity<?> validateOffer(@RequestBody Map<String, Object> body, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        String code  = body.getOrDefault("code",    "").toString();
        double sub   = ((Number) body.getOrDefault("subtotal", 0)).doubleValue();
        return ResponseEntity.ok(offerService.validateCode(code, sub));
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


}
