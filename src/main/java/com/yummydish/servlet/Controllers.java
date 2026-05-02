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

// ═══════════════════════════════════════════════════════════════════
// CUSTOMER AUTH — /login, /signup, /logout, /forgot-password
// ═══════════════════════════════════════════════════════════════════
@Controller
class AuthController {
    private final UserService userService;
    @Autowired AuthController(UserService us) { this.userService = us; }

    @GetMapping("/")
    public String home(HttpSession s, Model m) {
        // If logged in, show home landing; if not, show home landing (public page)
        m.addAttribute("user", s.getAttribute("user"));
        return "index";
    }

    @GetMapping("/login")
    public String loginPage(HttpSession s) {
        return s.getAttribute("user") != null ? "redirect:/menu" : "auth/login";
    }

    @PostMapping("/login")
    public String doLogin(@RequestParam String email,
                          @RequestParam String password,
                          @RequestParam(defaultValue = "false") boolean stayLoggedIn,
                          HttpSession s, Model m) {
        User u = userService.authenticate(email, password);
        if (u == null) {
            m.addAttribute("error", "Invalid email or password.");
            return "auth/login";
        }
        // Block admins and drivers from customer login page
        if ("ADMIN".equals(u.getRole()) || "DRIVER".equals(u.getRole())) {
            m.addAttribute("error", "Please use the Admin / Driver login page.");
            return "auth/login";
        }
        s.setAttribute("user", u);
        if (stayLoggedIn) s.setMaxInactiveInterval(2592000);
        return "redirect:/menu";
    }

    @GetMapping("/signup")
    public String signupPage(HttpSession s) {
        return s.getAttribute("user") != null ? "redirect:/menu" : "auth/signup";
    }

    @PostMapping("/signup")
    public String doSignup(@RequestParam String name,
                           @RequestParam String email,
                           @RequestParam String password,
                           @RequestParam(defaultValue = "") String phone,
                           @RequestParam(defaultValue = "") String address,
                           @RequestParam(required = false, defaultValue = "") String cardNumber,
                           @RequestParam(required = false, defaultValue = "") String cardHolder,
                           @RequestParam(required = false, defaultValue = "") String cardExpiry,
                           HttpSession s, Model m) {
        try {
            User u = userService.register(name, email, password, phone, address,
                                          cardNumber, cardHolder, cardExpiry);
            s.setAttribute("user", u);
            return "redirect:/menu";
        } catch (IllegalArgumentException e) {
            m.addAttribute("error", e.getMessage());
            return "auth/signup";
        } catch (IOException e) {
            m.addAttribute("error", "Registration failed. Please try again.");
            return "auth/signup";
        }
    }

    @PostMapping("/social-login")
    public String socialLogin(@RequestParam(defaultValue = "") String name,
                              @RequestParam(defaultValue = "") String email,
                              @RequestParam(defaultValue = "") String pic,
                              HttpSession s) throws IOException {
        if (email.isBlank()) return "redirect:/login";
        User existing = userService.findByEmail(email);
        if (existing != null) {
            if ("ADMIN".equals(existing.getRole()) || "DRIVER".equals(existing.getRole()))
                return "redirect:/login?error=staff";
            if (!pic.isBlank()) userService.updateProfilePic(existing.getId(), pic);
            s.setAttribute("user", userService.findById(existing.getId()));
            return "redirect:/menu";
        }
        String autoPass = "SOCIAL_" + UUID.randomUUID().toString().replace("-", "").substring(0, 10);
        User nu = userService.register(name.isBlank() ? email.split("@")[0] : name,
                                       email, autoPass, "", "Please update your address",
                                       "", "", "");
        if (!pic.isBlank()) userService.updateProfilePic(nu.getId(), pic);
        s.setAttribute("user", nu);
        return "redirect:/menu";
    }

    @GetMapping("/forgot-password") public String forgotPage() { return "auth/forgot"; }
    @PostMapping("/forgot-password")
    public String doForgot(@RequestParam String email, Model m) {
        User u = userService.findByEmail(email);
        if (u != null) m.addAttribute("success", "Reset link sent to " + email + " (Demo: password unchanged)");
        else           m.addAttribute("error",   "No account found with that email.");
        return "auth/forgot";
    }

    @GetMapping("/logout")
    public String logout(HttpSession s) { s.invalidate(); return "redirect:/login"; }
}

