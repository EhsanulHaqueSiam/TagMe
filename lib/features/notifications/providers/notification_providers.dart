import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tagme/features/notifications/data/services/fcm_service.dart';
import 'package:tagme/features/notifications/data/services/local_notification_service.dart';

part 'notification_providers.g.dart';

/// Provides a singleton [LocalNotificationService].
///
/// The service must be initialized by calling `init()` separately (e.g. in
/// `main.dart`) before scheduling or showing notifications.
@Riverpod(keepAlive: true)
LocalNotificationService localNotificationService(Ref ref) {
  return LocalNotificationService();
}

/// Provides a singleton [FcmService] wired to the [LocalNotificationService].
///
/// The service must be initialized by calling `init(studentId)` separately
/// (e.g. in `main.dart`) after Firebase is ready.
@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  return FcmService(
    localNotificationService: ref.watch(localNotificationServiceProvider),
  );
}
