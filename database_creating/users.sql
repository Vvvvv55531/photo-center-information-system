CREATE USER "director"@"localhost" IDENTIFIED BY "director_password";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.products TO "director"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.format_types TO "director"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.paper_types TO "director"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.units TO "director"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.clients TO "director"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.employees TO "director"@"localhost";

CREATE USER "client"@"localhost" IDENTIFIED BY "client_password";
GRANT SELECT ON photo_center.products TO "client"@"localhost";
GRANT INSERT ON photo_center.orders TO "client"@"localhost";

CREATE USER "cashier"@"localhost" IDENTIFIED BY "cashier_password";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.orders TO "cashier"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.sales TO "cashier"@"localhost";
GRANT SELECT, INSERT, UPDATE, DELETE ON photo_center.products_in_sales TO "cashier"@"localhost";

CREATE USER "admin"@"localhost" IDENTIFIED BY "admin_password";
GRANT ALL PRIVILEGES ON photo_center.* TO "admin"@"localhost";