// ═══════════════════════════════════════════════════════════════════
// ADMIN AUTH — /admin/login (separate page, separate session key)
// ═══════════════════════════════════════════════════════════════════
@Controller
@RequestMapping("/admin")
class AdminAuthController {
    private final UserService userService;
    private final FoodItemService foodService;
    private final FileStorageUtil fsu;
    private final OfferService offerService;

    @Autowired
    AdminAuthController(UserService us, FoodItemService fs,
                        FileStorageUtil fsu, OfferService os) {
        this.userService = us; this.foodService = fs;
        this.fsu = fsu;       this.offerService = os;
    }

    private boolean isAdmin(HttpSession s) {
        Object o = s.getAttribute("admin");
        return o instanceof User u && "ADMIN".equals(u.getRole());
    }

    @GetMapping("/login")
    public String adminLoginPage(HttpSession s) {
        return isAdmin(s) ? "redirect:/admin/dashboard" : "admin/login";
    }

    @PostMapping("/login")
    public String doAdminLogin(@RequestParam String email,
                               @RequestParam String password,
                               HttpSession s, Model m) {
        User u = userService.authenticate(email, password);
        if (u == null || !"ADMIN".equals(u.getRole())) {
            m.addAttribute("error", "Invalid admin credentials.");
            return "admin/login";
        }
        s.setAttribute("admin", u);
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/logout")
    public String adminLogout(HttpSession s) {
        s.removeAttribute("admin");
        return "redirect:/admin/login";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession s, Model m) {
        if (!isAdmin(s)) return "redirect:/admin/login";

        List<Order> orders = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .sorted(Comparator.comparing(
                (Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : "",
                Comparator.reverseOrder()))
            .collect(Collectors.toList());

        long revenue = orders.stream().mapToLong(o -> (long) o.getTotalAmount()).sum();

        List<Feedback> feedbacks = fsu.readAll(fsu.getFeedbackFile()).stream()
            .map(Feedback::fromFileLine).filter(Objects::nonNull).collect(Collectors.toList());

        String today = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        m.addAttribute("admin",          s.getAttribute("admin"));
        m.addAttribute("user",           s.getAttribute("admin"));
        m.addAttribute("foods",          foodService.getAll());
        m.addAttribute("customers",      userService.getAllCustomers());
        m.addAttribute("drivers",        userService.getAllDrivers());
        m.addAttribute("orders",         orders);
        m.addAttribute("feedback",       feedbacks);
        m.addAttribute("offers",         offerService.getAll());
        m.addAttribute("revenue",        revenue);
        m.addAttribute("contacts",       fsu.readAll(fsu.getContactsFile()));
        m.addAttribute("cookingOrders",  orders.stream().filter(o -> Order.COOKING.equals(o.getStatus())).collect(Collectors.toList()));
        m.addAttribute("readyOrders",    orders.stream().filter(o -> Order.READY.equals(o.getStatus())).collect(Collectors.toList()));
        m.addAttribute("onwayOrders",    orders.stream().filter(o -> Order.ONWAY.equals(o.getStatus()) || Order.HANDOVER.equals(o.getStatus())).collect(Collectors.toList()));
        m.addAttribute("deliveredToday", orders.stream().filter(o -> Order.DELIVERED.equals(o.getStatus()) && o.getCreatedAt() != null && o.getCreatedAt().startsWith(today)).collect(Collectors.toList()));
        return "admin/dashboard";
    }

    // ── Food management ───────────────────────────────────────────
    @PostMapping("/food/add")
    public String addFood(@RequestParam String name, @RequestParam String description,
                          @RequestParam double price, @RequestParam String category,
                          @RequestParam(defaultValue = "") String ingredients,
                          @RequestParam(defaultValue = "—") String portionSize,
                          @RequestParam(defaultValue = "0") int calories,
                          @RequestParam(required = false, defaultValue = "") String imageUrl,
                          @RequestParam(defaultValue = "MainCourse") String foodType,
                          HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        foodService.add(name, description, price, category, ingredients,
                        portionSize, calories, imageUrl, foodType);
        return "redirect:/admin/dashboard?tab=food";
    }

    @PostMapping("/food/delete")
    public String deleteFood(@RequestParam String id, HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        foodService.delete(id);
        return "redirect:/admin/dashboard?tab=food";
    }

    @PostMapping("/food/toggle")
    public String toggleFood(@RequestParam String id, HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        foodService.toggleAvailability(id);
        return "redirect:/admin/dashboard?tab=food";
    }

    @GetMapping("/food/get/{id}")
    public ResponseEntity<?> getFoodJson(@PathVariable String id, HttpSession s) {
        if (!isAdmin(s)) return ResponseEntity.status(401).build();
        var f = foodService.getById(id);
        if (f == null) return ResponseEntity.notFound().build();
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("id", f.getId()); m.put("name", f.getName()); m.put("description", f.getDescription());
        m.put("price", f.getPrice()); m.put("category", f.getCategory());
        m.put("ingredients", f.getIngredients() != null ? f.getIngredients() : "");
        m.put("portionSize", f.getPortionSize() != null ? f.getPortionSize() : "");
        m.put("calories", f.getCalories()); m.put("imageUrl", f.getImageUrl() != null ? f.getImageUrl() : "");
        m.put("available", f.isAvailable()); m.put("popular", f.isPopular());
        m.put("foodType", f.getFoodType());
        return ResponseEntity.ok(m);
    }

    @PostMapping("/food/update")
    public String updateFood(@RequestParam String id,
                             @RequestParam String name, @RequestParam String description,
                             @RequestParam double price, @RequestParam String category,
                             @RequestParam(defaultValue="") String ingredients,
                             @RequestParam(defaultValue="—") String portionSize,
                             @RequestParam(defaultValue="0") int calories,
                             @RequestParam(defaultValue="") String imageUrl,
                             @RequestParam(defaultValue="MainCourse") String foodType,
                             @RequestParam(defaultValue="true") boolean available,
                             HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        foodService.update(id, name, description, price, category, ingredients, portionSize, calories, available, imageUrl);
        return "redirect:/admin/dashboard?tab=food";
    }

    @PostMapping("/user/update")
    public String adminUpdateUser(@RequestParam String id,
                                  @RequestParam(defaultValue="") String name,
                                  @RequestParam(defaultValue="") String phone,
                                  @RequestParam(defaultValue="") String address,
                                  @RequestParam(defaultValue="") String profilePicUrl,
                                  HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        var u = userService.findById(id);
        if (u != null) {
            if (!name.isBlank())         u.setName(name);
            if (!phone.isBlank())        u.setPhone(phone);
            if (!address.isBlank())      u.setAddress(address);
            if (!profilePicUrl.isBlank()) u.setProfilePicUrl(profilePicUrl);
            fsu.update(fsu.getUsersFile(), id, u.toFileLine());
        }
        // Return to correct tab based on role
        var user = userService.findById(id);
        String tab = (user != null && "DRIVER".equals(user.getRole())) ? "drivers" : "users";
        return "redirect:/admin/dashboard?tab=" + tab;
    }

    // ── Order status — MANUAL only, admin controls this ──────────
    @PostMapping("/order/status")
    public String updateOrderStatus(@RequestParam String orderId,
                                    @RequestParam String status,
                                    HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        String line = fsu.findById(fsu.getOrdersFile(), orderId);
        if (line != null) {
            Order o = Order.fromLine(line);
            o.setStatus(status);
            o.setUpdatedAt(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
            // Auto-assign least-loaded driver when moving to READY/HANDOVER
            if ((Order.READY.equals(status) || Order.HANDOVER.equals(status))
                    && (o.getDriverId() == null || o.getDriverId().isBlank())) {
                User assignedDriver = findLeastLoadedDriver();
                if (assignedDriver != null) {
                    o.setDriverId(assignedDriver.getId());
                    o.setDriverName(assignedDriver.getName());
                    o.setDriverContact(assignedDriver.getPhone() != null ? assignedDriver.getPhone() : "");
                }
            }
            fsu.update(fsu.getOrdersFile(), orderId, o.toFileLine());
        }
        return "redirect:/admin/dashboard?tab=orders";
    }

    /** Load-balance drivers: assign to the one with fewest active orders */
    private User findLeastLoadedDriver() {
        List<User> drivers = userService.getAllDrivers();
        if (drivers.isEmpty()) return null;
        Map<String, Long> load = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> !Order.DELIVERED.equals(o.getStatus()) && !Order.CANCELLED.equals(o.getStatus())
                      && o.getDriverId() != null && !o.getDriverId().isBlank())
            .collect(java.util.stream.Collectors.groupingBy(Order::getDriverId, java.util.stream.Collectors.counting()));
        return drivers.stream()
            .min(Comparator.comparingLong(d -> load.getOrDefault(d.getId(), 0L)))
            .orElse(null);
    }

    // ── User management ───────────────────────────────────────────
    @PostMapping("/user/delete")
    public String deleteUser(@RequestParam String id, HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        userService.delete(id);
        return "redirect:/admin/dashboard?tab=users";
    }

    // ── Driver management ─────────────────────────────────────────
    @PostMapping("/driver/add")
    public String addDriver(@RequestParam String name,
                            @RequestParam String email,
                            @RequestParam String password,
                            @RequestParam(defaultValue = "") String phone,
                            HttpSession s, Model m) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        try {
            userService.registerDriver(name, email, password, phone);
        } catch (IllegalArgumentException e) {
            // email already taken — just redirect back with tab
        }
        return "redirect:/admin/dashboard?tab=drivers";
    }

    // ── Offer management ──────────────────────────────────────────
    @PostMapping("/offer/add")
    public String addOffer(@RequestParam String code, @RequestParam String title,
                           @RequestParam String description,
                           @RequestParam double discount,
                           @RequestParam(defaultValue = "0") double minOrder,
                           HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        Offer o = new Offer();
        o.setCode(code.toUpperCase()); o.setTitle(title); o.setDescription(description);
        o.setDiscountPercent(discount); o.setMinOrderAmount(minOrder); o.setActive(true);
        o.setCreatedAt(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
        offerService.add(o);
        return "redirect:/admin/dashboard?tab=offers";
    }

    @PostMapping("/offer/delete")
    public String deleteOffer(@RequestParam String code, HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        offerService.delete(code);
        return "redirect:/admin/dashboard?tab=offers";
    }

    // ── Feedback reply ────────────────────────────────────────────
    @PostMapping("/feedback/reply")
    public String replyFeedback(@RequestParam String feedbackId,
                                @RequestParam String reply,
                                HttpSession s) throws IOException {
        if (!isAdmin(s)) return "redirect:/admin/login";
        String line = fsu.findById(fsu.getFeedbackFile(), feedbackId);
        if (line != null) {
            String[] parts = line.split("\\|", -1);
            if (parts.length >= 8) {
                parts[7] = reply.replace("|", "").replace("\n", " ");
                fsu.update(fsu.getFeedbackFile(), feedbackId, String.join("|", parts));
            }
        }
        return "redirect:/admin/dashboard?tab=feedback";
    }
}

// ═══════════════════════════════════════════════════════════════════
// DRIVER AUTH — /driver/login (completely separate from customer)
// ═══════════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════════
// CHECKOUT
// ═══════════════════════════════════════════════════════════════════
@Controller
class CheckoutController {
    @GetMapping("/cart") public String cart(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); return "checkout/cart";
    }
    @GetMapping("/thank-you") public String thanks(HttpSession s, Model m) {
        if (s.getAttribute("user") == null) return "redirect:/login";
        m.addAttribute("user", s.getAttribute("user")); return "checkout/thank-you";
    }
}

// ═══════════════════════════════════════════════════════════════════
// ACCOUNT — customer profile (no driver section)
// ═══════════════════════════════════════════════════════════════════
@Controller @RequestMapping("/account")
class AccountController {
    private final UserService userService;
    @Autowired AccountController(UserService us) { this.userService = us; }

