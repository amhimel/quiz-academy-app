import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';

/// Holds the last searched code (null = no search yet)
final quizSearchQueryProvider =
StateProvider.autoDispose<String?>((ref) => null);

/// Search quiz by code (e.g. Q-123-456)
final quizByCodeProvider =
FutureProvider.family<Quiz?, String>((ref, codeRaw) async {
  final code = codeRaw.trim();
  if (code.isEmpty) return null;

  final sb = Supabase.instance.client;

  final data = await sb
      .from('quizzes')
      .select(
      'id, code, title, description, type, duration_minutes, '
          'num_questions, created_at, created_by'
  )
      .eq('code', code)
      .maybeSingle();

  if (data == null) return null;
  return Quiz.fromMap(data as Map<String, dynamic>);
});
