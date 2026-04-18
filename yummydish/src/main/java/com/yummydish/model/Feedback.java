package com.yummydish.model;

/**
 * Feedback — OOP: Abstract class (Abstraction)
 * Subclasses: PublicReview, AdminReport (Inheritance + Polymorphism)
 */
public abstract class Feedback {

    private String id;
    private String orderId;
    private String customerId;
    private String customerName;
    private String text;
    private String foodItemId;
    private String foodItemName;
    private String adminReply;
    private String createdAt;
    private String type;

    // Abstract methods — Polymorphism
    public abstract String  getDisplayIcon();
    public abstract boolean isPublicFeedback();

    // Factory method: reads a file line, returns correct subclass
    public static Feedback fromFileLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] p = line.split("\\|", -1);
        String t = (p.length >= 10) ? p[9] : "REVIEW";

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

        if (f instanceof PublicReview && p.length > 10) {
            try { ((PublicReview) f).setRating(Integer.parseInt(p[10])); }
            catch (Exception ignored) {}
        }
        return f;
    }

    public String toFileLine() {
        return String.join("|",
            safe(id), safe(orderId), safe(customerId), safe(customerName),
            safe(text), safe(foodItemId), safe(foodItemName),
            safe(adminReply), safe(createdAt), safe(type));
    }

    private static String safe(String v) {
        return (v != null) ? v.replace("|", "").replace("\n", " ") : "";
    }

    // Getters & Setters
    public String getId()              { return id; }
    public void   setId(String v)      { this.id = v; }
    public String getOrderId()         { return orderId; }
    public void   setOrderId(String v) { this.orderId = v; }
    public String getCustomerId()      { return customerId; }
    public void   setCustomerId(String v) { this.customerId = v; }
    public String getCustomerName()    { return customerName; }
    public void   setCustomerName(String v) { this.customerName = v; }
    public String getText()            { return text; }
    public void   setText(String v)    { this.text = v; }
    public String getFoodItemId()      { return foodItemId; }
    public void   setFoodItemId(String v) { this.foodItemId = v; }
    public String getFoodItemName()    { return foodItemName; }
    public void   setFoodItemName(String v) { this.foodItemName = v; }
    public String getAdminReply()      { return adminReply; }
    public void   setAdminReply(String v) { this.adminReply = v; }
    public String getCreatedAt()       { return createdAt; }
    public void   setCreatedAt(String v) { this.createdAt = v; }
    public String getType()            { return type; }
    public void   setType(String v)    { this.type = v; }
}

/** PublicReview — Inheritance from Feedback. Visible to all users. */
class PublicReview extends Feedback {
    private int rating = 5;

    public PublicReview() { setType("REVIEW"); }

    @Override public String  getDisplayIcon()    { return "⭐"; }
    @Override public boolean isPublicFeedback()  { return true; }

    @Override
    public String toFileLine() {
        return super.toFileLine() + "|" + rating;
    }

    public int  getRating()      { return rating; }
    public void setRating(int v) { this.rating = v; }
}

/** AdminReport — Inheritance from Feedback. Only visible to admins. */
class AdminReport extends Feedback {
    private boolean resolved = false;

    public AdminReport() { setType("REPORT"); }

    @Override public String  getDisplayIcon()    { return "🚩"; }
    @Override public boolean isPublicFeedback()  { return false; }

    @Override
    public String toFileLine() {
        return super.toFileLine() + "|" + resolved;
    }

    public boolean isResolved()        { return resolved; }
    public void    setResolved(boolean v) { this.resolved = v; }
}
