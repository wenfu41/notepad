class DatabaseConstants {
  // 表名
  static const String categoriesTable = 'categories';
  static const String transactionsTable = 'transactions';
  static const String budgetsTable = 'budgets';
  static const String monthlyBudgetsTable = 'monthly_budgets';
  static const String statisticsTable = 'statistics';

  // 列名
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnIcon = 'icon';
  static const String columnColor = 'color';
  static const String columnSortOrder = 'sort_order';
  static const String columnIsDefault = 'is_default';
  static const String columnAmount = 'amount';
  static const String columnType = 'type';
  static const String columnCategoryId = 'category_id';
  static const String columnCategoryName = 'category_name';
  static const String columnDescription = 'description';
  static const String columnDate = 'date';
  static const String columnYear = 'year';
  static const String columnMonth = 'month';
  static const String columnSpent = 'spent';
  static const String columnTotalAmount = 'total_amount';
  static const String columnTotalSpent = 'total_spent';
  static const String columnData = 'data';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // 数据类型
  static const String typeText = 'TEXT';
  static const String typeInteger = 'INTEGER';
  static const String typeReal = 'REAL';
  static const String typeBoolean = 'INTEGER'; // SQLite 使用 INTEGER 表示布尔值

  // 约束
  static const String constraintPrimaryKey = 'PRIMARY KEY';
  static const String constraintNotNull = 'NOT NULL';
  static const String constraintUnique = 'UNIQUE';
  static const String constraintForeignKey = 'FOREIGN KEY';
  static const String constraintReferences = 'REFERENCES';
  static const String constraintDefault = 'DEFAULT';

  // 默认值
  static const int defaultSortOrder = 0;
  static const int defaultIsDefault = 0;
  static const String defaultDescription = '';
  static const double defaultAmount = 0.0;
  static const double defaultSpent = 0.0;
  static const double defaultTotalAmount = 0.0;
  static const double defaultTotalSpent = 0.0;
  static const int defaultMonth = 0;

  // 交易类型
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';

  // 统计类型
  static const String statisticsTypeMonthly = 'monthly';
  static const String statisticsTypeYearly = 'yearly';
  static const String statisticsTypeCategory = 'category';
}