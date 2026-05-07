package com.yummydish.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Order — OOP: Encapsulation (private fields + getters/setters)
 * Contains CartItem as a static inner class.
 */
public class Order {

    public static final String PENDING   = "PENDING";
    public static final String COOKING   = "COOKING";
    public static final String READY     = "READY";
    public static final String HANDOVER  = "HANDOVER";
    public static final String ONWAY     = "ON_WAY";
    public static final String DELIVERED = "DELIVERED";
    public static final String CANCELLED = "CANCELLED";

    private String orderId;
    private String customerId;
    private String customerName;
    private String deliveryAddress;
    private String chefNote;
    private String driverNote;
    private String paymentMethod;
    private String status;
    private String offerCode;
    private String driverId;
    private String driverName;
    private String driverContact;
    private String orderType;
    private String createdAt;
    private String updatedAt;
    private double subtotal;
    private double deliveryFee  = 250.0;
    private double discount;
    private double tip          = 0.0;
    private double weatherFee   = 0.0;
    private double totalAmount;
    private int    loyaltyPoints = 0;   // points earned on this order
    private String estimatedEta = "";   // e.g. "25 min"
    private String scheduledFor = "";   // e.g. "2024-12-25 14:00"
    private List<CartItem> items = new ArrayList<>();

    public Order() {
        this.status    = PENDING;
        this.orderType = "STANDARD";
    }

    public void calculateTotal() {
        subtotal    = items.stream().mapToDouble(CartItem::getLineTotal).sum();
        totalAmount = subtotal + deliveryFee + tip + weatherFee - discount;
        loyaltyPoints = (int)(subtotal / 10); // 1 point per LKR 10
    }

    public String getStatusBadge() {
        if (status == null) return "Pending ⏳";
        switch (status) {
            case COOKING:   return "Cooking 🍳";
            case READY:     return "Ready for Pickup 📦";
            case HANDOVER:  return "Driver Picked Up 🤝";
            case ONWAY:     return "On the Way 🛵";
            case DELIVERED: return "Delivered ✅";
            case CANCELLED: return "Cancelled ❌";
            default:        return "Pending ⏳";
        }
    }

    public int getStatusProgress() {
        if (status == null) return 5;
        switch (status) {
            case COOKING:   return 25;
            case READY:     return 45;
            case HANDOVER:  return 60;
            case ONWAY:     return 82;
            case DELIVERED: return 100;
            case CANCELLED: return 0;
            default:        return 5;
        }
    }

    // Serialize — fields 0-19, then ||I|| then items
    public String toFileLine() {
        StringBuilder sb = new StringBuilder();
        sb.append(String.join("|",
            safe(orderId), safe(customerId), safe(customerName),
            String.valueOf(subtotal), String.valueOf(deliveryFee),
            String.valueOf(discount), String.valueOf(totalAmount),
            safe(deliveryAddress), safe(chefNote), safe(driverNote),
            safe(paymentMethod), safe(status), safe(offerCode),
            safe(driverId), safe(driverName), safe(driverContact),
            safe(orderType), safe(createdAt), safe(updatedAt),
            String.valueOf(tip), String.valueOf(weatherFee),
            String.valueOf(loyaltyPoints), safe(estimatedEta), safe(scheduledFor)));
        sb.append("||I||");
        for (CartItem ci : items) { sb.append(ci.toMini()).append(";"); }
        return sb.toString();
    }

