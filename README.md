# YummyDish — Component 02 — Food Catalog & Menu Management

## Project: SE1020 Object-Oriented Programming — Online Food Delivery System

**Full Project GitHub:** https://github.com/IT25101779/OOP-Project-21

---

## Component 02: Food Catalog & Menu Management

### Files You Own
| File | Purpose |
|------|---------|
| `FoodItem.java` | Abstract base class + MainCourse/Beverage/Dessert subclasses. Inheritance & Abstraction. |
| `FoodItemService.java` | CRUD: add, getAll, search, update, toggleAvailability, delete |
| `menu/index.jsp` | Main Menu Dashboard — category filter, live AJAX search, food grid |
| `menu/food-detail.jsp` | Food Item Detail Page — nutrition, reviews, add to cart |
| `reviews/index.jsp` | Public Reviews Page — rating bars, filter by stars |
| `data/food_items.txt` | Sample data file for demonstration |

### OOP Concepts Demonstrated
- **Encapsulation**: `FoodItem` stores `name`, `price`, `ingredients`, `nutritionalInfo` as private fields
- **Inheritance**: `MainCourse extends FoodItem`, `Beverage extends FoodItem`, `Dessert extends FoodItem`
- **Abstraction**: Abstract methods `getNutritionalInfo()` and `getFoodType()` — each subclass implements differently

### CRUD Operations
- **Create**: Admin adds food item via `POST /admin/food/add`
- **Read**: `GET /menu` + `GET /api/foods?search=&category=` → `FoodItemService.search()`
- **Update**: Admin edits via `POST /admin/food/update`, toggle availability `/admin/food/toggle`
- **Delete**: `POST /admin/food/delete` → removes from `food_items.txt`


---

## How to Run the Full Project

```bash
# Requirements: Java 17+, Maven
cd yummydish
mvn spring-boot:run
```
Open: http://localhost:8080

**Default credentials:**
- Admin: `admin@yummydish.com` / `admin123` → http://localhost:8080/admin/login
- Driver: `driver@yummydish.com` / `driver123` → http://localhost:8080/driver/login
- Customer: Register at http://localhost:8080/signup

---

## My Primary Files (highlighted contribution)

```
  src/main/java/com/yummydish/model/FoodItem.java
  src/main/java/com/yummydish/service/FoodItemService.java
  src/main/webapp/WEB-INF/views/menu/index.jsp
  src/main/webapp/WEB-INF/views/menu/food-detail.jsp
  src/main/webapp/WEB-INF/views/reviews/index.jsp
  data/food_items.txt
```

---

## Tech Stack
- Java 17 + Spring Boot 3.2
- JSP / JSTL (Jakarta EE 10)
- Bootstrap 5 + Inter/Fraunces fonts
- Google Maps API
- File-based storage (no database)
- Maven build system
