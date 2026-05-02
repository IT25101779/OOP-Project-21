package com.yummydish.service;

import com.yummydish.model.Offer;
import com.yummydish.util.FileStorageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * OfferService — CRUD for promo codes.
 * CREATE: add()    READ: getAll(), getActive(), findByCode(), validateCode()
 * DELETE: delete()
 */
@Service
public class OfferService {

    private final FileStorageUtil fileStorage;

    @Autowired
    public OfferService(FileStorageUtil fileStorage) {
        this.fileStorage = fileStorage;
    }

    // ── READ ──────────────────────────────────────────────────────
    public List<Offer> getAll() {
        return fileStorage.readAll(fileStorage.getOffersFile()).stream()
            .map(Offer::fromLine)
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    public List<Offer> getActive() {
        return getAll().stream()
            .filter(Offer::isActive)
            .collect(Collectors.toList());
    }

    public Offer findByCode(String code) {
        if (code == null || code.isBlank()) return null;
        String line = fileStorage.findById(fileStorage.getOffersFile(), code.toUpperCase());
        return line != null ? Offer.fromLine(line) : null;
    }

    /**
     * Validate a promo code against a subtotal.
     * Returns a map with: valid (boolean), discount (double), message (String)
     */
    public Map<String, Object> validateCode(String code, double subtotal) {
        Map<String, Object> result = new LinkedHashMap<>();
        Offer offer = findByCode(code);

        if (offer == null || !offer.isActive()) {
            result.put("valid",   false);
            result.put("message", "Invalid promo code.");
            return result;
        }
        if (subtotal < offer.getMinOrderAmount()) {
            result.put("valid",   false);
            result.put("message", "Minimum order LKR " +
                Math.round(offer.getMinOrderAmount()) + " required for this offer.");
            return result;
        }

        double discount = offer.calculateDiscount(subtotal);
        result.put("valid",    true);
        result.put("discount", discount);
        result.put("code",     offer.getCode());
        result.put("percent",  (int) offer.getDiscountPercent());
        result.put("message",  offer.getTitle() + " applied! You save LKR " +
            Math.round(discount));
        return result;
    }

    // ── CREATE ────────────────────────────────────────────────────
    public boolean add(Offer offer) throws IOException {
        fileStorage.appendLine(fileStorage.getOffersFile(), offer.toFileLine());
        return true;
    }

    // ── DELETE ────────────────────────────────────────────────────
    public boolean delete(String code) throws IOException {
        return fileStorage.delete(fileStorage.getOffersFile(), code);
    }
}
