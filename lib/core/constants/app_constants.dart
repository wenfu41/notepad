class AppConstants {
  // 应用信息
  static const String appName = '记账助手';
  static const String appVersion = '1.0.0';
  static const String appDescription = '一个美观实用的记账应用';

  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm:ss';
  static const String monthYearFormat = 'yyyy年MM月';
  static const String yearFormat = 'yyyy年';

  // 货币格式
  static const String currencySymbol = '¥';
  static const String currencyFormat = '#,##0.00';

  // 默认值
  static const int defaultPageSize = 20;
  static const double defaultFontSize = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;

  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 网络相关
  static const int networkTimeout = 30000; // 30秒
  static const int retryAttempts = 3;

  // 文件路径
  static const String backupFolder = 'backups';
  static const String exportFileNamePrefix = 'expense_tracker_backup';
  static const String exportDateFormat = 'yyyyMMdd_HHmmss';

  // 本地存储键
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefCurrencySymbol = 'currency_symbol';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLastBackupDate = 'last_backup_date';
  static const String prefAutoBackup = 'auto_backup';
  static const String prefBudgetReminder = 'budget_reminder';

  // 通知相关
  static const String notificationChannelId = 'expense_tracker_notifications';
  static const String notificationChannelName = '记账助手通知';
  static const String notificationChannelDescription = '记账提醒和预算提醒';

  // 分享相关
  static const String shareSubject = '记账助手 - 我的使用体验';
  static const String shareText = '我正在使用记账助手应用，非常好用的记账工具！';

  // 支持链接
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'support@example.com';

  // 数据验证
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 99999999.99;
  static const int maxDescriptionLength = 200;
  static const int maxCategoryNameLength = 20;

  // 图表配置
  static const int chartDefaultMonths = 6;
  static const int chartMaxDataPoints = 12;
  static const double chartAnimationDuration = 1000.0;

  // 预算相关
  static const double defaultBudgetPercentage = 80.0; // 80%预算警告
  static const double overBudgetPercentage = 100.0; // 100%超支警告

  // 统计相关
  static int get statisticsDefaultYear => DateTime.now().year;
  static int get statisticsDefaultMonth => DateTime.now().month;

  // 错误代码
  static const int errorCodeGeneral = 1000;
  static const int errorCodeNetwork = 1001;
  static const int errorCodeDatabase = 1002;
  static const int errorCodeFileNotFound = 1003;
  static const int errorCodePermissionDenied = 1004;
  static const int errorCodeInvalidData = 1005;

  // 成功代码
  static const int successCode = 200;

  // 调试模式
  static const bool isDebugMode = true;
  static const String debugTag = 'ExpenseTracker';
}

class AppRoutes {
  static const String home = '/home';
  static const String addTransaction = '/add_transaction';
  static const String editTransaction = '/edit_transaction';
  static const String categories = '/categories';
  static const String addCategory = '/add_category';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String backup = '/backup';
  static const String about = '/about';

  // 命名参数
  static const String paramTransactionId = 'transaction_id';
  static const String paramCategoryId = 'category_id';
  static const String paramDate = 'date';
  static const String paramTransactionType = 'transaction_type';
}

class AppStrings {
  // 通用
  static const String appName = AppConstants.appName;
  static const String ok = '确定';
  static const String cancel = '取消';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String add = '添加';
  static const String update = '更新';
  static const String search = '搜索';
  static const String filter = '筛选';
  static const String clear = '清空';
  static const String done = '完成';
  static const String back = '返回';
  static const String next = '下一步';
  static const String previous = '上一步';
  static const String loading = '加载中...';
  static const String error = '错误';
  static const String success = '成功';
  static const String warning = '警告';
  static const String info = '提示';

  // 底部导航
  static const String homeTab = '首页';
  static const String statisticsTab = '统计';
  static const String categoriesTab = '分类';
  static const String settingsTab = '设置';

  // 交易相关
  static const String income = '收入';
  static const String expense = '支出';
  static const String amount = '金额';
  static const String category = '分类';
  static const String description = '备注';
  static const String date = '日期';
  static const String today = '今天';
  static const String yesterday = '昨天';
  static const String thisWeek = '本周';
  static const String thisMonth = '本月';
  static const String thisYear = '今年';
  static const String addTransaction = '添加记录';
  static const String editTransaction = '编辑记录';
  static const String deleteTransaction = '删除记录';
  static const String noTransactions = '暂无记录';

  // 预算相关
  static const String budget = '预算';
  static const String monthlyBudget = '月度预算';
  static const String categoryBudget = '分类预算';
  static const String budgetRemaining = '剩余预算';
  static const String budgetUsed = '已使用';
  static const String budgetExceeded = '超出预算';
  static const String budgetWarning = '预算警告';

  // 统计相关
  static const String statistics = '统计';
  static const String monthlyStatistics = '月度统计';
  static const String yearlyStatistics = '年度统计';
  static const String totalIncome = '总收入';
  static const String totalExpense = '总支出';
  static const String netAmount = '净收入';
  static const String averageSpending = '平均支出';
  static const String trendAnalysis = '趋势分析';

  // 分类相关
  static const String categories = '分类';
  static const String addCategory = '添加分类';
  static const String editCategory = '编辑分类';
  static const String deleteCategory = '删除分类';
  static const String categoryName = '分类名称';
  static const String categoryIcon = '分类图标';
  static const String categoryColor = '分类颜色';
  static const String defaultCategories = '默认分类';
  static const String customCategories = '自定义分类';

  // 设置相关
  static const String settings = '设置';
  static const String general = '通用';
  static const String appearance = '外观';
  static const String dataManagement = '数据管理';
  static const String backup = '备份';
  static const String restore = '恢复';
  static const String export = '导出';
  static const String import = '导入';
  static const String theme = '主题';
  static const String language = '语言';
  static const String currency = '货币';
  static const String notifications = '通知';

  // 消息提示
  static const String deleteConfirm = '确定要删除这条记录吗？';
  static const String deleteSuccess = '删除成功';
  static const String saveSuccess = '保存成功';
  static const String updateSuccess = '更新成功';
  static const String addSuccess = '添加成功';
  static const String invalidAmount = '请输入有效金额';
  static const String invalidCategory = '请选择分类';
  static const String networkError = '网络错误，请检查网络连接';
  static const String databaseError = '数据库错误';
  static const String noData = '暂无数据';
  static const String loadingFailed = '加载失败';
}