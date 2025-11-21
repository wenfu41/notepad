import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

// 分类服务提供者
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

// 分类状态
class CategoryState {
  final List<Category> categories;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  final bool isLoading;
  final String? error;

  const CategoryState({
    required this.categories,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.isLoading,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? categories,
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryState &&
        other.categories == categories &&
        other.expenseCategories == expenseCategories &&
        other.incomeCategories == incomeCategories &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return categories.hashCode ^
        expenseCategories.hashCode ^
        incomeCategories.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }
}

// 分类状态提供者
class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService _categoryService;

  CategoryNotifier(this._categoryService) : super(const CategoryState(
    categories: [],
    expenseCategories: [],
    incomeCategories: [],
    isLoading: false,
  ));

  // 获取所有分类
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _categoryService.getAllCategories();
      final expenseCategories = await _categoryService.getExpenseCategories();
      final incomeCategories = await _categoryService.getIncomeCategories();

      state = state.copyWith(
        categories: categories,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 根据ID获取分类
  Category? getCategoryById(String id) {
    try {
      return state.categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // 添加分类
  Future<void> addCategory(Category category) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _categoryService.addCategory(category);
      await loadCategories(); // 重新加载数据
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 更新分类
  Future<void> updateCategory(Category category) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _categoryService.updateCategory(category);
      await loadCategories(); // 重新加载数据
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 删除分类
  Future<void> deleteCategory(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories(); // 重新加载数据
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 搜索分类
  Future<void> searchCategories(String searchTerm) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _categoryService.searchCategories(searchTerm);
      final expenseCategories = categories.where((c) => _isExpenseCategory(c.id)).toList();
      final incomeCategories = categories.where((c) => _isIncomeCategory(c.id)).toList();

      state = state.copyWith(
        categories: categories,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 重新排序分类
  Future<void> reorderCategories(List<Category> categories) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _categoryService.reorderCategories(categories);
      await loadCategories(); // 重新加载数据
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadCategories();
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 判断是否为支出分类
  bool _isExpenseCategory(String categoryId) {
    final expenseCategoryIds = [
      'food', 'transport', 'shopping', 'entertainment',
      'health', 'education', 'housing', 'utilities',
      'communication', 'other'
    ];
    return expenseCategoryIds.contains(categoryId);
  }

  // 判断是否为收入分类
  bool _isIncomeCategory(String categoryId) {
    final incomeCategoryIds = [
      'salary', 'bonus', 'investment', 'partTime',
      'gift', 'refund', 'otherIncome'
    ];
    return incomeCategoryIds.contains(categoryId);
  }
}

// 分类提供者
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoryNotifier(categoryService);
});

// 支出分类提供者
final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryProvider).expenseCategories;
});

// 收入分类提供者
final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryProvider).incomeCategories;
});

// 默认分类提供者
final defaultCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return categories.where((c) => c.isDefault).toList();
});

// 自定义分类提供者
final customCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return categories.where((c) => !c.isDefault).toList();
});

// 根据ID获取分类提供者
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categories = ref.watch(categoryProvider).categories;
  try {
    return categories.firstWhere((category) => category.id == id);
  } catch (e) {
    return null;
  }
});

// 分类映射提供者（ID -> 名称）
final categoryMapProvider = Provider<Map<String, String>>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return {for (var category in categories) category.id: category.name};
});

// 分类颜色映射提供者（ID -> 颜色）
final categoryColorMapProvider = Provider<Map<String, String>>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return {for (var category in categories) category.id: category.color};
});

// 分类图标映射提供者（ID -> 图标）
final categoryIconMapProvider = Provider<Map<String, String>>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return {for (var category in categories) category.id: category.icon};
});

// 分类计数提供者
final categoryCountProvider = Provider<int>((ref) {
  return ref.watch(categoryProvider).categories.length;
});

// 默认分类计数提供者
final defaultCategoryCountProvider = Provider<int>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return categories.where((c) => c.isDefault).length;
});

// 自定义分类计数提供者
final customCategoryCountProvider = Provider<int>((ref) {
  final categories = ref.watch(categoryProvider).categories;
  return categories.where((c) => !c.isDefault).length;
});

// 搜索分类提供者
final searchedCategoriesProvider = FutureProvider.family<List<Category>, String>((ref, searchTerm) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return await categoryService.searchCategories(searchTerm);
});

// 分类名称提供者
final categoryNameProvider = Provider.family<String, String>((ref, categoryId) {
  final categoryMap = ref.watch(categoryMapProvider);
  return categoryMap[categoryId] ?? '未知分类';
});

// 分类颜色提供者
final categoryColorProvider = Provider.family<String, String>((ref, categoryId) {
  final categoryColorMap = ref.watch(categoryColorMapProvider);
  return categoryColorMap[categoryId] ?? '#2196F3';
});

// 分类图标提供者
final categoryIconProvider = Provider.family<String, String>((ref, categoryId) {
  final categoryIconMap = ref.watch(categoryIconMapProvider);
  return categoryIconMap[categoryId] ?? '📦';
});