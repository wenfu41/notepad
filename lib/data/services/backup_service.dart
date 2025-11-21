import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'excel.dart';
import '../../core/database/persistent_database_helper.dart';

class BackupService {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  // 检查存储权限
  Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 30) {
        // Android 11+ 需要所有文件访问权限
        final permission = await Permission.manageExternalStorage.request();
        return permission.isGranted;
      } else {
        // Android 10 及以下
        final permission = await Permission.storage.request();
        return permission.isGranted;
      }
    }
    return true; // iOS 不需要特殊权限
  }

  // 获取 Android 版本
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // 简化版本获取，实际应用中可以使用 device_info_plus 包
      return 29; // 假设为 Android 10
    }
    return 0;
  }

  // 导出数据到 Excel 文件
  Future<String> exportToExcel() async {
    try {
      // 检查权限
      final hasPermission = await checkStoragePermission();
      if (!hasPermission) {
        throw Exception('需要存储权限才能导出数据');
      }

      // 创建 Excel 文件
      final excel = Excel.createExcel();

      // 删除默认工作表
      excel.delete('Sheet1');

      // 导出分类数据
      await _exportCategoriesToExcel(excel);

      // 导出交易数据
      await _exportTransactionsToExcel(excel);

      // 获取导出目录
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'expense_tracker_export_$timestamp.xlsx';
      final filePath = path.join(exportDir.path, fileName);

      // 保存文件
      final file = File(filePath);
      await file.writeAsBytes(excel.save()!);

      print('Excel 导出成功: $filePath');
      return filePath;
    } catch (e) {
      throw Exception('导出 Excel 失败: $e');
    }
  }

  // 导出分类到 Excel
  Future<void> _exportCategoriesToExcel(Excel excel) async {
    try {
      final categories = await _categoryService.getAllCategories();
      final sheet = excel['分类'];

      // 设置表头
      final headers = [
        '分类ID', '分类名称', '图标', '颜色', '排序顺序', '是否默认', '创建时间', '更新时间'
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = headers[i];
      }

      // 填充数据
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = category.id;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = category.name;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = category.icon;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = category.color;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = category.sortOrder;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = category.isDefault ? 1 : 0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
            .value = _formatDateTime(category.createdAt);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
            .value = _formatDateTime(category.updatedAt);
      }
    } catch (e) {
      throw Exception('导出分类数据失败: $e');
    }
  }

  // 导出交易到 Excel
  Future<void> _exportTransactionsToExcel(Excel excel) async {
    try {
      final transactions = await _transactionService.getAllTransactions();
      final sheet = excel['交易记录'];

      // 设置表头
      final headers = [
        '交易ID', '金额', '类型', '分类ID', '备注', '日期', '创建时间', '更新时间'
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = headers[i];
      }

      // 填充数据
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = transaction.id;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = transaction.amount;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = transaction.type.name;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = transaction.categoryId;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = transaction.description;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = _formatDateTime(transaction.date);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
            .value = _formatDateTime(transaction.createdAt);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
            .value = _formatDateTime(transaction.updatedAt);
      }
    } catch (e) {
      throw Exception('导出交易数据失败: $e');
    }
  }

  // 从 Excel 导入数据
  Future<void> importFromExcel(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // 导入分类数据
      await _importCategoriesFromExcel(excel);

      // 导入交易数据
      await _importTransactionsFromExcel(excel);

      print('Excel 导入成功: $filePath');
    } catch (e) {
      throw Exception('导入 Excel 失败: $e');
    }
  }

  // 从 Excel 导入分类数据
  Future<void> _importCategoriesFromExcel(Excel excel) async {
    try {
      final sheet = excel.sheets['分类'];
      if (sheet == null) return;

      final categories = <Category>[];

      // 跳过表头，从第二行开始读取
      for (int row = 1; row <= sheet.maxRows; row++) {
        try {
          final id = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .value?.toString() ?? '';
          final name = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value?.toString() ?? '';
          final icon = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .value?.toString() ?? '';
          final color = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
              .value?.toString() ?? '#2196F3';
          final sortOrder = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
              .value ?? 0;
          final isDefault = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
              .value == 1;

          final createdAtStr = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
              .value?.toString() ?? '';
          final updatedAtStr = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
              .value?.toString() ?? '';

          if (id.isNotEmpty && name.isNotEmpty) {
            categories.add(Category(
              id: id,
              name: name,
              icon: icon,
              color: color,
              sortOrder: sortOrder is int ? sortOrder : 0,
              isDefault: isDefault,
              createdAt: _parseDateTime(createdAtStr),
              updatedAt: _parseDateTime(updatedAtStr),
            ));
          }
        } catch (e) {
          print('跳过行 $row: $e');
        }
      }

      // 批量插入分类
      for (final category in categories) {
        try {
          await _categoryService.addCategory(category);
        } catch (e) {
          print('插入分类失败 ${category.name}: $e');
        }
      }
    } catch (e) {
      throw Exception('导入分类数据失败: $e');
    }
  }

  // 从 Excel 导入交易数据
  Future<void> _importTransactionsFromExcel(Excel excel) async {
    try {
      final sheet = excel.sheets['交易记录'];
      if (sheet == null) return;

      final transactions = <Transaction>[];

      // 跳过表头，从第二行开始读取
      for (int row = 1; row <= sheet.maxRows; row++) {
        try {
          final id = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .value?.toString() ?? '';
          final amount = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value is num ? (sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value as num).toDouble() : 0.0;
          final typeStr = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .value?.toString() ?? 'expense';
          final categoryId = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
              .value?.toString() ?? '';
          final description = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
              .value?.toString() ?? '';

          final dateStr = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
              .value?.toString() ?? '';
          final createdAtStr = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
              .value?.toString() ?? '';
          final updatedAtStr = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
              .value?.toString() ?? '';

          if (id.isNotEmpty && categoryId.isNotEmpty) {
            final type = typeStr.toLowerCase() == 'income'
                ? TransactionType.income
                : TransactionType.expense;

            transactions.add(Transaction(
              id: id,
              amount: amount,
              type: type,
              categoryId: categoryId,
              description: description,
              date: _parseDateTime(dateStr),
              createdAt: _parseDateTime(createdAtStr),
              updatedAt: _parseDateTime(updatedAtStr),
            ));
          }
        } catch (e) {
          print('跳过行 $row: $e');
        }
      }

      // 批量插入交易记录
      await _transactionService.addTransactions(transactions);
    } catch (e) {
      throw Exception('导入交易数据失败: $e');
    }
  }

  // 备份数据库文件
  Future<String> backupDatabase() async {
    try {
      final hasPermission = await checkStoragePermission();
      if (!hasPermission) {
        throw Exception('需要存储权限才能备份数据库');
      }

      return await PersistentDatabaseHelper.backupDatabase();
    } catch (e) {
      throw Exception('备份数据库失败: $e');
    }
  }

  // 从备份恢复数据库
  Future<void> restoreDatabase(String backupPath) async {
    try {
      final hasPermission = await checkStoragePermission();
      if (!hasPermission) {
        throw Exception('需要存储权限才能恢复数据库');
      }

      await PersistentDatabaseHelper.restoreDatabase(backupPath);
    } catch (e) {
      throw Exception('恢复数据库失败: $e');
    }
  }

  // 获取导出目录
  Future<Directory> _getExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        // 尝试获取公共下载目录
        final downloadDir = Directory('/storage/emulated/0/Download/ExpenseTracker');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }

      // iOS 或其他平台
      final documentsDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(path.join(documentsDir.path, 'exports'));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    } catch (e) {
      // 回退到应用内部目录
      final documentsDir = await getApplicationDocumentsDirectory();
      return Directory(path.join(documentsDir.path, 'exports'));
    }
  }

  // 获取备份文件列表
  Future<List<FileInfo>> getBackupFiles() async {
    try {
      final exportDir = await _getExportDirectory();
      final files = <FileInfo>[];

      await for (final entity in exportDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          files.add(FileInfo(
            path: entity.path,
            name: path.basename(entity.path),
            size: stat.size,
            modified: stat.modified,
          ));
        }
      }

      // 按修改时间倒序排列
      files.sort((a, b) => b.modified.compareTo(a.modified));
      return files;
    } catch (e) {
      throw Exception('获取备份文件列表失败: $e');
    }
  }

  // 删除备份文件
  Future<void> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('删除备份文件失败: $e');
    }
  }

  // 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  // 解析日期时间
  DateTime _parseDateTime(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return DateTime.now();
    }
  }
}

// 文件信息类
class FileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime modified;

  FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}