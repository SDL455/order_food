import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Manages FCM token retrieval, permission requests, and local notification display.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Android notification channel for foreground notifications.
  static const _channel = AndroidNotificationChannel(
    'order_food_channel',
    'Order Food Notifications',
    description: 'Notifications for order updates and new orders',
    importance: Importance.high,
  );

  /// Initialise FCM permissions, local notification plugin, and listeners.
  Future<void> init() async {
    // Request permission (iOS / web)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Create Android notification channel
    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);

    // Initialise local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // ── Foreground messages ──
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // ── Background / terminated tap ──
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      // Defer navigation until app is built (cold start from notification tap)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessage(initial);
      });
    }
  }

  /// Get the current FCM token.
  Future<String?> getToken() => _fcm.getToken();

  /// Show a local notification when the app is in the foreground.
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    }
  }

  void _handleMessage(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  /// Navigate based on notification data payload.
  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'order') {
      Get.toNamed('/orders');
    } else if (type == 'chat') {
      final chatId = data['chatId'] as String?;
      if (chatId != null && chatId.isNotEmpty) {
        Get.toNamed('/chat', arguments: {'chatId': chatId});
      } else {
        Get.toNamed('/chat-list');
      }
    }
  }
}
