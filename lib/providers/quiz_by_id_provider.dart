import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';

final quizByIdProvider =
FutureProvider.family<Quiz, String>((ref, quizId) async {
  final sb = Supabase.instance.client;

  final res = await sb
      .from('quizzes')
      .select('id, code, title, description, type, duration_minutes, '
      'num_questions, created_at, created_by')
      .eq('id', quizId)
      .limit(1);

  final list = (res as List<dynamic>);
  if (list.isEmpty) throw Exception('Quiz not found');
  return Quiz.fromMap(list.first as Map<String, dynamic>);
});
