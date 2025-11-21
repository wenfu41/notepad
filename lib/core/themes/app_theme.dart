import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryVariant,
        surface: AppColors.scaffoldBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onError: AppColors.white,
        outline: AppColors.outline,
      ),

      // 字体主题
      fontFamily: AppTextStyles.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.h2(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.h3(color: AppColors.textPrimary),
        headlineLarge: AppTextStyles.h4(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.h5(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.h6(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.h6(color: AppColors.textPrimary),
        titleMedium: AppTextStyles.subtitle1(color: AppColors.textPrimary),
        titleSmall: AppTextStyles.subtitle2(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.body1(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.body2(color: AppColors.textPrimary),
        bodySmall: AppTextStyles.caption(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.button(color: AppColors.textOnPrimary),
        labelMedium: AppTextStyles.button(color: AppColors.textPrimary),
        labelSmall: AppTextStyles.caption(color: AppColors.textSecondary),
      ),

      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.primary,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h6(color: AppColors.textPrimary),
        toolbarTextStyle: AppTextStyles.body1(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),

      // 卡片主题
      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        shadowColor: AppColors.cardShadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shadowColor: AppColors.buttonShadow,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextStyles.button(color: AppColors.textOnPrimary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.button(color: AppColors.primary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextStyles.button(color: AppColors.primary),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.body2(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.body2(color: AppColors.textDisabled),
        errorStyle: AppTextStyles.caption(color: AppColors.error),
        helperStyle: AppTextStyles.caption(color: AppColors.textSecondary),
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dialogBackground,
        surfaceTintColor: AppColors.primary,
        elevation: 8,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTextStyles.h6(color: AppColors.textPrimary),
        contentTextStyle: AppTextStyles.body1(color: AppColors.textPrimary),
      ),

      // 底部弹出框主题
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.bottomSheetBackground,
        surfaceTintColor: AppColors.primary,
        elevation: 16,
        shadowColor: AppColors.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
      ),

      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // 列表瓦片主题
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.transparent,
        selectedTileColor: AppColors.primary.withOpacity(0.08),
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.body1(color: AppColors.textPrimary),
        subtitleTextStyle: AppTextStyles.body2(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // 图标主题
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.grey300,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextStyles.caption(color: AppColors.white),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.4);
          }
          return AppColors.grey300;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // 复选框主题
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.grey600, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // 单选框主题
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey600;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // 芯片主题
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primary.withOpacity(0.12),
        disabledColor: AppColors.grey200,
        labelStyle: AppTextStyles.body2(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.body2(color: AppColors.primary),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Tab主题
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.subtitle1(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.subtitle1(color: AppColors.textSecondary),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider,
      ),

      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.grey300,
        circularTrackColor: AppColors.grey300,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        primaryContainer: AppColors.darkPrimaryVariant,
        secondary: AppColors.darkSecondary,
        secondaryContainer: AppColors.darkSecondaryVariant,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
        outline: AppColors.darkBorder,
      ),

      // 字体主题（深色）
      fontFamily: AppTextStyles.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1Dark(color: AppColors.darkTextPrimary),
        displayMedium: AppTextStyles.h2(color: AppColors.darkTextPrimary),
        displaySmall: AppTextStyles.h3(color: AppColors.darkTextPrimary),
        headlineLarge: AppTextStyles.h4(color: AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.h5(color: AppColors.darkTextPrimary),
        headlineSmall: AppTextStyles.h6(color: AppColors.darkTextPrimary),
        titleLarge: AppTextStyles.h6(color: AppColors.darkTextPrimary),
        titleMedium: AppTextStyles.subtitle1(color: AppColors.darkTextPrimary),
        titleSmall: AppTextStyles.subtitle2(color: AppColors.darkTextSecondary),
        bodyLarge: AppTextStyles.body1Dark(color: AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.body2(color: AppColors.darkTextPrimary),
        bodySmall: AppTextStyles.caption(color: AppColors.darkTextSecondary),
        labelLarge: AppTextStyles.button(color: AppColors.darkTextPrimary),
        labelMedium: AppTextStyles.button(color: AppColors.darkTextPrimary),
        labelSmall: AppTextStyles.caption(color: AppColors.darkTextSecondary),
      ),

      // AppBar主题（深色）
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: AppColors.darkPrimary,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h6(color: AppColors.darkTextPrimary),
        toolbarTextStyle: AppTextStyles.body1Dark(color: AppColors.darkTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 24,
        ),
      ),

      // 底部导航栏主题（深色）
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),

      // 卡片主题（深色）
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.darkBorder,
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // 其他组件主题可以类似地进行深色适配...
    );
  }
}