// lib/features/auth/widgets/app_text_field.dart
import 'package:flutter/material.dart';

class AppTextFieldWithValidator extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final double height;

  const AppTextFieldWithValidator({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.validator,
    this.height = 10.0,// <-- add
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        filled: true, // enable background color
        fillColor: Colors.grey.shade100, // background color (change as needed)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // corner radius
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300), // border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
