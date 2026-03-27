import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagme/app/app.dart';
import 'package:tagme/core/utils/seed_data.dart';
import 'package:tagme/features/rides/providers/schedule_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(plan-02): Uncomment after running `flutterfire configure`
  // which generates firebase_options.dart
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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
