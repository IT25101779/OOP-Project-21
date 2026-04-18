# YummyDish — Component 04 — Advanced Ordering (Group & Scheduled Orders)

## Project: SE1020 Object-Oriented Programming — Online Food Delivery System

**Full Project GitHub:** https://github.com/IT25101779/OOP-Project-21

---

## Component 04: Advanced Ordering — Group & Scheduled Orders

### Files You Own
| File | Purpose |
|------|---------|
| `group/index.jsp` | Group Order Page — create/join room, share 6-digit code, add items, checkout |
| `schedule/index.jsp` | Scheduled Order Page — date/time picker, 50% deposit, My Schedules tab |
| `data/group_rooms.txt` | Sample group rooms data file |
| `data/scheduled_orders.txt` | Sample scheduled orders data file |

### Backend Endpoints (in Controllers.java — explain these at viva)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/group/create` | POST | Generates 6-digit room code, writes to group_rooms.txt |
| `/api/group/join/{code}` | POST | Reads room details, allows member to join |
| `/api/group/room/{code}/details` | GET | Returns all items in a group room |
| `/api/scheduled-orders` | GET | Lists user's scheduled orders |
| `/api/scheduled-orders/{id}/cancel` | POST | Cancels a scheduled order |
| `/api/order` with `orderType=SCHEDULED` | POST | Books a scheduled order with 50% deposit |

### OOP Concepts Demonstrated
- **Inheritance**: `GroupOrder` and `ScheduledOrder` logically extend the base `Order` class — `orderType` field and `scheduledFor` field demonstrate this
- **Polymorphism**: `processPayment()` — group orders split between members, scheduled orders charge 50% deposit upfront
- **Encapsulation**: Room code and member list kept private within group room record

### CRUD Operations
- **Create**: Create room → `group_rooms.txt`; Book schedule → `orders.txt` + `scheduled_orders.txt`
- **Read**: Join room by code; View my scheduled orders
- **Update**: Members add items to group cart; deposit status updated
- **Delete**: Cancel group room; Cancel scheduled order (with window check)


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
  src/main/webapp/WEB-INF/views/group/index.jsp
  src/main/webapp/WEB-INF/views/schedule/index.jsp
  data/group_rooms.txt
  data/scheduled_orders.txt
```

---

## Tech Stack
- Java 17 + Spring Boot 3.2
- JSP / JSTL (Jakarta EE 10)
- Bootstrap 5 + Inter/Fraunces fonts
- Google Maps API
- File-based storage (no database)
- Maven build system
