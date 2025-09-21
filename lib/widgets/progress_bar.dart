import 'package:flutter/material.dart';

const _primary = Color(0xFF4E5CF5);

class ProgressBar extends StatelessWidget {
  final int currentIndex;
  final int total;

  const ProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i <= currentIndex;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: filled ? _primary : const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
