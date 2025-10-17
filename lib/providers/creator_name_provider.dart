import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns profiles.display_name for a given uid (or null if missing)
final creatorNameProvider =
FutureProvider.family.autoDispose<String?, String>((ref, uid) async {
  ref.keepAlive(); // list স্ক্রল করলে বারবার dispose না হোক
  final data = await Supabase.instance.client
      .from('profiles')
      .select('display_name')
      .eq('id', uid)
      .maybeSingle();

  final name = (data?['display_name'] as String?)?.trim();
  return (name == null || name.isEmpty) ? null : name;
});
