class QuizState {
  final bool isSaving;
  final String? error;

  QuizState({this.isSaving = false, this.error});

  QuizState copyWith({bool? isSaving, String? error}) {
    return QuizState(
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}