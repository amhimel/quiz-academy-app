class CsvImportState {
  final bool loading;
  final String? error;
  final int quizzes;
  final int questions;

  const CsvImportState({
    this.loading = false,
    this.error,
    this.quizzes = 0,
    this.questions = 0,
  });

  CsvImportState copyWith({
    bool? loading,
    String? error,
    int? quizzes,
    int? questions,
  }) {
    return CsvImportState(
      loading: loading ?? this.loading,
      error: error,
      quizzes: quizzes ?? this.quizzes,
      questions: questions ?? this.questions,
    );
  }
}
