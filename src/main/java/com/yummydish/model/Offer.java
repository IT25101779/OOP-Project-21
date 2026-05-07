package com.yummydish.model;

/** Offer / promo code model */
public class Offer {
    private String code;
    private String title;
    private String description;
    private double discountPercent;   // e.g. 20.0 = 20%
    private double minOrderAmount;    // 0 = no minimum
    private boolean active;
    private String createdAt;

    public Offer() {}

    public String toFileLine() {
        return String.join("|",
            s(code), s(title), s(description),
            String.valueOf(discountPercent),
            String.valueOf(minOrderAmount),
            String.valueOf(active),
            s(createdAt));
    }

    public static Offer fromLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] p = line.split("\\|", -1);
        Offer o = new Offer();
        if (p.length > 0) o.code            = p[0];
        if (p.length > 1) o.title           = p[1];
        if (p.length > 2) o.description     = p[2];
        if (p.length > 3) try { o.discountPercent = Double.parseDouble(p[3]); } catch(Exception ignored){}
        if (p.length > 4) try { o.minOrderAmount  = Double.parseDouble(p[4]); } catch(Exception ignored){}
        if (p.length > 5) o.active          = Boolean.parseBoolean(p[5]);
        if (p.length > 6) o.createdAt       = p[6];
        return o;
    }

    /** Apply this offer to a subtotal and return the discount amount */
    public double calculateDiscount(double subtotal) {
        if (!active) return 0;
        if (subtotal < minOrderAmount) return 0;
        return Math.round(subtotal * discountPercent / 100.0 * 100.0) / 100.0;
    }

    private String s(String v) { return v != null ? v.replace("|","") : ""; }

    public String  getCode()                    { return code; }
    public void    setCode(String v)            { this.code = v; }
    public String  getTitle()                   { return title; }
    public void    setTitle(String v)           { this.title = v; }
    public String  getDescription()             { return description; }
    public void    setDescription(String v)     { this.description = v; }
    public double  getDiscountPercent()         { return discountPercent; }
    public void    setDiscountPercent(double v) { this.discountPercent = v; }
    public double  getMinOrderAmount()          { return minOrderAmount; }
    public void    setMinOrderAmount(double v)  { this.minOrderAmount = v; }
    public boolean isActive()                   { return active; }
    public void    setActive(boolean v)         { this.active = v; }
    public String  getCreatedAt()               { return createdAt; }
    public void    setCreatedAt(String v)       { this.createdAt = v; }
}
