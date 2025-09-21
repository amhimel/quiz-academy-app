import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_academy/models/quiz_type.dart';
import 'package:quiz_academy/widgets/app_button.dart';
import '../../core/enums/all_enum.dart';
import '../../models/question_draft.dart';
import '../../models/quiz_draft.dart';
import '../../widgets/custom_back_button.dart';
import 'create_quiz_questions_screen.dart';

const _primary = Color(0xFF4E5CF5);

// Ranges
const _minQuestions = 1;
const _maxQuestions = 100;
const _minMinutes = 1;
const _maxMinutes = 180;

// Defaults (shown as hints; used if left empty)
const _defaultQuestions = 10;
const _defaultMinutes = 5;

class CreateQuizMetaScreen extends StatefulWidget {
  final String initialCode;

  const CreateQuizMetaScreen({super.key, required this.initialCode});

  @override
  State<CreateQuizMetaScreen> createState() => _CreateQuizMetaScreenState();
}

class _CreateQuizMetaScreenState extends State<CreateQuizMetaScreen> {
  final _formKey = GlobalKey<FormState>();

  // text controllers
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  // numeric controllers (EMPTY so hint shows and clears on focus)
  final TextEditingController _numQCtrl = TextEditingController();
  final TextEditingController _durCtrl = TextEditingController();

  // focus (optional now; kept if you later prefill text)
  final _numQFocus = FocusNode();
  final _durFocus = FocusNode();

  QuizType _type = QuizType.generalKnowledge;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _numQCtrl.dispose();
    _durCtrl.dispose();
    _numQFocus.dispose();
    _durFocus.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _validateIntInRangeAllowEmpty(
    String? v, {
    required int min,
    required int max,
  }) {
    // Allow empty (we’ll use default on submit)
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'Enter a valid number';
    if (n < min || n > max) return 'Enter between $min and $max';
    return null;
  }

  // Auto-format: strip leading zeros, clamp to max, keep caret.
  void _normalizeNumeric(TextEditingController c, int max) {
    final old = c.text;
    if (old.isEmpty) return; // allow empty so hint can show
    String next = old.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (next.isEmpty) next = '0';
    final parsed = int.tryParse(next);
    if (parsed != null && parsed > max) next = max.toString();
    if (next != c.text) {
      c.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final numQuestions =
        int.tryParse(
          _numQCtrl.text.trim().isEmpty
              ? _defaultQuestions.toString()
              : _numQCtrl.text.trim(),
        ) ??
        _defaultQuestions;

    final duration =
        int.tryParse(
          _durCtrl.text.trim().isEmpty
              ? _defaultMinutes.toString()
              : _durCtrl.text.trim(),
        ) ??
        _defaultMinutes;

    final draft = QuizDraft(
      code: widget.initialCode,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      type: _type,
      numQuestions: numQuestions,
      durationMinutes: duration,
      questions: List.generate(numQuestions, (_) => QuestionDraft()),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateQuizQuestionsScreen(draft: draft),
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
  Future<void> _copyCode() async {
    final code = widget.initialCode;
    await Clipboard.setData(ClipboardData(text: code)); // copy
    if (!mounted) return;
    // Optional haptic feedback
    HapticFeedback.lightImpact();

    // Show confirmation
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Quiz"),
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8,0,8,8),
          child: CustomBackButton(onPressed: (){},),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.initialCode,
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

                // Quiz Title
                //const Text("Enter the name of the Quiz"),
                //const SizedBox(height: 10),
                TextFormField(
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 16),
                  controller: _title,
                  decoration: _filledDecoration(
                    context,
                    label: 'Enter the name of the Quiz',
                  ),
                  validator: _required,
                ),

                // Quiz Description
                //const SizedBox(height: 10),
                //const Text("Enter the Quiz Descriptions"),
                const SizedBox(height: 10),
                TextFormField(
                  maxLength: 300,
                  minLines: 3,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 16),
                  controller: _desc,
                  decoration: _filledDecoration(
                    context,
                    label: 'Enter the Quiz Descriptions',
                    hint:
                        'Tell players what to expect, topics, difficulty, etc.',
                  ),
                  validator: _required,
                ),

                const SizedBox(height: 10),

                // Quiz Type (dropdown styled like text field)
                //const Text("Quiz Type"),
                //const SizedBox(height: 10),
                DropdownButtonFormField<QuizType>(
                  isExpanded: true,
                  value: _type,
                  decoration: _filledDecoration(context, label: 'Quiz Type'),
                  items: QuizType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),

                // Number of Questions
                //const SizedBox(height: 16),
                // const Text("Number of Questions"),
                const SizedBox(height: 10),
                TextFormField(
                  focusNode: _numQFocus,
                  controller: _numQCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3), // up to 100
                  ],
                  decoration: _filledDecoration(
                    context,
                    label: 'Number of Questions',
                    hint: '$_defaultQuestions',
                    helper: 'Allowed: $_minQuestions–$_maxQuestions',
                  ),
                  validator: (v) => _validateIntInRangeAllowEmpty(
                    v,
                    min: _minQuestions,
                    max: _maxQuestions,
                  ),
                  onChanged: (_) => _normalizeNumeric(_numQCtrl, _maxQuestions),
                ),

                // Quiz Duration (minutes)
                // const SizedBox(height: 16),
                // const Text("Quiz Duration"),
                const SizedBox(height: 10),
                TextFormField(
                  focusNode: _durFocus,
                  controller: _durCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3), // up to 180
                  ],
                  decoration: _filledDecoration(
                    context,
                    label: 'Quiz Duration',
                    hint: '$_defaultMinutes',
                    helper: 'Allowed: $_minMinutes–$_maxMinutes minutes',
                  ),
                  validator: (v) => _validateIntInRangeAllowEmpty(
                    v,
                    min: _minMinutes,
                    max: _maxMinutes,
                  ),
                  onChanged: (_) => _normalizeNumeric(_durCtrl, _maxMinutes),
                ),

                const SizedBox(height: 24),
                AppButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: 'Continue',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
