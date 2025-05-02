import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:road_helperr/models/help_request.dart';
import 'package:road_helperr/ui/widgets/help_request_dialog.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Parse the payload to get the request ID
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('Notification tapped with payload: $payload');
      // The payload will be handled by the app when it's in the foreground
    }
  }

  // Show a help request notification
  Future<void> showHelpRequestNotification(HelpRequest request) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Create the notification details for Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'help_requests_channel',
      'Help Requests',
      channelDescription: 'Notifications for help requests',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    // Create the notification details for iOS
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Create the notification details for all platforms
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      request.requestId.hashCode, // Use the request ID hash as the notification ID
      'Help Request',
      'New help request from ${request.senderName}',
      notificationDetails,
      payload: request.requestId, // Pass the request ID as the payload
    );
  }

  // Show a help request response notification
  Future<void> showHelpRequestResponseNotification(
      String requestId, String responderName, bool accepted) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Create the notification details for Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'help_responses_channel',
      'Help Responses',
      channelDescription: 'Notifications for help request responses',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    // Create the notification details for iOS
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Create the notification details for all platforms
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      requestId.hashCode, // Use the request ID hash as the notification ID
      'Help Request Response',
      accepted
          ? '$responderName has accepted your help request'
          : '$responderName has declined your help request',
      notificationDetails,
      payload: requestId, // Pass the request ID as the payload
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
