import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../routing/route_names.dart';

typedef DeviceTokenCallback = Future<void> Function(
    String token, String platform);
typedef DeviceTokenUnregisterCallback = Future<void> Function(String token);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  String? _currentToken;

  GoRouter? _router;
  // If an FCM tap fires before the router has been wired (cold-start race),
  // stash the data and replay it as soon as setRouter is called.
  Map<String, dynamic>? _pendingTap;

  void setRouter(GoRouter router) {
    _router = router;
    final pending = _pendingTap;
    if (pending != null) {
      _pendingTap = null;
      _routeForData(pending);
    }
  }

  DeviceTokenCallback? _onRegisterToken;
  DeviceTokenUnregisterCallback? _onUnregisterToken;

  void setTokenCallbacks({
    required DeviceTokenCallback onRegister,
    required DeviceTokenUnregisterCallback onUnregister,
  }) {
    _onRegisterToken = onRegister;
    _onUnregisterToken = onUnregister;
  }

  Future<void> registerDeviceToken() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await messaging.getToken();
    if (token == null) return;
    _currentToken = token;
    final platform = Platform.isIOS ? 'ios' : 'android';
    await _onRegisterToken?.call(token, platform);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _currentToken = newToken;
      await _onRegisterToken?.call(newToken, platform);
    });
  }

  Future<void> unregisterDeviceToken() async {
    final token = _currentToken;
    if (token == null) return;
    await _onUnregisterToken?.call(token);
    _currentToken = null;
  }

  Future<void> _handleLocalNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      _routeForData(decoded);
    } catch (e) {
      debugPrint('[Notif] failed to decode local notification payload: $e');
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    FirebaseMessaging.onMessage.listen(_handleFcmForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmTap);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleFcmTap(initial);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      // Foreground FCMs are shown via _showHeadsUpNotification (below) which
      // packs the FCM data into the local notification's `payload`. When the
      // user taps the banner, this callback parses the payload and routes —
      // without it, foreground taps are dead-ends.
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
    _initialized = true;
  }

  void _handleFcmForeground(RemoteMessage message) {
    // Show local notification for foreground FCM messages
    _showHeadsUpNotification(message);
  }

  void _handleFcmTap(RemoteMessage message) {
    _routeForData(Map<String, dynamic>.from(message.data));
  }

  /// Performs the actual routing decision. If the router isn't wired yet
  /// (cold-start race), stash the data so [setRouter] can replay it.
  void _routeForData(Map<String, dynamic> data) {
    if (_router == null) {
      _pendingTap = data;
      return;
    }
    final type = data['type'] as String?;
    if (type == 'queue_called') {
      final appointmentId = data['appointmentId'] as String?;
      if (appointmentId != null) {
        _router!.goNamed(
          RouteNames.queueStatus,
          pathParameters: {'appointmentId': appointmentId},
        );
      }
    } else if (type == 'video_started') {
      final consultationId = data['consultationId'] as String?;
      if (consultationId != null) {
        _router!.goNamed(
          RouteNames.videoCall,
          pathParameters: {'id': consultationId},
        );
      }
    }
  }

  Future<void> _showHeadsUpNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    // Pack FCM data into the local notification's payload so the
    // onDidReceiveNotificationResponse callback can route on tap.
    final payload = jsonEncode(message.data);
    await _plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'realtime_alerts',
          'Real-time Alerts',
          channelDescription: 'Queue and video call alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute - 15 < 0 ? minute + 45 : minute - 15,
    );
    if (minute < 15) {
      scheduled = scheduled.subtract(const Duration(hours: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      'Time for $medicationName',
      '$dosage — in 15 minutes',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          channelDescription: 'Daily medication dose reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) =>
      _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<int>> scheduleAllTimes({
    required int baseId,
    required String medicationName,
    required String dosage,
    required List<String> times,
  }) async {
    final ids = <int>[];
    for (var i = 0; i < times.length; i++) {
      final parts = times[i].split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final id = baseId + i;
      await scheduleReminder(
        id: id,
        medicationName: medicationName,
        dosage: dosage,
        hour: h,
        minute: m,
      );
      ids.add(id);
    }
    return ids;
  }
}
