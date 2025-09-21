import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/widgets/app_button.dart';
import '../../models/quiz_draft.dart';
import '../../providers/quiz_notifier.dart';
import '../../widgets/progress_bar.dart';

const _primary = Color(0xFF4E5CF5);

/// ───────────────────────── Providers (top-level) ─────────────────────────
/// Current question index (0-based)
final currentQuestionIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Correct option index for the *currently visible* question (0..3 or null)
final correctIndexProvider = StateProvider.autoDispose<int?>((ref) => null);

class CreateQuizQuestionsScreen extends ConsumerStatefulWidget {
  final QuizDraft draft;
  const CreateQuizQuestionsScreen({super.key, required this.draft});

  @override
  ConsumerState<CreateQuizQuestionsScreen> createState() =>
      _CreateQuizQuestionsScreenState();
}

class _CreateQuizQuestionsScreenState
    extends ConsumerState<CreateQuizQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers for the visible question
  late final TextEditingController _q = TextEditingController();
  late final List<TextEditingController> _opts =
  List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _loadControllersForIndex(0); // initial load
  }

  @override
  void dispose() {
    _q.dispose();
    for (final c in _opts) {
      c.dispose();
    }
    super.dispose();
  }

  /// Load text fields and selected correct option from the draft at [idx]
  void _loadControllersForIndex(int idx) {
    final q = widget.draft.questions[idx];
    _q.text = q.text;
    for (int i = 0; i < _opts.length; i++) {
      _opts[i].text = i < q.options.length ? q.options[i] : '';
    }
    ref.read(correctIndexProvider.notifier).state = q.correctIndex;
  }

  /// Persist what's currently on screen back into draft at [idx]
  void _saveCurrent(int idx) {
    final qd = widget.draft.questions[idx];
    qd.text = _q.text.trim();
    qd.options = _opts.map((c) => c.text.trim()).toList();
    qd.correctIndex = ref.read(correctIndexProvider);
  }

  Future<void> _nextOrFinish() async {
    if (!_formKey.currentState!.validate()) return;

    final correct = ref.read(correctIndexProvider);
    if (correct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the correct answer.')),
      );
      return;
    }

    final index = ref.read(currentQuestionIndexProvider);
    final isLast = index == widget.draft.numQuestions - 1;

    _saveCurrent(index);

    if (isLast) {
      final notifier = ref.read(quizNotifierProvider.notifier);
      final success = await notifier.saveQuiz(widget.draft);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved to Supabase!')),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(quizNotifierProvider).error ?? "Unknown error";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } else {
      // Move to next question (no setState needed)
      ref.read(currentQuestionIndexProvider.notifier).state = index + 1;
      // Controllers will reload via ref.listen in build()
    }
  }

  Future<void> _copyCode() async {
    final code = widget.draft.code;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied: $code'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  InputDecoration _filledDecoration(
      BuildContext context, {
        String? label,
        String? hint,
        String? helper,
        String? suffixText,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(currentQuestionIndexProvider);
    final total = widget.draft.numQuestions;
    final isLast = index == total - 1;

    // VALID: listen inside build to reload controllers when index changes
    ref.listen<int>(currentQuestionIndexProvider, (previous, next) {
      if (previous != next) _loadControllersForIndex(next);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Create Quiz")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Code + Copy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.draft.code,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ProgressBar(currentIndex: index, total: total),
              const SizedBox(height: 16),

              Text(
                "Question ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 16),
              const Text("Quiz Question"),
              const SizedBox(height: 10),

              TextFormField(
                maxLength: 100,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontSize: 16),
                controller: _q,
                decoration: _filledDecoration(
                  context,
                  label: 'Question',
                  hint: 'What is the h02?',
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Required" : null,
              ),

              const SizedBox(height: 12),
              const Text("Quiz Options (select the correct one)"),
              const SizedBox(height: 10),

              for (int i = 0; i < _opts.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: ref.watch(correctIndexProvider),
                      onChanged: (v) =>
                      ref.read(correctIndexProvider.notifier).state = v,
                      activeColor: _primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextFormField(
                        controller: _opts[i],
                        decoration: _filledDecoration(
                          context,
                          label: 'Option ${i + 1}',
                        ),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Required" : null,
                        textInputAction: (i == _opts.length - 1)
                            ? TextInputAction.done
                            : TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              if (ref.watch(correctIndexProvider) == null)
                const Padding(
                  padding: EdgeInsets.only(left: 40.0, bottom: 8),
                  child: Text(
                    'Please select the correct option.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 8),
              AppButton(
                onPressed: _nextOrFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                label: isLast ? "Continue" : "Next Question",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
