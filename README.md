# YummyDish — Component 05 — Delivery & Driver Tracking

## Project: SE1020 Object-Oriented Programming — Online Food Delivery System

**Full Project GitHub:** https://github.com/IT25101779/OOP-Project-21

---

## Component 05: Delivery & Driver Tracking

### Files You Own
| File | Purpose |
|------|---------|
| `driver/dashboard.jsp` | Driver Dashboard — live GPS map, order queue (nearest-first), in-app navigation |
| `driver/login.jsp` | Driver Login Page — separate from customer login |
| `activity/index.jsp` | User Activity Page — live order tracking, ETA countdown, driver map |
| `activity/order-detail.jsp` | Digital Receipt — order timeline, print, WhatsApp share |
| `maps.js` | Google Maps integration — geocoding, routing, live marker animation |
| `data/driver_locations.txt` | Driver GPS coordinates (updated in real time) |

### Backend Endpoints (in Controllers.java — explain these at viva)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/driver/dashboard` | GET | Shows READY + HANDOVER + ON_WAY orders |
| `/driver/pickup/{id}` | POST | Updates order to HANDOVER status |
| `/driver/delivering/{id}` | POST | Updates order to ON_WAY status |
| `/driver/delivered/{id}` | POST | Updates order to DELIVERED status |
| `/api/driver/location` | POST | Driver GPS posts location to driver_locations.txt |
| `/api/order/{id}/driver-location` | GET | Customer reads driver's real GPS position |
| `/api/weather` | GET | Real OpenWeatherMap API for weather surcharge |

### OOP Concepts Demonstrated
- **Encapsulation**: Driver contact info and GPS coordinates stored securely
- **Abstraction**: `haversine()` distance formula abstracts complex GPS maths into a simple `distanceKm(a, b)` call
- **Polymorphism**: Order status progression (`READY→HANDOVER→ON_WAY→DELIVERED`) uses polymorphic `statusBadge` and `statusProgress` methods

### CRUD Operations
- **Create**: Assign driver to order — writes driver details to order record
- **Read**: Driver reads READY orders; Customer reads real-time status every 6 seconds
- **Update**: Driver updates order status through each stage; GPS coordinates updated every 10 seconds
- **Delete**: Active delivery cleared from driver queue once DELIVERED


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
  src/main/webapp/WEB-INF/views/driver/dashboard.jsp
  src/main/webapp/WEB-INF/views/driver/login.jsp
  src/main/webapp/WEB-INF/views/activity/index.jsp
  src/main/webapp/WEB-INF/views/activity/order-detail.jsp
  src/main/webapp/js/maps.js
  data/driver_locations.txt
```

---

## Tech Stack
- Java 17 + Spring Boot 3.2
- JSP / JSTL (Jakarta EE 10)
- Bootstrap 5 + Inter/Fraunces fonts
- Google Maps API
- File-based storage (no database)
- Maven build system
