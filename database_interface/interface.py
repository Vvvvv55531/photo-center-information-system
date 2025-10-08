import sys
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
                             QLabel, QLineEdit, QPushButton, QComboBox, QTableWidget,
                             QTableWidgetItem, QTabWidget, QMessageBox, QDateEdit, QSpinBox,
                             QDoubleSpinBox, QGroupBox)
from PyQt5.QtCore import QDate
import pymysql
from pymysql import Error


class PhotoCenterApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Информационная система фотоцентра")
        self.setGeometry(100, 100, 1200, 800)

        # Подключение к базе данных
        self.connection = None
        self.connect_to_db()

        # Создание основного виджета и layout
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        self.main_layout = QVBoxLayout(self.central_widget)

        # Создание вкладок
        self.tabs = QTabWidget()
        self.main_layout.addWidget(self.tabs)

        # Добавление вкладок
        self.create_tables_tab()
        self.create_procedures_tab()
        self.create_visualization_tab()

        # Статус бар
        self.statusBar().showMessage("Готово")

    def connect_to_db(self):
        try:
            self.connection = pymysql.connect(
                host='localhost',
                user='root',
                password='rOto463+',
                database='photo_center',
                cursorclass=pymysql.cursors.DictCursor
            )
            if self.connection.open:
                print("Успешное подключение к базе данных")
        except Error as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось подключиться к базе данных: {e}")

    def create_tables_tab(self):
        """Вкладка для просмотра таблиц"""
        tab = QWidget()
        layout = QVBoxLayout(tab)

        # Выбор таблицы
        self.table_combo = QComboBox()
        self.table_combo.addItems([
            "branches", "clients", "employees", "products",
            "sales", "products_in_sales", "orders",
            "format_types", "paper_types", "payment_types", "units"
        ])

        # Кнопка загрузки
        load_btn = QPushButton("Загрузить таблицу")
        load_btn.clicked.connect(self.load_table_data)

        # Таблица для отображения данных
        self.table_widget = QTableWidget()
        self.table_widget.setEditTriggers(QTableWidget.NoEditTriggers)

        # Добавление элементов в layout
        top_layout = QHBoxLayout()
        top_layout.addWidget(QLabel("Выберите таблицу:"))
        top_layout.addWidget(self.table_combo)
        top_layout.addWidget(load_btn)
        top_layout.addStretch()

        layout.addLayout(top_layout)
        layout.addWidget(self.table_widget)

        self.tabs.addTab(tab, "Таблицы")

    def load_table_data(self):
        table_name = self.table_combo.currentText()
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(f"SELECT * FROM {table_name}")
                rows = cursor.fetchall()

                if not rows:
                    QMessageBox.information(self, "Информация", "Таблица пуста")
                    return

                # Получаем названия столбцов из первого ряда
                columns = list(rows[0].keys())

                # Настраиваем таблицу
                self.table_widget.setRowCount(len(rows))
                self.table_widget.setColumnCount(len(columns))
                self.table_widget.setHorizontalHeaderLabels(columns)

                # Заполняем таблицу данными
                for i, row in enumerate(rows):
                    for j, col in enumerate(columns):
                        value = row.get(col, "")
                        item = QTableWidgetItem(str(value) if value is not None else "")
                        self.table_widget.setItem(i, j, item)

                self.table_widget.resizeColumnsToContents()
                self.statusBar().showMessage(f"Загружена таблица: {table_name}")

        except Error as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось загрузить данные: {e}")

    def create_procedures_tab(self):
        """Вкладка для выполнения процедур"""
        tab = QWidget()
        layout = QVBoxLayout(tab)

        # Выбор процедуры
        self.procedure_combo = QComboBox()
        procedures = [
            "GetOrderStatistics",
            "GetOrdersByBranch",
            "GetRevenueByBranch",
            "GetPrintedPhotosByBranch",
            "GetAvgSalesByCategories",
            "GetClientsDiscountsByBranch",
            "GetPopularProductsByBranch",
            "GetAvgOrderTime",
            "GetTopClientsBySales",
            "GetTopEmployeesBySales"
        ]
        self.procedure_combo.addItems(procedures)
        self.procedure_combo.currentIndexChanged.connect(self.update_procedure_ui)

        # Область для параметров
        self.params_group = QGroupBox("Параметры процедуры")
        self.params_layout = QVBoxLayout(self.params_group)

        # Кнопка выполнения
        execute_btn = QPushButton("Выполнить процедуру")
        execute_btn.clicked.connect(self.execute_procedure)

        # Таблица для результатов
        self.result_widget = QTableWidget()
        self.result_widget.setEditTriggers(QTableWidget.NoEditTriggers)

        # Добавление элементов в layout
        top_layout = QHBoxLayout()
        top_layout.addWidget(QLabel("Выберите процедуру:"))
        top_layout.addWidget(self.procedure_combo)
        top_layout.addStretch()

        layout.addLayout(top_layout)
        layout.addWidget(self.params_group)
        layout.addWidget(execute_btn)
        layout.addWidget(self.result_widget)

        self.tabs.addTab(tab, "Процедуры")

        # Инициализация UI для первой процедуры
        self.update_procedure_ui()

    def update_procedure_ui(self):
        """Обновляет UI в зависимости от выбранной процедуры"""
        # Очищаем предыдущие элементы
        for i in reversed(range(self.params_layout.count())):
            widget = self.params_layout.itemAt(i).widget()
            if widget:
                widget.setParent(None)

        procedure_name = self.procedure_combo.currentText()

        # Процедуры с датами
        if procedure_name in ["GetOrderStatistics", "GetOrdersByBranch",
                              "GetRevenueByBranch", "GetPrintedPhotosByBranch",
                              "GetAvgOrderTime", "GetTopClientsBySales",
                              "GetTopEmployeesBySales"]:
            self.create_date_inputs()

        # Процедуры с филиалами
        if procedure_name in ["GetOrdersByBranch", "GetRevenueByBranch",
                              "GetPrintedPhotosByBranch", "GetClientsDiscountsByBranch",
                              "GetPopularProductsByBranch"]:
            self.create_branch_input()

        # Процедуры с киосками
        if procedure_name in ["GetTopClientsBySales", "GetTopEmployeesBySales"]:
            self.create_kiosk_input()

        # Специфические параметры
        if procedure_name == "GetAvgSalesByCategories":
            self.create_category_inputs()

    def create_date_inputs(self):
        """Создает поля для ввода дат"""
        group = QGroupBox("Диапазон дат")
        layout = QVBoxLayout(group)

        start_layout = QHBoxLayout()
        start_layout.addWidget(QLabel("Дата начала:"))
        self.start_date_edit = QDateEdit()
        self.start_date_edit.setCalendarPopup(True)
        self.start_date_edit.setDate(QDate.currentDate().addMonths(-1))
        start_layout.addWidget(self.start_date_edit)
        start_layout.addStretch()

        end_layout = QHBoxLayout()
        end_layout.addWidget(QLabel("Дата окончания:"))
        self.end_date_edit = QDateEdit()
        self.end_date_edit.setCalendarPopup(True)
        self.end_date_edit.setDate(QDate.currentDate())
        end_layout.addWidget(self.end_date_edit)
        end_layout.addStretch()

        layout.addLayout(start_layout)
        layout.addLayout(end_layout)

        self.params_layout.addWidget(group)

    def create_branch_input(self):
        """Создает поле для выбора филиала"""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("SELECT id_branch, address FROM branches")
                branches = cursor.fetchall()

                group = QGroupBox("Филиал")
                layout = QHBoxLayout(group)

                self.branch_combo = QComboBox()
                for branch in branches:
                    self.branch_combo.addItem(branch['address'], branch['id_branch'])

                layout.addWidget(self.branch_combo)
                layout.addStretch()

                self.params_layout.addWidget(group)

        except Error as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось загрузить филиалы: {e}")

    def create_kiosk_input(self):
        """Создает поле для выбора киоска"""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("SELECT id_branch, kiosk_address FROM branches WHERE kiosk_address IS NOT NULL")
                kiosks = cursor.fetchall()

                group = QGroupBox("Киоск")
                layout = QHBoxLayout(group)

                self.kiosk_combo = QComboBox()
                for kiosk in kiosks:
                    self.kiosk_combo.addItem(kiosk['kiosk_address'], kiosk['id_branch'])

                layout.addWidget(self.kiosk_combo)
                layout.addStretch()

                self.params_layout.addWidget(group)

        except Error as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось загрузить киоски: {e}")

    def create_category_inputs(self):
        """Создает поля для ввода категорий"""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("SELECT DISTINCT product_name FROM products")
                products = [p['product_name'] for p in cursor.fetchall()]

                group = QGroupBox("Категории товаров")
                layout = QVBoxLayout(group)

                category1_layout = QHBoxLayout()
                category1_layout.addWidget(QLabel("Категория 1:"))
                self.category1_combo = QComboBox()
                self.category1_combo.addItems(products)
                category1_layout.addWidget(self.category1_combo)
                category1_layout.addStretch()

                category2_layout = QHBoxLayout()
                category2_layout.addWidget(QLabel("Категория 2:"))
                self.category2_combo = QComboBox()
                self.category2_combo.addItems(products)
                category2_layout.addWidget(self.category2_combo)
                category2_layout.addStretch()

                category3_layout = QHBoxLayout()
                category3_layout.addWidget(QLabel("Категория 3:"))
                self.category3_combo = QComboBox()
                self.category3_combo.addItems(products)
                category3_layout.addWidget(self.category3_combo)
                category3_layout.addStretch()

                layout.addLayout(category1_layout)
                layout.addLayout(category2_layout)
                layout.addLayout(category3_layout)

                self.params_layout.addWidget(group)

        except Error as e:
            QMessageBox.critical(self, "Ошибка", f"Не удалось загрузить категории: {e}")

    def execute_procedure(self):
        """Выполняет выбранную процедуру"""
        procedure_name = self.procedure_combo.currentText()

        try:
            with self.connection.cursor() as cursor:
                params = []

                # Для всех процедур с датами
                if procedure_name in ["GetOrderStatistics", "GetOrdersByBranch",
                                    "GetRevenueByBranch", "GetPrintedPhotosByBranch",
                                    "GetAvgOrderTime", "GetTopClientsBySales",
                                    "GetTopEmployeesBySales"]:
                    start_date = self.start_date_edit.date().toString("yyyy-MM-dd")
                    end_date = self.end_date_edit.date().toString("yyyy-MM-dd")
                    if start_date > end_date:
                        raise ValueError("Дата начала не может быть больше даты окончания")

                if procedure_name == "GetOrderStatistics":
                    params = [start_date, end_date]

                elif procedure_name == "GetOrdersByBranch":
                    params = [self.branch_combo.currentData(), start_date, end_date]

                elif procedure_name == "GetRevenueByBranch":
                    params = [self.branch_combo.currentData(), start_date, end_date]

                elif procedure_name == "GetPrintedPhotosByBranch":
                    params = [self.branch_combo.currentData(), start_date, end_date]

                elif procedure_name == "GetAvgSalesByCategories":
                    params = [
                        self.category1_combo.currentText(),
                        self.category2_combo.currentText(),
                        self.category3_combo.currentText()
                    ]

                elif procedure_name == "GetClientsDiscountsByBranch":
                    params = [self.branch_combo.currentData()]

                elif procedure_name == "GetPopularProductsByBranch":
                    params = [self.branch_combo.currentData()]

                elif procedure_name == "GetAvgOrderTime":
                    params = [start_date, end_date]

                elif procedure_name == "GetTopClientsBySales":
                    params = [self.kiosk_combo.currentData(), start_date, end_date]

                elif procedure_name == "GetTopEmployeesBySales":
                    params = [self.kiosk_combo.currentData(), start_date, end_date]

                # Вызов процедуры
                cursor.callproc(procedure_name, params)

                # Получение результатов
                results = []
                while True:
                    result = cursor.fetchall()
                    if result:
                        results.extend(result)
                    if not cursor.nextset():
                        break

                if not results:
                    QMessageBox.information(self, "Результат", "Нет данных для отображения")
                    return

                # Отображение результатов в таблице
                columns = list(results[0].keys()) if results else []
                self.result_widget.setRowCount(len(results))
                self.result_widget.setColumnCount(len(columns))
                self.result_widget.setHorizontalHeaderLabels(columns)

                for i, row in enumerate(results):
                    for j, col in enumerate(columns):
                        value = row.get(col, "")
                        item = QTableWidgetItem(str(value) if value is not None else "")
                        self.result_widget.setItem(i, j, item)

                self.result_widget.resizeColumnsToContents()
                self.statusBar().showMessage(f"Выполнена процедура: {procedure_name}")

        except ValueError as ve:
            QMessageBox.warning(self, "Ошибка ввода", str(ve))
        except Error as e:
            QMessageBox.critical(self, "Ошибка базы данных", f"Ошибка выполнения процедуры: {e}")
        except Exception as e:
            QMessageBox.critical(self, "Ошибка", f"Неизвестная ошибка: {e}")

    def create_visualization_tab(self):
        """Вкладка для визуализации данных"""
        tab = QWidget()
        layout = QVBoxLayout(tab)

        # Заголовок
        title_label = QLabel("Визуализация данных")
        title_label.setStyleSheet("font-size: 16px; font-weight: bold;")
        layout.addWidget(title_label)

        # Описание
        desc_label = QLabel("Для просмотра графиков обратитесь к разделу 3.3 курсовой работы")
        layout.addWidget(desc_label)

        # Добавление вкладки
        self.tabs.addTab(tab, "Визуализация")

    def closeEvent(self, event):
        """Закрытие соединения с БД при закрытии приложения"""
        if self.connection and self.connection.open:
            self.connection.close()
        event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = PhotoCenterApp()
    window.show()
    sys.exit(app.exec_())
