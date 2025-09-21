import '../core/enums/all_enum.dart';

extension QuizTypeX on QuizType {
  String get label {
    switch (this) {
      case QuizType.generalKnowledge:
        return 'General Knowledge';
      case QuizType.science:
        return 'Science';
      case QuizType.history:
        return 'History';
      case QuizType.sports:
        return 'Sports';
      case QuizType.technology:
        return 'Technology';
      case QuizType.custom:
        return 'Custom';
    }
  }
}