import 'package:flutter/foundation.dart';
import 'quiz.dart';

@immutable
class AttemptRow {
  final String id;
  final String userId;
  final String quizId;
  final int correctCount;
  final int totalQuestions;
  final int timeSpentSec;
  final int score;
  final int? changeCountTotal;
  final DateTime finishedAt;

  const AttemptRow({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeSpentSec,
    required this.score,
    required this.changeCountTotal,
    required this.finishedAt,
  });

  factory AttemptRow.fromMap(Map<String, dynamic> m) => AttemptRow(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    quizId: m['quiz_id'] as String,
    correctCount: (m['correct_count'] ?? 0) as int,
    totalQuestions: (m['total_questions'] ?? 0) as int,
    timeSpentSec: (m['time_spent_sec'] ?? 0) as int,
    score: (m['score'] ?? 0) as int,
    changeCountTotal: m['change_count_total'] as int?,
    finishedAt: DateTime.parse(m['finished_at'] as String),
  );
}

@immutable
class AttemptWithQuiz {
  final AttemptRow attempt;
  final Quiz quiz;
  const AttemptWithQuiz({required this.attempt, required this.quiz});
}

@immutable
class LeaderboardEntry {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final AttemptRow bestAttempt;
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.bestAttempt,
  });
  double get accuracy => bestAttempt.totalQuestions == 0
      ? 0
      : bestAttempt.correctCount / bestAttempt.totalQuestions;
}
