import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/providers/csv_import_state.dart';
import 'package:quiz_academy/repositories/csv_import_repository.dart';


class CsvImportNotifier extends StateNotifier<CsvImportState> {
  CsvImportNotifier(this._repo) : super(const CsvImportState());
  final CsvImportRepository _repo;

  Future<void> importFromPicker() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _repo.pickAndImport();

    if (res.cancelled) {
      state = const CsvImportState(); // reset
      return;
    }

    if (res.error != null) {
      state = CsvImportState(loading: false, error: res.error);
    } else {
      state = CsvImportState(
        loading: false,
        quizzes: res.importedQuizzes,
        questions: res.importedQuestions,
      );
    }
  }
}

final csvImportProvider =
StateNotifierProvider<CsvImportNotifier, CsvImportState>((ref) {
  return CsvImportNotifier(CsvImportRepository());
});
