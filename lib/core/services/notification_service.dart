import 'dart:io';
import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../constant/api_urls.dart';

/// Handles Firebase Messaging setup and device registration to backend.
class NotificationService {
  NotificationService({
    required Dio dio,
    required SharedPreferences prefs,
    required Logger logger,
  }) : _dio = dio,
       _prefs = prefs,
       _logger = logger;

  final Dio _dio;
  final SharedPreferences _prefs;
  final Logger _logger;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<Map<String, dynamic>> _chatMessageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get chatMessageStream =>
      _chatMessageController.stream;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important notifications.',
        importance: Importance.max,
        playSound: true,
      );

  /// Ensure Firebase is initialized and background handler is registered.
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Configure local notifications (needed to show notifications in foreground).
  Future<void> initLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  /// On iOS/macOS: allow showing notifications while app is in foreground.
  Future<void> configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Ask user for notification permission (iOS/Android 13+).
  Future<void> requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  /// Register current device token to backend.
  Future<void> registerDevice() async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      _logger.w('FCM token null/empty, skip register');
      return;
    }

    final model = await _readDeviceModel();
    final platform = Platform.isAndroid ? 'ANDROID' : 'IOS';

    final accessToken = _prefs.getString(ApiConstants.tokenKey);
    if (accessToken == null || accessToken.isEmpty) {
      _logger.w('Access token missing, skip register device');
      return;
    }

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/notifications/device',
        data: {'fcmToken': token, 'platform': platform, 'deviceModel': model},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      _logger.i(
        'Register device success: token=$token platform=$platform model=$model status=${response.statusCode}',
      );
    } catch (e, st) {
      _logger.e(
        'Register device failed: token=$token platform=$platform model=$model\n$e\n$st',
      );
    }
  }

  /// Re-register when token refreshes.
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((_) async {
      _logger.i('FCM token refreshed, re-registering device');
      await registerDevice();
    });
  }

  /// Log foreground messages to verify delivery; hook a local notification here if needed.
  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      final title = message.notification?.title;
      final body = message.notification?.body;
      _logger.i(
        'Foreground message received: title="$title" body="$body" data=${message.data}',
      );

      // Pipe chat messages to listeners so UI can update without manual refresh
      final type = message.data['type']?.toString().toUpperCase();
      if (type == 'CHAT_MESSAGE') {
        final enriched = Map<String, dynamic>.from(message.data);
        // Ensure content/body is present for UI rendering
        if ((enriched['content'] ?? '').toString().isEmpty) {
          enriched['content'] = body ?? enriched['body'] ?? '';
        }
        // Provide createdAt if missing
        enriched['createdAt'] ??= (message.sentTime ?? DateTime.now())
            .toIso8601String();
        // Provide id fallback
        enriched['id'] ??=
            message.messageId ??
            DateTime.now().microsecondsSinceEpoch.toString();
        _chatMessageController.add(enriched);
      }

      // Fallback to data payload if notification block is missing (data-only messages).
      final resolvedTitle = title ?? message.data['title'] as String?;
      final resolvedBody = body ?? message.data['body'] as String?;

      await _showLocalNotification(resolvedTitle, resolvedBody, message.data);
    });
  }

  Future<void> _showLocalNotification(
    String? title,
    String? body,
    Map<String, dynamic> data,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title ?? 'Notification',
      body ?? '',
      notificationDetails,
      payload: data.isNotEmpty ? data.toString() : null,
    );
  }

  Future<String> _readDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return info.model;
      }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.utsname.machine;
      }
    } catch (_) {
      // ignore and fallback
    }
    return 'Unknown Device';
  }
}

/// Top-level background handler required by Firebase Messaging.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Add logging or silent handling if needed.
}
