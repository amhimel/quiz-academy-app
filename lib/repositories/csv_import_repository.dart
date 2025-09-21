import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CsvImportRepository {
  final _sb = Supabase.instance.client;

  /// Pick a CSV file and import all quizzes/questions it contains.
  Future<ImportResult> pickAndImport() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true, // for web; on mobile you can read via path
    );
    if (res == null) {
      return ImportResult(cancelled: true);
    }

    final file = res.files.single;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final csvString = utf8.decode(bytes);

    return importFromCsvString(csvString);
  }

  /// Import quizzes from a CSV string with the header described above.
  Future<ImportResult> importFromCsvString(String csvString) async {
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);

    if (rows.isEmpty) {
      return ImportResult(error: 'CSV is empty.');
    }

    // Validate header
    final header = rows.first.map((e) => (e ?? '').toString().trim()).toList();
    final expected = [
      'code','title','description','type','duration_minutes','num_questions',
      'question_text','option1','option2','option3','option4','correct_index'
    ];
    if (!_sameHeader(header, expected)) {
      return ImportResult(
        error: 'Invalid header. Expected: ${expected.join(', ')}\nGot: ${header.join(', ')}',
      );
    }

    // Group rows by quiz code
    final Map<String, _QuizAccumulator> groups = {};

    for (int i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.isEmpty || (r.length == 1 && (r[0] as String).trim().isEmpty)) {
        continue; // skip blank lines
      }
      if (r.length < expected.length) {
        return ImportResult(error: 'Row ${i+1} has ${r.length} columns; expected ${expected.length}.');
      }

      final code   = _s(r[0]);
      final title  = _s(r[1]);
      final desc   = _s(r[2]);
      final type   = _s(r[3]);
      final durStr = _s(r[4]);
      final numStr = _s(r[5]);
      final qText  = _s(r[6]);
      final o1     = _s(r[7]);
      final o2     = _s(r[8]);
      final o3     = _s(r[9]);
      final o4     = _s(r[10]);
      final ciStr  = _s(r[11]);

      if (code.isEmpty) {
        return ImportResult(error: 'Row ${i+1}: "code" is required.');
      }
      if (qText.isEmpty) {
        return ImportResult(error: 'Row ${i+1}: "question_text" is required.');
      }

      final duration = int.tryParse(durStr) ?? 5;
      final declaredNum = int.tryParse(numStr);
      final correctIndex = int.tryParse(ciStr);
      if (correctIndex == null || correctIndex < 0 || correctIndex > 3) {
        return ImportResult(error: 'Row ${i+1}: correct_index must be 0..3.');
      }

      final acc = groups.putIfAbsent(code, () => _QuizAccumulator(
        code: code,
        title: title,
        description: desc,
        type: type.isEmpty ? 'generalKnowledge' : type,
        durationMinutes: duration,
        declaredNumQuestions: declaredNum,
      ));

      acc.questions.add(_QuestionRow(
        text: qText,
        options: [o1, o2, o3, o4],
        correctIndex: correctIndex,
      ));
    }

    if (groups.isEmpty) {
      return ImportResult(error: 'No data rows found.');
    }

    // Current user (for created_by)
    final user = _sb.auth.currentUser;
    if (user == null) {
      return ImportResult(error: 'You must be logged in to import.');
    }

    int importedQuizzes = 0;
    int importedQuestions = 0;

    for (final acc in groups.values) {
      // upsert quiz by code (to avoid duplicates)
      final quizRes = await _sb.from('quizzes').upsert({
        'code': acc.code,
        'title': acc.title,
        'description': acc.description,
        'type': acc.type,
        'duration_minutes': acc.durationMinutes,
        'num_questions': acc.declaredNumQuestions ?? acc.questions.length,
        'created_by': user.id,
      }, onConflict: 'code').select('id').single();

      final quizId = quizRes['id'];

      // Clean up any existing questions for this quiz (optional; comment if you prefer append)
      await _sb.from('questions').delete().eq('quiz_id', quizId);

      // Insert questions
      final payload = acc.questions.map((q) => {
        'quiz_id': quizId,
        'text': q.text,
        'options': q.options, // jsonb
        'correct_index': q.correctIndex,
      }).toList();

      if (payload.isNotEmpty) {
        await _sb.from('questions').insert(payload);
      }

      importedQuizzes += 1;
      importedQuestions += payload.length;
    }

    return ImportResult(
      importedQuizzes: importedQuizzes,
      importedQuestions: importedQuestions,
    );
  }

  static bool _sameHeader(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].toLowerCase() != b[i].toLowerCase()) return false;
    }
    return true;
  }

  static String _s(dynamic v) => (v ?? '').toString().trim();
}

class ImportResult {
  final bool cancelled;
  final String? error;
  final int importedQuizzes;
  final int importedQuestions;
  ImportResult({
    this.cancelled = false,
    this.error,
    this.importedQuizzes = 0,
    this.importedQuestions = 0,
  });
}

class _QuizAccumulator {
  final String code;
  final String title;
  final String description;
  final String type;
  final int durationMinutes;
  final int? declaredNumQuestions;
  final List<_QuestionRow> questions = [];

  _QuizAccumulator({
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.declaredNumQuestions,
  });
}

class _QuestionRow {
  final String text;
  final List<String> options;
  final int correctIndex;
  _QuestionRow({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}
