import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_academy/widgets/shared_quiz_card.dart';
import '../providers/feed_quizzes_provider.dart';
import '../widgets/feed_quiz_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedQuizzesProvider);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
            child: const Text('Quizzes'),
          ),
          SizedBox(height: 8),
          Flexible(
            child: feed.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('No quizzes yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemBuilder: (_, i) {
                    final quiz = list[i];
                    void go() {

                    }
                    return i == 0
                        ? SharedQuizCard(quiz: quiz,
                      onTap: () => context.push('/take-quiz', extra: quiz.id),
                      onStart: () =>
                          context.push('/take-quiz', extra: quiz.id),)
                        : FeedQuizCard(quiz: quiz,
                      onTap: () => context.push('/take-quiz', extra: quiz.id),
                      onStart: () =>
                          context.push('/take-quiz', extra: quiz.id),);
                  },

                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemCount: list.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
