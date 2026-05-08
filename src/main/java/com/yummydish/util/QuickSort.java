package com.yummydish.util;

import com.yummydish.model.FoodItem;

import java.util.ArrayList;
import java.util.List;

/**
 * QuickSort — Algorithm: QuickSort (Divide and Conquer)
 *
 * Sorts food items by price using the classic QuickSort algorithm.
 * Chosen because menu items need dynamic sorting on every user request
 * and QuickSort's average-case O(n log n) outperforms alternatives
 * for the typical menu size (10–200 items).
 *
 * Algorithm details:
 *   - Strategy:   Divide and Conquer — pick a pivot, partition around it
 *   - Pivot:      Median-of-three (first, middle, last) to avoid O(n²)
 *                 worst-case on already-sorted or reverse-sorted input
 *   - Partition:  Lomuto scheme — cleaner code, same O(n) partition cost
 *   - Base case:  Lists of 0 or 1 element are already sorted (return immediately)
 *   - Recursion:  Sort left partition (< pivot) + right partition (> pivot)
 *
 * Time complexity:
 *   Best case:    O(n log n) — balanced partitions
 *   Average case: O(n log n) — expected with random data
 *   Worst case:   O(n²)      — mitigated by median-of-three pivot
 *
 * Space complexity: O(log n) — recursion stack depth
 *
 * Used by: FoodItemService.sortedByPrice() → called from menu API endpoint
 *          whenever user selects "Price: Low to High" or "High to Low"
 */
public class QuickSort {

    // ── Public entry points ───────────────────────────────────────

    /**
     * Sort food items by price ascending (cheapest first).
     *
     * @param items list of FoodItem to sort (modified in-place)
     */
    public static void sortByPriceAscending(List<FoodItem> items) {
        if (items == null || items.size() <= 1) return;
        quickSort(items, 0, items.size() - 1, true);
    }

    /**
     * Sort food items by price descending (most expensive first).
     *
     * @param items list of FoodItem to sort (modified in-place)
     */
    public static void sortByPriceDescending(List<FoodItem> items) {
        if (items == null || items.size() <= 1) return;
        quickSort(items, 0, items.size() - 1, false);
    }

    /**
     * Return a new sorted list without modifying the original.
     *
     * @param items     source list (not modified)
     * @param ascending true for cheapest first, false for most expensive first
     * @return new sorted list
     */
    public static List<FoodItem> sorted(List<FoodItem> items, boolean ascending) {
        if (items == null) return new ArrayList<>();
        List<FoodItem> copy = new ArrayList<>(items);
        if (copy.size() <= 1) return copy;
        quickSort(copy, 0, copy.size() - 1, ascending);
        return copy;
    }

    // ── Core QuickSort (recursive, Lomuto partition) ──────────────

    /**
     * Recursive QuickSort on a subarray from index lo to hi (inclusive).
     *
     * @param items     the list being sorted in-place
     * @param lo        left boundary index
     * @param hi        right boundary index
     * @param ascending sort direction
     */
    private static void quickSort(List<FoodItem> items, int lo, int hi, boolean ascending) {
        // Base case: subarray of 0 or 1 element — already sorted
        if (lo >= hi) return;

        // Partition: place pivot in its final sorted position,
        // return the pivot's index
        int pivotIdx = partition(items, lo, hi, ascending);

        // Recursively sort left partition (elements before pivot)
        quickSort(items, lo, pivotIdx - 1, ascending);

        // Recursively sort right partition (elements after pivot)
        quickSort(items, pivotIdx + 1, hi, ascending);
    }

    /**
     * Lomuto partition scheme.
     *
     * Selects a pivot using median-of-three strategy, moves all elements
     * that belong before the pivot to the left, and places the pivot
     * in its final sorted position.
     *
     * @param items     list being partitioned
     * @param lo        left boundary
     * @param hi        right boundary (pivot ends up here after median swap)
     * @param ascending sort direction
     * @return final index of the pivot element
     */
    private static int partition(List<FoodItem> items, int lo, int hi, boolean ascending) {
        // ── Median-of-three pivot selection ──────────────────────
        // Compare first, middle, and last elements; use the median as pivot.
        // This avoids O(n²) worst-case on sorted/reverse-sorted input.
        int mid = lo + (hi - lo) / 2;
        medianOfThree(items, lo, mid, hi, ascending);
        // After medianOfThree, items[hi] holds the median (pivot)
        double pivot = items.get(hi).getPrice();

        // ── Lomuto partition ──────────────────────────────────────
        // i tracks the boundary between "less than pivot" and "greater than pivot"
        int i = lo - 1;

        for (int j = lo; j < hi; j++) {
            double current = items.get(j).getPrice();
            // For ascending: move elements smaller than pivot to left
            // For descending: move elements larger than pivot to left
            boolean shouldSwap = ascending
                ? current <= pivot
                : current >= pivot;

            if (shouldSwap) {
                i++;
                swap(items, i, j);
            }
        }

        // Place pivot in its correct final position
        int pivotFinalIdx = i + 1;
        swap(items, pivotFinalIdx, hi);
        return pivotFinalIdx;
    }

    /**
     * Median-of-three: sort items at indices a, b, c so that
     * items[c] holds the median value (used as pivot).
     *
     * @param items     the list
     * @param a         first index
     * @param b         middle index
     * @param c         last index (will hold median after this call)
     * @param ascending sort direction (determines what "median" means)
     */
    private static void medianOfThree(List<FoodItem> items, int a, int b, int c, boolean ascending) {
        // Sort the three elements so items[a] ≤ items[b] ≤ items[c] (ascending)
        // or items[a] ≥ items[b] ≥ items[c] (descending)
        if (shouldSwapForSort(items, a, b, ascending)) swap(items, a, b);
        if (shouldSwapForSort(items, a, c, ascending)) swap(items, a, c);
        if (shouldSwapForSort(items, b, c, ascending)) swap(items, b, c);
        // Now items[b] is the median — move it to items[c] to serve as pivot
        swap(items, b, c);
    }

    /**
     * Returns true if items at indices i and j are out of order
     * for the given sort direction.
     */
    private static boolean shouldSwapForSort(List<FoodItem> items, int i, int j, boolean ascending) {
        double pi = items.get(i).getPrice();
        double pj = items.get(j).getPrice();
        return ascending ? (pi > pj) : (pi < pj);
    }

    /**
     * Swap two elements in the list.
     *
     * @param items list to modify
     * @param i     first index
     * @param j     second index
     */
    private static void swap(List<FoodItem> items, int i, int j) {
        if (i == j) return;
        FoodItem temp = items.get(i);
        items.set(i, items.get(j));
        items.set(j, temp);
    }
}
