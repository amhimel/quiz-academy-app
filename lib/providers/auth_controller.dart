// features/auth/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../repositories/auth_repository.dart';
import 'dart:io';

/// Provides a single instance of AuthRepository and disposes it when unused.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepository();
  //ref.onDispose(repo.dispose);
  return repo;
});

/// Emits ProfileModel? whenever auth or profile changes.
/// - null = signed out
/// - ProfileModel = signed in (with latest profile fields)
final authStateProvider = StreamProvider<ProfileModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Thin controller façade around the repository.
/// Keep UI code clean and test the auth logic behind this layer.
class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<ProfileModel> register(
      String email,
      String password, {
        String? displayName,
        dynamic avatarFile,
      }) {
    return ref.read(authRepositoryProvider).register(
      email: email,
      password: password,
      displayName: displayName,
      avatarFile: avatarFile,
    );
  }

  Future<ProfileModel> login(String email, String password) {
    return ref.read(authRepositoryProvider).login(
      email: email,
      password: password,
    );
  }

  Future<void> logout() => ref.read(authRepositoryProvider).logout();

  Future<ProfileModel> updateProfile({
    String? displayName,
    dynamic avatarFile,
  }) {
    return ref.read(authRepositoryProvider).updateProfile(
      displayName: displayName,
      avatarFile: avatarFile,
    );
  }

  /// Synchronous snapshot of the current user (may be stale vs stream).
  ProfileModel? get current => ref.read(authRepositoryProvider).currentUserSync;
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});