    private boolean isCustomer(HttpSession s) {
        Object u = s.getAttribute("user");
        return u instanceof User && "CUSTOMER".equals(((User)u).getRole());
    }

    @GetMapping public String profile(HttpSession s, Model m) {
        if (!isCustomer(s)) {
            // Drivers go to driver portal, admins to admin portal
            if (s.getAttribute("driver") != null) return "redirect:/driver/dashboard";
            if (s.getAttribute("admin") != null)  return "redirect:/admin/dashboard";
            return "redirect:/login";
        }
        // Refresh user from file so loyalty points are up to date
        User u = (User) s.getAttribute("user");
        User fresh = userService.findById(u.getId());
        if (fresh != null) s.setAttribute("user", fresh);
        m.addAttribute("user", s.getAttribute("user"));
        return "account/profile";
    }

    @PostMapping("/update")
    public String update(@RequestParam(defaultValue = "") String name,
                         @RequestParam(defaultValue = "") String phone,
                         @RequestParam(defaultValue = "") String address,
                         @RequestParam(required = false, defaultValue = "") String cardNumber,
                         @RequestParam(required = false, defaultValue = "") String cardHolder,
                         @RequestParam(required = false, defaultValue = "") String cardExpiry,
                         HttpSession s, Model m) throws IOException {
        User u = (User) s.getAttribute("user"); if (u == null) return "redirect:/login";
        userService.update(u.getId(), name, phone, address, cardNumber, cardHolder, cardExpiry);
        User updated = userService.findById(u.getId());
        s.setAttribute("user", updated != null ? updated : u);
        m.addAttribute("user", s.getAttribute("user"));
        m.addAttribute("success", "Profile updated! ✅");
        return "account/profile";
    }

