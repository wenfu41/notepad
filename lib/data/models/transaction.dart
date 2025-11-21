enum TransactionType {
  expense('支出'),
  income('收入');

  const TransactionType(this.displayName);
  final String displayName;
}

enum TransactionCategory {
  // 支出类别
  food('餐饮', '🍔', TransactionType.expense),
  transport('交通', '🚗', TransactionType.expense),
  shopping('购物', '🛒', TransactionType.expense),
  entertainment('娱乐', '🎮', TransactionType.expense),
  health('医疗', '🏥', TransactionType.expense),
  education('教育', '📚', TransactionType.expense),
  housing('住房', '🏠', TransactionType.expense),
  utilities('水电费', '💡', TransactionType.expense),
  communication('通讯', '📱', TransactionType.expense),
  other('其他', '📦', TransactionType.expense),

  // 收入类别
  salary('工资', '💰', TransactionType.income),
  bonus('奖金', '🎁', TransactionType.income),
  investment('投资', '📈', TransactionType.income),
  partTime('兼职', '💼', TransactionType.income),
  gift('礼金', '🎂', TransactionType.income),
  refund('退款', '↩️', TransactionType.income),
  otherIncome('其他收入', '💵', TransactionType.income);

  const TransactionCategory(this.displayName, this.icon, this.type);
  final String displayName;
  final String icon;
  final TransactionType type;
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category_id': categoryId,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: map['category_id'] ?? map['categoryId'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] ?? map['updatedAt'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, categoryId: $categoryId, description: $description, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.description == description &&
        other.date == date &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        categoryId.hashCode ^
        description.hashCode ^
        date.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}