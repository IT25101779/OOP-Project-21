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
class FeedbackController {
    private final FoodItemService foodService;
    private final FileStorageUtil fsu;

    @Autowired FeedbackController(FoodItemService fs, FileStorageUtil fsu) {
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

@org.springframework.stereotype.Controller
@org.springframework.web.bind.annotation.RequestMapping("/error")
class YummyDishErrorController implements org.springframework.boot.web.servlet.error.ErrorController {
    @org.springframework.web.bind.annotation.GetMapping
    public String handleError(jakarta.servlet.http.HttpServletRequest req, org.springframework.ui.Model m) {
        Object code = req.getAttribute(org.springframework.web.util.WebUtils.ERROR_STATUS_CODE_ATTRIBUTE);
        Object msg  = req.getAttribute(org.springframework.web.util.WebUtils.ERROR_MESSAGE_ATTRIBUTE);
        Object ex   = req.getAttribute(org.springframework.web.util.WebUtils.ERROR_EXCEPTION_ATTRIBUTE);
        if (ex instanceof Throwable t) {
            System.err.println("[YummyDish ERROR] " + t.getClass().getName() + ": " + t.getMessage());
            t.printStackTrace();
        }
        String displayMsg = (msg != null && !msg.toString().isBlank()) ? msg.toString() : "An unexpected error occurred";
        m.addAttribute("errorCode",    code != null ? code.toString() : "500");
        m.addAttribute("errorMessage", displayMsg);
        return "error";
    }
}
