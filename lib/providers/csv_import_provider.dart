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
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    // 👇 we delegate to a small stateful widget so we can run animations inside
    builder: (ctx) => _CreateOrImportSheet(),
  );
}

/// Bottom sheet content with staggered animations
class _CreateOrImportSheet extends StatefulWidget {
  @override
  State<_CreateOrImportSheet> createState() => _CreateOrImportSheetState();
}

class _CreateOrImportSheetState extends State<_CreateOrImportSheet> {
  bool _showFirst = false;
  bool _showSecond = false;

  @override
  void initState() {
    super.initState();
    // Staggered reveal
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _showFirst = true);
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _showSecond = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Consumer(
        builder: (context, ref, _) {
          final st = ref.watch(csvImportProvider);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✨ Create or Import',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ───────────────────────── Import card ─────────────────────────
              _AnimatedChoiceCard(
                visible: _showFirst,
                duration: const Duration(milliseconds: 260),
                offset: const Offset(0, 0.12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: st.loading
                      ? null
                      : () async {
                    Navigator.of(context).pop(); // close sheet
                    await ref
                        .read(csvImportProvider.notifier)
                        .importFromPicker();

                    final result = ref.read(csvImportProvider);
                    if (result.error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade400,
                          content:
                          Text('❌ Import failed: ${result.error}'),
                        ),
                      );
                    } else if (!result.loading && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green.shade600,
                          content: Text(
                            '✅ Imported ${result.quizzes} quiz(es), '
                                '${result.questions} question(s).',
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primary,
                            child: st.loading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.upload_file,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Import from CSV',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ───────────────────────── Make card ─────────────────────────
              _AnimatedChoiceCard(
                visible: _showSecond,
                duration: const Duration(milliseconds: 300),
                offset: const Offset(0, 0.12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateQuizMetaScreen(
                          initialCode: generateCode(),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: theme.colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.secondary,
                            child: const Icon(
                              Icons.add_circle_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Make Questions Manually',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Reusable slide+fade wrapper
class _AnimatedChoiceCard extends StatelessWidget {
  const _AnimatedChoiceCard({
    required this.child,
    required this.visible,
    required this.duration,
    required this.offset,
  });

  final Widget child;
  final bool visible;
  final Duration duration;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : offset,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
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
