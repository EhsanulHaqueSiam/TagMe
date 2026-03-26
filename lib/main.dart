import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagme/app/app.dart';
import 'package:tagme/core/utils/seed_data.dart';

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

  runApp(const ProviderScope(child: TagMeApp()));
}
