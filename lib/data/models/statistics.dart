import 'transaction.dart';

class MonthlyStatistics {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final Map<String, double> categoryExpenses;
  final Map<String, double> categoryIncome;
  final int transactionCount;
  final DateTime lastUpdated;

  const MonthlyStatistics({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.categoryExpenses,
    required this.categoryIncome,
    required this.transactionCount,
    required this.lastUpdated,
  });

  factory MonthlyStatistics.fromTransactions(
    List<Transaction> transactions,
    int year,
    int month,
  ) {
    final monthTransactions = transactions.where((t) =>
      t.date.year == year && t.date.month == month
    ).toList();

    final totalIncome = monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final categoryExpenses = <String, double>{};
    final categoryIncome = <String, double>{};

    for (final transaction in monthTransactions) {
      if (transaction.type == TransactionType.expense) {
        categoryExpenses.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      } else {
        categoryIncome.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return MonthlyStatistics(
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: totalIncome - totalExpense,
      categoryExpenses: categoryExpenses,
      categoryIncome: categoryIncome,
      transactionCount: monthTransactions.length,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netAmount': netAmount,
      'categoryExpenses': categoryExpenses,
      'categoryIncome': categoryIncome,
      'transactionCount': transactionCount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory MonthlyStatistics.fromMap(Map<String, dynamic> map) {
    return MonthlyStatistics(
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      totalIncome: map['totalIncome']?.toDouble() ?? 0.0,
      totalExpense: map['totalExpense']?.toDouble() ?? 0.0,
      netAmount: map['netAmount']?.toDouble() ?? 0.0,
      categoryExpenses: Map<String, double>.from(map['categoryExpenses'] ?? {}),
      categoryIncome: Map<String, double>.from(map['categoryIncome'] ?? {}),
      transactionCount: map['transactionCount'] ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }
}

class YearlyStatistics {
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final Map<int, double> monthlyIncome;
  final Map<int, double> monthlyExpense;
  final Map<String, double> categoryExpenses;
  final Map<String, double> categoryIncome;
  final int transactionCount;
  final DateTime lastUpdated;

  const YearlyStatistics({
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.categoryExpenses,
    required this.categoryIncome,
    required this.transactionCount,
    required this.lastUpdated,
  });

  factory YearlyStatistics.fromTransactions(
    List<Transaction> transactions,
    int year,
  ) {
    final yearTransactions = transactions.where((t) => t.date.year == year).toList();

    final totalIncome = yearTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = yearTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthlyIncome = <int, double>{};
    final monthlyExpense = <int, double>{};
    final categoryExpenses = <String, double>{};
    final categoryIncome = <String, double>{};

    for (final transaction in yearTransactions) {
      final month = transaction.date.month;

      if (transaction.type == TransactionType.expense) {
        monthlyExpense.update(
          month,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
        categoryExpenses.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      } else {
        monthlyIncome.update(
          month,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
        categoryIncome.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return YearlyStatistics(
      year: year,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: totalIncome - totalExpense,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      categoryExpenses: categoryExpenses,
      categoryIncome: categoryIncome,
      transactionCount: yearTransactions.length,
      lastUpdated: DateTime.now(),
    );
  }

  List<MonthlyTrendData> getMonthlyTrend() {
    final List<MonthlyTrendData> trend = [];
    for (int month = 1; month <= 12; month++) {
      trend.add(MonthlyTrendData(
        month: month,
        income: monthlyIncome[month] ?? 0.0,
        expense: monthlyExpense[month] ?? 0.0,
        net: (monthlyIncome[month] ?? 0.0) - (monthlyExpense[month] ?? 0.0),
      ));
    }
    return trend;
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netAmount': netAmount,
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'categoryExpenses': categoryExpenses,
      'categoryIncome': categoryIncome,
      'transactionCount': transactionCount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory YearlyStatistics.fromMap(Map<String, dynamic> map) {
    return YearlyStatistics(
      year: map['year'] ?? 0,
      totalIncome: map['totalIncome']?.toDouble() ?? 0.0,
      totalExpense: map['totalExpense']?.toDouble() ?? 0.0,
      netAmount: map['netAmount']?.toDouble() ?? 0.0,
      monthlyIncome: Map<int, double>.from(map['monthlyIncome'] ?? {}),
      monthlyExpense: Map<int, double>.from(map['monthlyExpense'] ?? {}),
      categoryExpenses: Map<String, double>.from(map['categoryExpenses'] ?? {}),
      categoryIncome: Map<String, double>.from(map['categoryIncome'] ?? {}),
      transactionCount: map['transactionCount'] ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }
}

class MonthlyTrendData {
  final int month;
  final double income;
  final double expense;
  final double net;

  const MonthlyTrendData({
    required this.month,
    required this.income,
    required this.expense,
    required this.net,
  });
}

class CategoryStatistics {
  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final int transactionCount;
  final double percentage;
  final List<Transaction> transactions;
  final DateTime lastUpdated;

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
    required this.transactions,
    required this.lastUpdated,
  });

  factory CategoryStatistics.fromTransactions(
    List<Transaction> transactions,
    String categoryId,
    String categoryName,
    double totalPeriodAmount,
  ) {
    final categoryTransactions = transactions
        .where((t) => t.categoryId == categoryId)
        .toList();

    final totalAmount = categoryTransactions
        .fold(0.0, (sum, t) => sum + t.amount);

    final percentage = totalPeriodAmount > 0
        ? (totalAmount / totalPeriodAmount) * 100
        : 0.0;

    return CategoryStatistics(
      categoryId: categoryId,
      categoryName: categoryName,
      totalAmount: totalAmount,
      transactionCount: categoryTransactions.length,
      percentage: percentage,
      transactions: categoryTransactions,
      lastUpdated: DateTime.now(),
    );
  }
}