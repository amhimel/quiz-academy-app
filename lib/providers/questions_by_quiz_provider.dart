import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';

final questionsByQuizProvider =
FutureProvider.family<List<Question>, String>((ref, quizId) async {
  final sb = Supabase.instance.client;

  final res = await sb
      .from('questions')
      .select('id, quiz_id, text, options, correct_index, created_at')
      .eq('quiz_id', quizId)
      .order('created_at');

  final list = (res as List<dynamic>)
      .map((e) => Question.fromMap(e as Map<String, dynamic>))
      .toList(growable: false);

  return list;
});
