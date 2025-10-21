import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attempt_row.dart';

final quizLeaderboardProvider =
FutureProvider.family<List<LeaderboardEntry>, String>((ref, quizId) async {
  final sb = Supabase.instance.client;

  final res = await sb
      .from('quiz_attempts')
      .select(
      'id,user_id,quiz_id,correct_count,total_questions,time_spent_sec,score,change_count_total,finished_at,'
          'user:profiles(id,display_name,avatar_url)')
      .eq('quiz_id', quizId);

  // pick best attempt per user (score desc, accuracy desc, time asc, changes asc, finished_at asc)
  final best = <String, AttemptRow>{};
  int cmp(AttemptRow a, AttemptRow b) {
    if (a.score != b.score) return b.score.compareTo(a.score);
    final aa = a.totalQuestions == 0 ? 0 : a.correctCount / a.totalQuestions;
    final bb = b.totalQuestions == 0 ? 0 : b.correctCount / b.totalQuestions;
    if (aa != bb) return bb.compareTo(aa);
    if (a.timeSpentSec != b.timeSpentSec) {
      return a.timeSpentSec.compareTo(b.timeSpentSec);
    }
    final ac = a.changeCountTotal ?? (1 << 30);
    final bc = b.changeCountTotal ?? (1 << 30);
    if (ac != bc) return ac.compareTo(bc);
    return a.finishedAt.compareTo(b.finishedAt);
  }

  // choose best
  final metaByUser = HashMap<String, Map<String, dynamic>>();
  for (final raw in (res as List)) {
    final m = raw as Map<String, dynamic>;
    final attempt = AttemptRow.fromMap(m);
    final uid = attempt.userId;

    metaByUser[uid] = m['user'] as Map<String, dynamic>? ?? {};
    final prev = best[uid];
    if (prev == null || cmp(attempt, prev) < 0) {
      best[uid] = attempt;
    }
  }

  // to entries
  final entries = <LeaderboardEntry>[
    for (final uid in best.keys)
      LeaderboardEntry(
        userId: uid,
        displayName: metaByUser[uid]?['display_name'] as String?,
        avatarUrl: metaByUser[uid]?['avatar_url'] as String?,
        bestAttempt: best[uid]!,
      )
  ];

  // final sort
  entries.sort((a, b) => cmp(a.bestAttempt, b.bestAttempt));
  return entries;
});
