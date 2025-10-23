import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LBPeriod { weekly, monthly, allTime }

class GlobalLBEntry {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final int totalScore;
  final int attempts;
  final DateTime? lastAttempt;

  GlobalLBEntry({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.totalScore,
    required this.attempts,
    required this.lastAttempt,
  });
}

DateTime _startOfWeek(DateTime now) {
  final d = DateTime(now.year, now.month, now.day);
  // Monday as start (1..7). If you want Sunday, adjust.
  return d.subtract(Duration(days: d.weekday - 1));
}

DateTime _startOfMonth(DateTime now) => DateTime(now.year, now.month, 1);

final globalLeaderboardProvider =
FutureProvider.family<List<GlobalLBEntry>, LBPeriod>((ref, period) async {
  final sb = Supabase.instance.client;

  // 1) period window
  DateTime? from;
  final now = DateTime.now();
  switch (period) {
    case LBPeriod.weekly:
      from = _startOfWeek(now);
      break;
    case LBPeriod.monthly:
      from = _startOfMonth(now);
      break;
    case LBPeriod.allTime:
      from = null;
      break;
  }

  // 2) fetch attempts (filter by finished_at if needed)
  var query = sb
      .from('quiz_attempts')
      .select(
      'user_id, score, finished_at, user:profiles(id,display_name,avatar_url)');
  if (from != null) {
    query = query.gte('finished_at', from.toIso8601String());
  }
  final res = await query;

  // 3) group by user (sum score)
  final map = HashMap<String, GlobalLBEntry>();
  for (final row in (res as List)) {
    final m = row as Map<String, dynamic>;
    final uid = m['user_id'] as String;
    final score = (m['score'] ?? 0) as int;
    final finishedAt = DateTime.tryParse(m['finished_at'] as String? ?? '');
    final u = m['user'] as Map<String, dynamic>?;

    final prev = map[uid];
    if (prev == null) {
      map[uid] = GlobalLBEntry(
        userId: uid,
        displayName: u?['display_name'] as String?,
        avatarUrl: u?['avatar_url'] as String?,
        totalScore: score,
        attempts: 1,
        lastAttempt: finishedAt,
      );
    } else {
      map[uid] = GlobalLBEntry(
        userId: uid,
        displayName: prev.displayName ?? (u?['display_name'] as String?),
        avatarUrl: prev.avatarUrl ?? (u?['avatar_url'] as String?),
        totalScore: prev.totalScore + score,
        attempts: prev.attempts + 1,
        lastAttempt: [
          if (prev.lastAttempt != null) prev.lastAttempt!,
          if (finishedAt != null) finishedAt
        ].fold<DateTime?>(null, (a, b) => a == null ? b : (b.isAfter(a) ? b : a)),
      );
    }
  }

  final list = map.values.toList();

  // 4) sort (score desc, attempts desc, lastAttempt asc for stability)
  list.sort((a, b) {
    if (a.totalScore != b.totalScore) {
      return b.totalScore.compareTo(a.totalScore);
    }
    if (a.attempts != b.attempts) {
      return b.attempts.compareTo(a.attempts);
    }
    final aa = a.lastAttempt?.millisecondsSinceEpoch ?? 1 << 62;
    final bb = b.lastAttempt?.millisecondsSinceEpoch ?? 1 << 62;
    return aa.compareTo(bb);
  });

  return list;
});
