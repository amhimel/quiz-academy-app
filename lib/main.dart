import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_academy/app.dart';
import 'package:quiz_academy/core/constants/api_constant.dart';
import 'package:quiz_academy/core/router/app_router.dart' show routerProvider;
import 'package:quiz_academy/notification_services/notification_service.dart';
import 'package:quiz_academy/notification_services/notification_listener.dart' as qa_notif;

NotificationService? _notifService;
qa_notif.NotificationListener? _notifListener;

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: "assets/.env");
  await Supabase.initialize(url: ApiConstant.baseUrl, anonKey: ApiConstant.anonKey);

  // Use a single ProviderContainer for both router + the app
  final container = ProviderContainer();

  // Get GoRouter instance directly from Riverpod
  final router = container.read(routerProvider);

  // Run the app with the same container
  runApp(UncontrolledProviderScope(
    container: container,
    child: const App(),
  ));

  // Init local notifications with a navigation callback (no context required)
  _notifService = NotificationService(FlutterLocalNotificationsPlugin());
  await _notifService!.init(
    onOpenQuiz: (quizId) => router.go('/quiz/$quizId'),
  );

  // Start realtime if already signed in
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    _notifListener = qa_notif.NotificationListener(
      Supabase.instance.client,
      _notifService!,
    )..start(currentUser.id);
  }

  // Attach/detach on auth changes
  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    _notifListener?.stop();
    _notifListener = null;

    final user = event.session?.user;
    if (user != null) {
      _notifListener = qa_notif.NotificationListener(
        Supabase.instance.client,
        _notifService!,
      )..start(user.id);
    }
  });
}
