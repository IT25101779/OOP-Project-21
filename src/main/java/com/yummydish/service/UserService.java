package com.yummydish.service;

import com.yummydish.model.User;
import com.yummydish.util.FileStorageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * UserService — CRUD operations for User accounts.
 * OOP: Encapsulation (private fields, service layer hides storage details)
 * CREATE: register()   READ: findByEmail(), findById(), getAllCustomers()
 * UPDATE: update(), changePassword()   DELETE: delete()
 */
@Service
public class UserService {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();
    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final FileStorageUtil fileStorage;

    @Autowired
    public UserService(FileStorageUtil fileStorage) {
        this.fileStorage = fileStorage;
    }

    // ── CREATE ─────────────────────────────────────────────────────
    public User register(String name, String email, String rawPassword,
                         String phone, String address,
                         String cardNumber, String cardHolder, String cardExpiry)
            throws IOException {
        if (findByEmail(email) != null)
            throw new IllegalArgumentException("An account with this email already exists.");
        User u = new User();
        u.setId("USR" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase());
        u.setName(name != null ? name.trim() : "");
        u.setEmail(email.toLowerCase().trim());
        u.setPasswordHash(ENCODER.encode(rawPassword));
        u.setPhone(phone != null ? phone.trim() : "");
        u.setAddress(address != null ? address.trim() : "");
        u.setRole("CUSTOMER");
        u.setCreatedAt(LocalDateTime.now().format(DTF));
        u.setCardNumber(cardNumber != null ? cardNumber.trim() : "");
        u.setCardHolder(cardHolder != null ? cardHolder.trim() : "");
        u.setCardExpiry(cardExpiry != null ? cardExpiry.trim() : "");
        u.setProfilePicUrl("");
        fileStorage.appendLine(fileStorage.getUsersFile(), u.toFileLine());
        return u;
    }

    // ── READ ───────────────────────────────────────────────────────
    public User findByEmail(String email) {
        if (email == null || email.isBlank()) return null;
        for (String line : fileStorage.readAll(fileStorage.getUsersFile())) {
            String[] p = line.split("\\|", -1);
            if (p.length > 2 && p[2].equalsIgnoreCase(email.trim())) return User.fromLine(line);
        }
        return null;
    }

    public User findById(String id) {
        String line = fileStorage.findById(fileStorage.getUsersFile(), id);
        return line != null ? User.fromLine(line) : null;
    }

    public List<User> getAllCustomers() {
        List<User> list = new ArrayList<>();
        for (String line : fileStorage.readAll(fileStorage.getUsersFile())) {
            String[] p = line.split("\\|", -1);
            if (p.length > 6 && "CUSTOMER".equals(p[6])) list.add(User.fromLine(line));
        }
        return list;
    }

    public List<User> getAllDrivers() {
        List<User> list = new ArrayList<>();
        for (String line : fileStorage.readAll(fileStorage.getUsersFile())) {
            String[] p = line.split("\\|", -1);
            if (p.length > 6 && "DRIVER".equals(p[6])) list.add(User.fromLine(line));
        }
        return list;
    }

    public User registerDriver(String name, String email, String rawPassword, String phone)
            throws IOException {
        if (findByEmail(email) != null)
            throw new IllegalArgumentException("An account with this email already exists.");
        User u = new User();
        u.setId("DRV" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase());
        u.setName(name != null ? name.trim() : "");
        u.setEmail(email.toLowerCase().trim());
        u.setPasswordHash(ENCODER.encode(rawPassword));
        u.setPhone(phone != null ? phone.trim() : "");
        u.setAddress("");
        u.setRole("DRIVER");
        u.setCreatedAt(LocalDateTime.now().format(DTF));
        u.setCardNumber(""); u.setCardHolder(""); u.setCardExpiry(""); u.setProfilePicUrl("");
        fileStorage.appendLine(fileStorage.getUsersFile(), u.toFileLine());
        return u;
    }

    // ── UPDATE ─────────────────────────────────────────────────────
    public boolean update(String userId, String name, String phone, String address,
                          String cardNumber, String cardHolder, String cardExpiry)
            throws IOException {
        User u = findById(userId);
        if (u == null) return false;
        if (name != null && !name.isBlank())       u.setName(name.trim());
        if (phone != null && !phone.isBlank())     u.setPhone(phone.trim());
        if (address != null && !address.isBlank()) u.setAddress(address.trim());
        if (cardNumber != null) u.setCardNumber(cardNumber.trim());
        if (cardHolder != null) u.setCardHolder(cardHolder.trim());
        if (cardExpiry != null) u.setCardExpiry(cardExpiry.trim());
        return fileStorage.update(fileStorage.getUsersFile(), userId, u.toFileLine());
    }

    public boolean updateProfilePic(String userId, String picUrl) throws IOException {
        User u = findById(userId);
        if (u == null) return false;
        u.setProfilePicUrl(picUrl != null ? picUrl : "");
        return fileStorage.update(fileStorage.getUsersFile(), userId, u.toFileLine());
    }

    /** Polymorphism: overloaded update — changes only password after verification */
    public boolean changePassword(String userId, String currentRaw, String newRaw) throws IOException {
        User u = findById(userId);
        if (u == null) return false;
        if (!ENCODER.matches(currentRaw, u.getPasswordHash())) return false;
        u.setPasswordHash(ENCODER.encode(newRaw));
        return fileStorage.update(fileStorage.getUsersFile(), userId, u.toFileLine());
    }

    // ── DELETE ─────────────────────────────────────────────────────
    public boolean delete(String userId) throws IOException {
        return fileStorage.delete(fileStorage.getUsersFile(), userId);
    }

    // ── AUTH ───────────────────────────────────────────────────────
    public User authenticate(String email, String rawPassword) {
        User u = findByEmail(email);
        if (u == null) return null;
        String hash = u.getPasswordHash();
        if (hash == null || hash.isBlank()) return null;
        if (rawPassword.startsWith("SOCIAL_")) return null;
        return ENCODER.matches(rawPassword, hash) ? u : null;
    }
}
