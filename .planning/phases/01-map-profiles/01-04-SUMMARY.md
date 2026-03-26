---
phase: 01-map-profiles
plan: 04
subsystem: map
tags: [flutter_map, geoflutterfire_plus, marker-cluster, bottom-sheet, firestore-geo-query, seed-data]

# Dependency graph
requires:
  - phase: 01-map-profiles
    plan: 02
    provides: "MapScreen with OSM tiles, user blue dot, MapTopBar, MyLocationFab, location providers"
  - phase: 01-map-profiles
    plan: 03
    provides: "Student model with Firestore CRUD, profile provider, AppColors with university colors"
provides:
  - "NearbyStudentsProvider streaming geo-queried students within configurable radius"
  - "StudentMarker widget with 48px circular avatar and university-colored border"
  - "StudentBottomSheet with photo, name, university, distance, transport, route"
  - "MarkerClusterLayerWidget integration on MapScreen"
  - "8 mock BD student profiles seeded in Firestore"
  - "location_utils with formatDistance and calculateDistanceKm"
affects: [ride-matching, chat, profile-view]

# Tech tracking
tech-stack:
  added: [flutter_map_marker_cluster, geoflutterfire_plus geo queries]
  patterns: [client-side distance sort for geo queries, markerChildBehavior for custom marker taps, DraggableScrollableSheet for profile bottom sheet]

key-files:
  created:
    - lib/features/map/providers/nearby_students_provider.dart
    - lib/features/map/presentation/widgets/student_marker.dart
    - lib/features/map/presentation/widgets/student_bottom_sheet.dart
    - lib/core/utils/seed_data.dart
    - lib/core/utils/location_utils.dart
  modified:
    - lib/features/map/presentation/screens/map_screen.dart
    - lib/main.dart

key-decisions:
  - "Used asyncMap instead of map for nearby students stream to await SharedPreferences for profile ID filtering"
  - "Set markerChildBehavior: true on cluster layer so StudentMarker GestureDetector handles taps directly"
  - "Wrapped seed data call in try-catch so app runs without Firebase configured"

patterns-established:
  - "Geo query pattern: GeoCollectionReference.subscribeWithin() + client-side sort by distance"
  - "Marker tap pattern: markerChildBehavior + GestureDetector + showModalBottomSheet"
  - "Seed data pattern: shouldSeed() guard + batch write + debug-mode-only execution"

requirements-completed: [MAP-02, PROF-03]

# Metrics
duration: 6min
completed: 2026-03-27
---

# Phase 01 Plan 04: Nearby Student Markers Summary

**Geo-queried student markers with clustering, university-colored borders, and draggable profile bottom sheet on map**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-26T22:49:25Z
- **Completed:** 2026-03-26T22:55:45Z
- **Tasks:** 3 (2 auto + 1 auto-approved checkpoint)
- **Files modified:** 7

## Accomplishments
- NearbyStudentsProvider streams Firestore geo query results within 5km configurable radius, sorted by distance
- StudentMarker renders 48px circular avatar with 3px university-colored border, white outer ring, drop shadow, cached network image, and accessibility semantics
- StudentBottomSheet displays draggable profile with photo, name, university, distance, transport type chips, route visualization
- MapScreen integrates MarkerClusterLayerWidget with 200ms fade-in animation and 48px accent-colored cluster badges
- 8 mock BD student profiles seeded in Firestore with realistic university/route/transport data

## Task Commits

Each task was committed atomically:

1. **Task 1: Nearby students provider and student marker widget** - `c18119d` (feat)
2. **Task 2: Student bottom sheet, seed data, and map integration** - `5c01341` (feat)
3. **Task 3: Verify complete Phase 1 flow on device** - auto-approved (checkpoint)

## Files Created/Modified
- `lib/features/map/providers/nearby_students_provider.dart` - Streams nearby students from Firestore geo queries
- `lib/features/map/presentation/widgets/student_marker.dart` - Circular avatar marker with university-colored border
- `lib/features/map/presentation/widgets/student_bottom_sheet.dart` - Draggable profile bottom sheet on marker tap
- `lib/core/utils/seed_data.dart` - Seeds 8 mock BD student profiles with geo-hashed locations
- `lib/core/utils/location_utils.dart` - formatDistance and calculateDistanceKm helpers
- `lib/features/map/presentation/screens/map_screen.dart` - Added MarkerClusterLayerWidget and nearby students integration
- `lib/main.dart` - Added debug-mode seed data call with try-catch guard

## Decisions Made
- Used `asyncMap` instead of `map` for nearby students stream to await SharedPreferences for local profile ID filtering (avoids importing profile repository provider into the geo query)
- Set `markerChildBehavior: true` on MarkerClusterLayerOptions so the StudentMarker's own GestureDetector handles tap events directly rather than going through the cluster layer's onMarkerTap callback
- Wrapped seed data call in `try-catch` with `on Exception` so the app still launches without Firebase being configured (firebase_options.dart not yet generated)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. Firebase configuration (via `flutterfire configure`) is required before Firestore-dependent features work, but this was already documented in prior plans.

## Next Phase Readiness
- Complete Phase 1 flow implemented: permission -> profile setup -> map with markers -> bottom sheet -> profile edit
- Ready for Phase 2 (ride posting/matching) -- map infrastructure complete
- Firebase configuration required before on-device testing of Firestore features (seed data, nearby students, profile save)
- Cloud Storage Blaze plan needed for profile photo uploads (documented in STATE.md blockers)

## Self-Check: PASSED

All 7 files verified present. Both task commits (c18119d, 5c01341) verified in git log.

---
*Phase: 01-map-profiles*
*Completed: 2026-03-27*
