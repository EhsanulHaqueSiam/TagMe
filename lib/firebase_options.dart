// STUB — no real keys. App runs with limited functionality.
// To enable Firebase: run `flutterfire configure`
// Then: git update-index --skip-worktree lib/firebase_options.dart
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase not configured. Run `flutterfire configure` to set up.',
    );
  }
}
