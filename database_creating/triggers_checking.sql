SHOW TRIGGERS FROM photo_center;

-- apply_discount_for_large_orders
INSERT INTO orders (id_branch, id_employee, id_client, id_product, id_format_type, id_paper_type, id_payment_type, order_status, order_place, order_type, order_date, completion_date, number_photos, discount, price) VALUES
(1, 1, 1, 1, 1, 2, 1, "Завершен", "Киоск", "Несрочный", "2025-04-20 10:00:00", "2025-04-22 12:00:00", 11, 0.0, 500.00);
SELECT * FROM orders;
DELETE FROM orders WHERE id_order = 26;
ALTER TABLE orders AUTO_INCREMENT = 26;
SELECT * FROM orders;

-- update_sale_status_to_completed
UPDATE sales
SET sale_status = "Оплачен"
WHERE id_sale = 13;
SELECT * FROM sales;

-- merge_product_quantity_on_duplicate
SELECT * FROM products_in_sales;
INSERT INTO products_in_sales (id_sale, id_product, quantity) VALUES
(16, 9, 2);

-- update_order_price_on_photo_change
SELECT * FROM orders;
UPDATE orders
SET number_photos = 9
WHERE id_order = 25;
SELECT * FROM orders;

-- prevent_urgent_orders_in_kiosk
INSERT INTO orders (id_branch, id_employee, id_client, id_product, id_format_type, id_paper_type, id_payment_type, order_status, order_place, order_type, order_date, completion_date, number_photos, discount, price) VALUES
(1, 1, 1, 1, 1, 2, 1, "Завершен", "Киоск", "Срочный", "2025-04-20 10:00:00", "2025-04-22 12:00:00", 5, 0.05, 500.00);
