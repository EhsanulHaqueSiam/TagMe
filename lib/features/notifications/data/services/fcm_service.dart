import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tagme/features/notifications/data/services/local_notification_service.dart';

/// Manages FCM token lifecycle and foreground message display.
///
/// Requires a [LocalNotificationService] to display local notifications when
/// FCM messages arrive while the app is foregrounded (FCM does not show UI
/// automatically in that case).
class FcmService {
  /// Creates an [FcmService] that delegates foreground display to
  /// [localNotificationService].
  FcmService({required this.localNotificationService});

  /// The local notification service used to show foreground FCM messages.
  final LocalNotificationService localNotificationService;

  /// Initializes FCM for [studentId]: requests permission, saves token,
  /// listens for token refresh, and handles foreground messages.
  Future<void> init(String studentId) async {
    // Request notification permission (triggers POST_NOTIFICATIONS dialog on
    // Android 13+).
    await FirebaseMessaging.instance.requestPermission();

    // Get and save the initial FCM token.
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveToken(studentId, token);
    }

    // Listen for token refreshes and persist the new token.
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) => _saveToken(studentId, newToken),
    );

    // Handle foreground messages by showing a local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Persists [token] to `students/{studentId}/tokens/{token}` in Firestore.
  ///
  /// The token string is used as the document ID to deduplicate tokens.
  Future<void> _saveToken(String studentId, String token) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('tokens')
        .doc(token)
        .set({
      'token': token,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Displays a local notification for a foreground FCM message.
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    if (title.isEmpty && body.isEmpty) return;

    localNotificationService.showNow(
      title,
      body,
      payload: message.data['conversationId'] as String?,
    );
    debugPrint('FCM foreground message displayed: $title');
  }
}
