import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../constants/database_constants.dart';

class CustomDatabaseHelper {
  static const String _databaseName = 'expense_tracker_persistent.db';
  static const int _databaseVersion = 1;
  static Database? _database;
  static String? _customPath;

  // 设置自定义数据库路径
  static Future<void> setCustomPath(String path) async {
    try {
      _customPath = path;
      // 关闭当前数据库连接
      await close();
      print('自定义数据库路径设置: $path');
    } catch (e) {
      print('设置自定义路径失败: $e');
    }
  }

  // 获取自定义数据库路径
  static String? getCustomPath() {
    return _customPath;
  }

  // 重置为默认路径
  static Future<void> resetToDefault() async {
    _customPath = null;
    await close();
    print('重置为默认数据库路径');
  }

  // 获取数据库实例
  static Future<Database> get database async {
    if (_database == null) {
      print('正在初始化自定义数据库...');
      _database = await _initCustomDatabase();
      print('自定义数据库初始化完成');
    }
    return _database!;
  }

  // 初始化自定义数据库
  static Future<Database> _initCustomDatabase() async {
    Directory? directory;
    String path;

    try {
      if (_customPath != null && _customPath!.isNotEmpty) {
        // 使用自定义路径
        directory = Directory(_customPath!);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        path = join(directory.path, _databaseName);
        print('使用自定义路径: $path');
      } else {
        // 使用默认路径（应用内部存储）
        directory = await getApplicationDocumentsDirectory();
        directory = Directory(join(directory.path, 'expense_tracker_data'));
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        path = join(directory.path, _databaseName);
        print('使用默认路径: $path');
      }

      print('准备打开自定义数据库...');

      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );

      print('自定义数据库打开成功!');
      return db;
    } catch (e) {
      print('初始化自定义数据库失败: $e');
      rethrow;
    }
  }

  // 创建数据库表
  static Future<void> _createDatabase(Database db, int version) async {
    print('创建自定义数据库表结构...');
    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建交易表
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    print('自定义数据库表创建完成!');
  }

  // 升级数据库
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    print('升级数据库从版本 $oldVersion 到 $newVersion');
  }

  // 关闭数据库
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // 获取当前数据库路径
  static Future<String> getCurrentDatabasePath() async {
    if (_customPath != null && _customPath!.isNotEmpty) {
      return join(_customPath!, _databaseName);
    }
    // 使用默认路径
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'expense_tracker_data', _databaseName);
  }

  // 检查数据库是否存在
  static Future<bool> databaseExists() async {
    try {
      final path = await getCurrentDatabasePath();
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // 获取数据库文件大小
  static Future<int> getDatabaseSize() async {
    try {
      final path = await getCurrentDatabasePath();
      final file = File(path);

      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}