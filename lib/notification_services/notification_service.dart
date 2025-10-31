import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef OnOpenQuiz = void Function(String quizId);

class NotificationService {
  NotificationService(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  late OnOpenQuiz _onOpenQuiz;

  Future<void> init({required OnOpenQuiz onOpenQuiz}) async {
    _onOpenQuiz = onOpenQuiz;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        _openFromPayload(resp.payload);
      },
    );

    // handle cold-start from a tapped notification
    final details = await _plugin.getNotificationAppLaunchDetails();
    if ((details?.didNotificationLaunchApp ?? false) &&
        details?.notificationResponse?.payload != null) {
      _openFromPayload(details!.notificationResponse!.payload);
    }
  }

  void _openFromPayload(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final quizId = data['quiz_id'] as String?;
      if (quizId != null) _onOpenQuiz(quizId);
    } catch (_) {
      // ignore malformed payloads
    }
  }

  Future<void> showQuizNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const android = AndroidNotificationDetails(
      'quiz_new_channel',
      'New Quizzes',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOS = DarwinNotificationDetails();

    final nid = (data['quiz_id'] ?? DateTime.now().millisecondsSinceEpoch)
        .hashCode &
    0x7fffffff;

    await _plugin.show(
      nid,
      title,
      body,
      const NotificationDetails(android: android, iOS: iOS),
      payload: jsonEncode(data),
    );
  }
}
