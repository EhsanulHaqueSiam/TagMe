import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/app/app.dart';
import 'package:tagme/core/utils/seed_data.dart';
import 'package:tagme/features/notifications/data/services/fcm_service.dart';
import 'package:tagme/features/notifications/data/services/local_notification_service.dart';
import 'package:tagme/features/rides/providers/schedule_providers.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase. Run `flutterfire configure` to generate
  // firebase_options.dart if it does not exist yet.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Exception catch (e) {
    debugPrint('Firebase init failed: $e — app will run with limited functionality');
  }

  // Initialize local notification service (no Firebase dependency).
  final localNotificationService = LocalNotificationService();
  await localNotificationService.init();

  // Initialize FCM token management (requires Firebase).
  // Wrapped in try-catch so the app still runs without Firebase configured.
  try {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString('local_profile_id');
    if (profileId != null) {
      final fcmService = FcmService(
        localNotificationService: localNotificationService,
      );
      await fcmService.init(profileId);
    }
  } on Exception catch (e) {
    debugPrint('FCM init skipped: $e');
  }

  // Seed mock student data in debug mode (temporary for development).
  // Only runs when Firebase is configured; wrapped in try-catch so the app
  // still launches without Firebase.
  if (kDebugMode) {
    try {
      final needsSeed = await shouldSeed();
      if (needsSeed) {
        await seedMockStudents();
      }
    } on Exception catch (e) {
      debugPrint('Skipping seed: $e');
    }
  }

  // Process recurring ride schedules on app open.
  try {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString('local_profile_id');
    if (profileId != null) {
      await processRecurringSchedules(profileId);
    }
  } on Exception catch (_) {
    // Non-fatal: app continues even if auto-post fails.
  }

  runApp(const ProviderScope(child: TagMeApp()));
}
