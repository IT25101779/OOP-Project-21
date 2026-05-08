package com.yummydish.model;

/**
 * User — OOP: Encapsulation (private fields + getters/setters)
 * Demonstrates Polymorphism via getDashboardUrl()
 */
public class User {

    private String id;
    private String name;
    private String email;
    private String passwordHash;
    private String phone;
    private String address;
    private String role;
    private String createdAt;
    private String cardNumber;
    private String cardHolder;
    private String cardExpiry;
    private String profilePicUrl;
    private int    loyaltyPoints = 0;

    public User() {}

    /** Polymorphism: each role redirects to a different dashboard URL */
    public String getDashboardUrl() {
        if ("ADMIN".equals(role))  return "/admin/dashboard";
        if ("DRIVER".equals(role)) return "/driver";
        return "/menu";
    }

    public boolean hasCard() {
        return cardNumber != null && !cardNumber.isBlank();
    }

    public String getMaskedCard() {
        if (!hasCard()) return "";
        String c = cardNumber.replaceAll("\\s", "");
        return "**** **** **** " + c.substring(Math.max(0, c.length() - 4));
    }

    public String toFileLine() {
        return String.join("|",
            safe(id), safe(name), safe(email), safe(passwordHash),
            safe(phone), safe(address), safe(role), safe(createdAt),
            safe(cardNumber), safe(cardHolder), safe(cardExpiry), safe(profilePicUrl), String.valueOf(loyaltyPoints));
    }

    public static User fromLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] p = line.split("\\|", -1);
        User u = new User();
        if (p.length > 0)  u.id            = p[0];
        if (p.length > 1)  u.name          = p[1];
        if (p.length > 2)  u.email         = p[2];
        if (p.length > 3)  u.passwordHash  = p[3];
        if (p.length > 4)  u.phone         = p[4];
        if (p.length > 5)  u.address       = p[5];
        if (p.length > 6)  u.role          = p[6];
        if (p.length > 7)  u.createdAt     = p[7];
        if (p.length > 8)  u.cardNumber    = p[8];
        if (p.length > 9)  u.cardHolder    = p[9];
        if (p.length > 10) u.cardExpiry    = p[10];
        if (p.length > 11) u.profilePicUrl = p[11];
        if (p.length > 12) { try { u.loyaltyPoints = Integer.parseInt(p[12]); } catch(Exception e){} }
        return u;
    }

    private static String safe(String v) {
        return (v != null) ? v.replace("|", "").replace("\n", " ") : "";
    }

    // Getters & Setters
    public String getId()                    { return id; }
    public void   setId(String v)            { this.id = v; }
    public String getName()                  { return name; }
    public void   setName(String v)          { this.name = v; }
    public String getEmail()                 { return email; }
    public void   setEmail(String v)         { this.email = v; }
    public String getPasswordHash()          { return passwordHash; }
    public void   setPasswordHash(String v)  { this.passwordHash = v; }
    public String getPhone()                 { return phone; }
    public void   setPhone(String v)         { this.phone = v; }
    public String getAddress()               { return address; }
    public void   setAddress(String v)       { this.address = v; }
    public String getRole()                  { return role; }
    public void   setRole(String v)          { this.role = v; }
    public String getCreatedAt()             { return createdAt; }
    public void   setCreatedAt(String v)     { this.createdAt = v; }
    public String getCardNumber()            { return cardNumber; }
    public void   setCardNumber(String v)    { this.cardNumber = v; }
    public String getCardHolder()            { return cardHolder; }
    public void   setCardHolder(String v)    { this.cardHolder = v; }
    public String getCardExpiry()            { return cardExpiry; }
    public void   setCardExpiry(String v)    { this.cardExpiry = v; }
    public String getProfilePicUrl()         { return profilePicUrl; }
    public void   setProfilePicUrl(String v) { this.profilePicUrl = v; }
    public int    getLoyaltyPoints()         { return loyaltyPoints; }
    public void   setLoyaltyPoints(int v)    { this.loyaltyPoints = v; }
    public void   addLoyaltyPoints(int v)    { this.loyaltyPoints += v; }
}
