import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../settings/view/settings_page.dart';

// 年份选择状态管理
final _selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).loadTransactions();
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardTab(onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            }),
            _StatisticsTab(),
            _CategoriesTab(),
            _SettingsTab(),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddTransactionDialog,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: AppStrings.statisticsTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: AppStrings.categoriesTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: AppStrings.settingsTab,
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionBottomSheet(),
    );
  }
}

// 仪表板页面
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab({required this.onPageChanged});

  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部统计卡片
            _buildSummaryCards(context, ref),
            const SizedBox(height: 24),

            // 快速操作按钮
            _buildQuickActions(context, ref),
            const SizedBox(height: 24),

            // 最近交易
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最近交易',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onPageChanged(2); // 切换到分类标签页
                    },
                    child: const Text('查看全部'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentTransactions(context, ref),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateRange = DateRange(startOfMonth, endOfMonth);

    final totalIncome = ref.watch(totalIncomeProvider(dateRange));
    final totalExpense = ref.watch(totalExpenseProvider(dateRange));
    final netIncome = ref.watch(netIncomeProvider(dateRange));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: '本月收入',
              amount: '¥${totalIncome.toStringAsFixed(2)}',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: '本月支出',
              amount: '¥${totalExpense.toStringAsFixed(2)}',
              icon: Icons.trending_down,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: AppButton.primary(
              text: '记一笔',
              icon: Icons.add,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddTransactionBottomSheet(),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton.outlined(
              text: '查看统计',
              icon: Icons.bar_chart,
              onPressed: () {
                onPageChanged(1); // 切换到统计标签页
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref) {
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    if (recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无交易记录',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角的 + 按钮开始记账',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentTransactions.map((transaction) {
        return TransactionCard(
          title: categoryMap[transaction.categoryId] ?? '未知分类',
          subtitle: transaction.description,
          amount: transaction.amount.toStringAsFixed(2),
          category: categoryMap[transaction.categoryId] ?? '未知分类',
          categoryIcon: '💰', // 从分类提供者获取
          categoryColor: '#2196F3', // 从分类提供者获取
          date: DateFormat('MM-dd HH:mm').format(transaction.date),
          isIncome: transaction.type == TransactionType.income,
          onTap: () {
            // 查看详情（可选）
          },
        );
      }).toList(),
    );
  }
}

// 统计页面
class _StatisticsTab extends ConsumerWidget {
  const _StatisticsTab();

  // 构建年度统计项目
  Widget _buildYearStatItem(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 显示年份选择对话框
  void _showYearSelectorDialog(BuildContext context, WidgetRef ref) {
    final currentYear = DateTime.now().year;
    final selectedYear = ref.read(_selectedYearProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择年份'),
        content: SizedBox(
          width: double.infinity,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6, // 显示近6年
            itemBuilder: (context, index) {
              final year = currentYear - index;
              final isSelected = year == selectedYear;

              return InkWell(
                onTap: () {
                  ref.read(_selectedYearProvider.notifier).state = year;
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$year年',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateRange = DateRange(startOfMonth, endOfMonth);

    final totalIncome = ref.watch(totalIncomeProvider(dateRange));
    final totalExpense = ref.watch(totalExpenseProvider(dateRange));
    final netIncome = ref.watch(netIncomeProvider(dateRange));
    final transactions = ref.watch(transactionsByDateRangeProvider(dateRange));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '统计分析',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 月度总览
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: '本月收入',
                    amount: '¥${totalIncome.toStringAsFixed(2)}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: '本月支出',
                    amount: '¥${totalExpense.toStringAsFixed(2)}',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SummaryCard(
              title: '本月结余',
              amount: '¥${netIncome.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              color: netIncome >= 0 ? Colors.blue : Colors.orange,
            ),
            const SizedBox(height: 24),

            // 年度总览
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '年度统计 (${now.year}年)',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _showYearSelectorDialog(context, ref);
                        },
                        child: Text('切换年份'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final selectedYear = ref.watch(_selectedYearProvider);
                      final startOfYear = DateTime(selectedYear, 1, 1);
                      final endOfYear = DateTime(selectedYear + 1, 1, 0, 23, 59, 59);
                      final yearDateRange = DateRange(startOfYear, endOfYear);

                      final yearIncome = ref.watch(totalIncomeProvider(yearDateRange));
                      final yearExpense = ref.watch(totalExpenseProvider(yearDateRange));
                      final yearNetIncome = ref.watch(netIncomeProvider(yearDateRange));

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildYearStatItem(
                                  '年度收入',
                                  '¥${yearIncome.toStringAsFixed(2)}',
                                  Icons.trending_up,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildYearStatItem(
                                  '年度支出',
                                  '¥${yearExpense.toStringAsFixed(2)}',
                                  Icons.trending_down,
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildYearStatItem(
                            '年度结余',
                            '¥${yearNetIncome.toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                            yearNetIncome >= 0 ? Colors.blue : Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 交易详情
            Text(
              '本月交易明细',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: colors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '本月暂无交易记录',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击右下角的 + 按钮开始记账',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: transactions.map((transaction) {
                  final categoryMap = ref.watch(categoryMapProvider);
                  return TransactionCard(
                    title: categoryMap[transaction.categoryId] ?? '未知分类',
                    subtitle: transaction.description,
                    amount: transaction.amount.toStringAsFixed(2),
                    category: categoryMap[transaction.categoryId] ?? '未知分类',
                    categoryIcon: ref.watch(categoryIconProvider(transaction.categoryId)),
                    categoryColor: ref.watch(categoryColorProvider(transaction.categoryId)),
                    date: DateFormat('MM-dd HH:mm').format(transaction.date),
                    isIncome: transaction.type == TransactionType.income,
                  );
                }).toList(),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// 分类页面（全部交易）
class _CategoriesTab extends ConsumerStatefulWidget {
  const _CategoriesTab();

  @override
  ConsumerState<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<_CategoriesTab> {
  // 显示编辑交易对话框
  void _showEditTransactionDialog(BuildContext context, WidgetRef ref, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(transaction: transaction),
    ).then((result) {
      if (result == true) {
        // 编辑成功，刷新数据
        ref.read(transactionProvider.notifier).refresh();
      }
    });
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定要删除这条记录吗？\n${transaction.description}\n金额：¥${transaction.amount.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(transactionProvider.notifier).deleteTransaction(transaction.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final transactions = ref.watch(transactionProvider).transactions;
    final categoryMap = ref.watch(categoryMapProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '全部交易',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '共 ${transactions.length} 笔',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: colors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无交易记录',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击右下角的 + 按钮开始记账',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionCard(
                    title: categoryMap[transaction.categoryId] ?? '未知分类',
                    subtitle: transaction.description,
                    amount: transaction.amount.toStringAsFixed(2),
                    category: categoryMap[transaction.categoryId] ?? '未知分类',
                    categoryIcon: ref.watch(categoryIconProvider(transaction.categoryId)),
                    categoryColor: ref.watch(categoryColorProvider(transaction.categoryId)),
                    date: DateFormat('yyyy-MM-dd HH:mm').format(transaction.date),
                    isIncome: transaction.type == TransactionType.income,
                    onEdit: () {
                      _showEditTransactionDialog(context, ref, transaction);
                    },
                    onDelete: () {
                      _showDeleteConfirmDialog(context, ref, transaction);
                    },
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// 设置页面占位符
class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsPage();
  }
}

// 添加交易底部弹窗
class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends ConsumerState<AddTransactionBottomSheet> {
  TransactionType _transactionType = TransactionType.expense;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 默认选择第一个分类
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = _transactionType == TransactionType.expense
          ? ref.read(expenseCategoriesProvider)
          : ref.read(incomeCategoriesProvider);
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = categories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showMessage('请输入有效的金额');
      return;
    }

    if (_selectedCategoryId == null) {
      _showMessage('请选择分类');
      return;
    }

    try {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        type: _transactionType,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(transactionProvider.notifier).addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);
        _showMessage('记账成功');
      }
    } catch (e) {
      _showMessage('保存失败：$e');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final categories = _transactionType == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    // 获取键盘高度，为输入法预留空间
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // 动态调整高度，如果键盘弹出则使用全屏
      height: keyboardHeight > 0 ? screenHeight : screenHeight * 0.9,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖动指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colors.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                Text(
                  '添加记录',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _saveTransaction,
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              // 添加底部内边距，防止键盘遮挡内容
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 金额输入
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface.withOpacity(0.3),
                      ),
                      prefixText: '¥',
                      prefixStyle: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 收入/支出切换
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _transactionType == TransactionType.expense
                                ? colors.error.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _transactionType == TransactionType.expense
                                  ? colors.error
                                  : colors.outline,
                            ),
                          ),
                          child: AppButton.outlined(
                            text: '支出',
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                            onPressed: () {
                              setState(() {
                                _transactionType = TransactionType.expense;
                                _selectedCategoryId = null;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _transactionType == TransactionType.income
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _transactionType == TransactionType.income
                                  ? Colors.green
                                  : colors.outline,
                            ),
                          ),
                          child: AppButton.outlined(
                            text: '收入',
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                            onPressed: () {
                              setState(() {
                                _transactionType = TransactionType.income;
                                _selectedCategoryId = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 分类选择
                  Text(
                    '选择分类',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (categories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_outlined, color: colors.error),
                          const SizedBox(width: 8),
                          Text(
                            '暂无可用分类，请先添加分类',
                            style: TextStyle(color: colors.onErrorContainer),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = _selectedCategoryId == category.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withOpacity(0.1)
                                  : colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.outline,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected ? colors.primary : colors.onSurfaceVariant,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // 描述输入
                  Text(
                    '备注描述',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: '输入描述信息（可选）',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    // 添加键盘处理
                    onTap: () {
                      // 确保点击输入框时可以滚动到可见区域
                      Scrollable.ensureVisible(
                        context,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 时间选择
                  Text(
                    '选择时间',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '选择日期和时间',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 编辑交易对话框
class EditTransactionDialog extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionDialog({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends ConsumerState<EditTransactionDialog> {
  late TransactionType _transactionType;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _transactionType = widget.transaction.type;
    _amountController.text = widget.transaction.amount.toString();
    _descriptionController.text = widget.transaction.description;
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.date;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = _transactionType == TransactionType.expense
          ? ref.read(expenseCategoriesProvider)
          : ref.read(incomeCategoriesProvider);
      if (categories.isNotEmpty && _selectedCategoryId == null) {
        setState(() {
          _selectedCategoryId = categories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showMessage("请输入有效的金额");
      return;
    }

    if (_selectedCategoryId == null) {
      _showMessage("请选择分类");
      return;
    }

    try {
      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        amount: amount,
        type: _transactionType,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        createdAt: widget.transaction.createdAt,
        updatedAt: DateTime.now(),
      );

      await ref.read(transactionProvider.notifier).updateTransaction(updatedTransaction);

      if (mounted) {
        Navigator.pop(context, true);
        _showMessage("更新成功");
      }
    } catch (e) {
      _showMessage("更新失败: $e");
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Text(
                  "编辑记录",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 类型选择
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _transactionType = TransactionType.expense;
                        _selectedCategoryId = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _transactionType == TransactionType.expense
                            ? colors.error.withOpacity(0.1)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _transactionType == TransactionType.expense
                              ? colors.error
                              : colors.outline,
                        ),
                      ),
                      child: Text(
                        "支出",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _transactionType == TransactionType.expense
                              ? colors.error
                              : colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _transactionType = TransactionType.income;
                        _selectedCategoryId = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _transactionType == TransactionType.income
                            ? Colors.green.withOpacity(0.1)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _transactionType == TransactionType.income
                              ? Colors.green
                              : colors.outline,
                        ),
                      ),
                      child: Text(
                        "收入",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _transactionType == TransactionType.income
                              ? Colors.green
                              : colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 金额输入
            Text(
              "金额",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "0.00",
                prefixText: "¥ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 分类选择
            Text(
              "分类",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final categories = _transactionType == TransactionType.expense
                    ? ref.watch(expenseCategoriesProvider)
                    : ref.watch(incomeCategoriesProvider);

                if (categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Text(
                      "暂无分类",
                      style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: [
                          Text(category.icon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // 描述输入
            Text(
              "备注",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "添加备注...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 日期时间选择
            Text(
              "时间",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: colors.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat("yyyy-MM-dd HH:mm").format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: colors.onSurface.withOpacity(0.6)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("取消"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    child: const Text("保存"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
