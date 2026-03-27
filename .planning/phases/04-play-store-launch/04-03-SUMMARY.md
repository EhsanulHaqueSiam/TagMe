---
phase: 04-play-store-launch
plan: 03
subsystem: infra
tags: [android, gradle, signing, firebase, icons, splash, play-store]

# Dependency graph
requires:
  - phase: 04-01
    provides: Settings screen with legal/about sections
  - phase: 04-02
    provides: Privacy policy and terms bundled as assets
provides:
  - Release signing config with key.properties fallback
  - Firebase initialization enabled with try-catch
  - Stub firebase_options.dart for pre-configure compilation
  - flutter_launcher_icons config for branded app icon
  - flutter_native_splash config for branded splash screen
  - key.properties.example with keystore generation instructions
affects: []

# Tech tracking
tech-stack:
  added: [flutter_launcher_icons ^0.14.4, flutter_native_splash ^2.4.7]
  patterns: [conditional signing config, firebase init try-catch]

key-files:
  created:
    - android/key.properties.example
    - lib/firebase_options.dart
    - flutter_launcher_icons.yaml
    - flutter_native_splash.yaml
    - assets/icon/README.md
  modified:
    - android/app/build.gradle.kts
    - lib/main.dart
    - pubspec.yaml

key-decisions:
  - "Conditional signing: release config when key.properties exists, debug fallback when not"
  - "Firebase init wrapped in try-catch so app runs without firebase_options.dart configured"
  - "Stub firebase_options.dart throws UnsupportedError with instructions to run flutterfire configure"

patterns-established:
  - "Release signing: key.properties loaded at top of build.gradle.kts, signingConfigs before buildTypes"
  - "Firebase graceful degradation: try-catch around initializeApp for dev environments"

requirements-completed: [STORE-03, STORE-01]

# Metrics
duration: 2min
completed: 2026-03-27
---

# Phase 04 Plan 03: Release Build Configuration Summary

**Release signing with key.properties fallback, Firebase init enabled, and flutter_launcher_icons/flutter_native_splash configs for Play Store branding**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-27T19:21:13Z
- **Completed:** 2026-03-27T19:23:08Z
- **Tasks:** 1 (+ 1 checkpoint auto-approved)
- **Files modified:** 8

## Accomplishments
- Release signing config in build.gradle.kts reads from key.properties with debug fallback for development
- Firebase.initializeApp uncommented and wrapped in try-catch for graceful degradation
- Stub firebase_options.dart ensures code compiles before flutterfire configure runs
- flutter_launcher_icons.yaml and flutter_native_splash.yaml ready for icon/splash generation
- key.properties.example committed with keystore generation instructions
- Dev dependencies added: flutter_launcher_icons ^0.14.4, flutter_native_splash ^2.4.7

## Task Commits

Each task was committed atomically:

1. **Task 1: Configure release signing, Firebase init, and icon/splash generation** - `8f0aaea` (feat)
2. **Task 2: Verify release readiness (checkpoint)** - Auto-approved (auto_advance=true)

## Files Created/Modified
- `android/app/build.gradle.kts` - Release signing config with conditional key.properties loading
- `android/key.properties.example` - Template with keytool instructions for developers
- `lib/main.dart` - Firebase.initializeApp uncommented with try-catch, imports added
- `lib/firebase_options.dart` - Stub class for pre-flutterfire-configure compilation
- `pubspec.yaml` - Added flutter_launcher_icons and flutter_native_splash dev deps
- `flutter_launcher_icons.yaml` - Adaptive icon config with #1B73E8 background
- `flutter_native_splash.yaml` - Splash screen config with #FAFAFA background
- `assets/icon/README.md` - Instructions for required PNG icon assets

## Decisions Made
- Conditional signing: uses release signing when key.properties exists, falls back to debug when not (allows both dev and release builds)
- Firebase init wrapped in try-catch so the app continues to run even without Firebase configured
- Stub firebase_options.dart throws UnsupportedError with clear instructions to run flutterfire configure

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

1. **lib/firebase_options.dart** (intentional stub) - Throws UnsupportedError until `flutterfire configure` generates the real file. This is by design per the plan -- the stub ensures compilation succeeds before Firebase project setup.

## User Setup Required

**External services require manual configuration before release AAB build:**

1. **Firebase:** Run `flutterfire configure` to generate real firebase_options.dart
2. **Stadia Maps:** Register at https://client.stadiamaps.com/signup for production tile provider
3. **Upload keystore:** Generate with keytool per instructions in key.properties.example, create key.properties
4. **Icon assets:** Place icon_foreground.png (1024x1024) and splash_logo.png (1152x1152) in assets/icon/
5. **Play Console:** Create developer account, complete data safety form, content rating, store listing

## Next Phase Readiness
- All automated build configuration is complete
- Manual setup steps documented (Firebase, keystore, icon assets, Play Console)
- After manual setup: `flutter build appbundle --release` will produce the AAB for upload

## Self-Check: PASSED

All 8 files verified present. Commit 8f0aaea verified in git log.

---
*Phase: 04-play-store-launch*
*Completed: 2026-03-27*
