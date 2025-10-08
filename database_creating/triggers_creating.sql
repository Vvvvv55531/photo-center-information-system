DELIMITER $$

CREATE TRIGGER prevent_urgent_orders_in_kiosk
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_type = "Срочный" AND NEW.order_place = "Киоск" THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Срочные заказы могут быть сделаны только в филиале";
    END IF;
END $$


CREATE TRIGGER apply_discount_for_large_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.number_photos > 10 THEN
        SET NEW.discount = 0.10; -- Применяем скидку 10%
    END IF;
END $$


CREATE TRIGGER update_sale_status_to_completed
BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    IF NEW.sale_status = "Оплачен" THEN
        SET NEW.sale_status = "Завершен";
    END IF;
END $$


CREATE TRIGGER update_products_price_on_sale
AFTER INSERT ON products_in_sales
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(11,2);

    SELECT SUM(p.price * ps.quantity)
    INTO total
    FROM products_in_sales ps
    JOIN products p ON ps.id_product = p.id_product
    WHERE ps.id_sale = NEW.id_sale;

    UPDATE sales
    SET price = total
    WHERE id_sale = NEW.id_sale;
END $$


CREATE TRIGGER update_order_price_on_photo_change
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.number_photos != NEW.number_photos THEN
        SET NEW.price = NEW.number_photos * (
            SELECT price FROM products WHERE id_product = NEW.id_product
        );
    END IF;
END $$

DELIMITER ;
