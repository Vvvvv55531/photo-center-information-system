import matplotlib.pyplot as plt
import seaborn as sns
import pymysql

# Подключение к базе данных
connection = pymysql.connect(
    host="localhost",
    user="root",
    password="rOto463+",
    database="photo_center"
)

cursor = connection.cursor()

# Запрос для получения цен заказов
query1 = "SELECT price FROM orders WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'"
cursor.execute(query1)

# Извлечение данных
data = cursor.fetchall()
prices = [row[0] for row in data]

# Гистограмма цен заказов
plt.figure(figsize=(10, 6))
sns.histplot(prices, kde=True, bins=30)
plt.title("Гистограмма цен заказов за 2025 год")
plt.xlabel("Цена")
plt.ylabel("Частота")
plt.show()

# Запрос для получения суммы продаж по месяцам
query2 = "SELECT MONTH(order_date), SUM(price) FROM sales GROUP BY MONTH(order_date)"
cursor.execute(query2)

# Извлечение данных
data = cursor.fetchall()
months = [row[0] for row in data]
sales = [row[1] for row in data]

# Линейный график суммы продаж по месяцам
plt.figure(figsize=(10, 6))
plt.plot(months, sales, marker='o')
plt.title("Сумма продаж по месяцам")
plt.xlabel("Месяц")
plt.ylabel("Сумма продаж")
plt.xticks(months)
plt.grid(True)
plt.show()

# Запрос для получения количества срочных и несрочных заказов
query = "SELECT order_type, COUNT(*) FROM orders GROUP BY order_type"
cursor.execute(query)

# Извлечение данных
data = cursor.fetchall()
order_types = [row[0] for row in data]
order_counts = [row[1] for row in data]

# График баров для сравнения типов заказов
plt.figure(figsize=(8, 6))
plt.bar(order_types, order_counts, color=['skyblue', 'orange'])
plt.title("Сравнение количества срочных и несрочных заказов")
plt.xlabel("Тип заказа")
plt.ylabel("Количество заказов")
plt.show()
