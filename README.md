# YummyDish — Online Food Delivery System

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


### Features
**Real-time order tracking** on the Orders page — status updates every 5 seconds via `/api/order/{id}` polling; live progress steps animate as order moves through states
**Live tracking map** per order — click "Show Live Map" to see a map with route from kitchen to delivery address, with simulated driver marker movement
**Pin-drop location picker** in Cart — click "Drop a Pin on Map" to open an interactive map; click anywhere to drop a delivery pin; address is auto-resolved via reverse geocoding
**Deliver to another address** — "Deliver to Another Address" toggle in Cart lets users enter a recipient name, phone, and a separate delivery address
**Admin: Drivers tab** — admin can create new driver accounts from the dashboard; drivers show in a dedicated tab with link to Driver Portal
**Recent Orders widget** on Account page — shows last 3 orders with live status
