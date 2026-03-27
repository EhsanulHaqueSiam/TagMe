import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Manages local notifications: initialization, scheduled departure reminders,
/// and immediate foreground notification display for FCM messages.
class LocalNotificationService {
  /// Creates a [LocalNotificationService] backed by a
  /// [FlutterLocalNotificationsPlugin].
  LocalNotificationService()
      : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Initializes timezone data, the notification plugin, and Android channels.
  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels explicitly so they exist before first use.
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chat_messages',
          'Chat Messages',
          description: 'Notifications for new chat messages',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'departure_reminders',
          'Departure Reminders',
          description: 'Reminders for upcoming ride departures',
          importance: Importance.high,
        ),
      );
    }
  }

  /// Schedules a local notification 15 minutes before [departureTime].
  ///
  /// Uses [AndroidScheduleMode.inexactAllowWhileIdle] to avoid requiring the
  /// restricted `SCHEDULE_EXACT_ALARM` permission on Android 14+.
  Future<void> scheduleDepartureReminder({
    required int id,
    required String rideOrigin,
    required String rideDestination,
    required DateTime departureTime,
  }) async {
    final reminderTime =
        departureTime.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: 'Ride departing soon',
      body: '$rideOrigin -> $rideDestination in 15 minutes',
      scheduledDate: tzTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'departure_reminders',
          'Departure Reminders',
          channelDescription: 'Reminders for upcoming ride departures',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Shows an immediate local notification (used for foreground FCM messages).
  Future<void> showNow(
    String title,
    String body, {
    String? payload,
  }) async {
    final id = payload?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_messages',
          'Chat Messages',
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancels a previously scheduled reminder by [id].
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Handles a tap on a notification.
  ///
  /// Navigation routing will be wired when GoRouter context is available.
  void _onNotificationTap(NotificationResponse response) {
    debugPrint(
      'Notification tapped: ${response.payload}',
    );
  }
}
