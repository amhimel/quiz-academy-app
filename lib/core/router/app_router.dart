// core/router/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_controller.dart';
import '../../providers/profile_completion_provider.dart';
import '../../screens/complete_profile_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Current auth value (for redirect logic)
  final authValue = ref.watch(authStateProvider);               // AsyncValue<ProfileModel?>
  // Stream of auth changes (for GoRouter refresh)
  final authStream = ref.watch(authStateProvider.stream);       // Stream<ProfileModel?>
  final needsCompletion = ref.watch(needsProfileCompletionProvider);

  return GoRouter(
    initialLocation: '/login',
    // Rebuild GoRouter when the auth stream emits
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final user = authValue.asData?.value; // ProfileModel? or null

      final onLogin = state.matchedLocation == '/login';
      final onRegister = state.matchedLocation == '/register';
      final onComplete = state.matchedLocation == '/complete-profile';

      if (user == null) {
        return (onLogin || onRegister) ? null : '/login';
      }

      if (needsCompletion && !onComplete) return '/complete-profile';
      if (!needsCompletion && onComplete) return '/home';
      if (onLogin || onRegister) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/complete-profile', builder: (_, __) => const CompleteProfileScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
