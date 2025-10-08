DELIMITER $$

CREATE PROCEDURE GetOrderStatistics (
    IN start_date DATE, 
    IN end_date DATE
)
BEGIN
	IF start_date IS NULL OR end_date IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Дата начала или дата окончания не могут быть NULL";
    END IF;
	
    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;

    SELECT 
        b.address AS branch,
        SUM(o.order_place = "Филиал") AS orders_in_branch,
        SUM(o.order_place = "Киоск") AS orders_in_kiosk,
        COUNT(o.id_order) AS total_orders
    FROM orders o
    JOIN branches b ON o.id_branch = b.id_branch
    WHERE o.order_date BETWEEN start_date AND end_date
    GROUP BY b.id_branch
    UNION ALL
    SELECT 
        "Всего по фотоцентру" AS branch,
        SUM(o.order_place = "Филиал") AS orders_in_branch,
        SUM(o.order_place = "Киоск") AS orders_in_kiosk,
        COUNT(o.id_order) AS total_orders
    FROM orders o
    WHERE o.order_date BETWEEN start_date AND end_date;
END $$


CREATE PROCEDURE GetOrdersByBranch (
    IN branch_id INT,
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF branch_id IS NULL OR start_date IS NULL OR end_date IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Филиал, дата начала или дата окончания не могут быть NULL";
    END IF;

    IF NOT EXISTS (SELECT 1 FROM branches WHERE id_branch = branch_id) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Указанный филиал не существует в базе данных";
    END IF;

    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;

    SELECT
        p.id_product,
        p.product_name,
        o.order_type,
        "Филиал" AS order_place,
        COUNT(o.id_order) AS order_count,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    JOIN products p ON o.id_product = p.id_product
    WHERE o.id_branch = branch_id
        AND o.order_place = "Филиал"
        AND o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type, p.id_product
    UNION ALL
    SELECT
        p.id_product,
        p.product_name,
        o.order_type,
        "Киоск" AS order_place,
        COUNT(o.id_order) AS order_count,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    JOIN products p ON o.id_product = p.id_product
    WHERE o.id_branch = branch_id
        AND o.order_place = "Киоск"
        AND o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type, p.id_product

    ORDER BY order_place, order_type DESC, id_product;

END $$


CREATE PROCEDURE GetRevenueByBranch (
    IN branch_id INT,
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF branch_id IS NULL OR start_date IS NULL OR end_date IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Филиал, дата начала или дата окончания не могут быть NULL";
    END IF;

    IF NOT EXISTS (SELECT 1 FROM branches WHERE id_branch = branch_id) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Указанный филиал не существует в базе данных";
    END IF;

    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;

    SELECT
        p.id_product,
        p.product_name,
        o.order_type,
        "Филиал" AS order_place,
        SUM(o.price) AS order_sum,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    JOIN products p ON o.id_product = p.id_product
    WHERE o.id_branch = branch_id
        AND o.order_place = "Филиал"
        AND o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type, p.id_product
    UNION ALL
    SELECT
        p.id_product,
        p.product_name,
        o.order_type,
        "Киоск" AS order_place,
        SUM(o.price) AS order_sum,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    JOIN products p ON o.id_product = p.id_product
    WHERE o.id_branch = branch_id
        AND o.order_place = "Киоск"
        AND o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type, p.id_product

    ORDER BY order_place, order_type DESC, id_product;

END $$


CREATE PROCEDURE GetPrintedPhotosByBranch (
    IN branch_id INT,
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF branch_id IS NULL OR start_date IS NULL OR end_date IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Филиал, дата начала или дата окончания не могут быть NULL";
    END IF;

    IF NOT EXISTS (SELECT 1 FROM branches WHERE id_branch = branch_id) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Указанный филиал не существует в базе данных";
    END IF;

    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;

    SELECT
        "Филиал" AS order_place,
        o.order_type,
        SUM(o.number_photos) AS total_photos,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    WHERE o.id_branch = branch_id
        AND o.order_place = "Филиал"
        AND o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type
    UNION ALL
    SELECT
        "Киоск" AS order_place,
        o.order_type,
        SUM(o.number_photos) AS total_photos,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    WHERE o.id_branch = branch_id
        AND o.order_place = "Киоск"
        AND o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type
    UNION ALL
    SELECT
        "Всего по фотоцентру" AS order_place,
        o.order_type,
        SUM(o.number_photos) AS total_photos,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    WHERE o.order_date BETWEEN start_date AND end_date
    GROUP BY o.order_type

    ORDER BY order_place DESC, order_type DESC;

END $$


CREATE PROCEDURE GetAvgSalesByCategories (
    IN category1 VARCHAR(45),
    IN category2 VARCHAR(45),
    IN category3 VARCHAR(45)
)
BEGIN
    IF category1 IS NULL OR category2 IS NULL OR category3 IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Категории не могут быть NULL";
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM products
        WHERE product_name IN (category1, category2, category3)
    ) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Ни одна из указанных категорий не найдена в базе данных";
    END IF;

    SELECT
        p.id_product,
        p.product_name,
        p.product_type AS category,
        ROUND(AVG(s.price), 2) AS avg_sale_price,
        COUNT(s.id_sale) AS total_sales
    FROM products p
    INNER JOIN products_in_sales ps ON p.id_product = ps.id_product
    INNER JOIN sales s ON ps.id_sale = s.id_sale
    WHERE p.product_name IN (category1, category2, category3)
    GROUP BY p.id_product
    UNION ALL
    SELECT
        p.id_product,
        p.product_name,
        p.product_type AS category,
        ROUND(AVG(o.price), 2) AS avg_sale_price,
        COUNT(o.id_order) AS total_sales
    FROM products p
    INNER JOIN orders o ON p.id_product = o.id_product
    WHERE p.product_name IN (category1, category2, category3)
    GROUP BY p.id_product

    ORDER BY id_product;

END $$


CREATE PROCEDURE GetClientsDiscountsByBranch (
    IN branch_id INT
)
BEGIN
    IF branch_id IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Идентификатор филиала не может быть NULL";
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM branches WHERE id_branch = branch_id
    ) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Филиал с указанным id не найден";
    END IF;

    SELECT 
        c.id_client,
        c.client_name,
        c.discount AS client_discount,
        SUM(o.price) AS total_order_value
    FROM clients c
    JOIN orders o ON c.id_client = o.id_client
    WHERE o.id_branch = branch_id
        AND o.discount > 0
    GROUP BY c.id_client;

END $$


CREATE PROCEDURE GetPopularProductsByBranch (
	IN branch_id INT
)
BEGIN
    IF branch_id IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Идентификатор филиала не может быть NULL";
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM branches WHERE id_branch = branch_id
    ) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Филиал с указанным id не найден";
    END IF;

    SELECT 
        p.id_product,
        p.product_name,
        SUM(ps.quantity) AS total_sales,
        "Филиал" AS sales_place
    FROM products p
    JOIN products_in_sales ps ON p.id_product = ps.id_product
    JOIN sales s ON ps.id_sale = s.id_sale
    WHERE p.product_type = "Товар"
        AND s.id_branch = branch_id
    GROUP BY p.id_product
    UNION ALL
    SELECT 
        p.id_product,
        p.product_name,
        SUM(ps.quantity) AS total_sales,
        "Фотоцентр" AS sales_place
    FROM products p
    JOIN products_in_sales ps ON p.id_product = ps.id_product
    JOIN sales s ON ps.id_sale = s.id_sale
    WHERE p.product_type = "Товар"
    GROUP BY p.id_product
    ORDER BY sales_place, total_sales DESC;

