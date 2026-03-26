---
phase: 01-map-profiles
plan: 03
subsystem: map
tags: [flutter_map, geolocator, permission_handler, geoflutterfire_plus, osm, riverpod, location]

# Dependency graph
requires:
  - phase: 01-map-profiles/01
    provides: Flutter project scaffold, app shell, router, theme, color constants
provides:
  - Location permission explain-then-ask screen with CTA and permanently denied handling
  - LocationRepository wrapping Geolocator for GPS and Firestore geo writes
  - Riverpod location providers (currentLocation stream, locationPermission, hasLocationPermission, searchRadius)
  - Full-screen map with OSM tiles centered on GPS at zoom 13
  - Blue pulsing dot at user location
  - MapTopBar with avatar and TagMe title
  - MyLocationFab to recenter map at zoom 15
  - Location-denied banner with Enable Location chip
affects: [01-04]

# Tech tracking
tech-stack:
  added: []
  patterns: [permission-explain-then-ask, foreground-only-location, osm-tile-user-agent, map-overlay-stack]

key-files:
  created:
    - lib/features/permission/presentation/screens/location_permission_screen.dart
    - lib/features/map/data/repositories/location_repository.dart
    - lib/features/map/providers/location_provider.dart
    - lib/features/map/presentation/screens/map_screen.dart
    - lib/features/map/presentation/widgets/map_top_bar.dart
    - lib/features/map/presentation/widgets/my_location_fab.dart
  modified:
    - lib/app/router.dart

key-decisions:
  - "Used Geolocator.getCurrentPosition with LocationSettings instead of deprecated desiredAccuracy parameter (geolocator 14.x API)"
  - "Used AsyncValue.value instead of valueOrNull (not available in riverpod 3.2.1)"
  - "profileProvider name instead of profileNotifierProvider (Riverpod 4.x codegen naming convention)"

patterns-established:
  - "Explain-then-ask permission flow: custom screen before system dialog"
  - "Foreground-only GPS: LocationSettings with distanceFilter 50m, no background service"
  - "Map overlay pattern: Stack with FlutterMap base, positioned widgets on top"
  - "OSM tile safety: always set userAgentPackageName to com.tagme.app"

requirements-completed: [MAP-01, MAP-03, MAP-04]

# Metrics
duration: 9min
completed: 2026-03-27
---

# Phase 01 Plan 03: Map & Location Summary

**Full-screen OSM map with GPS centering at zoom 13, location permission explain-then-ask flow, and location providers with 50m foreground-only GPS streaming**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-26T22:36:40Z
- **Completed:** 2026-03-26T22:45:40Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Location permission screen with explain-then-ask pattern, "Enable Location" CTA, "Not Now" skip, and permanently denied "Open Settings" fallback
- LocationRepository with Geolocator GPS stream (50m distance filter, foreground-only) and Firestore GeoFirePoint writes
- Full-screen FlutterMap with OSM tiles (userAgentPackageName: com.tagme.app), centered on user GPS at zoom 13
- MapTopBar overlay with user avatar (tap for profile-edit) and "TagMe" title with drop shadow
- MyLocationFab re-centers map to user location at zoom 15
- Location-denied banner with Enable Location chip when permission not granted

## Task Commits

Each task was committed atomically:

1. **Task 1: Location permission screen and location providers** - `ef109d4` (feat)
2. **Task 2: Map screen with OSM tiles, top bar, and FAB** - `8ecafc1` (feat, included in parallel agent commit)

## Files Created/Modified
- `lib/features/permission/presentation/screens/location_permission_screen.dart` - Explain-then-ask permission screen with CTA, Not Now, and permanently denied handling
- `lib/features/map/data/repositories/location_repository.dart` - Geolocator wrapper with GPS stream and Firestore GeoFirePoint writes
- `lib/features/map/providers/location_provider.dart` - Riverpod providers for currentLocation, locationPermission, hasLocationPermission, searchRadius
- `lib/features/map/presentation/screens/map_screen.dart` - Full-screen FlutterMap with OSM tiles, blue dot, location state handling
- `lib/features/map/presentation/widgets/map_top_bar.dart` - Transparent overlay with avatar and TagMe title
- `lib/features/map/presentation/widgets/my_location_fab.dart` - FAB with crosshair icon for map recentering
- `lib/app/router.dart` - Wired LocationPermissionScreen, MapScreen, permission redirect guard

## Decisions Made
- Used `LocationSettings` parameter instead of deprecated `desiredAccuracy` for `Geolocator.getCurrentPosition` (geolocator 14.x breaking change)
- Used `AsyncValue.value` (nullable getter) instead of `valueOrNull` which is not available in riverpod 3.2.1
- Used `profileProvider` (not `profileNotifierProvider`) per Riverpod 4.x codegen naming convention for notifier classes

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed Geolocator deprecated API usage**
- **Found during:** Task 1 (LocationRepository)
- **Issue:** `desiredAccuracy` parameter is deprecated in geolocator 14.x
- **Fix:** Used `locationSettings: LocationSettings(accuracy: LocationAccuracy.high)` instead
- **Files modified:** lib/features/map/data/repositories/location_repository.dart
- **Verification:** dart analyze reports no warnings
- **Committed in:** ef109d4

**2. [Rule 3 - Blocking] Fixed Riverpod AsyncValue API mismatch**
- **Found during:** Task 1 (location_provider.dart)
- **Issue:** `valueOrNull` does not exist on `AsyncValue` in riverpod 3.2.1
- **Fix:** Changed to `.value` (nullable getter available on AsyncValue)
- **Files modified:** lib/features/map/providers/location_provider.dart
- **Verification:** dart analyze reports no errors
- **Committed in:** ef109d4

**3. [Rule 3 - Blocking] Fixed generated provider name for profile notifier**
- **Found during:** Task 2 (MapTopBar referencing profile provider)
- **Issue:** Riverpod 4.x codegen generates `profileProvider` (not `profileNotifierProvider`) for `ProfileNotifier` class
- **Fix:** Changed `ref.watch(profileNotifierProvider)` to `ref.watch(profileProvider)`
- **Files modified:** lib/features/map/presentation/widgets/map_top_bar.dart
- **Verification:** dart analyze reports no errors
- **Committed in:** 8ecafc1 (via parallel agent commit)

---

**Total deviations:** 3 auto-fixed (1 bug, 2 blocking)
**Impact on plan:** All auto-fixes necessary for API compatibility. No scope creep.

## Issues Encountered
- Task 2 files were committed by the parallel Plan 02 agent (commit 8ecafc1) which ran `git add` broadly. The files are correctly committed but under the Plan 02 docs commit rather than a separate Task 2 commit. Content is correct and verified.

## Known Stubs
None -- all components are fully wired with real data sources (GPS via Geolocator, profile via profileProvider).

## User Setup Required
None -- no external service configuration required. OSM tiles work without API keys.

## Next Phase Readiness
- Map screen ready for student markers and clustering (Plan 04)
- Location providers ready for nearby student geo queries
- Permission flow complete -- all downstream features can assume location state is available via providers
- searchRadiusProvider (5km default) ready for geo query integration

## Self-Check: PASSED

All 6 created files verified present. Both task commits (ef109d4, 8ecafc1) verified in git log.

---
*Phase: 01-map-profiles*
*Completed: 2026-03-27*
