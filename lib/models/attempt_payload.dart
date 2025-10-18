import 'package:flutter/foundation.dart';

@immutable
class AttemptPayload {
  final String quizId;
  final int correctCount;
  final int totalQuestions;
  final int timeSpentSec;
  final int score;

  final int tapCountTotal;       // সব অপশনে মোট ট্যাপ
  final int changeCountTotal;    // selection change মোট
  final Map<String, dynamic> tapCounts; // {qId: {changes:int, per_option:[...]}}
  final Map<String, int> answers;       // {qId: selectedIndex}
  final DateTime finishedAt;

  const AttemptPayload({
    required this.quizId,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeSpentSec,
    required this.score,
    required this.tapCountTotal,
    required this.changeCountTotal,
    required this.tapCounts,
    required this.answers,
    required this.finishedAt,
  });

  Map<String, dynamic> toRow(String userId) => {
    'user_id': userId,
    'quiz_id': quizId,
    'correct_count': correctCount,
    'total_questions': totalQuestions,
    'time_spent_sec': timeSpentSec,
    'score': score,
    'tap_count_total': tapCountTotal,
    'change_count_total': changeCountTotal,
    'tap_counts': tapCounts,
    'answers': answers,
    'finished_at': finishedAt.toIso8601String(),
  };
}
