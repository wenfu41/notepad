class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'sortOrder': sortOrder,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '#2196F3',
      sortOrder: map['sortOrder'] ?? 0,
      isDefault: (map['isDefault'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: $color, sortOrder: $sortOrder, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.sortOrder == sortOrder &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        sortOrder.hashCode ^
        isDefault.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

// 预设分类
class DefaultCategories {
  static List<Category> get expenseCategories => [
    Category(
      id: 'food',
      name: '餐饮',
      icon: '🍔',
      color: '#FF6B6B',
      sortOrder: 1,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'transport',
      name: '交通',
      icon: '🚗',
      color: '#4ECDC4',
      sortOrder: 2,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'shopping',
      name: '购物',
      icon: '🛒',
      color: '#45B7D1',
      sortOrder: 3,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'entertainment',
      name: '娱乐',
      icon: '🎮',
      color: '#96CEB4',
      sortOrder: 4,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'health',
      name: '医疗',
      icon: '🏥',
      color: '#FECA57',
      sortOrder: 5,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'education',
      name: '教育',
      icon: '📚',
      color: '#9C88FF',
      sortOrder: 6,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'housing',
      name: '住房',
      icon: '🏠',
      color: '#FD79A8',
      sortOrder: 7,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'utilities',
      name: '水电费',
      icon: '💡',
      color: '#FDCB6E',
      sortOrder: 8,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'communication',
      name: '通讯',
      icon: '📱',
      color: '#6C5CE7',
      sortOrder: 9,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'other',
      name: '其他',
      icon: '📦',
      color: '#B2BEC3',
      sortOrder: 10,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<Category> get incomeCategories => [
    Category(
      id: 'salary',
      name: '工资',
      icon: '💰',
      color: '#00B894',
      sortOrder: 1,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'bonus',
      name: '奖金',
      icon: '🎁',
      color: '#E17055',
      sortOrder: 2,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'investment',
      name: '投资',
      icon: '📈',
      color: '#0984E3',
      sortOrder: 3,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'partTime',
      name: '兼职',
      icon: '💼',
      color: '#A29BFE',
      sortOrder: 4,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'gift',
      name: '礼金',
      icon: '🎂',
      color: '#FD79A8',
      sortOrder: 5,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'refund',
      name: '退款',
      icon: '↩️',
      color: '#55A3FF',
      sortOrder: 6,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'otherIncome',
      name: '其他收入',
      icon: '💵',
      color: '#636E72',
      sortOrder: 7,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}