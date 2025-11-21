import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/home/view/home_page.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/category_provider.dart';
import 'core/database/persistent_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 请求存储权限
  await _requestStoragePermission();

  // 初始化数据库
  await PersistentDatabaseHelper.database;

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// 请求存储权限
Future<void> _requestStoragePermission() async {
  try {
    // Android 11+ 需要请求管理外部存储权限
    if (await Permission.storage.isPermanentlyDenied) {
      // 用户永久拒绝了权限，显示引导用户去设置页面开启权限的对话框
      openAppSettings();
      return;
    }

    // 请求存储权限
    final storageStatus = await Permission.storage.request();
    final manageStorageStatus = await Permission.manageExternalStorage.request();

    if (storageStatus.isPermanentlyDenied || manageStorageStatus.isPermanentlyDenied) {
      // 如果用户永久拒绝，引导用户去设置页面
      openAppSettings();
    } else if (!storageStatus.isGranted && !manageStorageStatus.isGranted) {
      print('存储权限被拒绝，数据将保存在应用内部存储');
    } else {
      print('存储权限已授予');
    }
  } catch (e) {
    print('请求权限时发生错误: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
