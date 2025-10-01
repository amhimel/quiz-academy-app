import 'dart:async';
import 'package:flutter/material.dart';

String _greetingFor(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return "Good Morning";
  if (h >= 12 && h < 17) return "Good Afternoon";
  if (h >= 17 && h < 21) return "Good Evening";
  return "Good Night";
}

IconData _iconForGreeting(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return Icons.wb_sunny;
  if (h >= 12 && h < 17) return Icons.cloud;
  if (h >= 17 && h < 21) return Icons.wb_twilight;
  return Icons.nights_stay;
}

Color _colorForGreeting(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return Colors.amber;
  if (h >= 12 && h < 17) return Colors.grey;
  if (h >= 17 && h < 21) return Colors.deepOrange;
  return Colors.blueAccent;
}

Duration _timeUntilNextBoundary(DateTime now) {
  DateTime next;
  final boundaries = [
    DateTime(now.year, now.month, now.day, 5),
    DateTime(now.year, now.month, now.day, 12),
    DateTime(now.year, now.month, now.day, 17),
    DateTime(now.year, now.month, now.day, 21),
  ]..sort((a, b) => a.compareTo(b));

  next = boundaries.firstWhere(
    (b) => b.isAfter(now),
    orElse: () => DateTime(now.year, now.month, now.day + 1, 5),
  );
  return next.difference(now);
}

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String name;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap; // 👈 new
  final double height;
  final EdgeInsetsGeometry contentPadding;

  const CustomAppbar({
    super.key,
    required this.name,
    this.profileImageUrl,
    this.onProfileTap,
    this.onLogoutTap, // 👈 new
    this.height = kToolbarHeight + 20,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  });

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppbarState extends State<CustomAppbar> {
  late String _greeting;
  late IconData _icon;
  late Color _color;
  Timer? _timer;

  void _updateGreeting() {
    final now = DateTime.now();
    _greeting = _greetingFor(now);
    _icon = _iconForGreeting(now);
    _color = _colorForGreeting(now);
  }

  void _schedule() {
    _timer?.cancel();
    _updateGreeting();
    _timer = Timer(_timeUntilNextBoundary(DateTime.now()), () {
      if (!mounted) return;
      setState(() {
        _updateGreeting();
        _schedule();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: widget.height,
      title: Padding(
        padding: widget.contentPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_icon, size: 18, color: _color),
                      const SizedBox(width: 6),
                      Text(
                        _greeting,
                        style: TextStyle(fontSize: 14, color: _color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Profile avatar
            GestureDetector(
              onTap: widget.onProfileTap,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.profileImageUrl != null
                    ? NetworkImage(widget.profileImageUrl!)
                    : null,
                child: widget.profileImageUrl == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ),
            // const SizedBox(width: 12),
            // // Logout icon in circle
            // GestureDetector(
            //   onTap: widget.onLogoutTap,
            //   child: const CircleAvatar(
            //     radius: 20,
            //     backgroundColor:  Color(0xFF4E63FF),
            //     child: Icon(Icons.logout_rounded, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