    @PostMapping("/delete")
    public String delete(HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u != null) { userService.delete(u.getId()); s.invalidate(); }
        return "redirect:/login?deleted=true";
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> body, HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).body(Map.of("error", "Not logged in"));
        String current = body.getOrDefault("currentPassword", "");
        String newPwd  = body.getOrDefault("newPassword", "");
        if (current.isBlank() || newPwd.isBlank() || newPwd.length() < 6) {
            return ResponseEntity.badRequest().body(Map.of("error", "Password must be at least 6 characters."));
        }
        try {
            boolean ok = userService.changePassword(u.getId(), current, newPwd);
            if (!ok) return ResponseEntity.badRequest().body(Map.of("error", "Current password is incorrect."));
            User updated = userService.findById(u.getId());
            s.setAttribute("user", updated != null ? updated : u);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("error", "Failed to update password."));
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// ACTIVITY
// ═══════════════════════════════════════════════════════════════════
@Controller @RequestMapping("/activity")
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

// ═══════════════════════════════════════════════════════════════════
// EXTRA PAGES — about, contact, reviews, group, schedule
// ═══════════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════════
// REST API
// ═══════════════════════════════════════════════════════════════════
@RestController @RequestMapping("/api")
class ApiController {
    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final String DRIVER_NAME    = "Kasun Perera";
    private static final String DRIVER_CONTACT = "071-456-7890";

