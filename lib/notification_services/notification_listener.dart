import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class NotificationListener {
  NotificationListener(this._supabase, this._service);

  final SupabaseClient _supabase;
  final NotificationService _service;
  RealtimeChannel? _ch;

  void start(String userId) {
    _ch = _supabase.channel('notif-$userId');

    _ch!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'to_user',
        value: userId, // UUID string OK
      ),
      callback: (payload) {
        final rec = payload.newRecord;
        final title = (rec['title'] as String?) ?? 'New quiz';
        final body = (rec['body'] as String?) ?? '';
        final data = Map<String, dynamic>.from(rec['data'] as Map);
        _service.showQuizNotification(title: title, body: body, data: data);
      },
    )
        .subscribe();
  }

  void stop() {
    if (_ch != null) {
      _supabase.removeChannel(_ch!);
      _ch = null;
    }
  }
}
