// lib/features/auth/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:quiz_academy/core/constants/my_app_colors.dart';

class CardButton extends StatelessWidget {
  // Primary API
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  // Layout + style
  final bool expanded; // <-- NEW: full-width or compact
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final ButtonStyle? style;

  CardButton({
    super.key,
    String? text,
    bool? loading,
    required this.onPressed,
    String? label,
    bool? isLoading,
    this.expanded = true,                 // <-- default full-width (old behavior)
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 10,
    this.style,
  })  : label = label ?? text ?? 'Submit',
        isLoading = isLoading ?? loading ?? false;

  @override
  Widget build(BuildContext context) {
    final baseStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? MyAppColors.appButtonColor,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
    );

    final mergedStyle = style == null ? baseStyle : baseStyle.merge(style);

    final btn = ElevatedButton(
      style: mergedStyle,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          )),
    );

    // Only force full width if expanded == true
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
