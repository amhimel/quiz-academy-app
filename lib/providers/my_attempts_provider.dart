import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attempt_row.dart';
import '../models/quiz.dart';

/// আমি যেসব কুইজ দিয়েছি — সেগুলো (unique) + আমার লাস্ট অ্যাটেম্পট সাথে।
final myAttemptedQuizzesProvider = FutureProvider<List<AttemptWithQuiz>>((
  ref,
) async {
  final sb = Supabase.instance.client;
  final uid = sb.auth.currentUser?.id;
  if (uid == null) return const [];

  final res = await sb
      .from('quiz_attempts')
      .select(
        'id,user_id,quiz_id,correct_count,total_questions,time_spent_sec,score,change_count_total,finished_at,'
        'quiz:quizzes(id,code,title,description,type,duration_minutes,num_questions,created_at,created_by)',
      )
      .eq('user_id', uid)
      .order('finished_at', ascending: false);

  // latest per quiz
  final seen = HashSet<String>();
  final out = <AttemptWithQuiz>[];
  for (final row in (res as List)) {
    final m = row as Map<String, dynamic>;
    final attempt = AttemptRow.fromMap(m);
    if (seen.contains(attempt.quizId)) continue;
    seen.add(attempt.quizId);
    final q = Quiz.fromMap(m['quiz'] as Map<String, dynamic>);
    out.add(AttemptWithQuiz(attempt: attempt, quiz: q));
  }
  return out;
});

/// কতজন People join (distinct users) — সিম্পল safe ভার্সন
final participantsCountProvider =
FutureProvider.autoDispose.family<int, String>((ref, quizId) async {
  final sb = Supabase.instance.client;
  final res = await sb.from('quiz_attempts')
      .select('user_id')
      .eq('quiz_id', quizId);

  final set = <String>{};
  for (final m in (res as List)) {
    set.add((m as Map<String, dynamic>)['user_id'] as String);
  }
  return set.length;
});
