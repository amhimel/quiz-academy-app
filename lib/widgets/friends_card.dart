import 'package:flutter/material.dart';
import 'package:quiz_academy/widgets/app_button.dart';
import 'package:quiz_academy/widgets/card_button.dart';

class FriendsCard extends StatelessWidget {
  const FriendsCard({
    super.key,
    this.title = "Play quiz together with your friends now!",
    this.onFindFriends,
    this.onFriendRequests,
    this.redColor = const Color(0xFFE04444),
    this.blueColor = const Color(0xFF3450F5),
    this.cardColor = const Color(0xFF5C5C5C),
  });

  final String title;
  final VoidCallback? onFindFriends;
  final VoidCallback? onFriendRequests;

  // Theme colors (can tweak to match your design system)
  final Color redColor;
  final Color blueColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // 👈 bounds the Stack
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

                  // Title & subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                        child: Text(
                          title,
                          //overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom row (avatar + name + CTA)
                  Row(
                    children: [
                      CardButton(
                        label: "Find Friends",
                        onPressed: onFindFriends,
                        expanded: false,
                        // compact button
                        backgroundColor: const Color(0xFF4E63FF),
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        borderRadius: 22,
                      ),
                      const SizedBox(width: 8),
                      CardButton(
                        label: "Friend Requests",
                        onPressed: onFriendRequests,
                        expanded: false,
                        // compact button
                        backgroundColor: const Color(0xFF4E63FF),
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
