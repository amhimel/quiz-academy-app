import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_draft.dart';

class QuizRepository {
  final _sb = Supabase.instance.client;

  /// Save a full quiz (quizzes + questions)
  Future<void> saveQuiz(QuizDraft draft) async {
    final user = _sb.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    // Insert quiz row and return its id
    final quizRes = await _sb
        .from('quizzes')
        .insert({
          'code': draft.code,
          'title': draft.title,
          'description': draft.description,
          'type': draft.type.name, // enum as string
          'duration_minutes': draft.durationMinutes,
          'num_questions': draft.numQuestions,
          'created_by': user.id,
        })
        .select('id')
        .single();

    final quizId = quizRes['id'];

    // Insert all questions
    final questions = draft.questions.map(
      (q) => {
        'quiz_id': quizId,
        'text': q.text,
        'options': q.options, // jsonb array
        'correct_index': q.correctIndex,
      },
    );

    await _sb.from('questions').insert(questions.toList());
  }
}
