// lib/features/auth/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:quiz_academy/core/constants/my_app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle style;

  /// Customizable size
  final double? width;
  final double? height;

  /// Optional icon
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;

  AppButton({
    super.key,
    String? text,        // alias
    bool? loading,       // alias
    required this.onPressed,
    String? label,
    bool? isLoading,
    this.style = const ButtonStyle(),
    this.width,
    this.height,
    this.icon,           // 👈 new
    this.iconColor,
    this.iconSize = 20,
  })  : label = label ?? text ?? 'Submit',
        isLoading = isLoading ?? loading ?? false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyAppColors.appButtonColor,
          padding: height != null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ).merge(style),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: iconColor ?? Colors.white),
              if (label.isNotEmpty) const SizedBox(width: 8),
            ],
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
