class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final double amount;
  final int year;
  final int month;
  final double spent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.year,
    required this.month,
    required this.spent,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remaining => amount - spent;
  double get percentageSpent => amount > 0 ? spent / amount : 0.0;
  bool get isOverBudget => spent > amount;
  bool get isNearBudget => amount > 0 && percentageSpent >= 0.8;

  Budget copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? amount,
    int? year,
    int? month,
    double? spent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Budget updateSpent(double newSpent) {
    return copyWith(
      spent: newSpent,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'year': year,
      'month': month,
      'spent': spent,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      year: map['year'] ?? DateTime.now().year,
      month: map['month'] ?? DateTime.now().month,
      spent: map['spent']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, categoryName: $categoryName, amount: $amount, year: $year, month: $month, spent: $spent, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.amount == amount &&
        other.year == year &&
        other.month == month &&
        other.spent == spent &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        categoryName.hashCode ^
        amount.hashCode ^
        year.hashCode ^
        month.hashCode ^
        spent.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class MonthlyBudget {
  final String id;
  final int year;
  final int month;
  final double totalAmount;
  final double totalSpent;
  final List<Budget> categoryBudgets;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonthlyBudget({
    required this.id,
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.totalSpent,
    required this.categoryBudgets,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalRemaining => totalAmount - totalSpent;
  double get percentageSpent => totalAmount > 0 ? totalSpent / totalAmount : 0.0;
  bool get isOverBudget => totalSpent > totalAmount;
  bool get isNearBudget => totalAmount > 0 && percentageSpent >= 0.8;

  MonthlyBudget copyWith({
    String? id,
    int? year,
    int? month,
    double? totalAmount,
    double? totalSpent,
    List<Budget>? categoryBudgets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyBudget(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      totalSpent: totalSpent ?? this.totalSpent,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'totalAmount': totalAmount,
      'totalSpent': totalSpent,
      'categoryBudgets': categoryBudgets.map((b) => b.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      id: map['id'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      month: map['month'] ?? DateTime.now().month,
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      totalSpent: map['totalSpent']?.toDouble() ?? 0.0,
      categoryBudgets: (map['categoryBudgets'] as List<dynamic>?)
              ?.map((b) => Budget.fromMap(b))
              .toList() ??
          [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}