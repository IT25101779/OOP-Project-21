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

// ═══════════════════════════════════════════════════════════════════
// MENU
// ═══════════════════════════════════════════════════════════════════
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

    @PostMapping("/order")
    public ResponseEntity<?> placeOrder(@RequestBody Map<String, Object> body, HttpSession s) {
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

}
