package com.yummydish.service;

import com.yummydish.model.FoodItem;
import com.yummydish.util.FileStorageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

import com.yummydish.util.QuickSort;

/**
 * FoodItemService — CRUD operations for menu items.
 * CREATE: add()       READ: getAll(), getById(), getByCategory(), search(), sortedByPrice()
 * UPDATE: update(), toggleAvailability()    DELETE: delete()
 *
 * Sorting uses a custom QuickSort implementation (O(n log n) average)
 * instead of Java's built-in Collections.sort(), fulfilling the
 * QuickSort data-structures requirement.
 */
@Service
public class FoodItemService {

    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final FileStorageUtil fileStorage;

    @Autowired
    public FoodItemService(FileStorageUtil fileStorage) {
        this.fileStorage = fileStorage;
    }

    // ── CREATE ────────────────────────────────────────────────────
    public FoodItem add(String name, String description, double price,
                        String category, String ingredients, String portionSize,
                        int calories, String imageUrl, String foodType) throws IOException {

        String id  = "FD" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        String now = LocalDateTime.now().format(DTF);
        String line = String.join("~",
            id, name, description, String.valueOf(price), category,
            (ingredients != null ? ingredients : ""),
            (portionSize != null ? portionSize : "—"),
            String.valueOf(calories),
            "true", "false", "0.0", "0",
            (imageUrl != null ? imageUrl : ""),
            now,
            (foodType != null ? foodType : "MainCourse"));

        FoodItem item = FoodItem.fromLine(line);
        fileStorage.appendLine(fileStorage.getFoodItemsFile(), item.toFileLine());
        return item;
    }

    // ── READ ──────────────────────────────────────────────────────
    public List<FoodItem> getAll() {
        return fileStorage.readAll(fileStorage.getFoodItemsFile()).stream()
            .map(FoodItem::fromLine)
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    public List<FoodItem> getAvailable() {
        return getAll().stream()
            .filter(FoodItem::isAvailable)
            .collect(Collectors.toList());
    }

    public FoodItem getById(String id) {
        String line = fileStorage.findById(fileStorage.getFoodItemsFile(), id);
        return line != null ? FoodItem.fromLine(line) : null;
    }

    public List<FoodItem> getByCategory(String category) {
        return getAvailable().stream()
            .filter(f -> f.getCategory() != null && f.getCategory().equalsIgnoreCase(category))
            .collect(Collectors.toList());
    }

    public List<FoodItem> search(String term) {
        return fileStorage.search(fileStorage.getFoodItemsFile(), term).stream()
            .map(FoodItem::fromLine)
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    /**
     * Sort available food items by price using QuickSort algorithm.
     * QuickSort average O(n log n) — see com.yummydish.util.QuickSort for full details.
     *
     * @param ascending true = cheapest first, false = most expensive first
     * @return new sorted list of available items
     */
    public List<FoodItem> sorted(boolean ascending) {
        List<FoodItem> items = getAvailable();
        // ── QuickSort (custom implementation, not Java's built-in sort) ──
        QuickSort.sortByPriceAscending(items);
        if (!ascending) {
            // Reverse the ascending result for descending order
            // (avoids a second full sort pass)
            java.util.Collections.reverse(items);
        }
        return items;
    }

    /**
     * Convenience: sort by price ascending using QuickSort.
     */
    public List<FoodItem> sortedByPriceLowToHigh() {
        return sorted(true);
    }

    /**
     * Convenience: sort by price descending using QuickSort.
     */
    public List<FoodItem> sortedByPriceHighToLow() {
        return sorted(false);
    }

    // ── UPDATE ────────────────────────────────────────────────────
    public boolean update(String id, String name, String description, double price,
                          String category, String ingredients, String portionSize,
                          int calories, boolean available, String imageUrl) throws IOException {
        FoodItem f = getById(id);
        if (f == null) return false;
        f.setName(name);
        f.setDescription(description);
        f.setPrice(price);
        f.setCategory(category);
        f.setIngredients(ingredients);
        f.setPortionSize(portionSize);
        f.setCalories(calories);
        f.setAvailable(available);
        if (imageUrl != null && !imageUrl.isBlank()) f.setImageUrl(imageUrl);
        return fileStorage.update(fileStorage.getFoodItemsFile(), id, f.toFileLine());
    }

    public boolean toggleAvailability(String id) throws IOException {
        FoodItem f = getById(id);
        if (f == null) return false;
        f.setAvailable(!f.isAvailable());
        return fileStorage.update(fileStorage.getFoodItemsFile(), id, f.toFileLine());
    }

    // ── DELETE ────────────────────────────────────────────────────
    public boolean delete(String id) throws IOException {
        return fileStorage.delete(fileStorage.getFoodItemsFile(), id);
    }
}
