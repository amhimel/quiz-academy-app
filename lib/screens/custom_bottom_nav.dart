import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key, required this.pages});

  final List<Widget> pages;

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int index = 0;

  // ✅ Use Flutter built-in icons
  final icons = const [
    Icons.home,
    Icons.quiz,
    Icons.leaderboard,
    Icons.group, // friends
  ];

  final labels = const ["Home", "Quizzes", "Leaderboard", "Friends"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      body: Stack(
        children: [
          Positioned.fill(child: widget.pages[index]),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.zero,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Shadow
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    ),

                    // Clipped white bar with concave scoop
                    ClipPath(
                      clipper: _TopConcaveClipper(
                        scoopRadius: 40,
                        scoopWidth: 180,
                      ),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: List.generate(icons.length, (i) {
                            final selected = i == index;
                            return Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => setState(() => index = i),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF1F4BFF)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        icons[i],
                                        size: 22,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF8F8F8F),
                                      ),
                                    ),
                                    Text(
                                      labels[i],
                                      style: TextStyle(
                                        fontSize: selected ? 14 : 12,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: selected
                                            ? const Color(0xFF1F4BFF)
                                            : const Color(0xFF8F8F8F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    // Center FAB overlapping the scoop
                    Positioned.fill(
                      top: -30,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1F4BFF),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add,
                                color: Colors.white, size: 28),
                            onPressed: () {
                              // TODO: create quiz action
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper: concave scoop at top center
class _TopConcaveClipper extends CustomClipper<Path> {
  _TopConcaveClipper({required this.scoopRadius, required this.scoopWidth});

  final double scoopRadius;
  final double scoopWidth;

  @override
  Path getClip(Size size) {
    final r = 20.0;
    final cx = size.width / 2;
    final top = 0.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    final outer = Path()..addRRect(rect);

    final half = scoopWidth / 2;
    final bowl = Path()
      ..moveTo(cx - half, top)
      ..quadraticBezierTo(
        cx - half * 0.60,
        top,
        cx - scoopRadius * 0.90,
        top + scoopRadius * 0.50,
      )
      ..arcToPoint(
        Offset(cx + scoopRadius * 0.90, top + scoopRadius * 0.50),
        radius: Radius.circular(scoopRadius * 1.0),
        clockwise: false,
      )
      ..quadraticBezierTo(cx + half * 0.60, top, cx + half, top)
      ..lineTo(size.width - r, top)
      ..close();

    return Path.combine(PathOperation.difference, outer, bowl);
  }

  @override
  bool shouldReclip(covariant _TopConcaveClipper old) =>
      old.scoopRadius != scoopRadius || old.scoopWidth != scoopWidth;
}
