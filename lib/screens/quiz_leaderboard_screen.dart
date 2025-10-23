import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attempt_row.dart';
import '../providers/quiz_leaderboard_provider.dart';

class QuizLeaderboardScreen extends ConsumerWidget {
  final String quizId;

  const QuizLeaderboardScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(quizLeaderboardProvider(quizId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Leaderboard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Failed: $e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(
                        child: Text('No attempts yet for this quiz.'),
                      );
                    }
                    final top3 = list.take(3).toList(growable: false);
                    final rest = list.length > 3
                        ? list.sublist(3)
                        : <LeaderboardEntry>[];

                    return ListView(
                      children: [
                        _Podium(entries: top3),
                        const SizedBox(height: 18),
                        _RestListContainer(rest: rest),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ======================= HELPERS ======================= */

String _ordinal(int n) {
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

class _PhotoAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const _PhotoAvatar({required this.url, this.size = 26});

  @override
  Widget build(BuildContext context) {
    final has = (url != null && url!.isNotEmpty);
    return CircleAvatar(
      radius: size,
      backgroundColor: Colors.white,
      backgroundImage: has ? NetworkImage(url!) : null,
      child: has ? null : const Icon(Icons.person, color: Colors.black54),
    );
  }
}

class _RankChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RankChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/* ======================= PODIUM ======================= */

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const h1 = 180.0, h2 = 150.0, h3 = 150.0;

    Widget col(LeaderboardEntry? e, double height, List<Color> grad, int rank) {
      final name = e == null
          ? '—'
          : (e.displayName ?? e.userId.substring(0, 6));
      final pts = e?.bestAttempt.score ?? 0;
      final url = e?.avatarUrl;

      // rank color palette
      final chipColor = rank == 1
          ? const Color(0xFFFFC84D)
          : (rank == 2 ? const Color(0xFFB7C7FF) : const Color(0xFFD7C9FF));

      return Column(
        children: [
          Column(
            children: [
              // Photo + Rank chip on top
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _PhotoAvatar(url: url, size: 25),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: _RankChip(label: _ordinal(rank), color: chipColor),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Bar
              Container(
                width: (w - 25) / 3 - 10,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: grad,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '$name \n$pts\nPoints ',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    LeaderboardEntry? at(int i) => i < entries.length ? entries[i] : null;

    // order: 2nd | 1st | 3rd
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: col(at(1), h2, const [
            Color(0xFF5D81F8),
            Color(0xFF92BFFF),
          ], 2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: col(at(0), h1, const [
            Color(0xFFF85C6F),
            Color(0xFFFF8DA1),
          ], 1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: col(at(2), h3, const [
            Color(0xFF6456FD),
            Color(0xFFA58DFF),
          ], 3),
        ),
      ],
    );
  }
}

/* ============ REST (4th, 5th, 6th...) ============ */

class _RestListContainer extends StatelessWidget {
  final List<LeaderboardEntry> rest;

  const _RestListContainer({required this.rest});

  @override
  Widget build(BuildContext context) {
    if (rest.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          children: List.generate(rest.length, (i) {
            final e = rest[i];
            final rank = i + 4;
            return Padding(
              padding: EdgeInsets.only(bottom: i == rest.length - 1 ? 0 : 12),
              child: _LBRow(
                rankLabel: _ordinal(rank),
                name: e.displayName ?? e.userId.substring(0, 6),
                avatarUrl: e.avatarUrl,
                points: e.bestAttempt.score,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LBRow extends StatelessWidget {
  final String rankLabel; // e.g., 4th, 5th, ...
  final String name;
  final String? avatarUrl;
  final int points;

  const _LBRow({
    super.key,
    required this.rankLabel,
    required this.name,
    required this.avatarUrl,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // rank chip (ordinal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EDFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              rankLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // avatar
          _PhotoAvatar(url: avatarUrl, size: 20),
          const SizedBox(width: 12),

          // name + points
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$points points',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
