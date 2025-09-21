import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_draft.dart';
import '../models/quiz_state.dart';
import '../repositories/quiz_repository.dart';


class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._repo) : super(QuizState());

  final QuizRepository _repo;

  Future<bool> saveQuiz(QuizDraft draft) async {
    try {
      state = state.copyWith(isSaving: true, error: null);
      await _repo.saveQuiz(draft);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

/// Provider
final quizNotifierProvider =
StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(QuizRepository());
});
