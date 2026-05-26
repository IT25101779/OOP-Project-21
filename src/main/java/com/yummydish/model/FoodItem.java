package com.yummydish.model;


public abstract class FoodItem {

    
    private String id;
    private String name;
    private String description;
    private String category;       // e.g. "Breakfast", "Lunch", "Dinner"
    private String ingredients;
    private String portionSize;
    private String imageUrl;
    private String createdAt;
    private double price;
    private double rating;
    private int    calories;
    private int    reviewCount;
    private boolean available;
    private boolean popular;

    public FoodItem() {}

   
    // MUST implement these — but in their own way.
    // This is abstraction: hiding implementation, exposing only the interface.
    public abstract String getNutritionalInfo(); 
    public abstract String getFoodType();       

    // ── FILE HANDLING: Serialize object → one tilde-delimited line ─
    // CRUD - CREATE/UPDATE: written to data/food_items.txt
    public String toFileLine() {
        return String.join("~",
                clean(id), clean(name), clean(description),
                String.valueOf(price), clean(category),
                clean(ingredients), clean(portionSize),
                String.valueOf(calories),
                String.valueOf(available), String.valueOf(popular),
                String.valueOf(rating), String.valueOf(reviewCount),
                clean(imageUrl), clean(createdAt), getFoodType());
    }

    // ── FILE HANDLING + POLYMORPHISM: Factory method
    // READ: reads a line from food_items.txt and returns the

    public static FoodItem fromLine(String line) {
        if (line == null || line.isBlank()) return null;
        String[] p = line.split("~", -1);
        if (p.length < 14) return null;

        // POLYMORPHISM: decides which subclass to instantiate at runtime
        String type = (p.length >= 15) ? p[14] : "MainCourse";
        FoodItem f;
        switch (type) {
            case "Beverage": f = new Beverage();   break;
            case "Dessert":  f = new Dessert();    break;
            default:         f = new MainCourse(); break;
        }

        // Populate fields from file line
        f.id          = p[0];
        f.name        = p[1];
        f.description = p[2];
        f.price       = parseDouble(p[3]);
        f.category    = p[4];
        f.ingredients = p[5];
        f.portionSize = p[6];
        f.calories    = parseInt(p[7]);
        f.available   = Boolean.parseBoolean(p[8]);
        f.popular     = Boolean.parseBoolean(p[9]);
        f.rating      = parseDouble(p[10]);
        f.reviewCount = parseInt(p[11]);
        f.imageUrl    = p[12];
        f.createdAt   = (p.length > 13) ? p[13] : "";
        return f;
    }

    // Helper methods
    private static String clean(String v) {
        return (v != null) ? v.replace("~", " ").replace("\n", " ") : "";
    }
    private static double parseDouble(String s) {
        try { return Double.parseDouble(s); } catch (Exception e) { return 0; }
    }
    private static int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return 0; }
    }

    // ENCAPSULATION
    public String  getId()               { return id; }
    public void    setId(String v)       { this.id = v; }
    public String  getName()             { return name; }
    public void    setName(String v)     { this.name = v; }
    public String  getDescription()      { return description; }
    public void    setDescription(String v) { this.description = v; }
    public double  getPrice()            { return price; }
    public void    setPrice(double v)    { this.price = v; }
    public String  getCategory()         { return category; }
    public void    setCategory(String v) { this.category = v; }
    public String  getIngredients()      { return ingredients; }
    public void    setIngredients(String v) { this.ingredients = v; }
    public String  getPortionSize()      { return portionSize; }
    public void    setPortionSize(String v) { this.portionSize = v; }
    public String  getImageUrl()         { return imageUrl; }
    public void    setImageUrl(String v) { this.imageUrl = v; }
    public String  getCreatedAt()        { return createdAt; }
    public void    setCreatedAt(String v){ this.createdAt = v; }
    public int     getCalories()         { return calories; }
    public void    setCalories(int v)    { this.calories = v; }
    public int     getReviewCount()      { return reviewCount; }
    public void    setReviewCount(int v) { this.reviewCount = v; }
    public double  getRating()           { return rating; }
    public void    setRating(double v)   { this.rating = v; }
    public boolean isAvailable()         { return available; }
    public void    setAvailable(boolean v){ this.available = v; }
    public boolean isPopular()           { return popular; }
    public void    setPopular(boolean v) { this.popular = v; }
}



/**
 * MainCourse — INHERITANCE from FoodItem
 * POLYMORPHISM: getNutritionalInfo() returns protein/carb/fat breakdown
 */
class MainCourse extends FoodItem {
    public MainCourse() { super(); }

    // POLYMORPHISM: overrides abstract method from FoodItem
    @Override
    public String getFoodType() { return "MainCourse"; }

    // POLYMORPHISM: unique nutritional breakdown for main courses
    @Override
    public String getNutritionalInfo() {
        return String.format(
                "Calories: %d kcal | Protein: ~%dg | Carbs: ~%dg | Fat: ~%dg",
                getCalories(),
                (int)(getCalories() * 0.25 / 4),   // 25% from protein
                (int)(getCalories() * 0.50 / 4),   // 50% from carbs
                (int)(getCalories() * 0.25 / 9)    // 25% from fat
        );
    }
}

/**
 * Beverage — INHERITANCE from FoodItem
 * POLYMORPHISM: getNutritionalInfo() returns sugar/caffeine info
 */
class Beverage extends FoodItem {
    public Beverage() { super(); }

    // POLYMORPHISM: overrides abstract method from FoodItem
    @Override
    public String getFoodType() { return "Beverage"; }

    // POLYMORPHISM: unique nutritional breakdown for beverages
    @Override
    public String getNutritionalInfo() {
        String caffeine = (getCalories() > 150) ? "Moderate" : "Low";
        return String.format(
                "Calories: %d kcal | Sugar: ~%dg | Volume: %s | Caffeine: %s",
                getCalories(),
                (int)(getCalories() / 16),
                (getPortionSize() != null ? getPortionSize() : "—"),
                caffeine
        );
    }
}

/**
 * Dessert — INHERITANCE from FoodItem
 * POLYMORPHISM: getNutritionalInfo() returns sugar/saturated fat info
 */
class Dessert extends FoodItem {
    public Dessert() { super(); }

    // POLYMORPHISM: overrides abstract method from FoodItem
    @Override
    public String getFoodType() { return "Dessert"; }

    // POLYMORPHISM: unique nutritional breakdown for desserts
    @Override
    public String getNutritionalInfo() {
        return String.format(
                "Calories: %d kcal | Sugar: ~%dg | Sat. Fat: ~%dg | Serving: %s",
                getCalories(),
                (int)(getCalories() * 0.40 / 4),   // 40% from sugar
                (int)(getCalories() * 0.15 / 9),   // 15% from saturated fat
                (getPortionSize() != null ? getPortionSize() : "—")
        );
    }
}
