import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_academy/widgets/custom_appbar.dart';
import '../models/profile_model.dart';
import '../providers/my_profile_provider.dart';
import '../widgets/create_or_import_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final _sb = Supabase.instance.client;

class CustomBottomNav extends ConsumerStatefulWidget {
  const CustomBottomNav({super.key, required this.pages});

  final List<Widget> pages;

  @override
  ConsumerState<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends ConsumerState<CustomBottomNav> {
  int index = 0;

  // ✅ Built-in icons
  final icons = const [Icons.home, Icons.quiz, Icons.leaderboard, Icons.group];
  final labels = const ["Home", "Quizzes", "Leaderboard", "Friends"];

  String _fallbackName(ProfileModel? p) {
    if (p == null) return "Guest";
    final dn = (p.displayName ?? '').trim();
    if (dn.isNotEmpty) return dn;
    final username = p.email.split('@').first;
    return username.isEmpty
        ? "User"
        : username[0].toUpperCase() + username.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    // 🔔 Show error as SnackBar (do NOT rebuild a separate Scaffold)
    ref.listen<AsyncValue<ProfileModel?>>(myProfileProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final m = ScaffoldMessenger.maybeOf(context);
            if (m == null) return;
            m.hideCurrentSnackBar();
            m.showSnackBar(
              SnackBar(
                content: Text('Failed to load profile: $e'),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
          });
        },
      );
    });

    // Use latest data if present; otherwise fall back
    final p = profileAsync.valueOrNull;
    final name = _fallbackName(p);
    final avatarUrl = p?.profileImage;

    return Scaffold(
      appBar: CustomAppbar(
        name: name,
        profileImageUrl: avatarUrl,
        onProfileTap: () {},
        height: 90,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        onLogoutTap: () async {
          await _sb.auth.signOut();
          context.go('/login');
        },

      ),
      backgroundColor: const Color(0xFFF3EBDD),
      body: Stack(
        children: [
          // Your current page
          Positioned.fill(child: widget.pages[index]),

          // (Optional) thin loading bar while fetching/refreshing
          if (profileAsync.isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),

          // ---- bottom nav stays mounted, unchanged ----
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
                    // Bar
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
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
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
                    // Center FAB
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
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => CreateOrImportSheet.show(
                              context,
                              onMakeTap: () {
                                context.push('/create-quiz');
                              },
                            ),
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

/// Concave clipper unchanged
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
