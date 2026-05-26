package com.yummydish.util;

import com.yummydish.model.Order;
import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;
import java.util.Queue;
import java.util.ArrayList;


@Component
public class OrderQueue {

    //  Core Queue backed by ArrayDeque for O(1) enqueue/dequeue
    private final Queue<Order> queue = new ArrayDeque<>();

    // ─Singleton lock for thread-safe access
    private final Object lock = new Object();

   
    public void enqueue(Order order) {
        if (order == null) return;
        synchronized (lock) {
            queue.offer(order);   // offer() is Queue's non-throwing add
        }
    }

   
    public Order dequeue() {
        synchronized (lock) {
            return queue.poll();   // poll() returns null if empty (safe)
        }
    }

   
    public Order peek() {
        synchronized (lock) {
            return queue.peek();
        }
    }

  
    public boolean removeById(String orderId) {
        if (orderId == null) return false;
        synchronized (lock) {
            return queue.removeIf(o -> orderId.equals(o.getOrderId()));
        }
    }

    
    public void restoreFromStorage(List<Order> pendingOrders) {
        synchronized (lock) {
            queue.clear();
            if (pendingOrders != null) {
                pendingOrders.forEach(queue::offer);
            }
        }
    }

  
    public int size() {
        synchronized (lock) {
            return queue.size();
        }
    }

   
    public boolean isEmpty() {
        synchronized (lock) {
            return queue.isEmpty();
        }
    }

    
    public List<Order> snapshot() {
        synchronized (lock) {
            return Collections.unmodifiableList(new ArrayList<>(queue));
        }
    }

   
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
