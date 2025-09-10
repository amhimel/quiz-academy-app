// lib/features/auth/controllers/profile_completion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import 'auth_controller.dart';

final needsProfileCompletionProvider = Provider<bool>((ref) {
  final auth = ref.watch(authStateProvider); // AsyncValue<ProfileModel?>
  return auth.maybeWhen(
    data: (p) {
      if (p == null) return false; // signed out
      final missingName = (p.displayName == null || p.displayName!.trim().isEmpty);
      final missingAvatar = (p.profileImage == null || p.profileImage!.isEmpty);
      return missingName || missingAvatar;
    },
    orElse: () => false,
  );
});
