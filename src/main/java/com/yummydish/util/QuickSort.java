package com.yummydish.util;

import com.yummydish.model.FoodItem;

import java.util.ArrayList;
import java.util.List;

public class QuickSort {

    public static void sortByPriceAscending(List<FoodItem> items) {
        if (items == null || items.size() <= 1) return;
        quickSort(items, 0, items.size() - 1, true);
    }
// Sort food items by price descending (most expensive first).
    
    public static void sortByPriceDescending(List<FoodItem> items) {
        if (items == null || items.size() <= 1) return;
        quickSort(items, 0, items.size() - 1, false);
    }

 
    public static List<FoodItem> sorted(List<FoodItem> items, boolean ascending) {
        if (items == null) return new ArrayList<>();
        List<FoodItem> copy = new ArrayList<>(items);
        if (copy.size() <= 1) return copy;
        quickSort(copy, 0, copy.size() - 1, ascending);
        return copy;
    }

    //  Core QuickSort (recursive, Lomuto partition)
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

    private static int partition(List<FoodItem> items, int lo, int hi, boolean ascending) {
        //  Median-of-three pivot selection 
        // Compare first, middle, and last elements; use the median as pivot.
        // This avoids O(n²) worst-case on sorted/reverse-sorted input.
        int mid = lo + (hi - lo) / 2;
        medianOfThree(items, lo, mid, hi, ascending);
        // After medianOfThree, items[hi] holds the median (pivot)
        double pivot = items.get(hi).getPrice();

        //  Lomuto partition
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

   
    private static void medianOfThree(List<FoodItem> items, int a, int b, int c, boolean ascending) {
        // Sort the three elements so items[a] ≤ items[b] ≤ items[c] (ascending)
        // or items[a] ≥ items[b] ≥ items[c] (descending)
        if (shouldSwapForSort(items, a, b, ascending)) swap(items, a, b);
        if (shouldSwapForSort(items, a, c, ascending)) swap(items, a, c);
        if (shouldSwapForSort(items, b, c, ascending)) swap(items, b, c);
        // Now items[b] is the median — move it to items[c] to serve as pivot
        swap(items, b, c);
    }

   
    private static boolean shouldSwapForSort(List<FoodItem> items, int i, int j, boolean ascending) {
        double pi = items.get(i).getPrice();
        double pj = items.get(j).getPrice();
        return ascending ? (pi > pj) : (pi < pj);
    }

    private static void swap(List<FoodItem> items, int i, int j) {
        if (i == j) return;
        FoodItem temp = items.get(i);
        items.set(i, items.get(j));
        items.set(j, temp);
    }
}
