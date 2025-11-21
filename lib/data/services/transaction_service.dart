import 'dart:async';
import '../models/transaction.dart';
import '../../core/database/database_service.dart';
import '../../core/database/persistent_database_helper.dart';
import '../../core/constants/database_constants.dart';

class TransactionService {
  final DatabaseService _databaseService = DatabaseService();

  // 获取所有交易记录
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.transactionsTable,
        orderBy: '${DatabaseConstants.columnDate} DESC',
      );

      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取交易记录失败: $e');
    }
  }

  // 按日期范围获取交易记录
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.transactionsTable,
        where: '${DatabaseConstants.columnDate} BETWEEN ? AND ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: '${DatabaseConstants.columnDate} DESC',
      );

      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取日期范围内的交易记录失败: $e');
    }
  }

  // 按月获取交易记录
  Future<List<Transaction>> getTransactionsByMonth(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      return await getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('获取月度交易记录失败: $e');
    }
  }

  // 按年获取交易记录
  Future<List<Transaction>> getTransactionsByYear(int year) async {
    try {
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year + 1, 1, 0, 23, 59, 59);

      return await getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('获取年度交易记录失败: $e');
    }
  }

  // 按分类获取交易记录
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.transactionsTable,
        where: '${DatabaseConstants.columnCategoryId} = ?',
        whereArgs: [categoryId],
        orderBy: '${DatabaseConstants.columnDate} DESC',
      );

      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取分类交易记录失败: $e');
    }
  }

  // 按类型获取交易记录
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.transactionsTable,
        where: '${DatabaseConstants.columnType} = ?',
        whereArgs: [type.name],
        orderBy: '${DatabaseConstants.columnDate} DESC',
      );

      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取类型交易记录失败: $e');
    }
  }

  // 根据ID获取交易记录
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.transactionsTable,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Transaction.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('获取交易记录失败: $e');
    }
  }

  // 添加交易记录
  Future<String> addTransaction(Transaction transaction) async {
    try {
      final id = await _databaseService.insert(
        DatabaseConstants.transactionsTable,
        transaction.toMap(),
      );
      return transaction.id;
    } catch (e) {
      throw Exception('添加交易记录失败: $e');
    }
  }

  // 更新交易记录
  Future<int> updateTransaction(Transaction transaction) async {
    try {
      return await _databaseService.update(
        DatabaseConstants.transactionsTable,
        transaction.toMap(),
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('更新交易记录失败: $e');
    }
  }

  // 删除交易记录
  Future<int> deleteTransaction(String id) async {
    try {
      return await _databaseService.delete(
        DatabaseConstants.transactionsTable,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('删除交易记录失败: $e');
    }
  }

  // 批量添加交易记录
  Future<void> addTransactions(List<Transaction> transactions) async {
    try {
      final List<Map<String, dynamic>> maps =
          transactions.map((t) => t.toMap()).toList();
      await _databaseService.batchInsert(
        DatabaseConstants.transactionsTable,
        maps,
      );
    } catch (e) {
      throw Exception('批量添加交易记录失败: $e');
    }
  }

  // 搜索交易记录
  Future<List<Transaction>> searchTransactions(String searchTerm) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.search(
        DatabaseConstants.transactionsTable,
        searchTerm,
        searchColumns: [
          DatabaseConstants.columnDescription,
          DatabaseConstants.columnCategoryId,
        ],
        orderBy: '${DatabaseConstants.columnDate} DESC',
      );

      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('搜索交易记录失败: $e');
    }
  }

  // 获取交易记录总数
  Future<int> getTransactionCount() async {
    try {
      return await _databaseService.getCount(DatabaseConstants.transactionsTable);
    } catch (e) {
      throw Exception('获取交易记录总数失败: $e');
    }
  }

  // 获取指定日期范围内的交易记录总数
  Future<int> getTransactionCountByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _databaseService.getCount(
        DatabaseConstants.transactionsTable,
        where: '${DatabaseConstants.columnDate} BETWEEN ? AND ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );
    } catch (e) {
      throw Exception('获取日期范围内的交易记录总数失败: $e');
    }
  }

  // 计算指定日期范围内的总收入
  Future<double> getTotalIncomeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await _databaseService.getSum(
        DatabaseConstants.transactionsTable,
        DatabaseConstants.columnAmount,
        where: '${DatabaseConstants.columnType} = ? AND ${DatabaseConstants.columnDate} BETWEEN ? AND ?',
        whereArgs: [
          DatabaseConstants.transactionTypeIncome,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );
      return result ?? 0.0;
    } catch (e) {
      throw Exception('计算总收入失败: $e');
    }
  }

  // 计算指定日期范围内的总支出
  Future<double> getTotalExpenseByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await _databaseService.getSum(
        DatabaseConstants.transactionsTable,
        DatabaseConstants.columnAmount,
        where: '${DatabaseConstants.columnType} = ? AND ${DatabaseConstants.columnDate} BETWEEN ? AND ?',
        whereArgs: [
          DatabaseConstants.transactionTypeExpense,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );
      return result ?? 0.0;
    } catch (e) {
      throw Exception('计算总支出失败: $e');
    }
  }

  // 计算指定分类的总金额
  Future<double> getTotalAmountByCategory(
    String categoryId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      String whereClause = '${DatabaseConstants.columnCategoryId} = ?';
      List<dynamic> whereArgs = [categoryId];

      if (startDate != null && endDate != null) {
        whereClause += ' AND ${DatabaseConstants.columnDate} BETWEEN ? AND ?';
        whereArgs.addAll([
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ]);
      }

      final result = await _databaseService.getSum(
        DatabaseConstants.transactionsTable,
        DatabaseConstants.columnAmount,
        where: whereClause,
        whereArgs: whereArgs,
      );
      return result ?? 0.0;
    } catch (e) {
      throw Exception('计算分类总金额失败: $e');
    }
  }

  // 获取最近的交易记录
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.transactionsTable,
        orderBy: '${DatabaseConstants.columnDate} DESC',
        limit: limit,
      );

      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取最近交易记录失败: $e');
    }
  }

  // 获取今日交易记录
  Future<List<Transaction>> getTodayTransactions() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return await getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('获取今日交易记录失败: $e');
    }
  }

  // 获取本周交易记录
  Future<List<Transaction>> getThisWeekTransactions() async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: now.weekday - 1));
      final endDate = startDate.add(const Duration(days: 6));

      return await getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('获取本周交易记录失败: $e');
    }
  }

  // 清空所有交易记录
  Future<void> clearAllTransactions() async {
    try {
      await _databaseService.clearTable(DatabaseConstants.transactionsTable);
    } catch (e) {
      throw Exception('清空交易记录失败: $e');
    }
  }
}