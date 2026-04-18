package com.yummydish.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import jakarta.annotation.PostConstruct;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

@Component
public class FileStorageUtil {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();

    @Value("${app.data.dir:data}")        private String dataDir;
    @Value("${app.data.users:data/users.txt}")             private String usersFile;
    @Value("${app.data.food-items:data/food_items.txt}")   private String foodItemsFile;
    @Value("${app.data.orders:data/orders.txt}")           private String ordersFile;
    @Value("${app.data.feedback:data/feedback.txt}")       private String feedbackFile;
    @Value("${app.data.scheduled-orders:data/scheduled_orders.txt}") private String scheduledOrdersFile;
    @Value("${app.data.group-rooms:data/group_rooms.txt}") private String groupRoomsFile;
    @Value("${app.data.offers:data/offers.txt}")           private String offersFile;
    @Value("${app.data.contacts:data/contacts.txt}")       private String contactsFile;
    @Value("${app.data.driver-locations:data/driver_locations.txt}") private String driverLocationsFile;

    @PostConstruct
    public void init() throws IOException {
        Files.createDirectories(Paths.get(dataDir));
        for (String f : new String[]{usersFile,foodItemsFile,ordersFile,feedbackFile,
                scheduledOrdersFile,groupRoomsFile,offersFile,contactsFile,driverLocationsFile}) {
            if (!Files.exists(Paths.get(f))) Files.createFile(Paths.get(f));
        }
        fixLineEndings();
        seedData();
    }

    private void fixLineEndings() {
        for (String f : new String[]{usersFile,foodItemsFile,ordersFile,feedbackFile,
                scheduledOrdersFile,groupRoomsFile,offersFile,contactsFile}) {
            try {
                Path p = Paths.get(f);
                if (!Files.exists(p)) continue;
                String content = new String(Files.readAllBytes(p), StandardCharsets.UTF_8);
                if (content.contains("\r")) {
                    Files.write(p, content.replace("\r\n","\n").replace("\r","\n")
                            .getBytes(StandardCharsets.UTF_8));
                }
            } catch (IOException ignored) {}
        }
    }

    public synchronized List<String> readAll(String file) {
        List<String> lines = new ArrayList<>();
        try (BufferedReader r = Files.newBufferedReader(Paths.get(file), StandardCharsets.UTF_8)) {
            String line;
            while ((line = r.readLine()) != null) { line = line.trim(); if (!line.isBlank()) lines.add(line); }
        } catch (IOException ignored) {}
        return lines;
    }

    public String findById(String file, String id) {
        for (String l : readAll(file)) if (firstField(l).equals(id)) return l;
        return null;
    }

    public List<String> search(String file, String term) {
        List<String> r = new ArrayList<>();
        String low = term.toLowerCase();
        for (String l : readAll(file)) if (l.toLowerCase().contains(low)) r.add(l);
        return r;
    }

    public synchronized void appendLine(String file, String line) throws IOException {
        Path p = Paths.get(file);
        Files.createDirectories(p.getParent());
        try (BufferedWriter w = Files.newBufferedWriter(p, StandardCharsets.UTF_8,
                StandardOpenOption.CREATE, StandardOpenOption.APPEND)) {
            w.write(line); w.newLine();
        }
    }

    public synchronized boolean update(String file, String id, String newLine) throws IOException {
        List<String> lines = readAll(file); boolean found = false;
        List<String> out = new ArrayList<>();
        for (String l : lines) {
            if (firstField(l).equals(id)) { out.add(newLine); found = true; } else out.add(l);
        }
        if (found) writeAll(file, out);
        return found;
    }

    public synchronized boolean delete(String file, String id) throws IOException {
        List<String> lines = readAll(file); int before = lines.size();
        lines.removeIf(l -> firstField(l).equals(id));
        if (lines.size() < before) { writeAll(file, lines); return true; }
        return false;
    }

    private String firstField(String l) {
        if (l.contains("~")) return l.split("~")[0];
        if (l.contains("|")) return l.split("\\|")[0];
        return l;
    }

    private synchronized void writeAll(String file, List<String> lines) throws IOException {
        try (BufferedWriter w = Files.newBufferedWriter(Paths.get(file), StandardCharsets.UTF_8,
                StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING)) {
            for (String l : lines) { w.write(l); w.newLine(); }
        }
    }

    public String getUsersFile()           { return usersFile; }
    public String getFoodItemsFile()       { return foodItemsFile; }
    public String getOrdersFile()          { return ordersFile; }
    public String getFeedbackFile()        { return feedbackFile; }
    public String getScheduledOrdersFile() { return scheduledOrdersFile; }
    public String getGroupRoomsFile()      { return groupRoomsFile; }
    public String getOffersFile()          { return offersFile; }
    public String getContactsFile()        { return contactsFile; }
    public String getDriverLocationsFile() { return driverLocationsFile; }

