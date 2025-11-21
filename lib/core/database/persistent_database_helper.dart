import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/database_constants.dart';

class PersistentDatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'expense_tracker_persistent.db';
  static const int _databaseVersion = 1;

  // 获取数据库实例（支持路径切换）
  static Future<Database> get database async {
    if (_database == null) {
      print('正在初始化数据库...');
      _database = await _initDatabase();
      print('数据库初始化完成: ${_database?.path}');
    }
    return _database!;
  }

  // 强制重新初始化数据库（用于路径切换后）
  static Future<Database> forceReinitialize() async {
    print('强制重新初始化数据库...');

    // 关闭当前数据库连接
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('旧数据库连接已关闭');
    }

    // 重新初始化
    _database = await _initDatabase();
    print('数据库重新初始化完成: ${_database?.path}');
    return _database!;
  }

  // 初始化数据库（支持自定义路径，优先外部存储，回退到内部存储）
  static Future<Database> _initDatabase() async {
    String path;

    try {
      // 首先检查是否有自定义路径设置
      final prefs = await SharedPreferences.getInstance();
      final customPath = prefs.getString('custom_database_path');

      print('检查自定义路径: ${customPath ?? "无"}');

      if (customPath != null && customPath.isNotEmpty) {
        // 使用用户自定义的路径
        try {
          final customDir = Directory(customPath);
          if (!await customDir.exists()) {
            print('创建自定义路径目录: $customPath');
            await customDir.create(recursive: true);
          }

          path = join(customPath, _databaseName);
          print('尝试使用自定义存储路径: $path');

          // 检查文件是否可以访问
          final testFile = File(path);
          print('自定义路径文件可访问性: ${await testFile.exists() ? "存在" : "不存在"}');

          final db = await openDatabase(
            path,
            version: _databaseVersion,
            onCreate: _createDatabase,
            onUpgrade: _upgradeDatabase,
            onOpen: _onDatabaseOpen,
          );

          print('✅ 自定义路径数据库打开成功!');
          _database = db; // 确保保存数据库引用
          return db;
        } catch (e) {
          print('❌ 自定义路径初始化失败: $e');
          print('清除无效的自定义路径设置');
          // 清除无效的自定义路径
          await prefs.remove('custom_database_path');
          // 继续尝试默认路径
        }
      }

      // 默认路径逻辑：优先尝试外部存储
      print('尝试使用默认外部存储路径');
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // 尝试在Android的外部存储根目录创建1bb文件夹
        final externalStorageRoot = Directory('/storage/emulated/0');
        final oneBBDirectory = Directory(join(externalStorageRoot.path, '1bb'));

        try {
          // 尝试创建1bb文件夹
          if (!await oneBBDirectory.exists()) {
            await oneBBDirectory.create(recursive: true);
            print('/1bb 文件夹创建成功');
          }

          // 在1bb文件夹下创建应用数据目录
          final appDataDir = Directory(join(oneBBDirectory.path, 'expense_tracker_data'));
          if (!await appDataDir.exists()) {
            await appDataDir.create(recursive: true);
          }

          path = join(appDataDir.path, _databaseName);
          print('使用外部存储路径: $path');
        } catch (e) {
          print('无法访问外部存储: $e');
          throw e; // 让外部存储初始化失败，使用回退方案
        }
      } else {
        throw Exception('无法获取外部存储目录');
      }

      // 尝试打开外部存储的数据库
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onOpen: _onDatabaseOpen,
      );

      print('✅ 外部存储数据库打开成功!');
      _database = db; // 确保保存数据库引用
      return db;
    } catch (e) {
      print('⚠️ 外部存储初始化失败，使用内部存储回退: $e');

      // 回退到内部存储
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final internalDataDir = Directory(join(documentsDirectory.path, 'expense_tracker_data'));

      if (!await internalDataDir.exists()) {
        await internalDataDir.create(recursive: true);
      }

      path = join(internalDataDir.path, _databaseName);
      print('使用内部存储路径: $path');

      final fallbackDb = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onOpen: _onDatabaseOpen,
      );

      print('✅ 内部存储数据库打开成功!');
      _database = fallbackDb; // 确保保存数据库引用
      return fallbackDb;
    }
  }

  // 创建数据库表
  static Future<void> _createDatabase(Database db, int version) async {
    print('创建数据库表结构...');
    print('数据库版本: $version');
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
        ${DatabaseConstants.columnUpdatedAt} INTEGER NOT NULL
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

    // 创建索引
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

    // 检查是否已经有默认分类（避免重复插入）
    final existingCategories = await db.query(
      DatabaseConstants.categoriesTable,
      where: '${DatabaseConstants.columnIsDefault} = ?',
      whereArgs: [1],
    );

    if (existingCategories.isNotEmpty) {
      return; // 已有默认分类，不再插入
    }

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
        'sort_order': category['sortOrder'],
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    for (final category in incomeCategories) {
      batch.insert(DatabaseConstants.categoriesTable, {
        'id': category['id'],
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'sort_order': category['sortOrder'],
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    await batch.commit();
    print('数据库表创建完成!');

    // 强制写入一条测试记录来确保数据库文件被创建
    await db.insert(DatabaseConstants.categoriesTable, {
      DatabaseConstants.columnId: 'test_check',
      DatabaseConstants.columnName: 'test',
      DatabaseConstants.columnIcon: '🧪',
      DatabaseConstants.columnColor: '#000000',
      DatabaseConstants.columnSortOrder: 9999,
      DatabaseConstants.columnIsDefault: 0,
      DatabaseConstants.columnCreatedAt: DateTime.now().millisecondsSinceEpoch,
      DatabaseConstants.columnUpdatedAt: DateTime.now().millisecondsSinceEpoch,
    });

    // 立即删除测试记录
    await db.delete(DatabaseConstants.categoriesTable, where: '${DatabaseConstants.columnId} = ?', whereArgs: ['test_check']);

    print('数据库文件强制写入完成');
  }

  // 获取当前数据库路径（与实际使用的路径保持一致）
  static Future<String> getDatabasePath() async {
    try {
      // 首先检查是否有自定义路径设置
      final prefs = await SharedPreferences.getInstance();
      final customPath = prefs.getString('custom_database_path');

      if (customPath != null && customPath.isNotEmpty) {
        final customDatabasePath = join(customPath, _databaseName);
        // 检查自定义路径的数据库是否存在
        final customFile = File(customDatabasePath);
        if (await customFile.exists()) {
          return customDatabasePath;
        }
      }

      // 默认路径逻辑：首先尝试外部存储路径
      final externalStorageDir = await getExternalStorageDirectory();
      if (externalStorageDir != null) {
        final externalStorageRoot = Directory('/storage/emulated/0');
        final oneBBDirectory = Directory(join(externalStorageRoot.path, '1bb'));
        final appDataDir = Directory(join(oneBBDirectory.path, 'expense_tracker_data'));
        final externalPath = join(appDataDir.path, _databaseName);

        // 检查外部存储数据库是否存在
        final externalFile = File(externalPath);
        if (await externalFile.exists()) {
          return externalPath;
        }
      }

      // 回退到内部存储路径
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final internalDataDir = Directory(join(documentsDirectory.path, 'expense_tracker_data'));
      final internalPath = join(internalDataDir.path, _databaseName);

      return internalPath;
    } catch (e) {
      // 最终回退方案
      final documentsDirectory = await getApplicationDocumentsDirectory();
      return join(documentsDirectory.path, _databaseName);
    }
  }

  // 检查数据库是否存在
  static Future<bool> databaseExists() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // 获取数据库文件大小
  static Future<int> getDatabaseSize() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);

      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // 备份数据库到 /1bb 文件夹中的备份目录
  static Future<String> backupDatabase() async {
    try {
      final sourcePath = await getDatabasePath();
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        throw Exception('数据库文件不存在');
      }

      Directory? backupDir;

      if (Platform.isAndroid) {
        // 创建 /1bb 文件夹中的备份目录
        final internalStorage = Directory('/storage/emulated/0');
        final oneBBDirectory = Directory(join(internalStorage.path, '1bb'));

        if (!await oneBBDirectory.exists()) {
          await oneBBDirectory.create(recursive: true);
        }

        backupDir = Directory(join(oneBBDirectory.path, 'expense_tracker_backups'));
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
      }

      if (backupDir == null) {
        throw Exception('无法创建备份目录');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = join(backupDir.path, 'backup_$timestamp.db');

      await sourceFile.copy(backupPath);
      print('数据库备份成功: $backupPath');
      print('备份位置: /storage/emulated/0/1bb/expense_tracker_backups/');

      return backupPath;
    } catch (e) {
      throw Exception('备份数据库失败: $e');
    }
  }

  // 从备份恢复数据库
  static Future<void> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('备份文件不存在');
      }

      // 关闭当前数据库连接
      await close();

      final targetPath = await getDatabasePath();

      // 备份当前数据库文件
      final currentFile = File(targetPath);
      if (await currentFile.exists()) {
        final backupCurrentPath = '$targetPath.backup.${DateTime.now().millisecondsSinceEpoch}';
        await currentFile.copy(backupCurrentPath);
      }

      // 复制备份文件
      await backupFile.copy(targetPath);

      print('数据库恢复成功: $targetPath');
    } catch (e) {
      throw Exception('恢复数据库失败: $e');
    }
  }

  // 关闭数据库
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // 删除数据库（谨慎使用）
  static Future<void> deleteDatabase() async {
    await close();
    final path = await getDatabasePath();
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // 导出数据库信息
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      print('getDatabaseInfo: 开始获取数据库信息...');

      // 确保数据库被创建 - 访问数据库实例会触发创建
      final db = await database;
      print('getDatabaseInfo: 数据库实例获取成功');

      // 直接使用当前数据库实例的路径，这是最准确的
      final currentPath = db.path;
      print('getDatabaseInfo: 当前数据库路径: $currentPath');

      // 检查文件是否存在和大小
      final file = File(currentPath);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;

      print('getDatabaseInfo: 存在=$exists, 大小=$size');

      return {
        'path': currentPath,
        'exists': exists,
        'size': size,
        'version': _databaseVersion,
      };
    } catch (e) {
      print('getDatabaseInfo: 获取数据库信息失败: $e');
      return {
        'error': e.toString(),
        'path': '未知路径',
        'exists': false,
        'size': 0,
        'version': _databaseVersion,
      };
    }
  }
}