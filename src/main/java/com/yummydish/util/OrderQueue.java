package com.yummydish.util;

import com.yummydish.model.Order;
import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;
import java.util.Queue;
import java.util.ArrayList;

/**
 * OrderQueue — Data Structure: Queue (FIFO)
 *
 * Manages order processing in strict arrival sequence using Java's Queue interface
 * backed by an ArrayDeque (double-ended queue, O(1) enqueue/dequeue).
 *
 * FIFO guarantees:
 *   enqueue()  — new order joins the back of the queue  (O(1))
 *   dequeue()  — next order to process leaves the front (O(1))
 *   peek()     — inspect front order without removing   (O(1))
 *   size()     — current queue depth                    (O(1))
 *
 * Used by: placeOrder() → enqueues every new STANDARD order
 *          Admin dashboard → reads queue to display processing order
 *          Status updates  → dequeues when order moves to COOKING
 */
@Component
public class OrderQueue {

    // ── Core Queue backed by ArrayDeque for O(1) enqueue/dequeue ──
    private final Queue<Order> queue = new ArrayDeque<>();

    // ── Singleton lock for thread-safe access ─────────────────────
    private final Object lock = new Object();

    /**
     * Enqueue — add a new order to the back of the processing queue.
     * Called immediately after a new order is persisted to file.
     *
     * @param order the newly placed Order
     */
    public void enqueue(Order order) {
        if (order == null) return;
        synchronized (lock) {
            queue.offer(order);   // offer() is Queue's non-throwing add
        }
    }

    /**
     * Dequeue — remove and return the front (oldest) order for processing.
     * Called when the kitchen starts cooking an order (status → COOKING).
     *
     * @return the next Order to process, or null if queue is empty
     */
    public Order dequeue() {
        synchronized (lock) {
            return queue.poll();   // poll() returns null if empty (safe)
        }
    }

    /**
     * Peek — inspect the next order without removing it.
     * Used to display which order the kitchen should handle next.
     *
     * @return the front Order, or null if queue is empty
     */
    public Order peek() {
        synchronized (lock) {
            return queue.peek();
        }
    }

    /**
     * Remove a specific order from the queue by ID.
     * Used when an order is cancelled before it enters the kitchen.
     *
     * @param orderId the order ID to remove
     * @return true if the order was found and removed
     */
    public boolean removeById(String orderId) {
        if (orderId == null) return false;
        synchronized (lock) {
            return queue.removeIf(o -> orderId.equals(o.getOrderId()));
        }
    }

    /**
     * Restore queue from persistent storage on application startup.
     * Loads all PENDING orders so the queue survives server restarts.
     *
     * @param pendingOrders list of PENDING orders in arrival order
     */
    public void restoreFromStorage(List<Order> pendingOrders) {
        synchronized (lock) {
            queue.clear();
            if (pendingOrders != null) {
                pendingOrders.forEach(queue::offer);
            }
        }
    }

    /**
     * Size — current number of orders waiting to be processed.
     *
     * @return queue depth
     */
    public int size() {
        synchronized (lock) {
            return queue.size();
        }
    }

    /**
     * isEmpty — check if queue has any pending orders.
     *
     * @return true if no orders are waiting
     */
    public boolean isEmpty() {
        synchronized (lock) {
            return queue.isEmpty();
        }
    }

    /**
     * Snapshot — get an ordered read-only view of the entire queue.
     * Used by the admin dashboard to display all queued orders in sequence.
     * Does NOT modify the queue.
     *
     * @return unmodifiable list of queued orders (front → back)
     */
    public List<Order> snapshot() {
        synchronized (lock) {
            return Collections.unmodifiableList(new ArrayList<>(queue));
        }
    }

    /**
     * Clear — empty the entire queue.
     * Used when all pending orders have been processed.
     */
    public void clear() {
        synchronized (lock) {
            queue.clear();
        }
    }

    @Override
    public String toString() {
        synchronized (lock) {
            return "OrderQueue{size=" + queue.size() + ", front=" +
                   (queue.isEmpty() ? "empty" : queue.peek().getOrderId()) + "}";
        }
    }
}