    private void seedData() throws IOException {
        ensureSystemAccount("ADMIN001","Admin User","admin@yummydish.com","admin123","0771234567","Colombo 03","ADMIN");
        ensureSystemAccount("DRIVER001","Kasun Perera","driver@yummydish.com","driver123","0714567890","Colombo 05","DRIVER");

        if (readAll(offersFile).isEmpty()) {
            appendLine(offersFile, "FIRST20|New User Deal|20% off your first order|20.0|0.0|true|2024-01-01");
            appendLine(offersFile, "LUNCH15|Lunch Special|15% off all lunch items|15.0|0.0|true|2024-01-01");
            appendLine(offersFile, "FAMILY30|Family Feast|30% off orders above LKR 4000|30.0|4000.0|true|2024-01-01");
            appendLine(offersFile, "SAVE10|Save 10|10% off any order|10.0|0.0|true|2024-01-01");
        }

        if (readAll(foodItemsFile).isEmpty()) {
            String[][] foods = {
                {"FD001","Grilled Chicken Burger","Juicy grilled chicken with lettuce and secret sauce on a brioche bun.","1250","Lunch","Chicken breast,Brioche bun,Lettuce,Tomato,Secret sauce,Pickles","300g","520","true","true","4.8","234","https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80","2024-01-01","MainCourse"},
                {"FD002","Margherita Pizza","Classic pizza with San Marzano tomato sauce and fresh mozzarella.","1850","Dinner","Pizza dough,San Marzano tomatoes,Mozzarella,Fresh basil,Olive oil","400g","720","true","true","4.9","412","https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80","2024-01-01","MainCourse"},
                {"FD003","Eggs Benedict","Poached eggs on English muffin with Canadian bacon and hollandaise.","980","Breakfast","Eggs,English muffin,Canadian bacon,Hollandaise sauce,Chives","280g","450","true","false","4.7","189","https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=500&q=80","2024-01-01","MainCourse"},
                {"FD004","Beef Tacos x3","Three soft tortillas with seasoned beef, pico de gallo and guacamole.","1100","Lunch","Corn tortillas,Ground beef,Pico de gallo,Guacamole,Sour cream","350g","610","true","true","4.6","301","https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&q=80","2024-01-01","MainCourse"},
                {"FD005","Acai Power Bowl","Thick acai with banana, granola, fresh berries and honey drizzle.","890","Breakfast","Acai,Banana,Granola,Mixed berries,Honey,Coconut flakes","320g","380","true","false","4.5","145","https://images.unsplash.com/photo-1490323948606-3d20e9acf1a1?w=500&q=80","2024-01-01","MainCourse"},
                {"FD006","Pasta Carbonara","Spaghetti with crispy pancetta, egg yolk sauce and Pecorino Romano.","1450","Dinner","Spaghetti,Pancetta,Egg yolks,Pecorino Romano,Black pepper","380g","680","true","true","4.9","523","https://images.unsplash.com/photo-1612874742237-6526221588e3?w=500&q=80","2024-01-01","MainCourse"},
                {"FD007","Caesar Salad","Romaine with grilled chicken, Caesar dressing and Parmesan shavings.","1050","Lunch","Romaine lettuce,Grilled chicken,Caesar dressing,Croutons,Parmesan","300g","390","true","false","4.4","198","https://images.unsplash.com/photo-1512852939750-1305098529bf?w=500&q=80","2024-01-01","MainCourse"},
                {"FD008","Chocolate Lava Cake","Warm dark chocolate cake with molten center and vanilla ice cream.","750","Others","Dark chocolate,Butter,Eggs,Flour,Vanilla ice cream","200g","540","true","true","4.8","367","https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=80","2024-01-01","Dessert"},
                {"FD009","Mango Lassi","Refreshing yogurt drink with Alphonso mango, cardamom and rose water.","450","Others","Alphonso mango,Greek yogurt,Cardamom,Rose water,Sugar","350ml","210","true","false","4.3","112","https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=500&q=80","2024-01-01","Beverage"},
                {"FD010","BBQ Ribs Platter","Slow-smoked baby back ribs with BBQ sauce, coleslaw and fries.","2400","Dinner","Baby back ribs,BBQ sauce,Coleslaw,Fries","600g","1100","true","true","4.7","289","https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80","2024-01-01","MainCourse"},
                {"FD011","Avocado Toast","Sourdough with smashed avocado, poached egg, feta and bagel spice.","820","Breakfast","Sourdough bread,Avocado,Poached egg,Feta","250g","420","true","false","4.5","176","https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=500&q=80","2024-01-01","MainCourse"},
                {"FD012","Pad Thai","Rice noodles with shrimp, tofu, bean sprouts and tamarind sauce.","1300","Lunch","Rice noodles,Shrimp,Tofu,Bean sprouts,Peanuts,Tamarind sauce","380g","560","true","true","4.6","244","https://images.unsplash.com/photo-1559314809-0d155014e29e?w=500&q=80","2024-01-01","MainCourse"}
            };
            for (String[] f : foods) appendLine(foodItemsFile, String.join("~", f));
        }
    }

    private void ensureSystemAccount(String id, String name, String email,
                                     String rawPassword, String phone,
                                     String address, String role) throws IOException {
        String newHash = ENCODER.encode(rawPassword);
        List<String> lines = readAll(usersFile);
        boolean found = false;
        List<String> out = new ArrayList<>();
        for (String l : lines) {
            String[] p = l.split("\\|", -1);
            if (p.length > 0 && p[0].equals(id)) {
                // Always refresh the hash so credentials are guaranteed to work
                p[3] = newHash;
                out.add(String.join("|", p));
                found = true;
            } else {
                out.add(l);
            }
        }
        if (!found) {
            out.add(String.join("|", id, name, email, newHash, phone, address, role, "2024-01-01", "", "", "", ""));
        }
        writeAll(usersFile, out);
    }
}
