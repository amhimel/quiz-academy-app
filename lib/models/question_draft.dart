class QuestionDraft {
  String text;
  List<String> options;
  int? correctIndex; // <-- which option is correct (0-based). null if not chosen yet.

  QuestionDraft({
    this.text = '',
    List<String>? options,
    this.correctIndex,
  }) : options = options ?? ['', '', '', '']; // you use 4 options in UI
}
