import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/persistent_database_helper.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/services/category_service.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastBackupTime;
  int _totalTransactions = 0;
  int _totalCategories = 0;

  @override
  void initState() {
    super.initState();
    _loadDataInfo();
  }

  Future<void> _loadDataInfo() async {
    try {
      final transactionService = TransactionService();
      final categoryService = CategoryService();

      final transactions = await transactionService.getAllTransactions();
      final categories = await categoryService.getAllCategories();

      // 使用 PersistentDatabaseHelper 获取数据库信息
      final dbInfo = await PersistentDatabaseHelper.getDatabaseInfo();
      final dbExists = dbInfo['exists'] as bool;
      final dbSize = dbInfo['size'] as int;
      final dbPath = dbInfo['path'] as String;

      print('_loadDataInfo: 数据库路径=$dbPath, 存在=$dbExists');

      String? lastBackupTime;
      if (dbExists) {
        final file = File(dbPath);
        if (await file.exists()) {
          final stat = await file.stat();
          lastBackupTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(stat.modified);
        }
      }

      if (mounted) {
        setState(() {
          _totalTransactions = transactions.length;
          _totalCategories = categories.length;
          _lastBackupTime = lastBackupTime;
        });
      }
    } catch (e) {
      print('_loadDataInfo: 错误=$e');
      if (mounted) {
        setState(() {
          _lastBackupTime = '获取数据信息失败';
        });
      }
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // 导出数据库
      final backupPath = await PersistentDatabaseHelper.backupDatabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('数据导出成功！\n文件位置: $backupPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // 更新最后备份时间
        await _loadDataInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('数据导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _showImportDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('导入数据'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('导入数据将覆盖当前所有数据！'),
                Text('请确保要导入的备份文件是有效的。'),
                SizedBox(height: 16),
                Text('备份文件通常位于：'),
                Text('/storage/emulated/0/Download/ExpenseTracker_Backup/'),
                SizedBox(height: 8),
                Text('文件名格式：backup_时间戳.db'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定导入'),
              onPressed: () {
                Navigator.of(context).pop();
                _importData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
    });

    try {
      // 这里应该让用户选择备份文件，但为了简化，我们使用最新的备份文件
      final backupDir = '/storage/emulated/0/Download/ExpenseTracker_Backup';
      final directory = Directory(backupDir);

      if (!await directory.exists()) {
        throw Exception('备份目录不存在');
      }

      final files = await directory.list().where((f) => f.path.endsWith('.db')).toList();

      if (files.isEmpty) {
        throw Exception('没有找到备份文件');
      }

      // 按修改时间排序，选择最新的备份文件
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      final latestBackup = files.first.path;

      await PersistentDatabaseHelper.restoreDatabase(latestBackup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据导入成功！应用将重新加载数据。'),
            backgroundColor: Colors.green,
          ),
        );

        // 重新加载数据
        await _loadDataInfo();
        ref.invalidate(transactionProvider);
        ref.invalidate(categoryProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('数据导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  
  void _showDatabaseInfo() async {
    try {
      final dbInfo = await PersistentDatabaseHelper.getDatabaseInfo();
      final path = dbInfo['path'] as String;
      final size = dbInfo['size'] as int;
      final exists = dbInfo['exists'] as bool;
      final version = dbInfo['version'] as int?;

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('数据库信息'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('数据库路径: $path'),
                const SizedBox(height: 8),
                Text('数据库状态: ${exists ? "存在" : "不存在"}'),
                const SizedBox(height: 8),
                Text('文件大小: ${(size / 1024).toStringAsFixed(2)} KB'),
                const SizedBox(height: 8),
                Text('数据库版本: ${version ?? "未知"}'),
                const SizedBox(height: 8),
                Text('最后备份: ${_lastBackupTime ?? "无备份记录"}'),
                const SizedBox(height: 8),
                Text('交易记录数量: $_totalTransactions'),
                const SizedBox(height: 8),
                Text('分类数量: $_totalCategories'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取数据库信息失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 数据概览
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数据概览',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          '交易记录',
                          '$_totalTransactions',
                          Icons.receipt_long,
                          colors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDataItem(
                          '分类',
                          '$_totalCategories',
                          Icons.category,
                          colors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextButton(
                          text: '查看数据库信息',
                          onPressed: _showDatabaseInfo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            
            // 数据库存储位置
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数据库存储位置',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      return FutureBuilder<Map<String, dynamic>>(
                        future: PersistentDatabaseHelper.getDatabaseInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.hasError) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '无法获取数据库路径信息',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.error,
                                ),
                              ),
                            );
                          }

                          final dbInfo = snapshot.data!;
                          final currentPath = dbInfo['path'] as String? ?? '未知路径';
                          final exists = dbInfo['exists'] as bool? ?? false;
                          final size = (dbInfo['size'] as int? ?? 0) / 1024;

                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: exists
                                      ? colors.primary.withOpacity(0.1)
                                      : colors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storage,
                                          color: exists ? colors.primary : colors.error,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '当前路径:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: exists ? colors.primary : colors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentPath,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '状态: ${exists ? "正常" : "不存在"}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: exists ? colors.primary : colors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '大小: ${size.toStringAsFixed(2)} KB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.onSurface.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: AppButton.outlined(
                                  text: '选择存储位置',
                                  icon: Icons.folder_open,
                                  onPressed: _selectDatabaseLocation,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton.outlined(
                                      text: '备份数据',
                                      icon: Icons.backup,
                                      onPressed: _exportData,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppButton.outlined(
                                      text: '恢复数据',
                                      icon: Icons.restore,
                                      isLoading: _isImporting,
                                      onPressed: _importData,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: AppTextButton(
                                  text: '重置为默认位置',
                                  onPressed: _resetToDefaultLocation,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 应用信息
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '应用信息',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem('应用名称', '记账助手'),
                  _buildInfoItem('版本', '1.0.0'),
                  _buildInfoItem('数据存储', '外部存储（数据持久化）'),
                  _buildInfoItem('数据库', 'SQLite'),
                  if (_lastBackupTime != null)
                    _buildInfoItem('最后备份', _lastBackupTime!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // 获取当前数据库信息（确保实时更新）
  Future<Map<String, dynamic>> _getCurrentDatabaseInfo() async {
    try {
      // 直接获取当前数据库实例的路径，这是最准确的
      final db = await PersistentDatabaseHelper.database;
      final currentPath = db.path;

      // 检查文件是否存在和大小
      final file = File(currentPath);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;

      print('_getCurrentDatabaseInfo: 路径=$currentPath, 存在=$exists, 大小=$size');

      return {
        'path': currentPath,
        'exists': exists,
        'size': size,
        'version': 1,
      };
    } catch (e) {
      print('_getCurrentDatabaseInfo: 错误=$e');
      return {
        'path': '获取失败',
        'exists': false,
        'size': 0,
        'version': 1,
        'error': e.toString(),
      };
    }
  }

  // 选择数据库存储位置
  Future<void> _selectDatabaseLocation() async {
    try {
      // 使用文件选择器选择文件夹
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择数据库存储位置',
        lockParentWindow: true,
      );

      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        // 确认选择
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认选择'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('您确定要将数据库存储位置设置为：'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    selectedDirectory,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '这将需要重新启动应用才能生效。\n\n'
                  '注意：如果选择的位置没有存储权限，应用将自动回退到内部存储。',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            // 保存自定义路径到SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('custom_database_path', selectedDirectory);

            // 立即重新初始化数据库以使用新路径
            await PersistentDatabaseHelper.forceReinitialize();

            // 重新加载数据
            await _loadDataInfo();
            ref.invalidate(transactionProvider);
            ref.invalidate(categoryProvider);

            if (mounted) {
              setState(() {}); // 刷新界面
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ 数据库位置已成功切换到：$selectedDirectory\n\n新数据库已初始化完成！'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          } catch (e) {
            // 如果切换失败，清除保存的路径
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('custom_database_path');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ 数据库位置切换失败：$e\n\n已恢复为默认路径'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择存储位置失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 重置为默认存储位置
  Future<void> _resetToDefaultLocation() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('重置位置'),
          content: const Text(
            '确定要将数据库存储位置重置为默认的外部存储吗？\n\n'
            '默认位置：/storage/emulated/0/1bb/expense_tracker_data/\n\n'
            '这将需要重新启动应用才能生效。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('确定重置'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          // 清除自定义路径设置
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('custom_database_path');

          // 立即重新初始化数据库以使用默认路径
          await PersistentDatabaseHelper.forceReinitialize();

          // 重新加载数据
          await _loadDataInfo();
          ref.invalidate(transactionProvider);
          ref.invalidate(categoryProvider);

          if (mounted) {
            setState(() {}); // 刷新界面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ 已成功重置为默认位置\n\n数据库已切换到默认路径！'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ 重置失败：$e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重置失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}