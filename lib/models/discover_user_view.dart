class DiscoverUserView {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;

  final String actionLabel;   // "Add Friend" | "Pending…" | "Friends ✓"
  final bool actionDisabled;  // disables button when pending/friends

  DiscoverUserView({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    required this.actionLabel,
    required this.actionDisabled,
  });
}