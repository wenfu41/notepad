import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // 基础字体样式
  static final String fontFamily = GoogleFonts.roboto().fontFamily ?? 'Roboto';

  // 字体大小常量
  static const double fontSize8 = 8.0;
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;
  static const double fontSize26 = 26.0;
  static const double fontSize28 = 28.0;
  static const double fontSize30 = 30.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize40 = 40.0;
  static const double fontSize48 = 48.0;

  // 字体权重
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // 行高
  static const double lineHeight1_2 = 1.2;
  static const double lineHeight1_3 = 1.3;
  static const double lineHeight1_4 = 1.4;
  static const double lineHeight1_5 = 1.5;
  static const double lineHeight1_6 = 1.6;

  // 标题样式
  static TextStyle h1({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize32,
      fontWeight: fontWeight ?? fontWeightBold,
      color: color,
      height: lineHeight1_2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle h2({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize28,
      fontWeight: fontWeight ?? fontWeightBold,
      color: color,
      height: lineHeight1_2,
      letterSpacing: -0.25,
    );
  }

  static TextStyle h3({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize24,
      fontWeight: fontWeight ?? fontWeightSemiBold,
      color: color,
      height: lineHeight1_3,
      letterSpacing: 0,
    );
  }

  static TextStyle h4({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize20,
      fontWeight: fontWeight ?? fontWeightSemiBold,
      color: color,
      height: lineHeight1_3,
      letterSpacing: 0,
    );
  }

  static TextStyle h5({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize18,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0,
    );
  }

  static TextStyle h6({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize16,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0,
    );
  }

  // 正文样式
  static TextStyle body1({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize16,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color,
      height: lineHeight1_5,
      letterSpacing: 0.15,
    );
  }

  static TextStyle body2({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color,
      height: lineHeight1_5,
      letterSpacing: 0.25,
    );
  }

  // 小字体样式
  static TextStyle subtitle1({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize16,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0.15,
    );
  }

  static TextStyle subtitle2({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0.1,
    );
  }

  static TextStyle caption({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize12,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0.4,
    );
  }

  static TextStyle overline({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize10,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color,
      height: lineHeight1_6,
      letterSpacing: 1.5,
    );
  }

  // 按钮文字样式
  static TextStyle button({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 1.25,
    );
  }

  // 数字显示样式（用于金额显示）
  static TextStyle currency({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize ?? fontSize16,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_2,
      letterSpacing: 0,
    );
  }

  static TextStyle largeCurrency({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize ?? fontSize24,
      fontWeight: fontWeight ?? fontWeightBold,
      color: color,
      height: lineHeight1_2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle smallCurrency({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize ?? fontSize12,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color,
      height: lineHeight1_2,
      letterSpacing: 0.25,
    );
  }

  // 特殊样式
  static TextStyle link({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0.1,
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
  }

  static TextStyle error({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0.25,
    );
  }

  static TextStyle success({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightMedium,
      color: color,
      height: lineHeight1_4,
      letterSpacing: 0.25,
    );
  }

  // 深色主题样式
  static TextStyle h1Dark({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? fontSize32,
      fontWeight: fontWeight ?? fontWeightBold,
      color: color,
      height: lineHeight1_2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle body1Dark({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? fontSize16,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color,
      height: lineHeight1_5,
      letterSpacing: 0.15,
    );
  }

  // 实用方法
  static TextStyle applyOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }

  static TextStyle withLineHeight(TextStyle style, double lineHeight) {
    return style.copyWith(height: lineHeight);
  }

  static TextStyle withLetterSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }

  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}