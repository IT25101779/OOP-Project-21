package com.yummydish.model;


// FILE: Feedback.java
// COMPONENT: C6 — Post-Order Feedback & Reporting
// MEMBER: Member 6

// OOP CONCEPTS DEMONSTRATED:
//   ✅ ABSTRACTION    — Feedback is abstract: defines getDisplayIcon()
//                       and isPublicFeedback() as abstract methods.
//                       Caller doesn't need to know if it's a review
//                       or report — just calls the method.
//   ✅ INHERITANCE    — PublicReview and AdminReport both extend Feedback,
//                       inheriting all common fields (id, text, customerId…)
//   ✅ POLYMORPHISM   — getDisplayIcon() returns "⭐" for reviews and
//                       "🚩" for reports. isPublicFeedback() returns
//                       true/false differently per subclass.
//                       fromFileLine() factory creates correct subclass.
//   ✅ ENCAPSULATION  — All fields private with getters/setters.
//
// CRUD OPERATIONS COVERED (via FeedbackController):
//   CREATE — POST /api/feedback: user submits review → feedback.txt
//   READ   — GET /api/food/{id}/reviews: reads public reviews from file
//   UPDATE — Admin replies to a review → line rewritten in feedback.txt
//   DELETE — Admin deletes inappropriate review → removed from file
//
// FILE HANDLING:
//   toFileLine()    — serializes to pipe-delimited line for feedback.txt
//   fromFileLine()  — factory: reads line, returns PublicReview/AdminReport


public abstract class Feedback {

  
    private String id;
    private String orderId;
    private String customerId;
    private String customerName;
    private String text;
    private String foodItemId;
    private String foodItemName;
    private String adminReply;     // admin can reply to reviews
    private String createdAt;
    private String type;           // "REVIEW" | "REPORT"

    // ── ABSTRACTION: Abstract methods — subclasses must implement ──
    // The UI layer just calls getDisplayIcon() without knowing the type
    public abstract String  getDisplayIcon();    // ⭐ or 🚩
    public abstract boolean isPublicFeedback();  // true = show publicly

    // ── FILE HANDLING + POLYMORPHISM: Factory method ───────────────
    // CRUD - READ: reads a line from feedback.txt, creates correct subclass
    public static Feedback fromFileLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] p = line.split("\\|", -1);
        String t = (p.length >= 10) ? p[9] : "REVIEW";

        // POLYMORPHISM: choose the right subclass based on type field
        Feedback f = "REPORT".equals(t) ? new AdminReport() : new PublicReview();

        if (p.length > 0)  f.id           = p[0];
        if (p.length > 1)  f.orderId      = p[1];
        if (p.length > 2)  f.customerId   = p[2];
        if (p.length > 3)  f.customerName = p[3];
        if (p.length > 4)  f.text         = p[4];
        if (p.length > 5)  f.foodItemId   = p[5];
        if (p.length > 6)  f.foodItemName = p[6];
        if (p.length > 7)  f.adminReply   = p[7];
        if (p.length > 8)  f.createdAt    = p[8];
        if (p.length > 9)  f.type         = p[9];

        // PublicReview has extra rating field at position 10
        if (f instanceof PublicReview && p.length > 10) {
            try { ((PublicReview) f).setRating(Integer.parseInt(p[10])); }
            catch (Exception ignored) {}
        }
        return f;
    }

    // ── FILE HANDLING: Serialize to pipe-delimited line ────────────
    // CRUD - CREATE: written to data/feedback.txt when review submitted
    public String toFileLine() {
        return String.join("|",
                safe(id), safe(orderId), safe(customerId), safe(customerName),
                safe(text), safe(foodItemId), safe(foodItemName),
                safe(adminReply), safe(createdAt), safe(type));
    }

    private static String safe(String v) {
        return (v != null) ? v.replace("|", "").replace("\n", " ") : "";
    }

    // ── ENCAPSULATION: Public Getters & Setters ────────────────────
    public String getId()                     { return id; }
    public void   setId(String v)             { this.id = v; }
    public String getOrderId()                { return orderId; }
    public void   setOrderId(String v)        { this.orderId = v; }
    public String getCustomerId()             { return customerId; }
    public void   setCustomerId(String v)     { this.customerId = v; }
    public String getCustomerName()           { return customerName; }
    public void   setCustomerName(String v)   { this.customerName = v; }
    public String getText()                   { return text; }
    public void   setText(String v)           { this.text = v; }
    public String getFoodItemId()             { return foodItemId; }
    public void   setFoodItemId(String v)     { this.foodItemId = v; }
    public String getFoodItemName()           { return foodItemName; }
    public void   setFoodItemName(String v)   { this.foodItemName = v; }
    public String getAdminReply()             { return adminReply; }
    public void   setAdminReply(String v)     { this.adminReply = v; }
    public String getCreatedAt()              { return createdAt; }
    public void   setCreatedAt(String v)      { this.createdAt = v; }
    public String getType()                   { return type; }
    public void   setType(String v)           { this.type = v; }
}

// ── INHERITANCE: PublicReview extends Feedback ────────────────────
/**
 * PublicReview — INHERITANCE from Feedback
 * Visible to all users on the food detail page.
 * Has an extra rating field (1-5 stars).
 * POLYMORPHISM: overrides getDisplayIcon() and isPublicFeedback()
 */
class PublicReview extends Feedback {
    private int rating = 5;  // star rating 1-5

    public PublicReview() {
        setType("REVIEW"); // set type on construction
    }

    // POLYMORPHISM: returns star icon for public review display
    @Override public String  getDisplayIcon()   { return "⭐"; }

    // POLYMORPHISM: public reviews are shown to everyone
    @Override public boolean isPublicFeedback() { return true; }

    // Override toFileLine() to include rating as extra field
    @Override
    public String toFileLine() {
        return super.toFileLine() + "|" + rating;
    }

    public int  getRating()       { return rating; }
    public void setRating(int v)  { this.rating = v; }
}

// ── INHERITANCE: AdminReport extends Feedback ─────────────────────
/**
 * AdminReport — INHERITANCE from Feedback
 * Only visible to admins in the moderation panel.
 * Has an extra resolved field.
 * POLYMORPHISM: overrides getDisplayIcon() and isPublicFeedback()
 */
class AdminReport extends Feedback {
    private boolean resolved = false;

    public AdminReport() {
        setType("REPORT"); // set type on construction
    }

    // POLYMORPHISM: returns flag icon for admin report display
    @Override public String  getDisplayIcon()   { return "🚩"; }

    // POLYMORPHISM: reports are NOT shown publicly
    @Override public boolean isPublicFeedback() { return false; }

    // Override toFileLine() to include resolved status as extra field
    @Override
    public String toFileLine() {
        return super.toFileLine() + "|" + resolved;
    }

    public boolean isResolved()          { return resolved; }
    public void    setResolved(boolean v){ this.resolved = v; }
}
