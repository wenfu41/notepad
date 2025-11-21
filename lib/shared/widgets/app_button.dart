import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final BorderSide? borderSide;
  final IconData? icon;
  final Widget? child;
  final ButtonStyle? style;
  final bool isOutlined;
  final bool isText;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderSide,
    this.icon,
    this.child,
    this.style,
    this.isOutlined = false,
    this.isText = false,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.icon,
    this.child,
  })  : backgroundColor = null,
      foregroundColor = null,
      disabledBackgroundColor = null,
      disabledForegroundColor = null,
      borderSide = null,
      style = null,
      isOutlined = false,
      isText = false;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderSide,
    this.icon,
    this.child,
  })  : backgroundColor = null,
      foregroundColor = null,
      disabledBackgroundColor = null,
      disabledForegroundColor = null,
      style = null,
      isOutlined = true,
      isText = false;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.icon,
    this.child,
  })  : backgroundColor = null,
      foregroundColor = null,
      disabledBackgroundColor = null,
      disabledForegroundColor = null,
      borderSide = null,
      style = null,
      isOutlined = false,
      isText = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 确定按钮样式
    ButtonStyle? buttonStyle;
    if (style != null) {
      buttonStyle = style!;
    } else if (isOutlined) {
      buttonStyle = OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: foregroundColor ?? colors.primary,
        side: borderSide ?? BorderSide(color: colors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(width ?? 0, height ?? 44),
      );
    } else if (isText) {
      buttonStyle = TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: foregroundColor ?? colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size(width ?? 0, height ?? 40),
      );
    } else {
      buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colors.primary,
        foregroundColor: foregroundColor ?? colors.onPrimary,
        shadowColor: colors.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(width ?? 0, height ?? 44),
      );
    }

    // 构建按钮内容
    Widget buttonChild;
    if (child != null) {
      buttonChild = child!;
    } else if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? colors.primary : colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    } else if (isText) {
      button = TextButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    } else {
      button = ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    }

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: button,
      );
    }

    return button;
  }
}

// 特殊用途的按钮组件
class PrimaryAppButton extends AppButton {
  const PrimaryAppButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.borderRadius,
    super.icon,
    super.child,
  }) : super.primary();
}

class OutlinedAppButton extends AppButton {
  const OutlinedAppButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.borderRadius,
    super.borderSide,
    super.icon,
    super.child,
  }) : super.outlined();
}

class AppTextButton extends AppButton {
  const AppTextButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.borderRadius,
    super.icon,
    super.child,
  }) : super.text();
}

// 带图标的按钮
class AppIconButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;
  final double? iconSize;
  final bool isCircular;
  final double? borderRadius;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 40,
    this.iconSize = 20,
    this.isCircular = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget buttonChild = Icon(
      icon,
      size: iconSize,
      color: foregroundColor ?? colors.onSurface,
    );

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: isCircular
            ? null
            : BorderRadius.circular(borderRadius ?? 8),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(child: buttonChild),
    );

    if (onPressed != null) {
      button = Material(
        color: backgroundColor ?? Colors.transparent,
        shape: isCircular
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 8)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: isCircular
              ? null
              : BorderRadius.circular(borderRadius ?? 8),
          child: button,
        ),
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}