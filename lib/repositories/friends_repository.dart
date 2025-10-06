import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/friend_request.dart';

class FriendsRepository {
  final _sb = Supabase.instance.client;

  Future<void> sendRequest(String toUserId) async {
    final me = _sb.auth.currentUser!.id;
    if (me == toUserId) throw 'You cannot friend yourself';
    await _sb.from('friend_requests').insert({
      'from_user': me,
      'to_user': toUserId,
    });
  }

  Future<void> cancelRequest(int requestId) async {
    await _sb.from('friend_requests').delete().match({
      'id': requestId,
      'status': 'pending', // extra safety; policy also enforces sender+pending
    });
  }

  Future<void> accept(int requestId) async {
    await _sb.from('friend_requests').update({
      'status': 'accepted',
      'decided_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  Future<void> decline(int requestId) async {
    await _sb.from('friend_requests').update({
      'status': 'declined',
      'decided_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  Future<List<FriendRequest>> incoming() async {
    final me = _sb.auth.currentUser!.id;
    final rows = await _sb
        .from('friend_requests')
        .select('*')
        .eq('to_user', me)
        .eq('status', 'pending')
        .order('requested_at', ascending: false);
    return (rows as List).map((e) => FriendRequest.fromMap(e)).toList();
  }

  Future<List<FriendRequest>> outgoing() async {
    final me = _sb.auth.currentUser!.id;
    final rows = await _sb
        .from('friend_requests')
        .select('*')
        .eq('from_user', me)
        .eq('status', 'pending')
        .order('requested_at', ascending: false);
    return (rows as List).map((e) => FriendRequest.fromMap(e)).toList();
  }

  Future<List<String>> friendsIds() async {
    final me = _sb.auth.currentUser!.id;
    final rows = await _sb.rpc('friend_ids', params: {'p_user': me});

    if (rows == null) return [];

    // handles both shapes: ['uuid', ...] or [{'friend_id':'uuid'}, ...]
    final list = rows as List;
    return list.map<String>((e) {
      if (e is String) return e;
      if (e is Map<String, dynamic>) return e['friend_id'] as String;
      throw StateError('Unexpected RPC row shape: $e');
    }).toList();
  }


  Future<List<Map<String, dynamic>>> friendQuizzes({int limit = 50}) async {
    final rows = await _sb
        .from('friend_quizzes')
        .select('*')
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  /// Realtime: stream new incoming friend requests for me
  RealtimeChannel subscribeIncoming(void Function(FriendRequest fr) onInsert) {
    final me = _sb.auth.currentUser!.id;
    final ch = _sb.channel('friend-req-$me')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'friend_requests',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'to_user', value: me),
        callback: (payload) {
          onInsert(FriendRequest.fromMap(payload.newRecord));
        },
      )
      ..subscribe();
    return ch;
  }

  /// Realtime: stream new quizzes by friends (optional)
  RealtimeChannel subscribeFriendQuizzes(void Function(Map<String,dynamic>) onInsert) {
    final ch = _sb.channel('friend-quizzes')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'quizzes',
        callback: (payload) async {
          // check if author is a friend before surfacing
          final author = payload.newRecord['created_by'] as String?;
          if (author == null) return;
          final ids = await friendsIds();
          if (ids.contains(author)) onInsert(payload.newRecord);
        },
      )
      ..subscribe();
    return ch;
  }
}
