# Component 06 — Post-Order Feedback & Reporting
## SE1020 Object-Oriented Programming | YummyDish — Online Food Delivery System

---

## My Files

| File | Description |
|------|-------------|
| `model/Feedback.java` | **Feedback model** — review text, rating, admin reply |
| `util/FileStorageUtil.java` | **Core file I/O** — readAll, findById, update, appendLine, delete |
| `servlet/Controllers.java` | Feedback API, admin report endpoint |
| `views/reviews/index.jsp` | **Review & Rating Submission Page** |
| `views/admin/dashboard.jsp` | **Admin Report Moderation Panel** — reply to reviews |
| `views/admin/report.jsp` | **Automated Daily Bill / Report View** |
| `views/activity/order-detail.jsp` | **Digital Bill View** — print, WhatsApp share |
| `views/about/index.jsp` | About Us Page |
| `views/contact/index.jsp` | Contact & FAQ Page |
| `css/yummydish.css` | Complete UI design system — dark mode, animations |
| `js/app.js` | Core JS — notifications, sound alerts, toast messages |
| `data/feedback.txt` | Reviews and feedback data file |
| `data/contacts.txt` | Contact form submissions |

---

## OOP Concepts

### Encapsulation
`Feedback.java` keeps all review data private:
```java
private String id, orderId, customerId, customerName;
private String text, foodItemId, foodItemName;
private String adminReply, createdAt, type;
private int    rating;

public String getText()       { return text; }
public int    getRating()     { return rating; }
public String getAdminReply() { return adminReply; }
```

### Inheritance
Two types of feedback inherit from the base `Feedback` class:
```
Feedback  (base)
├── PublicReview  → type = "REVIEW"  → shown publicly on food pages
└── AdminReport   → type = "REPORT"  → shown only in admin panel
```
Both use the same `Feedback.java` class — `type` field determines behaviour.

### Polymorphism
Display format differs based on feedback type:
- **REVIEW** → shown publicly with stars on food detail page + reviews page
- **REPORT** → shown privately in admin moderation panel only

### File Handling (FileStorageUtil.java)
This is the **core data layer** of the entire project:
```java
public List<String> readAll(String file)               // Read all lines
public String       findById(String file, String id)   // Find one record
public void         appendLine(String file, String line) // Create new record
public void         update(String file, String id, String newLine) // Update record
public void         delete(String file, String id)     // Delete record
```

---

## CRUD Operations

| Operation | Endpoint | Description |
|-----------|----------|-------------|
| **Create** | `POST /api/feedback` | Submits review → `feedback.txt` |
| **Read**   | `GET /api/food/{id}/reviews` | Loads reviews for food detail page |
| **Update** | `POST /admin/feedback/reply` | Admin adds reply → updates `feedback.txt` |
| **Delete** | Admin can remove review | `FileStorageUtil.delete()` |

---

## How to Run
```bash
cd yummydish && mvn spring-boot:run
```
- Reviews: http://localhost:8080/reviews
- Admin Panel: http://localhost:8080/admin/login  (admin@yummydish.com / admin123)
- Daily Report: http://localhost:8080/admin/report
