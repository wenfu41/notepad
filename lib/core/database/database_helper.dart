import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/database_constants.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 1;

  // 获取数据库实例
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onOpen: _onDatabaseOpen,
    );
  }

  // 创建数据库表
  static Future<void> _createDatabase(Database db, int version) async {
    // 创建分类表
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.categoriesTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnName} TEXT NOT NULL,
        ${DatabaseConstants.columnIcon} TEXT NOT NULL,
        ${DatabaseConstants.columnColor} TEXT NOT NULL,
        ${DatabaseConstants.columnSortOrder} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.columnIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.columnCreatedAt} INTEGER NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} INTEGER NOT NULL
      )
    ''');

    // 创建交易表
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.transactionsTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnAmount} REAL NOT NULL,
        ${DatabaseConstants.columnType} TEXT NOT NULL,
        ${DatabaseConstants.columnCategoryId} TEXT NOT NULL,
        ${DatabaseConstants.columnDescription} TEXT NOT NULL DEFAULT '',
        ${DatabaseConstants.columnDate} INTEGER NOT NULL,
        ${DatabaseConstants.columnCreatedAt} INTEGER NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} INTEGER NOT NULL,
        FOREIGN KEY (${DatabaseConstants.columnCategoryId})
        REFERENCES ${DatabaseConstants.categoriesTable}(${DatabaseConstants.columnId})
      )
    ''');

    // 创建预算表
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.budgetsTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnCategoryId} TEXT NOT NULL,
        ${DatabaseConstants.columnCategoryName} TEXT NOT NULL,
        ${DatabaseConstants.columnAmount} REAL NOT NULL,
        ${DatabaseConstants.columnYear} INTEGER NOT NULL,
        ${DatabaseConstants.columnMonth} INTEGER NOT NULL,
        ${DatabaseConstants.columnSpent} REAL NOT NULL DEFAULT 0.0,
        ${DatabaseConstants.columnCreatedAt} INTEGER NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} INTEGER NOT NULL,
        UNIQUE(${DatabaseConstants.columnCategoryId}, ${DatabaseConstants.columnYear}, ${DatabaseConstants.columnMonth})
      )
    ''');

    // 创建月度预算总表
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.monthlyBudgetsTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnYear} INTEGER NOT NULL,
        ${DatabaseConstants.columnMonth} INTEGER NOT NULL,
        ${DatabaseConstants.columnTotalAmount} REAL NOT NULL DEFAULT 0.0,
        ${DatabaseConstants.columnTotalSpent} REAL NOT NULL DEFAULT 0.0,
        ${DatabaseConstants.columnCreatedAt} INTEGER NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} INTEGER NOT NULL,
        UNIQUE(${DatabaseConstants.columnYear}, ${DatabaseConstants.columnMonth})
      )
    ''');

    // 创建统计表
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.statisticsTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnType} TEXT NOT NULL,
        ${DatabaseConstants.columnYear} INTEGER NOT NULL,
        ${DatabaseConstants.columnMonth} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.columnData} TEXT NOT NULL,
        ${DatabaseConstants.columnCreatedAt} INTEGER NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} INTEGER NOT NULL,
        UNIQUE(${DatabaseConstants.columnType}, ${DatabaseConstants.columnYear}, ${DatabaseConstants.columnMonth})
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('''
      CREATE INDEX idx_transactions_date
      ON ${DatabaseConstants.transactionsTable}(${DatabaseConstants.columnDate})
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category
      ON ${DatabaseConstants.transactionsTable}(${DatabaseConstants.columnCategoryId})
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_type
      ON ${DatabaseConstants.transactionsTable}(${DatabaseConstants.columnType})
    ''');

    await db.execute('''
      CREATE INDEX idx_budgets_period
      ON ${DatabaseConstants.budgetsTable}(${DatabaseConstants.columnYear}, ${DatabaseConstants.columnMonth})
    ''');

    await db.execute('''
      CREATE INDEX idx_statistics_period
      ON ${DatabaseConstants.statisticsTable}(${DatabaseConstants.columnType}, ${DatabaseConstants.columnYear}, ${DatabaseConstants.columnMonth})
    ''');

    // 插入默认分类数据
    await _insertDefaultCategories(db);
  }

  // 升级数据库
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < newVersion) {
      // 根据版本进行升级
      // 示例：添加新字段或新表
    }
  }

  // 数据库打开时的回调
  static Future<void> _onDatabaseOpen(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // 插入默认分类
  static Future<void> _insertDefaultCategories(Database db) async {
    final batch = db.batch();

    // 插入默认支出分类
    final expenseCategories = [
      {'id': 'food', 'name': '餐饮', 'icon': '🍔', 'color': '#FF6B6B', 'sortOrder': 1},
      {'id': 'transport', 'name': '交通', 'icon': '🚗', 'color': '#4ECDC4', 'sortOrder': 2},
      {'id': 'shopping', 'name': '购物', 'icon': '🛒', 'color': '#45B7D1', 'sortOrder': 3},
      {'id': 'entertainment', 'name': '娱乐', 'icon': '🎮', 'color': '#96CEB4', 'sortOrder': 4},
      {'id': 'health', 'name': '医疗', 'icon': '🏥', 'color': '#FECA57', 'sortOrder': 5},
      {'id': 'education', 'name': '教育', 'icon': '📚', 'color': '#9C88FF', 'sortOrder': 6},
      {'id': 'housing', 'name': '住房', 'icon': '🏠', 'color': '#FD79A8', 'sortOrder': 7},
      {'id': 'utilities', 'name': '水电费', 'icon': '💡', 'color': '#FDCB6E', 'sortOrder': 8},
      {'id': 'communication', 'name': '通讯', 'icon': '📱', 'color': '#6C5CE7', 'sortOrder': 9},
      {'id': 'other', 'name': '其他', 'icon': '📦', 'color': '#B2BEC3', 'sortOrder': 10},
    ];

    // 插入默认收入分类
    final incomeCategories = [
      {'id': 'salary', 'name': '工资', 'icon': '💰', 'color': '#00B894', 'sortOrder': 1},
      {'id': 'bonus', 'name': '奖金', 'icon': '🎁', 'color': '#E17055', 'sortOrder': 2},
      {'id': 'investment', 'name': '投资', 'icon': '📈', 'color': '#0984E3', 'sortOrder': 3},
      {'id': 'partTime', 'name': '兼职', 'icon': '💼', 'color': '#A29BFE', 'sortOrder': 4},
      {'id': 'gift', 'name': '礼金', 'icon': '🎂', 'color': '#FD79A8', 'sortOrder': 5},
      {'id': 'refund', 'name': '退款', 'icon': '↩️', 'color': '#55A3FF', 'sortOrder': 6},
      {'id': 'otherIncome', 'name': '其他收入', 'icon': '💵', 'color': '#636E72', 'sortOrder': 7},
    ];

    final now = DateTime.now().millisecondsSinceEpoch;

    for (final category in expenseCategories) {
      batch.insert(DatabaseConstants.categoriesTable, {
        'id': category['id'],
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'sortOrder': category['sortOrder'],
        'isDefault': 1,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    for (final category in incomeCategories) {
      batch.insert(DatabaseConstants.categoriesTable, {
        'id': category['id'],
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'sortOrder': category['sortOrder'],
        'isDefault': 1,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    await batch.commit();
  }

  // 关闭数据库
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // 删除数据库
  static Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // 备份数据库
  static Future<String> backupDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final sourcePath = join(documentsDirectory.path, _databaseName);

    final backupDir = Directory(join(documentsDirectory.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = join(backupDir.path, 'backup_$timestamp.db');

    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(backupPath);
      return backupPath;
    }

    throw Exception('数据库文件不存在');
  }

  // 获取数据库文件大小
  static Future<int> getDatabaseSize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    final file = File(path);

    if (await file.exists()) {
      return await file.length();
    }

    return 0;
  }
}