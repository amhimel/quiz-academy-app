import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/widgets/app_button.dart';
import 'package:quiz_academy/widgets/friends_card.dart';
import '../core/enums/all_enum.dart';
import '../providers/discover_users_provider.dart';
import '../providers/friends_providers.dart';
import '../providers/incoming_requests_view_provider.dart';

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
        return _IncomingRequestsList();
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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Text("No users to show right now"),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                      ? Text(
                          u.displayName.isNotEmpty ? u.displayName[0] : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                title: Text(
                  u.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: u.email != null
                    ? Text(
                        u.email!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 10),
                      )
                    : null,
                trailing: u.actionDisabled
                    ? null // 👈 Hide button if disabled
                    : AppButton(
                        width: 70,
                        height: 30,
                        onPressed: () => onAdd(u.id),
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

class _IncomingRequestsList extends ConsumerStatefulWidget {
  const _IncomingRequestsList({super.key});

  @override
  ConsumerState<_IncomingRequestsList> createState() =>
      _IncomingRequestsListState();
}

class _IncomingRequestsListState extends ConsumerState<_IncomingRequestsList> {
  final Set<int> _acceptedIds = {};
  final Set<int> _removingIds = {};

  Future<void> _accept(int requestId) async {
    setState(() => _acceptedIds.add(requestId));
    try {
      await ref.read(friendsRepoProvider).accept(requestId);
      // refresh data everywhere
      ref.invalidate(incomingFriendRequestsProvider);
      ref.invalidate(incomingFriendRequestsViewProvider);
      ref.invalidate(discoverUsersProvider);
    } catch (e) {
      if (mounted) setState(() => _acceptedIds.remove(requestId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept: $e')));
    }
  }

  Future<void> _decline(int requestId) async {
    setState(() => _removingIds.add(requestId));
    await Future.delayed(const Duration(milliseconds: 180)); // quick fade
    try {
      await ref.read(friendsRepoProvider).decline(requestId);
      ref.invalidate(incomingFriendRequestsProvider);
      ref.invalidate(incomingFriendRequestsViewProvider);
      ref.invalidate(discoverUsersProvider);
    } catch (e) {
      if (mounted) setState(() => _removingIds.remove(requestId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to decline: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final incoming = ref.watch(incomingFriendRequestsViewProvider);

    return incoming.when(
      data: (list) {
        final visible = list
            .where((v) => !_removingIds.contains(v.req.id))
            .toList();
        if (visible.isEmpty) {
          return const Center(child: Text("No incoming friend requests"));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: visible.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final v = visible[i];
            final r = v.req;
            final accepted = _acceptedIds.contains(r.id);

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _removingIds.contains(r.id) ? 0.0 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF4E9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: avatar + name + email
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: v.avatarUrl != null
                              ? NetworkImage(v.avatarUrl!)
                              : null,
                          child: v.avatarUrl == null
                              ? Text(
                                  v.displayName.isNotEmpty
                                      ? v.displayName[0]
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              if (v.email.isNotEmpty)
                                Text(
                                  v.email,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bottom: Accept / Decline
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: accepted ? 'Accepted ✓' : 'Accept',
                            icon: accepted
                                ? Icons.check_circle_rounded
                                : Icons.check_rounded,
                            height: 40,
                            onPressed: accepted ? null : () => _accept(r.id),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            label: 'Decline',
                            icon: Icons.close_rounded,
                            height: 40,
                            onPressed: () => _decline(r.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
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
