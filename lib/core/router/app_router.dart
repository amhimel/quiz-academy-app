import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_academy/screens/custom_bottom_nav.dart';
import 'package:quiz_academy/screens/login_screen.dart';
import 'package:quiz_academy/screens/complete_profile_screen.dart';
import 'package:quiz_academy/screens/create_quiz/create_quiz_meta_screen.dart';
import 'package:quiz_academy/screens/friend_list_Screen.dart';
import 'package:quiz_academy/screens/home_screen.dart';
import 'package:quiz_academy/screens/leader_board_screen.dart';
import 'package:quiz_academy/screens/quiz_list_screen.dart';
import 'package:quiz_academy/screens/register_screen.dart';
import 'package:quiz_academy/screens/take_quiz_screen.dart';

import '../../models/quiz_draft.dart';
import '../../providers/auth_controller.dart';
import '../../providers/profile_completion_provider.dart';
import '../../screens/quiz_leaderboard_screen.dart';
import '../../screens/search_quiz_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authValue = ref.watch(authStateProvider); // AsyncValue<ProfileModel?>
  final authStream = ref.watch(authStateProvider.stream);
  final needsCompletion = ref.watch(needsProfileCompletionProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final user = authValue.asData?.value;
      final onLogin = state.matchedLocation == '/login';
      final onRegister = state.matchedLocation == '/register';
      final onComplete = state.matchedLocation == '/complete-profile';

      if (user == null) {
        return (onLogin || onRegister) ? null : '/login';
      }

      if (needsCompletion && !onComplete) return '/complete-profile';
      if (!needsCompletion && onComplete) return '/nav';
      if (onLogin || onRegister) return '/nav';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/complete-profile', builder: (_, __) => const CompleteProfileScreen()),
      GoRoute(path: '/search-quiz', builder: (_, __) => const SearchQuizScreen()),
      GoRoute(
        path: '/nav',
        builder: (_, __) => CustomBottomNav(
          pages: const [
            HomeScreen(),
            YourQuizzesScreen(),
            LeaderBoardScreen(),
            FriendListScreen(),
          ],
        ),
      ),
      GoRoute(
        path: '/create-quiz',
        builder: (_, __) => CreateQuizMetaScreen(initialCode: generateCode()),
      ),
      GoRoute(
        path: '/quiz/:id',
        name: 'quiz',
        builder: (context, state) =>
            TakeQuizScreen(quizId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/take-quiz',
        name: 'take-quiz',
        builder: (_, state) {
          final quizId = state.extra as String?;
          if (quizId == null || quizId.isEmpty) {
            return const Scaffold(body: Center(child: Text('No quiz id')));
          }
          return TakeQuizScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: '/quiz/:id/leaderboard',
        name: 'quiz-leaderboard',
        builder: (_, state) =>
            QuizLeaderboardScreen(quizId: state.pathParameters['id']!),
      ),
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
