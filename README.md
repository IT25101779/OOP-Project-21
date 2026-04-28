# Component 05 — Delivery & Driver Tracking
## SE1020 Object-Oriented Programming | YummyDish — Online Food Delivery System

---

## My Files

| File | Description |
|------|-------------|
| `model/Order.java` | Order model — status constants, statusBadge, statusProgress |
| `util/FileStorageUtil.java` | File read/write utility (shared) |
| `servlet/Controllers.java` | `DriverController`, driver location API endpoints |
| `views/driver/dashboard.jsp` | **Driver Dashboard** — GPS map, order queue, in-app navigation |
| `views/driver/login.jsp` | Driver Login Page |
| `views/activity/index.jsp` | **User Activity / Ongoing Orders Page** — live tracking |
| `views/activity/order-detail.jsp` | **Digital Receipt / Order Status Page** |
| `js/maps.js` | Google Maps — routing, GPS, live marker animation |
| `data/driver_locations.txt` | Real-time driver GPS coordinates file |

---

## OOP Concepts

### Encapsulation
Driver contact details and GPS stored privately in Order:
```java
private String driverId, driverName, driverContact;
```
Driver locations file stores: `driverId|lat|lng|timestamp`

### Abstraction
`maps.js` abstracts all GPS complexity into simple methods:
```javascript
YDMaps.initMap(elementId, lat, lng, zoom)
YDMaps.drawRoute(map, originLat, originLng, destLat, destLng, callback)
YDMaps.animateMarkerTo(marker, newLat, newLng, steps)
```

### Polymorphism
Order `statusBadge` and `statusProgress` return different values per status:
```java
public String getStatusBadge() {
    return switch(status) {
        case COOKING   -> "🍳 Cooking";
        case READY     -> "📦 Ready";
        case ON_WAY    -> "🛵 On the Way";
        case DELIVERED -> "✅ Delivered";
        default        -> "⏳ Pending";
    };
}
```

---

## CRUD Operations

| Operation | Endpoint | Description |
|-----------|----------|-------------|
| **Create** | Driver assigned to order | `driverName`, `driverId` written to `orders.txt` |
| **Read**   | `GET /api/order/{id}/driver-location` | Customer reads driver GPS position |
| **Update** | `POST /driver/pickup/{id}` | Status: READY → HANDOVER |
| **Update** | `POST /driver/delivering/{id}` | Status: HANDOVER → ON_WAY |
| **Update** | `POST /driver/delivered/{id}` | Status: ON_WAY → DELIVERED |
| **Delete** | Auto-cleared from queue after DELIVERED | — |

---

## How to Run
```bash
cd yummydish && mvn spring-boot:run
```
- Driver Login: http://localhost:8080/driver/login  (driver@yummydish.com / driver123)
- Customer tracking: http://localhost:8080/activity
