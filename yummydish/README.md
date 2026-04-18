# YummyDish — Online Food Delivery System

## 🚀 How to Run

### Prerequisites
- Java 17+
- Maven 3.8+
- IntelliJ IDEA (recommended)

### Run with Maven
```bash
cd yummydish
mvn spring-boot:run
```

Then open: **http://localhost:8080**

---

## 🔑 Login Credentials

### Customer
- Register a new account at `/signup`
- Or use any existing customer account

### Admin Portal → `/admin/login`
| Email | Password |
|-------|----------|
| admin@yummydish.com | **admin123** |

### Driver Portal → `/driver/login`
| Email | Password |
|-------|----------|
| driver@yummydish.com | **driver123** |

> **Note:** Credentials are automatically re-seeded on every startup, so they always work even if `data/users.txt` is deleted.

---

## ✅ Changes Made (v2)

### Bug Fixes
1. **Driver tab removed** from customer navbar — customers no longer see the Driver link
2. **Admin & Driver login fixed** — passwords are guaranteed via on-startup hash refresh
3. **Account section fixed** — Edit Profile form posts correctly; success/error messages display properly; Change Password modal added
4. **Windows line endings (CRLF)** in data files auto-fixed on startup — was causing login parse failures

### New Features
5. **Real-time order tracking** on the Orders page — status updates every 5 seconds via `/api/order/{id}` polling; live progress steps animate as order moves through states
6. **Live tracking map** per order — click "Show Live Map" to see a map with route from kitchen to delivery address, with simulated driver marker movement
7. **Pin-drop location picker** in Cart — click "Drop a Pin on Map" to open an interactive map; click anywhere to drop a delivery pin; address is auto-resolved via reverse geocoding
8. **Deliver to another address** — "Deliver to Another Address" toggle in Cart lets users enter a recipient name, phone, and a separate delivery address
9. **Use My Location button** in Cart and Account — one-click GPS location fill
10. **Change Password** modal on Account page — verifies current password before allowing change
11. **Admin: Drivers tab** — admin can create new driver accounts from the dashboard; drivers show in a dedicated tab with link to Driver Portal
12. **Recent Orders widget** on Account page — shows last 3 orders with live status

### Data
- All data files auto-converted from CRLF to LF on startup
- `users.txt` is cleared and re-seeded on first run so passwords are guaranteed correct

---

## 📁 Data Files (in `/data/`)
| File | Purpose |
|------|---------|
| users.txt | All users (CUSTOMER, ADMIN, DRIVER) |
| food_items.txt | Menu items |
| orders.txt | All placed orders |
| feedback.txt | Reviews and reports |
| offers.txt | Promo codes |
| group_rooms.txt | Group order rooms |
| scheduled_orders.txt | Scheduled orders |
| driver_locations.txt | Live driver GPS positions |

---

## 🗺️ Google Maps
The API key is already set in `application.properties`. To use real GPS:
1. Go to Google Cloud Console
2. Enable: Maps JavaScript API, Places API, Directions API, Geocoding API
3. Add `http://localhost:8080/*` as an allowed referrer

