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

// Reviews, Contact, About page routes
@Controller
class FeedbackPageController {
@Controller
class ExtraController {
    private final FoodItemService foodService;
    private final FileStorageUtil fsu;

    @Autowired ExtraController(FoodItemService fs, FileStorageUtil fsu) {
        this.foodService = fs; this.fsu = fsu;
    }

    @GetMapping("/about")   public String about(HttpSession s, Model m)  { m.addAttribute("user", s.getAttribute("user")); return "about/index"; }
    @GetMapping("/reviews") public String reviews(HttpSession s, Model m) {
        List<Feedback> reviews = fsu.readAll(fsu.getFeedbackFile()).stream()
            .map(Feedback::fromFileLine).filter(f -> f != null && f.isPublicFeedback())
            .sorted(Comparator.comparing((Feedback f) -> f.getCreatedAt() != null ? f.getCreatedAt() : "", Comparator.reverseOrder()))
            .collect(Collectors.toList());
        m.addAttribute("reviews", reviews); m.addAttribute("user", s.getAttribute("user"));
        return "reviews/index";
    }

    @GetMapping("/contact")  public String contact(HttpSession s, Model m)  { m.addAttribute("user", s.getAttribute("user")); return "contact/index"; }
    @PostMapping("/contact")
    public String submitContact(@RequestParam String contactName,
                                @RequestParam String contactEmail,
                                @RequestParam String message, Model m) throws IOException {
        String id = "CON" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        fsu.appendLine(fsu.getContactsFile(),
            id + "|" + contactName + "|" + contactEmail + "|" +
            message.replace("|", "") + "|" +
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
        m.addAttribute("success", "Thank you! We'll get back to you soon.");
        return "contact/index";
    }

}

// REST API endpoints for Feedback & Reporting
@RestController @RequestMapping("/api")
class ApiFeedbackController {
    @PostMapping("/feedback")
    public ResponseEntity<?> feedback(@RequestBody Map<String, Object> body, HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        String fbId = "FB" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        String line = String.join("|",
            fbId, gs(body, "orderId"), u.getId(), u.getName(),
            gs(body, "text").replace("|", ""),
            gs(body, "foodItemId"), gs(body, "foodItemName"),
            "", LocalDateTime.now().format(DTF),
            gs(body, "type", "REVIEW"),
            String.valueOf(body.getOrDefault("rating", "5")));
        fsu.appendLine(fsu.getFeedbackFile(), line);
        return ResponseEntity.ok(Map.of("success", true));
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

}