    public static Order fromLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] mp = line.split("\\|\\|I\\|\\|", 2);
        String[] p  = mp[0].split("\\|", -1);
        Order o = new Order();
        if (p.length >= 19) {
            o.orderId         = p[0];
            o.customerId      = p[1];
            o.customerName    = p[2];
            o.subtotal        = parseDouble(p[3]);
            o.deliveryFee     = parseDouble(p[4]);
            o.discount        = parseDouble(p[5]);
            o.totalAmount     = parseDouble(p[6]);
            o.deliveryAddress = p[7];
            o.chefNote        = p[8];
            o.driverNote      = p[9];
            o.paymentMethod   = p[10];
            o.status          = p[11];
            o.offerCode       = p[12];
            o.driverId        = p[13];
            o.driverName      = p[14];
            o.driverContact   = p[15];
            o.orderType       = p[16];
            o.createdAt       = p[17];
            o.updatedAt       = p[18];
        }
        if (p.length > 19) o.tip          = parseDouble(p[19]);
        if (p.length > 20) o.weatherFee   = parseDouble(p[20]);
        if (p.length > 21) o.loyaltyPoints= (int)parseDouble(p[21]);
        if (p.length > 22) o.estimatedEta = p[22];
        if (p.length > 23) o.scheduledFor = p[23];
        if (mp.length > 1 && !mp[1].isBlank()) {
            for (String s : mp[1].split(";")) {
                if (!s.isBlank()) {
                    CartItem ci = CartItem.fromMini(s);
                    if (ci != null) o.items.add(ci);
                }
            }
        }
        return o;
    }

    private static String safe(String v) {
        return (v != null) ? v.replace("|", "").replace("\n", " ") : "";
    }
    private static double parseDouble(String s) {
        try { return Double.parseDouble(s); } catch (Exception e) { return 0; }
    }

    // ── CartItem ──────────────────────────────────────────────────
    public static class CartItem {
        private String foodId, foodName, imageUrl;
        private double price;
        private int    quantity;

        public CartItem() {}
        public CartItem(String foodId, String foodName, double price, int quantity, String imageUrl) {
            this.foodId = foodId; this.foodName = foodName;
            this.price  = price;  this.quantity  = quantity; this.imageUrl = imageUrl;
        }
        public double getLineTotal() { return price * quantity; }
        public String toMini() {
            return strip(foodId)+","+strip(foodName)+","+price+","+quantity+","+(imageUrl!=null?imageUrl:"");
        }
        public static CartItem fromMini(String s) {
            String[] p = s.split(",", 5);
            if (p.length < 4) return null;
            CartItem ci = new CartItem();
            ci.foodId=p[0]; ci.foodName=p[1];
            try{ci.price=Double.parseDouble(p[2]);}catch(Exception e){}
            try{ci.quantity=Integer.parseInt(p[3]);}catch(Exception e){}
            if(p.length>4) ci.imageUrl=p[4];
            return ci;
        }
        private static String strip(String v){return (v!=null)?v.replace(",",""):"";}
        public String getFoodId()            { return foodId; }
        public void   setFoodId(String v)    { this.foodId=v; }
        public String getFoodName()          { return foodName; }
        public void   setFoodName(String v)  { this.foodName=v; }
        public double getPrice()             { return price; }
        public void   setPrice(double v)     { this.price=v; }
        public int    getQuantity()          { return quantity; }
        public void   setQuantity(int v)     { this.quantity=v; }
        public String getImageUrl()          { return imageUrl; }
        public void   setImageUrl(String v)  { this.imageUrl=v; }
    }

    // Getters & Setters
    public String getOrderId()               { return orderId; }
    public void   setOrderId(String v)       { this.orderId=v; }
    public String getCustomerId()            { return customerId; }
    public void   setCustomerId(String v)    { this.customerId=v; }
    public String getCustomerName()          { return customerName; }
    public void   setCustomerName(String v)  { this.customerName=v; }
    public String getDeliveryAddress()       { return deliveryAddress; }
    public void   setDeliveryAddress(String v){ this.deliveryAddress=v; }
    public String getChefNote()              { return chefNote; }
    public void   setChefNote(String v)      { this.chefNote=v; }
    public String getDriverNote()            { return driverNote; }
    public void   setDriverNote(String v)    { this.driverNote=v; }
    public String getPaymentMethod()         { return paymentMethod; }
    public void   setPaymentMethod(String v) { this.paymentMethod=v; }
    public String getStatus()                { return status; }
    public void   setStatus(String v)        { this.status=v; }
    public String getOfferCode()             { return offerCode; }
    public void   setOfferCode(String v)     { this.offerCode=v; }
    public String getDriverId()              { return driverId; }
    public void   setDriverId(String v)      { this.driverId=v; }
    public String getDriverName()            { return driverName; }
    public void   setDriverName(String v)    { this.driverName=v; }
    public String getDriverContact()         { return driverContact; }
    public void   setDriverContact(String v) { this.driverContact=v; }
    public String getOrderType()             { return orderType; }
    public void   setOrderType(String v)     { this.orderType=v; }
    public String getCreatedAt()             { return createdAt; }
    public void   setCreatedAt(String v)     { this.createdAt=v; }
    public String getUpdatedAt()             { return updatedAt; }
    public void   setUpdatedAt(String v)     { this.updatedAt=v; }
    public double getSubtotal()              { return subtotal; }
    public void   setSubtotal(double v)      { this.subtotal=v; }
    public double getDeliveryFee()           { return deliveryFee; }
    public void   setDeliveryFee(double v)   { this.deliveryFee=v; }
    public double getDiscount()              { return discount; }
    public void   setDiscount(double v)      { this.discount=v; }
    public double getTip()                   { return tip; }
    public void   setTip(double v)           { this.tip=v; }
    public double getWeatherFee()            { return weatherFee; }
    public String getScheduledFor()          { return scheduledFor != null ? scheduledFor : ""; }
    public void   setScheduledFor(String v)  { this.scheduledFor = v; }
    public void   setWeatherFee(double v)    { this.weatherFee=v; }
    public double getTotalAmount()           { return totalAmount; }
    public void   setTotalAmount(double v)   { this.totalAmount=v; }
    public int    getLoyaltyPoints()         { return loyaltyPoints; }
    public void   setLoyaltyPoints(int v)    { this.loyaltyPoints=v; }
    public String getEstimatedEta()          { return estimatedEta; }
    public void   setEstimatedEta(String v)  { this.estimatedEta=v; }
    public List<CartItem> getItems()         { return items; }
    public void   setItems(List<CartItem> v) { this.items=v; }
}
