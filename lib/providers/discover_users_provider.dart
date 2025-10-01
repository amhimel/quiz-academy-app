// lib/screens/friends/discover_users_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discover_user_view.dart';
import 'friends_providers.dart';

final _sb = Supabase.instance.client;
final discoverUsersProvider =
    FutureProvider.autoDispose<List<DiscoverUserView>>((ref) async {
      final me = _sb.auth.currentUser!.id;

      // 1) candidate profiles (tweak limit/order as you wish)
      final rows = await _sb
          .from('profiles')
          .select('id, email, display_name, avatar_url')
          .neq('id', me)
          .limit(50);

      final profiles = (rows as List).cast<Map<String, dynamic>>();

      // 2) existing relations from your repo
      final repo = ref.read(friendsRepoProvider);

      final friendIds = await repo.friendsIds(); // accepted friends
      final outgoing = await repo.outgoing(); // pending I sent
      final incoming = await repo.incoming(); // pending others sent me

      final pendingOtherIds = <String>{
        ...outgoing.map((r) => r.toUser),
        ...incoming.map((r) => r.fromUser),
      };

      // 3) build list with action state
      final list = <DiscoverUserView>[];
      for (final p in profiles) {
        final id = p['id'] as String;
        final displayName = (p['display_name'] as String?)?.trim() ?? '';
        final email = (p['email'] as String?)?.trim();
        final avatar = p['avatar_url'] as String?;

        String label = 'Add Friend';
        bool disabled = false;

        if (friendIds.contains(id)) {
          label = 'Friends';
          disabled = true;
        } else if (pendingOtherIds.contains(id)) {
          label = 'Pending...';
          disabled = true;
        }

        list.add(
          DiscoverUserView(
            id: id,
            displayName: displayName.isEmpty ? 'User' : displayName,
            email: email?.isEmpty == true ? null : email,
            avatarUrl: avatar,
            actionLabel: label,
            actionDisabled: disabled,
          ),
        );
      }

      // Optional: show actionable profiles first
      list.sort(
        (a, b) =>
            (a.actionDisabled ? 1 : 0).compareTo(b.actionDisabled ? 1 : 0),
      );

      return list;
    });
