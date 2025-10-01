class FriendRequest {
  final int id;
  final String fromUser; // uuid
  final String toUser;   // uuid
  final String status;   // pending/accepted/declined
  final DateTime requestedAt;
  final DateTime? decidedAt;

  FriendRequest({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.requestedAt,
    this.decidedAt,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> m) => FriendRequest(
    id: m['id'] as int,
    fromUser: m['from_user'] as String,
    toUser: m['to_user'] as String,
    status: m['status'] as String,
    requestedAt: DateTime.parse(m['requested_at'] as String),
    decidedAt: m['decided_at'] == null ? null : DateTime.parse(m['decided_at']),
  );
}
