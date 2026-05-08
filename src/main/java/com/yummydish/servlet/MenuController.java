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
class GlobalAdvice {
    @Value("${google.maps.api.key:}")    private String mapsKey;
    @Value("${firebase.api.key:}")       private String fbKey;
    @Value("${firebase.auth.domain:}")   private String fbDomain;
    @Value("${firebase.project.id:}")    private String fbProject;
    @Value("${google.oauth.client.id:}") private String googleClientId;
    @Value("${google.oauth.client.id:}") private String googleOAuthClientId;

    private final OfferService offerService;
    @Autowired GlobalAdvice(OfferService offerService) { this.offerService = offerService; }

    @ModelAttribute("googleMapsApiKey")      public String mapsKey()          { return mapsKey; }
    @ModelAttribute("googleOAuthClientId")   public String googleOAuthClientId() { return googleOAuthClientId; }
    @ModelAttribute("firebaseApiKey")     public String fbKey()     { return fbKey; }
    @ModelAttribute("firebaseAuthDomain") public String fbDomain()  { return fbDomain; }
    @ModelAttribute("firebaseProjectId")  public String fbProject() { return fbProject; }
    @ModelAttribute("activeOffers")       public List<Offer> offers(){ return offerService.getActive(); }
}

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
