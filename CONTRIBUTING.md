# Contributing to TagMe

## Prerequisites

- Flutter 3.x (stable channel)
- Android device or emulator
- Git

## Step 1: Clone and Build

```bash
git clone https://github.com/EhsanulHaqueSiam/tagme.git
cd tagme
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
```

The app compiles immediately with a stub Firebase config. Map, UI, and navigation all work. Firestore features (profiles, rides, chat) won't work until you complete Step 2.

## Step 2: Set Up Firebase

1. Ask a maintainer to add your Google account to the Firebase project (`tagme-bd-2026`)

2. Install the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

3. Add the pub-cache bin to your PATH permanently:

```bash
# For zsh (add to ~/.zshrc):
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# For bash (add to ~/.bashrc):
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

4. Generate your Firebase config:

```bash
flutterfire configure
```

5. Tell git to ignore your local config (it contains API keys):

```bash
git update-index --skip-worktree lib/firebase_options.dart
```

6. Rebuild and install:

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Build Rules

- **Never build release locally** — it will crash your machine. Use `flutter build apk --debug` only.
- **Release builds** happen on GitHub Actions — push a `v*` tag or use workflow_dispatch.
- **Stop Gradle after building** to free RAM:

```bash
./android/gradlew --stop
```

## Code Generation

After modifying any `@freezed` model or `@riverpod` provider, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
  app/                 # App widget, router, theme
  core/                # Constants, utils, shared config
  features/
    chat/              # In-app messaging
    location_sharing/  # Live location, place search, POI, isochrones
    map/               # Map screen with nearby students
    notifications/     # FCM + local notifications
    profile/           # Student profile setup/edit
    rides/             # Ride posting, searching, matching, fares
    settings/          # App settings
```

## Sensitive Files

These files are **not committed** to the repo. Each developer generates their own:

| File | How to get it |
|------|---------------|
| `lib/firebase_options.dart` | Run `flutterfire configure` |
| `android/app/google-services.json` | Run `flutterfire configure` |
| `android/key.properties` | Copy from `android/key.properties.example` (release signing only) |

A stub `firebase_options.dart` is checked in so the project compiles without Firebase. After generating the real one, run `git update-index --skip-worktree lib/firebase_options.dart` so your keys don't accidentally get committed.
