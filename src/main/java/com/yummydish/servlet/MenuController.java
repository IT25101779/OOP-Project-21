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
