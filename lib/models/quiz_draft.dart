import 'dart:math';
import '../core/enums/all_enum.dart';
import 'question_draft.dart';
import 'quiz_type.dart';

class QuizDraft {
  final String code; // e.g., Q-452-456
  String title;
  String description;
  QuizType type;
  int numQuestions;
  int durationMinutes;
  final List<QuestionDraft> questions;

  QuizDraft({
    required this.code,
    this.title = '',
    this.description = '',
    this.type = QuizType.generalKnowledge,
    this.numQuestions = 10,
    this.durationMinutes = 5,
    List<QuestionDraft>? questions,
  }) : questions = questions ?? [];
}

// Utility to generate random quiz codes
String generateCode() {
  final rnd = Random();
  String part() => (100 + rnd.nextInt(900)).toString();
  return 'Q-${part()}-${part()}';
}
