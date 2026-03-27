---
phase: 04-play-store-launch
plan: 01
subsystem: ui
tags: [settings, tile-provider, stadia-maps, flutter-map, android-manifest]

# Dependency graph
requires:
  - phase: 03-chat-notifications
    provides: completed app with map, rides, and chat features
provides:
  - Settings screen with profile edit, legal links, and app info
  - Centralized TileConfig for Stadia Maps production tile provider
  - /settings and /legal/:type routes registered in GoRouter
  - Android app label corrected to "TagMe"
  - Asset directories (assets/legal/, assets/icon/) declared in pubspec
affects: [04-02-play-store-launch, 04-03-play-store-launch]

# Tech tracking
tech-stack:
  added: [stadia-maps-tiles]
  patterns: [centralized-tile-config]

key-files:
  created:
    - lib/features/settings/presentation/screens/settings_screen.dart
    - lib/core/constants/tile_config.dart
    - assets/legal/.gitkeep
    - assets/icon/.gitkeep
  modified:
    - lib/app/router.dart
    - lib/features/map/presentation/widgets/map_top_bar.dart
    - lib/features/map/presentation/screens/map_screen.dart
    - lib/features/rides/presentation/screens/ride_detail_screen.dart
    - lib/features/rides/presentation/screens/map_pin_picker_screen.dart
    - android/app/src/main/AndroidManifest.xml
    - pubspec.yaml

key-decisions:
  - "Stadia Maps OSM Bright tiles replace raw OSM tiles (free 200K/month, no API key needed for mobile)"
  - "TileConfig centralized in single file to avoid URL duplication across 3 map screens"
  - "Legal route uses placeholder Scaffold (Plan 02 replaces with real LegalDocumentScreen)"

patterns-established:
  - "TileConfig pattern: all map screens import TileConfig for URL, userAgent, and maxZoom"

requirements-completed: [STORE-01]

# Metrics
duration: 2min
completed: 2026-03-27
---

# Phase 04 Plan 01: Settings & Tile Provider Summary

**Settings screen with profile/legal links, Stadia Maps tile provider replacing raw OSM across all 3 map screens, and corrected Android app label**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-27T19:13:59Z
- **Completed:** 2026-03-27T19:16:58Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- Created Settings screen accessible from map top bar gear icon with profile edit, privacy policy, terms of service, and app version sections
- Centralized map tile configuration in TileConfig class using Stadia Maps OSM Bright tiles (production-ready, free tier)
- Replaced all raw OSM tile URLs and incorrect userAgent across map_screen, ride_detail_screen, and map_pin_picker_screen
- Fixed Android app label from "tagme" to "TagMe" for Play Store presentation

## Task Commits

Each task was committed atomically:

1. **Task 1: Create settings screen, tile config, and register routes** - `ae17fb1` (feat)
2. **Task 2: Wire settings icon, switch tiles to Stadia Maps, fix app label** - `0b536da` (feat)

## Files Created/Modified
- `lib/features/settings/presentation/screens/settings_screen.dart` - Settings screen with profile edit link, legal links, version info, and tile attribution
- `lib/core/constants/tile_config.dart` - Centralized Stadia Maps tile configuration (URL template, userAgent, maxZoom)
- `lib/app/router.dart` - Added /settings route, /legal/:type placeholder route, SettingsScreen import
- `lib/features/map/presentation/widgets/map_top_bar.dart` - Replaced empty SizedBox with settings gear icon button
- `lib/features/map/presentation/screens/map_screen.dart` - Switched TileLayer to TileConfig
- `lib/features/rides/presentation/screens/ride_detail_screen.dart` - Switched TileLayer to TileConfig
- `lib/features/rides/presentation/screens/map_pin_picker_screen.dart` - Switched TileLayer to TileConfig
- `android/app/src/main/AndroidManifest.xml` - Changed android:label from "tagme" to "TagMe"
- `pubspec.yaml` - Added assets/legal/ and assets/icon/ asset directories
- `assets/legal/.gitkeep` - Placeholder for legal documents (Plan 02 creates real files)
- `assets/icon/.gitkeep` - Placeholder for app icon assets

## Decisions Made
- Used Stadia Maps OSM Bright tiles (free 200K/month, no credit card, no API key needed for mobile apps) as production replacement for raw OSM tiles
- Centralized tile config in a single `TileConfig` class to avoid URL duplication and simplify future provider changes
- Legal route (`/legal/:type`) uses a placeholder Scaffold -- Plan 02 will replace with the real LegalDocumentScreen

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

| File | Line | Stub | Resolution |
|------|------|------|------------|
| lib/app/router.dart | 85 | `Text('Legal document placeholder')` | Plan 04-02 replaces with real LegalDocumentScreen |

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Settings screen ready for Plan 02 to wire legal document screens (privacy policy, terms of service)
- Stadia Maps tiles active across all map views
- Asset directories ready for Plan 02 legal markdown files and Plan 03 app icon

## Self-Check: PASSED

All created files exist. All commit hashes verified.

---
*Phase: 04-play-store-launch*
*Completed: 2026-03-27*
