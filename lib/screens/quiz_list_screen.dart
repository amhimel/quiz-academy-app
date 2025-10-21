// lib/screens/your_quizzes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/my_attempts_provider.dart'; // myAttemptedQuizzesProvider, participantsCountProvider

class YourQuizzesScreen extends ConsumerWidget {
  const YourQuizzesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAttemptedQuizzesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed: $e')),
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('You have not taken any quiz yet.'));
            }
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Text(
                      'Your Quizzes',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        final item = list[i];
                        return Padding(
                          padding: EdgeInsets.only(bottom: i == list.length - 1 ? 24 : 14),
                          child: _YourQuizCard(
                            quizId: item.quiz.id,
                            title: item.quiz.title,
                            questionsText: "${item.quiz.numQuestions} Questions",
                            onResult: () => context.push('/quiz/${item.quiz.id}/leaderboard'),
                          ),
                        );
                      },
                      childCount: list.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _YourQuizCard extends ConsumerWidget {
  final String quizId;
  final String title;
  final String questionsText;
  final VoidCallback onResult;

  const _YourQuizCard({
    required this.quizId,
    required this.title,
    required this.questionsText,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(participantsCountProvider(quizId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left icon box
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EDFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.quiz_outlined, size: 28, color: Color(0xFF3450F5)),
                ),
                const SizedBox(width: 12),
                // Middle content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        questionsText,
                        style: TextStyle(color: Colors.black.withOpacity(.6)),
                      ),

                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right "Result" button
                TextButton.icon(
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Result'),
                  onPressed: onResult,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3450F5),
                    padding: EdgeInsets.zero,
                  ),

                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const _StackedAvatars(),
                const SizedBox(width: 8),
                peopleAsync.when(
                  data: (n) => Text(
                    '+$n People join',
                    style: TextStyle(color: Colors.black.withOpacity(.7)),
                  ),
                  loading: () => Text(
                    '+… People join',
                    style: TextStyle(color: Colors.black.withOpacity(.3)),
                  ),
                  error: (_, __) => Text(
                    '+? People join',
                    style: TextStyle(color: Colors.black.withOpacity(.3)),
                  ),
                ),
              ],
            ),
          ],
        ),

      ),
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          _MiniAvatar(left: 0, color: Color(0xFFFFD7D7)),
          _MiniAvatar(left: 18, color: Color(0xFFE7EDFF)),
          _MiniAvatar(left: 36, color: Color(0xFFD8F5E3)),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final double left;
  final Color color;
  const _MiniAvatar({required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: const Icon(Icons.person, size: 16, color: Colors.black54),
      ),
    );
  }
}
