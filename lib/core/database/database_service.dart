import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../constants/database_constants.dart';
import 'persistent_database_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get _db async {
    _database ??= await PersistentDatabaseHelper.database;
    return _database!;
  }

  // 通用查询方法
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _db;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  // 插入数据
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await _db;
    return await db.insert(table, values);
  }

  // 批量插入数据
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> values,
  ) async {
    final db = await _db;
    final batch = db.batch();

    for (final value in values) {
      batch.insert(table, value);
    }

    await batch.commit();
  }

  // 更新数据
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await _db;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // 删除数据
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await _db;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // 执行原始SQL
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await _db;
    return await db.rawQuery(sql, arguments);
  }

  // 执行原始SQL（非查询）
  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await _db;
    return await db.rawUpdate(sql, arguments);
  }

  // 执行原始SQL（删除/插入/更新等）
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = await _db;
    await db.execute(sql);
  }

  // 事务处理
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await _db;
    return await db.transaction(action);
  }

  // 批量事务
  Future<List<dynamic>> batchTransaction(
    Future<void> Function(Batch batch) operations,
  ) async {
    final db = await _db;
    final batch = db.batch();

    await operations(batch);

    return await batch.commit();
  }

  // 检查表是否存在
  Future<bool> tableExists(String tableName) async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // 获取表结构
  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await _db;
    return await db.rawQuery("PRAGMA table_info($tableName)");
  }

  // 清空表
  Future<void> clearTable(String tableName) async {
    final db = await _db;
    await db.delete(tableName);
  }

  // 获取表的记录数
  Future<int> getCount(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 获取最大值
  Future<int?> getMaxValue(String table, String column, {String? where, List<dynamic>? whereArgs}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT MAX($column) as max_value FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result);
  }

  // 获取最小值
  Future<int?> getMinValue(String table, String column, {String? where, List<dynamic>? whereArgs}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT MIN($column) as min_value FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result);
  }

  // 获取总和
  Future<double?> getSum(String table, String column, {String? where, List<dynamic>? whereArgs}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM($column) as sum_value FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return result.first['sum_value'] as double?;
  }

  // 获取平均值
  Future<double?> getAverage(String table, String column, {String? where, List<dynamic>? whereArgs}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT AVG($column) as avg_value FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return result.first['avg_value'] as double?;
  }

  // 分页查询
  Future<List<Map<String, dynamic>>> queryWithPagination(
    String table, {
    int page = 1,
    int pageSize = 20,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final offset = (page - 1) * pageSize;
    return await query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: pageSize,
      offset: offset,
    );
  }

  // 搜索查询
  Future<List<Map<String, dynamic>>> search(
    String table,
    String searchTerm, {
    List<String> searchColumns = const [],
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    if (searchColumns.isEmpty || searchTerm.isEmpty) {
      return await query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    }

    final searchConditions = searchColumns
        .map((column) => '$column LIKE ?')
        .join(' OR ');
    final searchArgs = List.filled(searchColumns.length, '%$searchTerm%');

    final whereClause = where != null ? '($where) AND ($searchConditions)' : searchConditions;
    final whereClauseArgs = whereArgs != null ? [...whereArgs, ...searchArgs] : searchArgs;

    return await query(
      table,
      where: whereClause,
      whereArgs: whereClauseArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  // 关闭数据库连接
  Future<void> close() async {
    await PersistentDatabaseHelper.close();
    _database = null;
  }
}