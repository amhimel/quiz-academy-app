import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/widgets/app_button.dart';
import 'package:quiz_academy/widgets/friends_card.dart';
import '../core/enums/all_enum.dart';
import '../providers/discover_users_provider.dart';
import '../providers/friends_providers.dart';

class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({super.key});

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen> {
  FriendTab _tab = FriendTab.find;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          FriendsCard(
            onFindFriends: () => setState(() => _tab = FriendTab.find),
            onFriendRequests: () => setState(() => _tab = FriendTab.requests),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_tab) {
      case FriendTab.find:
        return _FindFriendsList(
          onAdd: (userId) async {
            await ref.read(friendsRepoProvider).sendRequest(userId);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Friend request sent')),
            );
            // Refresh discover and requests so the button switches to "Pending…"
            ref.invalidate(discoverUsersProvider);
            ref.invalidate(incomingFriendRequestsProvider);
            ref.invalidate(outgoingFriendRequestsProvider);
          },
        );

      case FriendTab.requests:
        return _IncomingRequestsList(
          onAccept: (reqId) async {
            await ref.read(friendsRepoProvider).accept(reqId);
            ref.invalidate(incomingFriendRequestsProvider);
            ref.invalidate(discoverUsersProvider);
          },
          onDecline: (reqId) async {
            await ref.read(friendsRepoProvider).decline(reqId);
            ref.invalidate(incomingFriendRequestsProvider);
            ref.invalidate(discoverUsersProvider);
          },
        );
    }
  }
}

class _FindFriendsList extends ConsumerWidget {
  final Future<void> Function(String userId) onAdd;

  const _FindFriendsList({required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(discoverUsersProvider);

    return users.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: Text("No users to show right now"),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final u = list[i];
            return Card(
              color: const Color(0xFFFAF4E9),
              borderOnForeground: true,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: u.avatarUrl != null
                      ? NetworkImage(u.avatarUrl!)
                      : null,
                  child: u.avatarUrl == null
                      ? Text(u.displayName.isNotEmpty ? u.displayName[0] : '?')
                      : null,
                ),
                title: Text(
                  u.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: u.email != null
                    ? Text(
                        u.email!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 10),
                      )
                    : null,
                trailing: AppButton(
                  width: 70,
                  height: 30,
                  onPressed: u.actionDisabled ? null : () => onAdd(u.id),
                  label: 'Add',
                  icon: Icons.add,
                  iconSize: 10,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load users: $e')),
    );
  }
}

class _IncomingRequestsList extends ConsumerWidget {
  final Future<void> Function(int id) onAccept;
  final Future<void> Function(int id) onDecline;

  const _IncomingRequestsList({
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incoming = ref.watch(incomingFriendRequestsProvider);

    return incoming.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text("No incoming friend requests"));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = list[i];
            return Card(
              child: ListTile(
                title: Text("Request from ${r.fromUser.substring(0, 8)}…"),
                subtitle: Text("Requested at: ${r.requestedAt}"),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => onDecline(r.id),
                      child: const Text("Decline"),
                    ),
                    ElevatedButton(
                      onPressed: () => onAccept(r.id),
                      child: const Text("Accept"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load requests: $e')),
    );
  }
}