END $$


CREATE PROCEDURE GetAvgOrderTime (
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF start_date IS NULL OR end_date IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Параметры start_date и end_date не могут быть NULL";
    END IF;

    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;
    
    SELECT 
        b.address AS branch,
        o.order_type,
        ROUND(AVG(TIMESTAMPDIFF(MINUTE, o.order_date, o.completion_date))) AS avg_completion_time_minutes
    FROM orders o
    JOIN branches b ON o.id_branch = b.id_branch
    WHERE o.order_date BETWEEN start_date AND end_date
      AND o.order_status = "Завершен"
    GROUP BY b.address, o.order_type
    UNION ALL
    SELECT 
        "Всего по фотоцентру" AS branch,
        o.order_type,
        ROUND(AVG(TIMESTAMPDIFF(MINUTE, o.order_date, o.completion_date))) AS avg_completion_time_minutes
    FROM orders o
    WHERE o.order_date BETWEEN start_date AND end_date
      AND o.order_status = "Завершен"
    GROUP BY o.order_type
    ORDER BY branch DESC, order_type DESC;

END $$


CREATE PROCEDURE GetTopClientsBySales (
    IN kiosk_id INT,
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF start_date IS NULL OR end_date IS NULL OR kiosk_id IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Параметры start_date, end_date и kiosk_id не могут быть NULL";
    END IF;

    IF NOT EXISTS (SELECT 1 FROM branches WHERE id_branch = kiosk_id) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Указанный киоск не существует в базе данных";
    END IF;
	
    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;

    SELECT 
        c.id_client,
        c.client_name,
        COUNT(s.id_sale) AS total_sales,
        "Киоск" AS sales_place
    FROM sales s
    JOIN clients c ON s.id_client = c.id_client
    JOIN branches b ON s.id_branch = b.id_branch
    WHERE s.order_date BETWEEN start_date AND end_date
      AND b.id_branch = kiosk_id
    GROUP BY c.id_client
    UNION ALL
    SELECT 
        c.id_client,
        c.client_name,
        COUNT(s.id_sale) AS total_sales,
        "Фотоцентр" AS sales_place
    FROM sales s
    JOIN clients c ON s.id_client = c.id_client
    WHERE s.order_date BETWEEN start_date AND end_date
    GROUP BY c.id_client

    ORDER BY sales_place, total_sales DESC;
    
END $$


CREATE PROCEDURE GetTopEmployeesBySales (
    IN kiosk_id INT,
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
       IF start_date IS NULL OR end_date IS NULL OR kiosk_id IS NULL THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Параметры start_date, end_date и kiosk_id не могут быть NULL";
    END IF;

    IF NOT EXISTS (SELECT 1 FROM branches WHERE id_branch = kiosk_id) THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Указанный филиал не существует в базе данных";
    END IF;
	
    IF start_date > end_date THEN
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Неверно задан период: дата начала больше даты окончания";
    END IF;

    SELECT 
        e.id_employee,
        e.employee_name,
        COUNT(s.id_sale) AS total_sales,
        "Киоск" AS sales_place
    FROM sales s
    JOIN employees e ON s.id_employee = e.id_employee
    JOIN branches b ON s.id_branch = b.id_branch
    WHERE s.order_date BETWEEN start_date AND end_date
      AND s.id_branch = kiosk_id
    GROUP BY e.id_employee, b.address
    UNION ALL
    SELECT 
        e.id_employee,
        e.employee_name,
        COUNT(s.id_sale) AS total_sales,
        "Фотоцентр" AS sales_place
    FROM sales s
    JOIN employees e ON s.id_employee = e.id_employee
    WHERE s.order_date BETWEEN start_date AND end_date
    GROUP BY e.id_employee
    ORDER BY sales_place, total_sales DESC;

END $$

DELIMITER ;
