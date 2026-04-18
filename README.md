# YummyDish — Component 06 — Post-Order Feedback & Reporting / UI & UX

## Project: SE1020 Object-Oriented Programming — Online Food Delivery System

**Full Project GitHub:** https://github.com/IT25101779/OOP-Project-21

---

## Component 06: Post-Order Feedback & Reporting + UI/UX Design

### Files You Own
| File | Purpose |
|------|---------|
| `Feedback.java` | Feedback model — Encapsulation of reviews, admin replies, ratings |
| `FileStorageUtil.java` | Core file I/O utility — readAll, findById, update, appendLine, CRLF fix |
| `admin/dashboard.jsp` | Admin Dashboard — Kanban board, live order management, user/food/driver CRUD |
| `admin/login.jsp` | Admin Login Page |
| `admin/report.jsp` | Printable Daily Sales Report |
| `about/index.jsp` | About Us Page — hero, stats, values, Google Maps embed |
| `contact/index.jsp` | Contact Page — contact cards, message form, FAQ accordion |
| `yummydish.css` | Complete professional stylesheet — dark mode, animations, glassmorphism |
| `app.js` | Core JS — Cart, Favs, Sound, Push Notifications, Pollers, Skeleton Loaders |
| `data/feedback.txt` | Sample reviews/feedback data |

### Backend Endpoints (in Controllers.java — explain these at viva)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/dashboard` | GET | All orders, users, foods, feedback, revenue stats |
| `/admin/food/add` | POST | Add food item (Create) |
| `/admin/food/update` | POST | Edit food item (Update) |
| `/admin/food/delete` | POST | Remove food item (Delete) |
| `/admin/feedback/reply` | POST | Admin replies to review (Update) |
| `/admin/offer/add` | POST | Add promo code (Create) |
| `/admin/report` | GET | Daily report with top items + payment breakdown |
| `/api/feedback` | POST | Submit review (Create) |
| `/api/food/{id}/reviews` | GET | Read reviews for food item |

### OOP Concepts Demonstrated
- **Encapsulation**: `Feedback` class — private `text`, `rating`, `adminReply` with getters/setters
- **Inheritance**: `PublicReview` and `AdminReport` logically inherit from `Feedback` (common `text` and `createdAt` fields)
- **Polymorphism**: `displayFormat()` differs for public reviews (star rating shown) vs admin reports (moderation actions shown)
- **File Handling**: `FileStorageUtil` demonstrates full file I/O — `readAll()`, `findById()`, `update()`, `appendLine()`, `delete()`


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
  src/main/java/com/yummydish/model/Feedback.java
  src/main/java/com/yummydish/util/FileStorageUtil.java
  src/main/java/com/yummydish/model/Offer.java
  src/main/webapp/WEB-INF/views/admin/dashboard.jsp
  src/main/webapp/WEB-INF/views/admin/login.jsp
  src/main/webapp/WEB-INF/views/admin/report.jsp
  src/main/webapp/WEB-INF/views/about/index.jsp
  src/main/webapp/WEB-INF/views/contact/index.jsp
  src/main/webapp/css/yummydish.css
  src/main/webapp/js/app.js
  data/feedback.txt
```

---

## Tech Stack
- Java 17 + Spring Boot 3.2
- JSP / JSTL (Jakarta EE 10)
- Bootstrap 5 + Inter/Fraunces fonts
- Google Maps API
- File-based storage (no database)
- Maven build system
