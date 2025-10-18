import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attempt_payload.dart';

/// State = AsyncValue<String?>  -> success হলে attempt id
final attemptSubmitControllerProvider =
StateNotifierProvider<AttemptSubmitController, AsyncValue<String?>>(
      (ref) => AttemptSubmitController(ref),
);

class AttemptSubmitController extends StateNotifier<AsyncValue<String?>> {
  AttemptSubmitController(this.ref) : super(const AsyncData<String?>(null));

  final Ref ref;

  Future<void> submit(AttemptPayload payload) async {
    state = const AsyncLoading();

    try {
      final sb = Supabase.instance.client;
      final uid = sb.auth.currentUser?.id;
      if (uid == null) {
        throw Exception('Not logged in');
      }

      final row = payload.toRow(uid);

      // পূর্ণ কলামসহ insert (id ফেরত নেব)
      final inserted = await sb
          .from('quiz_attempts')
          .insert(row)
          .select('id')
          .single();

      state = AsyncData<String?>(inserted['id'] as String?);
    } catch (e, st) {
      // যদি কিছু কলাম না থাকে, মিনিমাল সেটে fallback
      try {
        final sb = Supabase.instance.client;
        final uid = sb.auth.currentUser?.id;
        if (uid == null) rethrow;

        final minimal = {
          'user_id': uid,
          'quiz_id': payload.quizId,
          'correct_count': payload.correctCount,
          'total_questions': payload.totalQuestions,
          'time_spent_sec': payload.timeSpentSec,
          'score': payload.score,
          'finished_at': payload.finishedAt.toIso8601String(),
        };

        final inserted = await sb
            .from('quiz_attempts')
            .insert(minimal)
            .select('id')
            .single();

        state = AsyncData<String?>(inserted['id'] as String?);
      } catch (e2, st2) {
        state = AsyncError(e2, st2);
      }
    }
  }

  void reset() => state = const AsyncData<String?>(null);
}
