# TagMe

A mobile app for students in Bangladesh to find ride-sharing partners. See nearby peers on a map, post or search rides, match with compatible riders, chat, and split fares.

## Features

- **Interactive Map** — See nearby students with their name, photo, university, route, and transport type
- **Post & Search Rides** — Create rides or find existing ones by route, time, and transport preference
- **Transport Types** — Rickshaw, bike, bus, car, CNG + optional Pathao/Uber/Obhai tags
- **Smart Matching** — Proximity-based matching by origin, destination, and time overlap
- **Recurring Schedules** — Set weekly class commute patterns (MWF, TTh) and auto-post rides
- **In-App Chat** — Coordinate with matched riders, optionally share phone numbers
- **Fare Splitting** — Estimated cost per transport type, cost-per-person split, and running tab tracker
- **Gender Preference** — Safety-first matching preference for co-riders

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging)
- **Maps:** flutter_map + OpenStreetMap (free, no paid APIs)
- **State Management:** Riverpod
- **Routing:** OpenRouteService API

## Getting Started

### Prerequisites

- Flutter 3.x (stable channel)
- Android device or emulator (Android first, iOS not yet supported)
- A Firebase account (optional — app runs without it, but rides/chat/profiles won't persist)

### 1. Clone and Run (no Firebase)

```bash
git clone https://github.com/EhsanulHaqueSiam/tagme.git
cd tagme
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

The app compiles and runs immediately with a stub Firebase config. The map, UI, and navigation all work. Firestore-dependent features (profiles, rides, chat) will show errors until Firebase is configured.

### 2. Set Up Firebase (for full functionality)

1. Ask a project maintainer to add your Google account to the Firebase project (`tagme-bd-2026`)
2. Install the FlutterFire CLI and configure:

```bash
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"  # add to ~/.bashrc or ~/.zshrc permanently
flutterfire configure
```

3. Tell git to ignore your local Firebase config (it contains API keys):

```bash
git update-index --skip-worktree lib/firebase_options.dart
```

That's it — rebuild and the app connects to Firebase.

### Build Rules

- **Never build release locally** — use `flutter build apk --debug` only
- **Release builds** run on GitHub Actions (push a `v*` tag or use workflow_dispatch)
- **After building**, stop the Gradle daemon to free RAM: `./android/gradlew --stop`

## Project Structure

```
lib/
  app/             # App widget, router, theme
  core/            # Constants, utils, shared config
  features/
    chat/          # In-app messaging
    location_sharing/  # Live location, place search, POI, isochrones
    map/           # Map screen with nearby students
    notifications/ # FCM + local notifications
    profile/       # Student profile setup/edit
    rides/         # Ride posting, searching, matching, fares
    settings/      # App settings
```

## License

MIT
