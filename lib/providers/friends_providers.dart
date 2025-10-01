import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/friends_repository.dart';
import '../models/friend_request.dart';

final friendsRepoProvider = Provider((_) => FriendsRepository());

final incomingFriendRequestsProvider = FutureProvider.autoDispose<List<FriendRequest>>((ref) async {
  return ref.read(friendsRepoProvider).incoming();
});

final outgoingFriendRequestsProvider = FutureProvider.autoDispose<List<FriendRequest>>((ref) async {
  return ref.read(friendsRepoProvider).outgoing();
});

final friendQuizzesProvider = FutureProvider.autoDispose<List<Map<String,dynamic>>>((ref) async {
  return ref.read(friendsRepoProvider).friendQuizzes();
});
