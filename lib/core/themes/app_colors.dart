import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Color(0xFF1976D2); // Material Blue
  static const Color primaryVariant = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF03DAC6); // Material Teal Accent
  static const Color secondaryVariant = Color(0xFF018786);

  // 基础颜色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // 功能颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // 财务颜色
  static const Color income = Color(0xFF4CAF50); // 绿色 - 收入
  static const Color expense = Color(0xFFF44336); // 红色 - 支出
  static const Color budget = Color(0xFF2196F3); // 蓝色 - 预算
  static const Color saving = Color(0xFF9C27B0); // 紫色 - 储蓄

  // 分类颜色（预设）
  static const Map<String, Color> categoryColors = {
    // 支出类别
    'food': Color(0xFFFF6B6B),
    'transport': Color(0xFF4ECDC4),
    'shopping': Color(0xFF45B7D1),
    'entertainment': Color(0xFF96CEB4),
    'health': Color(0xFFFECA57),
    'education': Color(0xFF9C88FF),
    'housing': Color(0xFFFD79A8),
    'utilities': Color(0xFFFDCB6E),
    'communication': Color(0xFF6C5CE7),
    'other': Color(0xFFB2BEC3),

    // 收入类别
    'salary': Color(0xFF00B894),
    'bonus': Color(0xFFE17055),
    'investment': Color(0xFF0984E3),
    'partTime': Color(0xFFA29BFE),
    'gift': Color(0xFFFD79A8),
    'refund': Color(0xFF55A3FF),
    'otherIncome': Color(0xFF636E72),
  };

  // 图表颜色
  static const List<Color> chartColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFECA57),
    Color(0xFF9C88FF),
    Color(0xFFFD79A8),
    Color(0xFFFDCB6E),
    Color(0xFF6C5CE7),
    Color(0xFFA29BFE),
    Color(0xFF55A3FF),
    Color(0xFF00B894),
  ];

  // 渐变颜色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successLight, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorLight, errorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warningLight, warningDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 背景颜色
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFFFFFFF);
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color bottomSheetBackground = Color(0xFFFFFFFF);

  // 文字颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF000000);

  // 边框和分割线
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color outline = Color(0xFF757575);

  // 阴影颜色
  static const Color shadow = Color(0x1F000000);
  static const Color cardShadow = Color(0x1F000000);
  static const Color buttonShadow = Color(0x26000000);

  // 透明度颜色
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // 获取类别颜色
  static Color getCategoryColor(String categoryId) {
    return categoryColors[categoryId] ?? primary;
  }

  // 根据交易类型获取颜色
  static Color getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return income;
      case 'expense':
        return expense;
      default:
        return primary;
    }
  }

  // 获取预算状态颜色
  static Color getBudgetStatusColor(double percentageSpent) {
    if (percentageSpent >= 1.0) {
      return error; // 超支
    } else if (percentageSpent >= 0.8) {
      return warning; // 警告
    } else {
      return success; // 正常
    }
  }

  // 深色主题颜色
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkPrimaryVariant = Color(0xFF64B5F6);
  static const Color darkSecondary = Color(0xFF80CBC4);
  static const Color darkSecondaryVariant = Color(0xFF4DB6AC);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextDisabled = Color(0xFF666666);

  static const Color darkBorder = Color(0xFF444444);
  static const Color darkDivider = Color(0xFF444444);

  // 主题相关颜色计算方法
  static Color getTextColorForBackground(Color backgroundColor) {
    // 计算背景色的亮度，返回合适的文字颜色
    final double brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? textPrimary : darkTextPrimary;
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}