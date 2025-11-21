import '../models/category.dart';
import '../../core/database/database_service.dart';
import '../../core/database/persistent_database_helper.dart';
import '../../core/constants/database_constants.dart';

class CategoryService {
  final DatabaseService _databaseService = DatabaseService();

  // 获取所有分类
  Future<List<Category>> getAllCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.categoriesTable,
        orderBy: '${DatabaseConstants.columnSortOrder} ASC, ${DatabaseConstants.columnName} ASC',
      );

      return maps.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取分类列表失败: $e');
    }
  }

  // 按类型获取分类
  Future<List<Category>> getCategoriesByType(String type) async {
    try {
      // 由于我们在数据库中没有直接的type字段，需要根据分类ID来判断
      final allCategories = await getAllCategories();

      // 根据分类ID前缀或者预定义列表来区分收入和支出分类
      final expenseCategoryIds = [
        'food', 'transport', 'shopping', 'entertainment',
        'health', 'education', 'housing', 'utilities',
        'communication', 'other'
      ];

      final incomeCategoryIds = [
        'salary', 'bonus', 'investment', 'partTime',
        'gift', 'refund', 'otherIncome'
      ];

      if (type == 'expense') {
        return allCategories.where((category) =>
          expenseCategoryIds.contains(category.id)
        ).toList();
      } else if (type == 'income') {
        return allCategories.where((category) =>
          incomeCategoryIds.contains(category.id)
        ).toList();
      }

      return allCategories;
    } catch (e) {
      throw Exception('按类型获取分类失败: $e');
    }
  }

  // 获取支出分类
  Future<List<Category>> getExpenseCategories() async {
    return await getCategoriesByType('expense');
  }

  // 获取收入分类
  Future<List<Category>> getIncomeCategories() async {
    return await getCategoriesByType('income');
  }

  // 获取默认分类
  Future<List<Category>> getDefaultCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnIsDefault} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseConstants.columnSortOrder} ASC',
      );

      return maps.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取默认分类失败: $e');
    }
  }

  // 获取自定义分类
  Future<List<Category>> getCustomCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnIsDefault} = ?',
        whereArgs: [0],
        orderBy: '${DatabaseConstants.columnSortOrder} ASC, ${DatabaseConstants.columnName} ASC',
      );

      return maps.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      throw Exception('获取自定义分类失败: $e');
    }
  }

  // 根据ID获取分类
  Future<Category?> getCategoryById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.query(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Category.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('获取分类失败: $e');
    }
  }

  // 添加分类
  Future<String> addCategory(Category category) async {
    try {
      // 检查分类名称是否已存在
      final existingCategories = await getAllCategories();
      final nameExists = existingCategories.any((c) =>
        c.name.toLowerCase() == category.name.toLowerCase()
      );

      if (nameExists) {
        throw Exception('分类名称已存在');
      }

      await _databaseService.insert(
        DatabaseConstants.categoriesTable,
        category.toMap(),
      );
      return category.id;
    } catch (e) {
      throw Exception('添加分类失败: $e');
    }
  }

  // 更新分类
  Future<int> updateCategory(Category category) async {
    try {
      // 如果是默认分类，不允许修改名称
      if (category.isDefault) {
        final originalCategory = await getCategoryById(category.id);
        if (originalCategory != null && originalCategory.name != category.name) {
          throw Exception('不允许修改默认分类的名称');
        }
      }

      return await _databaseService.update(
        DatabaseConstants.categoriesTable,
        category.toMap(),
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      throw Exception('更新分类失败: $e');
    }
  }

  // 删除分类
  Future<int> deleteCategory(String id) async {
    try {
      // 检查是否是默认分类
      final category = await getCategoryById(id);
      if (category != null && category.isDefault) {
        throw Exception('不能删除默认分类');
      }

      // 检查是否有交易记录使用此分类
      // TODO: 需要实现检查交易记录的逻辑

      return await _databaseService.delete(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('删除分类失败: $e');
    }
  }

  // 获取下一个排序顺序
  Future<int> getNextSortOrder() async {
    try {
      final result = await _databaseService.getMaxValue(
        DatabaseConstants.categoriesTable,
        DatabaseConstants.columnSortOrder,
      );
      return (result ?? 0) + 1;
    } catch (e) {
      return 1;
    }
  }

  // 重新排序分类
  Future<void> reorderCategories(List<Category> categories) async {
    try {
      await _databaseService.transaction((txn) async {
        for (int i = 0; i < categories.length; i++) {
          await txn.update(
            DatabaseConstants.categoriesTable,
            {
              DatabaseConstants.columnSortOrder: i + 1,
              DatabaseConstants.columnUpdatedAt: DateTime.now().millisecondsSinceEpoch,
            },
            where: '${DatabaseConstants.columnId} = ?',
            whereArgs: [categories[i].id],
          );
        }
      });
    } catch (e) {
      throw Exception('重新排序分类失败: $e');
    }
  }

  // 搜索分类
  Future<List<Category>> searchCategories(String searchTerm) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseService.search(
        DatabaseConstants.categoriesTable,
        searchTerm,
        searchColumns: [DatabaseConstants.columnName],
        orderBy: '${DatabaseConstants.columnSortOrder} ASC, ${DatabaseConstants.columnName} ASC',
      );

      return maps.map((map) => Category.fromMap(map)).toList();
    } catch (e) {
      throw Exception('搜索分类失败: $e');
    }
  }

  // 获取分类数量
  Future<int> getCategoryCount() async {
    try {
      return await _databaseService.getCount(DatabaseConstants.categoriesTable);
    } catch (e) {
      throw Exception('获取分类数量失败: $e');
    }
  }

  // 获取默认分类数量
  Future<int> getDefaultCategoryCount() async {
    try {
      return await _databaseService.getCount(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnIsDefault} = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw Exception('获取默认分类数量失败: $e');
    }
  }

  // 获取自定义分类数量
  Future<int> getCustomCategoryCount() async {
    try {
      return await _databaseService.getCount(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnIsDefault} = ?',
        whereArgs: [0],
      );
    } catch (e) {
      throw Exception('获取自定义分类数量失败: $e');
    }
  }

  // 检查分类名称是否存在
  Future<bool> isCategoryNameExists(String name, {String? excludeId}) async {
    try {
      String whereClause = '${DatabaseConstants.columnName} = ?';
      List<dynamic> whereArgs = [name];

      if (excludeId != null) {
        whereClause += ' AND ${DatabaseConstants.columnId} != ?';
        whereArgs.add(excludeId);
      }

      final count = await _databaseService.getCount(
        DatabaseConstants.categoriesTable,
        where: whereClause,
        whereArgs: whereArgs,
      );

      return count > 0;
    } catch (e) {
      throw Exception('检查分类名称是否存在失败: $e');
    }
  }

  // 批量插入分类
  Future<void> insertCategories(List<Category> categories) async {
    try {
      final List<Map<String, dynamic>> maps =
          categories.map((c) => c.toMap()).toList();
      await _databaseService.batchInsert(
        DatabaseConstants.categoriesTable,
        maps,
      );
    } catch (e) {
      throw Exception('批量插入分类失败: $e');
    }
  }

  // 清空自定义分类
  Future<void> clearCustomCategories() async {
    try {
      await _databaseService.delete(
        DatabaseConstants.categoriesTable,
        where: '${DatabaseConstants.columnIsDefault} = ?',
        whereArgs: [0],
      );
    } catch (e) {
      throw Exception('清空自定义分类失败: $e');
    }
  }
}