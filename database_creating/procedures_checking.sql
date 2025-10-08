CALL GetOrderStatistics("2025-04-01", "2025-05-01");

CALL GetOrdersByBranch(1, "2025-04-01", "2025-05-01");

CALL GetRevenueByBranch(1, "2025-04-01", "2025-05-01");

CALL GetPrintedPhotosByBranch(1, "2025-04-01", "2025-05-01");

CALL GetAvgSalesByCategories("Печать фотографий", "Срочная печать фотографий", "Штатив");

CALL GetClientsDiscountsByBranch(1);

CALL GetPopularProductsByBranch(1);

CALL GetAvgOrderTime("2025-04-01", "2025-05-01");

CALL GetTopClientsBySales(1, "2025-04-01", "2025-05-01");

CALL GetTopEmployeesBySales(1, "2025-04-01", "2025-05-01");
