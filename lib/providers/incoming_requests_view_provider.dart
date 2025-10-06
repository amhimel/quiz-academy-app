// lib/providers/incoming_requests_view_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'friends_providers.dart';            // friendsRepoProvider
import '../models/friend_request.dart';

final _sb = Supabase.instance.client;

class IncomingRequestView {
  final FriendRequest req;
  final String displayName;
  final String email;
  final String? avatarUrl;

  IncomingRequestView({
    required this.req,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
  });
}

final incomingFriendRequestsViewProvider =
FutureProvider.autoDispose<List<IncomingRequestView>>((ref) async {
  final repo = ref.read(friendsRepoProvider);

  // 1) pending incoming
  final requests = await repo.incoming(); // List<FriendRequest>

  if (requests.isEmpty) return [];

  // 2) bulk-load sender profiles
  final ids = requests.map((r) => r.fromUser).toSet().toList();

  final rows = await _sb
      .from('profiles')
      .select('id, display_name, avatar_url , email')
      .inFilter('id', ids);

  final profiles = <String, Map<String, dynamic>>{
    for (final m in (rows as List)) m['id'] as String: m
  };

  // 3) build views
  return requests.map((r) {
    final p = profiles[r.fromUser];
    final name = (p?['display_name'] as String?)?.trim();
    final email = (p?['email'] as String?)?.trim();
    final avatar = p?['avatar_url'] as String?;
    return IncomingRequestView(
      req: r,
      displayName: (name == null || name.isEmpty) ? 'User' : name,
      email: (email == null || email.isEmpty) ? 'Email' : email,
      avatarUrl: avatar,
    );
  }).toList();
});
