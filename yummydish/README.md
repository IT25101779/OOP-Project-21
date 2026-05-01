# Component 04 — Advanced Ordering (Group & Scheduled Orders)
## SE1020 Object-Oriented Programming | YummyDish — Online Food Delivery System

---

## My Files

| File | Description |
|------|-------------|
| `model/Order.java` | Base Order class (GroupOrder & ScheduledOrder extend this) |
| `util/FileStorageUtil.java` | File read/write utility (shared) |
| `servlet/Controllers.java` | Group order and scheduled order API endpoints |
| `views/group/index.jsp` | **Group Order Lobby/Room Page** |
| `views/schedule/index.jsp` | **Scheduled Order Date/Time Form** |
| `data/group_rooms.txt` | Group rooms data file |
| `data/scheduled_orders.txt` | Scheduled orders data file |

---

## OOP Concepts

### Inheritance
Both advanced order types logically extend the base `Order` class:
```
Order  (base class)
├── GroupOrder     → orderType = "GROUP"    → split payments per member
└── ScheduledOrder → orderType = "SCHEDULED" → scheduledFor field, 50% deposit
```
The `Order.java` `orderType` and `scheduledFor` fields implement this:
```java
private String orderType   = "STANDARD";   // "GROUP" or "SCHEDULED"
private String scheduledFor = "";          // e.g. "2024-12-25 14:00"
```

### Polymorphism
`processPayment()` logic differs per order type:
- **Standard** → full amount on delivery
- **Group** → each member pays their own subtotal  
- **Scheduled** → 50% deposit charged at booking, rest on delivery

---

## CRUD Operations

| Operation | Endpoint | Description |
|-----------|----------|-------------|
| **Create** | `POST /api/group/create` | Generates 6-digit room code → `group_rooms.txt` |
| **Create** | `POST /api/order` (orderType=SCHEDULED) | Books future order → `orders.txt` |
| **Read**   | `POST /api/group/join/{code}` | Reads room by code → members can join |
| **Update** | Members add items to room | Updates group cart items |
| **Delete** | `POST /api/scheduled-orders/{id}/cancel` | Cancels scheduled order |

---

## How to Run
```bash
cd yummydish && mvn spring-boot:run
```
- Group Orders: http://localhost:8080/group
- Scheduled Orders: http://localhost:8080/schedule  (must be logged in + have saved card)
