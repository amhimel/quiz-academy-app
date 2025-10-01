import 'package:flutter/material.dart';
import 'package:quiz_academy/widgets/app_button.dart';
import 'package:quiz_academy/widgets/card_button.dart';

class SharedQuizCard extends StatelessWidget {
  const SharedQuizCard({
    super.key,
    this.category = "General Knowledge",
    this.durationText = "2min",
    this.title = "Saturday night Quiz",
    this.quizzesCountText = "13 Quizzes",
    this.sharedBy = "Brandon Matrovs",
    this.onClose,
    this.onStart,
    this.redColor = const Color(0xFFE04444),
    this.blueColor = const Color(0xFF3450F5),
    this.cardColor = const Color(0xFF5C5C5C),
  });

  final String category;
  final String durationText;
  final String title;
  final String quizzesCountText;
  final String sharedBy;
  final VoidCallback? onClose;
  final VoidCallback? onStart;

  // Theme colors (can tweak to match your design system)
  final Color redColor;
  final Color blueColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // 👈 bounds the Stack
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 🔴 Back layer
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          // 🔵 Middle layer
          Positioned(
            top: 28,
            left: 16,
            right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          // ⚫ Front card (bounded: top & bottom pinned)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            bottom: 0,
            // 👈 now Column has finite height
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 👈 spread vertically, no Spacer
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row (tags + close)
                  Row(
                    children: [
                      _buildTag(
                        category,
                        const Color(0xFFF5C4C4),
                        textColor: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      _buildTag(
                        durationText,
                        const Color(0xFF7B7B7B),
                        textColor: Colors.white,
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: onClose,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Title & subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quizzesCountText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),

                  // Bottom row (avatar + name + CTA)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFB48EF2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Shared By",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              sharedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CardButton(
                        label: "Start Now",
                        onPressed: onStart,
                        expanded: false, // compact button
                        backgroundColor: const Color(0xFF4E63FF),
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        borderRadius: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
