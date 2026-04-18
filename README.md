# YummyDish — Component 01 — User & Authentication Management

## Project: SE1020 Object-Oriented Programming — Online Food Delivery System

**Full Project GitHub:** https://github.com/IT25101779/OOP-Project-21

---

## Component 01: User & Authentication Management

### Files You Own
| File | Purpose |
|------|---------|
| `User.java` | User model — Encapsulation of user data (passwords, card info) with getters/setters. Inheritance base: Customer/Admin/Driver roles. |
| `UserService.java` | CRUD: register (Create), findByEmail/findById (Read), update (Update), delete (Delete) |
| `YummyDishApplication.java` | Spring Boot entry point, data file seeder |
| `auth/login.jsp` | User Login Page with Google Sign-In |
| `auth/signup.jsp` | User Registration Page |
| `auth/forgot.jsp` | Forgot Password Page |
| `account/profile.jsp` | User Profile — view/edit details, loyalty points, saved cards |
| `layout/header.jsp` | Shared navigation (maintained by this member) |
| `layout/footer.jsp` | Shared footer (maintained by this member) |

### OOP Concepts Demonstrated
- **Encapsulation**: `User` class — private fields (`passwordHash`, `cardNumber`, `loyaltyPoints`) with public getters/setters only
- **Inheritance**: `User` class is the base. Role field (`CUSTOMER`/`ADMIN`/`DRIVER`) enables polymorphic role behaviour. `getDashboardUrl()` demonstrates polymorphism.
- **Polymorphism**: `socialLogin()` vs standard email/password authentication use different validation paths

### CRUD Operations
- **Create**: `POST /signup` → `UserService.register()` → writes to `users.txt`
- **Read**: `POST /login` → `UserService.authenticate()` → reads `users.txt`
- **Update**: `POST /account/update` → `UserService.update()` → updates `users.txt`
- **Delete**: `POST /account/delete` → `UserService.delete()` → removes from `users.txt`


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
  src/main/java/com/yummydish/model/User.java
  src/main/java/com/yummydish/service/UserService.java
  src/main/java/com/yummydish/YummyDishApplication.java
  src/main/webapp/WEB-INF/views/auth/login.jsp
  src/main/webapp/WEB-INF/views/auth/signup.jsp
  src/main/webapp/WEB-INF/views/auth/forgot.jsp
  src/main/webapp/WEB-INF/views/account/profile.jsp
  src/main/webapp/WEB-INF/views/layout/header.jsp
  src/main/webapp/WEB-INF/views/layout/footer.jsp
```

---

## Tech Stack
- Java 17 + Spring Boot 3.2
- JSP / JSTL (Jakarta EE 10)
- Bootstrap 5 + Inter/Fraunces fonts
- Google Maps API
- File-based storage (no database)
- Maven build system
