import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final String? counterText;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final BorderRadius? borderRadius;
  final double? height;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
    this.contentPadding,
    this.counterText,
    this.filled = true,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.borderRadius,
    this.height,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget? suffixWidget = widget.suffix;
    if (widget.suffixIcon != null) {
      suffixWidget = IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: colors.onSurface.withOpacity(0.6),
        ),
        onPressed: () {
          if (widget.obscureText) {
            setState(() {
              _obscureText = !_obscureText;
            });
          }
          widget.onSuffixIconTap?.call();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withOpacity(0.87),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: widget.height,
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            validator: widget.validator,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            focusNode: _focusNode,
            textCapitalization: widget.textCapitalization,
            textAlign: widget.textAlign,
            style: widget.style ?? theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefix: widget.prefix,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: colors.onSurface.withValues(alpha: 0.6),
                    )
                  : null,
              suffix: suffixWidget,
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              counterText: widget.counterText,
              filled: widget.filled,
              fillColor: widget.fillColor ?? colors.surface,
              border: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(color: colors.outline),
                  ),
              enabledBorder: widget.enabledBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(color: colors.outline),
                  ),
              focusedBorder: widget.focusedBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
              errorBorder: widget.errorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(color: colors.error),
                  ),
              focusedErrorBorder: widget.focusedErrorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    borderSide: BorderSide(color: colors.error, width: 2),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// 金额输入框
class AmountInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final FormFieldValidator<double>? validator;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  const AmountInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppInput(
      label: label,
      hint: hint ?? '0.00',
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      initialValue: initialValue?.toStringAsFixed(2),
      autofocus: autofocus,
      focusNode: focusNode,
      enabled: enabled,
      prefixIcon: Icons.attach_money,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      onChanged: (value) {
        final amount = double.tryParse(value) ?? 0.0;
        onChanged?.call(amount);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入金额';
        }
        final amount = double.tryParse(value);
        if (amount == null) {
          return '请输入有效的金额';
        }
        if (amount <= 0) {
          return '金额必须大于0';
        }
        return validator?.call(amount);
      },
    );
  }
}

// 数字输入框
class NumberInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final int? initialValue;
  final ValueChanged<int>? onChanged;
  final FormFieldValidator<int>? validator;
  final bool enabled;
  final int? min;
  final int? max;
  final TextEditingController? controller;

  const NumberInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.min,
    this.max,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppInput(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      initialValue: initialValue?.toString(),
      enabled: enabled,
      onChanged: (value) {
        final number = int.tryParse(value) ?? 0;
        onChanged?.call(number);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入数字';
        }
        final number = int.tryParse(value);
        if (number == null) {
          return '请输入有效的数字';
        }
        if (min != null && number < min!) {
          return '数字不能小于 $min';
        }
        if (max != null && number > max!) {
          return '数字不能大于 $max';
        }
        return validator?.call(number);
      },
    );
  }
}

// 搜索输入框
class SearchInput extends StatelessWidget {
  final String? hint;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  const SearchInput({
    super.key,
    this.hint,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppInput(
      hint: hint ?? '搜索...',
      initialValue: initialValue,
      controller: controller,
      autofocus: autofocus,
      focusNode: focusNode,
      prefixIcon: Icons.search,
      suffixIcon: initialValue.isNotEmpty ? Icons.clear : null,
      onSuffixIconTap: () {
        controller?.clear();
        onClear?.call();
        onChanged?.call('');
      },
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

// 多行文本输入框
class TextArea extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextEditingController? controller;

  const TextArea({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 3,
    this.maxLength,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppInput(
      label: label,
      hint: hint,
      controller: controller,
      initialValue: initialValue,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
    );
  }
}