    @Value("${openweather.api.key:}") private String openWeatherKey;

    private final FoodItemService foodService;
    private final FileStorageUtil fsu;
    private final OfferService offerService;
    private final UserService userService;

    @Autowired ApiController(FoodItemService f, FileStorageUtil fs, OfferService o, UserService us) {
        this.foodService = f; this.fsu = fs; this.offerService = o; this.userService = us;
    }

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
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).body(Map.of("error", "Not logged in"));
        try {
            Order o = buildOrder(body, u);
            fsu.appendLine(fsu.getOrdersFile(), o.toFileLine());
            // Award loyalty points to user
            try {
                User usr = userService.findById(u.getId());
                if (usr != null) {
                    usr.addLoyaltyPoints(o.getLoyaltyPoints());
                    fsu.update(fsu.getUsersFile(), u.getId(), usr.toFileLine());
                }
            } catch(Exception ignored) {}
            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("success",        true);
            resp.put("orderId",        o.getOrderId());
            resp.put("total",          o.getTotalAmount());
            resp.put("loyaltyPoints",  o.getLoyaltyPoints());
            resp.put("estimatedEta",   o.getEstimatedEta());
            resp.put("driverName",     DRIVER_NAME);
            resp.put("driverContact",  DRIVER_CONTACT);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/order/{id}")
    public ResponseEntity<?> getOrder(@PathVariable String id, HttpSession s) {
        if (s.getAttribute("user") == null && s.getAttribute("admin") == null
            && s.getAttribute("driver") == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("orderId",       o.getOrderId());
        resp.put("status",        o.getStatus());
        resp.put("statusBadge",   o.getStatusBadge());
        resp.put("progress",      o.getStatusProgress());
        resp.put("totalAmount",   o.getTotalAmount());
        resp.put("driverName",    o.getDriverName()    != null ? o.getDriverName()    : "");
        resp.put("driverContact", o.getDriverContact() != null ? o.getDriverContact() : "");
        resp.put("deliveryAddress", o.getDeliveryAddress() != null ? o.getDeliveryAddress() : "");
        // Include items so customer can reorder
        resp.put("items", o.getItems().stream().map(i -> {
            Map<String,Object> im = new LinkedHashMap<>();
            im.put("foodId",   i.getFoodId());
            im.put("foodName", i.getFoodName());
            im.put("price",    i.getPrice());
            im.put("quantity", i.getQuantity());
            im.put("imageUrl", i.getImageUrl() != null ? i.getImageUrl() : "");
            return im;
        }).collect(Collectors.toList()));
        return ResponseEntity.ok(resp);
    }

    // Driver updates order status via AJAX (from driver dashboard map)
    @PostMapping("/order/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable String id,
                                          @RequestParam String status,
                                          HttpSession s) throws IOException {
        // Allow driver or admin session
        boolean allowed = s.getAttribute("driver") != null || s.getAttribute("admin") != null;
        if (!allowed) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        o.setStatus(status);
        o.setUpdatedAt(LocalDateTime.now().format(DTF));
        fsu.update(fsu.getOrdersFile(), id, o.toFileLine());
        return ResponseEntity.ok(Map.of("success", true));
    }

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

    @GetMapping("/weather")
    public ResponseEntity<?> getWeather() {
        // Real weather from OpenWeatherMap free API — Kandy, Sri Lanka (lat=7.2906, lon=80.6337)
        // API key stored in application.properties: openweather.api.key
        Map<String,Object> result = new LinkedHashMap<>();
        try {
            String apiKey = openWeatherKey != null && !openWeatherKey.isBlank() ? openWeatherKey : "";
            if (!apiKey.isBlank()) {
                String url = "https://api.openweathermap.org/data/2.5/weather?lat=7.2906&lon=80.6337&appid=" + apiKey + "&units=metric";
                var conn = new java.net.URL(url).openConnection();
                conn.setConnectTimeout(3000); conn.setReadTimeout(3000);
                String json = new String(conn.getInputStream().readAllBytes());
                                // Parse temperature, description, main from JSON using simple indexOf
                double temp = 27.0;
                String desc = "clear sky";
                String main = "Clear";
                try {
                    int ti = json.indexOf("\"temp\":"); if (ti>=0){ int end=json.indexOf(",",ti+7); if(end>ti) temp=Double.parseDouble(json.substring(ti+7,end).trim()); }
                } catch(Exception ignored){}
                try {
                    int di = json.indexOf("\"description\":\""); if(di>=0){ int s2=di+16; int e2=json.indexOf("\"",s2); if(e2>s2) desc=json.substring(s2,e2); }
                } catch(Exception ignored){}
                try {
                    int mi = json.indexOf("\"main\":\""); if(mi>=0){ int s2=mi+9; int e2=json.indexOf("\"",s2); if(e2>s2) main=json.substring(s2,e2); }
                } catch(Exception ignored){}
                boolean isRaining = main.equalsIgnoreCase("Rain") || main.equalsIgnoreCase("Drizzle") || main.equalsIgnoreCase("Thunderstorm");
                boolean isHeavy   = main.equalsIgnoreCase("Thunderstorm") || desc.contains("heavy");
                String icon = switch(main) {
                    case "Rain"         -> "🌧️";
                    case "Drizzle"      -> "🌦️";
                    case "Thunderstorm" -> "⛈️";
                    case "Clouds"       -> "⛅";
                    case "Mist","Fog","Haze" -> "🌫️";
                    default             -> "☀️";
                };
                result.put("condition", icon + " " + desc.substring(0,1).toUpperCase() + desc.substring(1));
                result.put("temp",      String.format("%.0f°C", temp));
                result.put("extraFee",  isHeavy ? 100 : isRaining ? 50 : 0);
                result.put("isRaining", isRaining);
                result.put("isHeavy",   isHeavy);
                result.put("updatedAt", LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm")));
                result.put("source",    "OpenWeatherMap");
                return ResponseEntity.ok(result);
            }
        } catch (Exception e) { /* fall through to simulated */ }
        // Fallback: realistic simulation based on Sri Lanka climate patterns
        int hour = LocalDateTime.now().getHour();
        boolean afternoonRain = hour >= 14 && hour <= 17; // afternoon showers common in Kandy
        String[] conds = afternoonRain
            ? new String[]{"🌧️ Light Rain","⛈️ Heavy Rain","⛅ Overcast"}
            : new String[]{"☀️ Clear","⛅ Partly Cloudy","☀️ Sunny"};
        int[] fees = afternoonRain ? new int[]{50, 100, 0} : new int[]{0, 0, 0};
        int pick = (int)(Math.random() * conds.length);
        result.put("condition", conds[pick]);
        result.put("temp",      (26 + (int)(Math.random()*7)) + "°C");
        result.put("extraFee",  fees[pick]);
        result.put("isRaining", fees[pick] > 0);
        result.put("isHeavy",   fees[pick] >= 100);
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
    @PostMapping("/driver/location")
    public ResponseEntity<?> updateDriverLocation(@RequestBody Map<String, Object> body,
                                                  HttpSession s) throws IOException {
        if (s.getAttribute("driver") == null) return ResponseEntity.status(401).build();
        User driver = (User) s.getAttribute("driver");
        double lat = ((Number) body.getOrDefault("lat", 0)).doubleValue();
        double lng = ((Number) body.getOrDefault("lng", 0)).doubleValue();
        // Store driver location as a simple file entry (keyed by driver ID)
        String locationLine = driver.getId() + "|" + lat + "|" + lng + "|" + LocalDateTime.now().format(DTF);
        // Update or append
        if (!fsu.update("data/driver_locations.txt", driver.getId(), locationLine)) {
            fsu.appendLine("data/driver_locations.txt", locationLine);
        }
        return ResponseEntity.ok(Map.of("success", true));
    }

    // ── Get driver location (for customer tracking) ───────────────
    @GetMapping("/driver/location/{orderId}")
    public ResponseEntity<?> getDriverLocation(@PathVariable String orderId, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        // Try to find real driver location; fall back to restaurant as default
        String order = fsu.findById(fsu.getOrdersFile(), orderId);
        if (order != null) {
            Order o = Order.fromLine(order);
            if (o.getDriverId() != null && !o.getDriverId().isBlank()) {
                String loc = fsu.findById("data/driver_locations.txt", o.getDriverId());
                if (loc != null) {
                    String[] p = loc.split("\\|", -1);
                    if (p.length >= 3) {
                        try {
                            double lat = Double.parseDouble(p[1]);
                            double lng = Double.parseDouble(p[2]);
                            return ResponseEntity.ok(Map.of("lat", lat, "lng", lng, "available", true));
                        } catch (Exception ignored) {}
                    }
                }
            }
        }
        // Simulate driver moving around Kandy
        double baseLat = 7.2906 + (Math.random() - 0.5) * 0.015;
        double baseLng = 80.6337 + (Math.random() - 0.5) * 0.015;
        return ResponseEntity.ok(Map.of("lat", baseLat, "lng", baseLng, "available", true));
    }

    // ── My orders (for account page quick view) ───────────────────
    @GetMapping("/my-orders")
    public ResponseEntity<?> myOrders(@RequestParam(defaultValue = "5") int limit, HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        List<Map<String, Object>> result = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> u.getId().equals(o.getCustomerId()))
            .sorted(Comparator.comparing(
                (Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : "",
                Comparator.reverseOrder()))
            .limit(limit)
            .map(o -> {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("orderId",     o.getOrderId());
                m.put("status",      o.getStatus());
                m.put("statusBadge", o.getStatusBadge());
                m.put("totalAmount", o.getTotalAmount());
                m.put("createdAt",   o.getCreatedAt());
                m.put("items",       o.getItems().stream().map(i -> {
                    Map<String,Object> im = new LinkedHashMap<>();
                    im.put("foodId",   i.getFoodId());
                    im.put("foodName", i.getFoodName());
                    im.put("price",    i.getPrice());
                    im.put("quantity", i.getQuantity());
                    im.put("imageUrl", i.getImageUrl() != null ? i.getImageUrl() : "");
                    return im;
                }).collect(Collectors.toList()));
                return m;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    // ── Poll for new orders (admin/driver use for auto-refresh) ─────
    @GetMapping("/orders/poll")
    public ResponseEntity<?> pollOrders(@RequestParam(defaultValue = "0") long since, HttpSession s) {
        boolean isAdmin  = s.getAttribute("admin")  instanceof User;
        boolean isDriver = s.getAttribute("driver") instanceof User;
        boolean isUser   = s.getAttribute("user")   instanceof User;
        if (!isAdmin && !isDriver && !isUser) return ResponseEntity.status(401).build();

        List<Map<String,Object>> orders = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> {
                if (isUser) {
                    User u = (User) s.getAttribute("user");
                    return u.getId().equals(o.getCustomerId());
                }
                if (isDriver) return Order.READY.equals(o.getStatus()) || Order.HANDOVER.equals(o.getStatus()) || Order.ONWAY.equals(o.getStatus());
                return true; // admin sees all
            })
            .sorted(Comparator.comparing((Order o) -> o.getCreatedAt() != null ? o.getCreatedAt() : "", Comparator.reverseOrder()))
            .limit(50)
            .map(o -> {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("orderId",     o.getOrderId());
                m.put("status",      o.getStatus());
                m.put("statusBadge", o.getStatusBadge());
                m.put("progress",    o.getStatusProgress());
                m.put("customerName",o.getCustomerName());
                m.put("totalAmount", o.getTotalAmount());
                m.put("createdAt",   o.getCreatedAt());
                m.put("driverName",  o.getDriverName()    != null ? o.getDriverName()    : "");
                m.put("driverContact",o.getDriverContact() != null ? o.getDriverContact() : "");
                return m;
            }).collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("orders", orders, "timestamp", System.currentTimeMillis()));
    }

    // ── Cancel order within 2 minutes of placing ────────────────
    @PostMapping("/order/{id}/cancel")
    public ResponseEntity<?> cancelOrder(@PathVariable String id, HttpSession s) throws IOException {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        if (!u.getId().equals(o.getCustomerId())) return ResponseEntity.status(403).build();
        if (Order.DELIVERED.equals(o.getStatus()) || Order.CANCELLED.equals(o.getStatus()))
            return ResponseEntity.badRequest().body(Map.of("error", "Order cannot be cancelled."));
        if (Order.ONWAY.equals(o.getStatus()) || Order.HANDOVER.equals(o.getStatus()))
            return ResponseEntity.badRequest().body(Map.of("error", "Driver has already picked up your order."));
        // Check 2-minute window
        try {
            var placed = java.time.LocalDateTime.parse(o.getCreatedAt(), java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            if (java.time.LocalDateTime.now().isAfter(placed.plusMinutes(2)))
                return ResponseEntity.badRequest().body(Map.of("error", "Cancellation window (2 min) has passed."));
        } catch (Exception ignored) {}
        o.setStatus(Order.CANCELLED);
        o.setUpdatedAt(java.time.LocalDateTime.now().format(DTF));
        fsu.update(fsu.getOrdersFile(), id, o.toFileLine());
        return ResponseEntity.ok(Map.of("success", true));
    }

    // ── Loyalty points ────────────────────────────────────────────
    @GetMapping("/loyalty")
    public ResponseEntity<?> loyalty(HttpSession s) {
        User u = (User) s.getAttribute("user");
        if (u == null) return ResponseEntity.status(401).build();
        int points = fsu.readAll(fsu.getOrdersFile()).stream()
            .map(Order::fromLine).filter(Objects::nonNull)
            .filter(o -> u.getId().equals(o.getCustomerId()) && Order.DELIVERED.equals(o.getStatus()))
            .mapToInt(o -> (int)(o.getTotalAmount() / 10))
            .sum();
        return ResponseEntity.ok(Map.of("points", points, "discount", points >= 100 ? (points / 100) * 50 : 0, "nextReward", Math.max(0, 100 - (points % 100))));
    }

    // ── Real driver location + nearby check ──────────────────────
    @GetMapping("/order/{id}/driver-location")
    public ResponseEntity<?> orderDriverLocation(@PathVariable String id, HttpSession s) {
        if (s.getAttribute("user") == null) return ResponseEntity.status(401).build();
        String line = fsu.findById(fsu.getOrdersFile(), id);
        if (line == null) return ResponseEntity.notFound().build();
        Order o = Order.fromLine(line);
        String status = o.getStatus() != null ? o.getStatus() : "";
        double lat = 7.2906, lng = 80.6337; // restaurant default
        boolean realLocation = false;
        // Read actual driver GPS location from file
        if (o.getDriverId() != null && !o.getDriverId().isBlank()) {
            String locLine = fsu.findById(fsu.getDriverLocationsFile(), o.getDriverId());
            if (locLine != null) {
                String[] p = locLine.split("\\|", -1);
                if (p.length >= 3) {
                    try { lat = Double.parseDouble(p[1]); lng = Double.parseDouble(p[2]); realLocation = true; }
                    catch (Exception ignored) {}
                }
            }
        }
        // Check if driver is within 1km of delivery address (simplified: check status)
        boolean nearby = Order.ONWAY.equals(status) && realLocation;
        return ResponseEntity.ok(Map.of(
            "lat", lat, "lng", lng,
            "nearby", nearby,
            "status", status,
            "realLocation", realLocation
        ));
    }

    // ── Admin stats snapshot ──────────────────────────────────────
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
        o.setDeliveryAddress(gs(body, "address", u.getAddress() != null ? u.getAddress() : ""));
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
