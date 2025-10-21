import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              const Text('Leaderboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Expanded(
                child: async.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Failed: $e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('No attempts yet for this quiz.'));
                    }
                    final top3 = list.take(3).toList();
                    final rest = list.length > 3 ? list.sublist(3) : <dynamic>[];

                    return ListView(
                      children: [
                        _Podium(entries: top3),
                        const SizedBox(height: 14),
                        ...List.generate(rest.length, (i) {
                          final e = rest[i];
                          final rank = i + 4;
                          return _LBRow(
                            rank: rank,
                            name: e.displayName ?? e.userId.substring(0, 6),
                            avatarUrl: e.avatarUrl,
                            points: e.bestAttempt.score,
                          );
                        }),
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

class _Podium extends StatelessWidget {
  final List entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h1 = 180.0, h2 = 140.0, h3 = 120.0;

    // helper for one column
    Widget col(String name, int points, double height, List<Color> grad) {
      return Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: const Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            width: (w - 32) / 3 - 10,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: grad),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '$name\n$points points',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      );
    }

    String nameAt(int i) =>
        i < entries.length ? (entries[i].displayName ?? entries[i].userId.substring(0, 6)) : '—';
    int pointsAt(int i) => i < entries.length ? entries[i].bestAttempt.score : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: col(nameAt(1), pointsAt(1), h2, [const Color(0xFF7EB2FF), const Color(0xFF6A8CFF)]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: col(nameAt(0), pointsAt(0), h1, [const Color(0xFFFF8DA1), const Color(0xFFFF6A7B)]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: col(nameAt(2), pointsAt(2), h3, [const Color(0xFFA58DFF), const Color(0xFF7A6BFF)]),
        ),
      ],
    );
  }
}

class _LBRow extends StatelessWidget {
  final int rank;
  final String name;
  final String? avatarUrl;
  final int points;
  const _LBRow({required this.rank, required this.name, this.avatarUrl, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 8))]
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE7EDFF),
          child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('$points points'),
        trailing: CircleAvatar(
          backgroundColor: const Color(0xFFF1F1F1),
          child: const Icon(Icons.person, color: Colors.black54),
        ),
      ),
    );
  }
}
