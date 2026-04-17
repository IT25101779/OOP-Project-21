package com.yummydish;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class YummyDishApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder app) {
        return app.sources(YummyDishApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(YummyDishApplication.class, args);
        System.out.println("\n========================================");
        System.out.println("  🍽️  YummyDish is running!");
        System.out.println("  👉  http://localhost:8080");
        System.out.println("  🔑  admin@yummydish.com / admin123");
        System.out.println("========================================\n");
    }
}
