import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_draft.dart';
import '../repositories/csv_import_repository.dart';
import 'package:flutter/material.dart';
import '../../screens/create_quiz/create_quiz_meta_screen.dart';

class CsvImportState {
  final bool loading;
  final String? error;
  final int quizzes;
  final int questions;

  CsvImportState({
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

Future<void> showCreateOrImportSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final theme = Theme.of(context);
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final st = ref.watch(csvImportProvider);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create or Import', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),

            // Option 1: Import
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import questions from CSV'),
              subtitle: const Text('Bulk add questions to a quiz by file'),
              onTap: st.loading
                  ? null
                  : () async {
                      Navigator.of(ctx).pop(); // close sheet first
                      // trigger import picker
                      await ref
                          .read(csvImportProvider.notifier)
                          .importFromPicker();

                      final result = ref.read(csvImportProvider);
                      if (result.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Import failed: ${result.error}'),
                          ),
                        );
                      } else if (!result.loading && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Imported ${result.quizzes} quiz(es), ${result.questions} question(s).',
                            ),
                          ),
                        );
                      }
                    },
              trailing: st.loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
            ),

            const Divider(height: 8),

            // Option 2: Make
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Make questions manually'),
              subtitle: const Text(
                'Create a new quiz and add questions one by one',
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                // navigate to your quiz creation flow
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateQuizMetaScreen(
                      initialCode: generateCode(), // your helper
                    ),
                  ),
                );
              },
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      );
    },
  );
}

class CsvImportNotifier extends StateNotifier<CsvImportState> {
  CsvImportNotifier(this._repo) : super(CsvImportState());
  final CsvImportRepository _repo;

  Future<void> importFromPicker() async {
    state = state.copyWith(loading: true, error: null);
    final res = await _repo.pickAndImport();
    if (res.cancelled) {
      state = CsvImportState(); // reset
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
