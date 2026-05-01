# Component 02 — Food Catalog & Menu Management
## SE1020 Object-Oriented Programming | YummyDish — Online Food Delivery System

---

## My Files

| File | Description |
|------|-------------|
| `model/FoodItem.java` | **Abstract FoodItem class** + MainCourse, Beverage, Dessert subclasses |
| `service/FoodItemService.java` | **CRUD operations** for food items |
| `util/FileStorageUtil.java` | File read/write utility (shared) |
| `servlet/Controllers.java` | `MenuController`, `AdminAuthController` (food sections) |
| `views/menu/index.jsp` | **Main Menu Dashboard** — search, filter, food grid |
| `views/menu/food-detail.jsp` | **Food Item Detail Page** — ingredients, nutrition, reviews |
| `views/admin/dashboard.jsp` | **Admin Menu Management Panel** |
| `views/admin/login.jsp` | Admin Login Page |
| `data/food_items.txt` | Food items data file |

---

## OOP Concepts

### Encapsulation
`FoodItem.java` stores all food details as **private fields**:
```java
private String id, name, description, category;
private double price;
private int    calories;
private String ingredients, portionSize;
private boolean available, popular;
```

### Inheritance
Abstract base class with three concrete subclasses:
```
FoodItem  (abstract)
├── MainCourse   → getFoodType() returns "MainCourse"
├── Beverage     → getFoodType() returns "Beverage"  
└── Dessert      → getFoodType() returns "Dessert"
```

### Abstraction
`FoodItem` declares **abstract methods** that each subclass must implement:
```java
public abstract String getFoodType();
public abstract String getNutritionalInfo();
```

---

## CRUD Operations

| Operation | Endpoint | Method |
|-----------|----------|--------|
| **Create** | `POST /admin/food/add`    | `FoodItemService.add()` → appends to `food_items.txt` |
| **Read**   | `GET /menu`               | `FoodItemService.getAll()`, `search()`, `getByCategory()` |
| **Update** | `POST /admin/food/update` | `FoodItemService.update()` → rewrites line |
| **Delete** | `POST /admin/food/delete` | `FoodItemService.delete()` → removes line |

---

## How to Run
```bash
cd yummydish && mvn spring-boot:run
```
- Menu: http://localhost:8080/menu
- Admin Panel: http://localhost:8080/admin/login  (admin@yummydish.com / admin123)
