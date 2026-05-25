package com.yummydish.model;

public abstract class Feedback {

    //  ENCAPSULATION: All fields private
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

    public abstract String  getDisplayIcon();
    public abstract boolean isPublicFeedback();

    // FILE HANDLING + POLYMORPHISM
    // CRUD - READ:feedback.txt
    public static Feedback fromFileLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] p = line.split("\\|", -1);
        String t = (p.length >= 10) ? p[9] : "REVIEW";

        // POLYMORPHISM
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

    // CRUD - CREATE:feedback.txt when review submitted
    public String toFileLine() {
        return String.join("|",
                safe(id), safe(orderId), safe(customerId), safe(customerName),
                safe(text), safe(foodItemId), safe(foodItemName),
                safe(adminReply), safe(createdAt), safe(type));
    }

    private static String safe(String v) {
        return (v != null) ? v.replace("|", "").replace("\n", " ") : "";
    }

    //  ENCAPSULATION
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
