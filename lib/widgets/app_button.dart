// lib/features/auth/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:quiz_academy/core/constants/my_app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;        // your existing prop
  final VoidCallback? onPressed;
  final bool isLoading;      // your existing prop

  // aliases so code that uses text/loading also compiles
  const AppButton({
    super.key,
    String? text,            // alias
    bool? loading,           // alias
    required this.onPressed,
    String? label,
    bool? isLoading,
  })  : label = label ?? text ?? 'Submit',
        isLoading = isLoading ?? loading ?? false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyAppColors.appButtonColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label, style: const TextStyle(fontSize: 16,color: Colors.white)),
      ),
    );
  }
}
