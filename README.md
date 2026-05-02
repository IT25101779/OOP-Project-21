# Component 01 — User & Authentication Management
## SE1020 Object-Oriented Programming | YummyDish — Online Food Delivery System

---

## My Files

| File | Description |
|------|-------------|
| `model/User.java` | **User model** — base class for Customer, Admin, Driver |
| `service/UserService.java` | **CRUD operations** for user management |
| `util/FileStorageUtil.java` | File read/write utility (shared) |
| `YummyDishApplication.java` | Spring Boot entry point |
| `servlet/Controllers.java` | `AuthController`, `AccountController` sections |
| `views/auth/login.jsp` | **User Login Page** |
| `views/auth/signup.jsp` | **User Registration Page** |
| `views/auth/forgot.jsp` | Forgot Password Page |
| `views/account/profile.jsp` | User Profile Page |
| `views/layout/header.jsp` | Shared navigation header |
| `views/layout/footer.jsp` | Shared footer |
| `data/users.txt` | User data file |

---

## OOP Concepts

### Encapsulation
`User.java` keeps all sensitive fields **private** — passwords, card numbers, loyalty points.
Only accessible via getters/setters:
```java
private String passwordHash;
private String cardNumber;
private int    loyaltyPoints;

public String getPasswordHash() { return passwordHash; }
public void   setLoyaltyPoints(int v) { this.loyaltyPoints = v; }
```

### Inheritance
`User` is the **base class**. Role field distinguishes Customer / Admin / Driver:
```java
public String getDashboardUrl() {
    if ("ADMIN".equals(role))  return "/admin/dashboard";
    if ("DRIVER".equals(role)) return "/driver/dashboard";
    return "/menu";
}
```

### Polymorphism
Two different authentication paths — standard email login vs simulated social login:
- `POST /login`         → email + password validation
- `POST /social-login`  → name + email from Google credential (no password needed)

---

## CRUD Operations

| Operation | Endpoint | Method in Code |
|-----------|----------|----------------|
| **Create** | `POST /signup` | `UserService.register()` → writes to `users.txt` |
| **Read**   | `POST /login`  | `UserService.authenticate()` → reads `users.txt` |
| **Update** | `POST /account/update` | `UserService.update()` → rewrites line in `users.txt` |
| **Delete** | `POST /account/delete` | `UserService.delete()` → removes line from `users.txt` |

---

## How to Run
```bash
cd yummydish && mvn spring-boot:run
```
- Login: http://localhost:8080/login
- Signup: http://localhost:8080/signup
- Profile: http://localhost:8080/account
