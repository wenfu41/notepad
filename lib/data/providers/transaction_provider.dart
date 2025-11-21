import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../models/statistics.dart';

// 交易服务提供者
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService();
});

// 交易状态
class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionState({
    required this.transactions,
    required this.isLoading,
    this.error,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionState &&
        other.transactions == transactions &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return transactions.hashCode ^ isLoading.hashCode ^ error.hashCode;
  }
}

// 交易状态提供者
class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionService _transactionService;

  TransactionNotifier(this._transactionService) : super(const TransactionState(transactions: [], isLoading: false));

  // 获取所有交易
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionService.getAllTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 按日期范围获取交易
  Future<void> loadTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionService.getTransactionsByDateRange(startDate, endDate);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 按月获取交易
  Future<void> loadTransactionsByMonth(int year, int month) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionService.getTransactionsByMonth(year, month);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 按年获取交易
  Future<void> loadTransactionsByYear(int year) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionService.getTransactionsByYear(year);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 按类型获取交易
  Future<void> loadTransactionsByType(TransactionType type) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionService.getTransactionsByType(type);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 添加交易
  Future<void> addTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _transactionService.addTransaction(transaction);
      final transactions = await _transactionService.getAllTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 更新交易
  Future<void> updateTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _transactionService.updateTransaction(transaction);
      final transactions = await _transactionService.getAllTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 删除交易
  Future<void> deleteTransaction(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _transactionService.deleteTransaction(id);
      final transactions = state.transactions.where((t) => t.id != id).toList();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 搜索交易
  Future<void> searchTransactions(String searchTerm) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _transactionService.searchTransactions(searchTerm);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadTransactions();
  }
}

// 交易提供者
final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return TransactionNotifier(transactionService);
});

// 最近交易提供者
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionProvider).transactions;
  // 返回最近10条交易记录
  return transactions.take(10).toList();
});

// 今日交易提供者
final todayTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return await transactionService.getTodayTransactions();
});

// 本周交易提供者
final thisWeekTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return await transactionService.getThisWeekTransactions();
});

// 月度统计提供者
final monthlyStatisticsProvider = Provider.family<MonthlyStatistics, DateTime>((ref, date) {
  final transactions = ref.watch(transactionProvider).transactions;
  return MonthlyStatistics.fromTransactions(
    transactions,
    date.year,
    date.month,
  );
});

// 年度统计提供者
final yearlyStatisticsProvider = Provider.family<YearlyStatistics, int>((ref, year) {
  final transactions = ref.watch(transactionProvider).transactions;
  return YearlyStatistics.fromTransactions(transactions, year);
});

// 交易总数提供者
final transactionCountProvider = Provider<int>((ref) {
  return ref.watch(transactionProvider).transactions.length;
});

// 按类型统计提供者
final transactionsByTypeProvider = Provider.family<List<Transaction>, TransactionType>((ref, type) {
  final transactions = ref.watch(transactionProvider).transactions;
  return transactions.where((t) => t.type == type).toList();
});

// 按分类统计提供者
final transactionsByCategoryProvider = Provider.family<List<Transaction>, String>((ref, categoryId) {
  final transactions = ref.watch(transactionProvider).transactions;
  return transactions.where((t) => t.categoryId == categoryId).toList();
});

// 日期范围参数类
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

// 按日期范围统计提供者
final transactionsByDateRangeProvider = Provider.family<List<Transaction>, DateRange>((ref, dateRange) {
  final transactions = ref.watch(transactionProvider).transactions;
  final startDate = dateRange.start;
  final endDate = dateRange.end;
  return transactions.where((t) =>
    t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    t.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();
});

// 总收入提供者
final totalIncomeProvider = Provider.family<double, DateRange>((ref, dateRange) {
  final transactions = ref.watch(transactionsByDateRangeProvider(dateRange));
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

// 总支出提供者
final totalExpenseProvider = Provider.family<double, DateRange>((ref, dateRange) {
  final transactions = ref.watch(transactionsByDateRangeProvider(dateRange));
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

// 净收入提供者
final netIncomeProvider = Provider.family<double, DateRange>((ref, dateRange) {
  final totalIncome = ref.watch(totalIncomeProvider(dateRange));
  final totalExpense = ref.watch(totalExpenseProvider(dateRange));
  return totalIncome - totalExpense;
});