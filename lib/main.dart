import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagme/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(plan-02): Uncomment after running `flutterfire configure`
  // which generates firebase_options.dart
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const ProviderScope(child: TagMeApp()));
}
