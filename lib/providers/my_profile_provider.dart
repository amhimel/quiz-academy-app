import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream current user's profile (live updates)
final myProfileProvider = StreamProvider<ProfileModel?>((ref) async* {
  final sb = ref.watch(supabaseProvider);
  final uid = sb.auth.currentUser?.id;
  if (uid == null) {
    yield null;
    return;
  }

  // Ensure: table primary key is `id`, Realtime enabled on table
  final stream = sb
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', uid)
      .limit(1);

  await for (final rows in stream) {
    if (rows.isEmpty) {
      yield null;
      continue;
    }
    yield ProfileModel.fromMap(rows.first as Map<String, dynamic>);
  }
});
