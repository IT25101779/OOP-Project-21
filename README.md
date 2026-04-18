# YummyDish — Component 03 — Cart & Standard Checkout Processing

## Project: SE1020 Object-Oriented Programming — Online Food Delivery System

**Full Project GitHub:** https://github.com/IT25101779/OOP-Project-21

---

## Component 03: Cart & Standard Checkout Processing

### Files You Own
| File | Purpose |
|------|---------|
| `Order.java` | Order model — CartItem inner class, price calculation, status constants, file serialisation |
| `Offer.java` | Promo code model — discount calculation |
| `OfferService.java` | CRUD for offers: add, validate, delete |
| `checkout/cart.jsp` | Persistent Shopping Cart — live map, saved locations, tip, promo codes |
| `checkout/thank-you.jsp` | Order Success Page — confetti, ETA countdown, live step tracking |
| `index.jsp` | Home/Landing Page — hero, popular items, how-it-works |
| `data/orders.txt` | Sample orders data file |
| `data/offers.txt` | Sample promo codes data file |

### OOP Concepts Demonstrated
- **Encapsulation**: `Order` class wraps item list, totals, status — private with getters/setters
- **Polymorphism**: `calculateFinalPrice()` behaviour differs — COD adds fee, Card applies loyalty discount
- **Inner Class**: `Order.CartItem` is a static inner class demonstrating nested class OOP concept

### CRUD Operations
- **Create**: `POST /api/order` → `buildOrder()` → writes to `orders.txt`
- **Read**: `GET /api/order/{id}` → reads current order status
- **Update**: Cart items updated in localStorage; `POST /api/validate-offer` validates promo
- **Delete**: `Cart.remove(id)` removes item from cart (localStorage)


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
  src/main/java/com/yummydish/model/Order.java
  src/main/java/com/yummydish/model/Offer.java
  src/main/java/com/yummydish/service/OfferService.java
  src/main/webapp/WEB-INF/views/checkout/cart.jsp
  src/main/webapp/WEB-INF/views/checkout/thank-you.jsp
  src/main/webapp/WEB-INF/views/index.jsp
  data/orders.txt
  data/offers.txt
```

---

## Tech Stack
- Java 17 + Spring Boot 3.2
- JSP / JSTL (Jakarta EE 10)
- Bootstrap 5 + Inter/Fraunces fonts
- Google Maps API
- File-based storage (no database)
- Maven build system
