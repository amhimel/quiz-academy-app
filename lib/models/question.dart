import 'package:flutter/foundation.dart';

@immutable
class Question {
  final String id;
  final String quizId;
  final String text;
  final List<String> options;
  final int correctIndex;

  const Question({
    required this.id,
    required this.quizId,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromMap(Map<String, dynamic> m) {
    final rawOpts = (m['options'] ?? []) as List<dynamic>;
    return Question(
      id: m['id'] as String,
      quizId: m['quiz_id'] as String,
      text: (m['text'] ?? '') as String,
      options: rawOpts.map((e) => e.toString()).toList(growable: false),
      correctIndex: (m['correct_index'] ?? -1) as int,
    );
  }
}
