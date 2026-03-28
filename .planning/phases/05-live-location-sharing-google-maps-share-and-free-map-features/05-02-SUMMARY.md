---
phase: 05-live-location-sharing-google-maps-share-and-free-map-features
plan: 02
subsystem: location
tags: [google-maps, url_launcher, share_plus, firestore, geolocator, geocoding, ors-pelias, riverpod]

# Dependency graph
requires:
  - phase: 05-live-location-sharing-google-maps-share-and-free-map-features
    provides: Message model extension, ChatRepository location support (plan 01)
provides:
  - MapsShareService for Google Maps open/share/directions via geo: intent with browser fallback
  - LiveLocationRepository for Firestore CRUD of live GPS sharing with throttled writer
  - GeocodingService for ORS Pelias autocomplete with Bangladesh focus
  - Riverpod providers for all three services
affects: [05-03-chat-location-sharing, 05-04-live-location-chat, 05-05-place-search, 05-06-poi-isochrone]

# Tech tracking
tech-stack:
  added: [share_plus 10.1.4]
  patterns: [throttled Firestore writes via ThrottledLocationWriter, geo: intent with web fallback]

key-files:
  created:
    - lib/features/location_sharing/data/services/maps_share_service.dart
    - lib/features/location_sharing/data/services/geocoding_service.dart
    - lib/features/location_sharing/data/repositories/live_location_repository.dart
    - lib/features/location_sharing/providers/geocoding_providers.dart
    - lib/features/location_sharing/providers/live_location_providers.dart
  modified:
    - pubspec.yaml

key-decisions:
  - "share_plus 10.1.4 uses Share.share(text) static API, not SharePlus.instance pattern from plan"
  - "GeoJsonFeature geometry coordinates accessed via geometry.coordinates[0][0] for point features"
  - "ORS geocodeAutoCompleteGet uses text: parameter, not query:"

patterns-established:
  - "ThrottledLocationWriter: 10-second min interval between Firestore writes with timer-based deferred write"
  - "geo: URI intent with Google Maps web fallback for Android map integration"
  - "liveLocations subcollection under conversations for per-user location docs"

requirements-completed: [LOC-02, LOC-03, LOC-04, LOC-05]

# Metrics
duration: 6min
completed: 2026-03-29
---

# Phase 5 Plan 2: Services Layer Summary

**MapsShareService for Google Maps integration, LiveLocationRepository with 10s-throttled Firestore writes, and GeocodingService wrapping ORS Pelias autocomplete with Dhaka focus**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-28T22:11:11Z
- **Completed:** 2026-03-28T22:17:40Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- MapsShareService handles opening locations in Google Maps (geo: intent with web fallback), navigation directions, and system share sheet
- LiveLocationRepository provides Firestore CRUD for live GPS sharing with ThrottledLocationWriter limiting writes to 10-second intervals
- GeocodingService wraps ORS Pelias autocomplete with 3-character minimum and Bangladesh focus point (Dhaka 23.8103, 90.4125)
- Riverpod providers generated for all services: geocodingServiceProvider, liveLocationRepositoryProvider, partnerLiveLocationProvider, activeLiveLocationsProvider

## Task Commits

Each task was committed atomically:

1. **Task 1: Create MapsShareService and GeocodingService** - `c26e5d2` (feat)
2. **Task 2: Create LiveLocationRepository with throttled writer and Riverpod providers** - `c5d1934` (feat)

## Files Created/Modified
- `lib/features/location_sharing/data/services/maps_share_service.dart` - Google Maps open/share/directions with geo: intent and browser fallback
- `lib/features/location_sharing/data/services/geocoding_service.dart` - ORS Pelias autocomplete with GeocodingResult model and Bangladesh focus
- `lib/features/location_sharing/data/repositories/live_location_repository.dart` - Firestore CRUD for liveLocations subcollection plus ThrottledLocationWriter
- `lib/features/location_sharing/providers/geocoding_providers.dart` - Riverpod provider for GeocodingService
- `lib/features/location_sharing/providers/live_location_providers.dart` - Riverpod providers for LiveLocationRepository and streaming
- `pubspec.yaml` - Added share_plus ^10.1.4 dependency

## Decisions Made
- share_plus 10.1.4 uses `Share.share(text)` static API, not `SharePlus.instance.share(ShareParams(...))` as plan specified -- corrected to match actual API
- GeoJsonFeature geometry for point features is accessed via `geometry.coordinates[0][0]` (not casting geometry as ORSCoordinate) -- corrected from plan
- ORS `geocodeAutoCompleteGet` uses `text:` named parameter, not `query:` -- corrected from plan

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed share_plus API call**
- **Found during:** Task 1 (MapsShareService creation)
- **Issue:** Plan specified `SharePlus.instance.share(ShareParams(text: text))` but share_plus 10.1.4 uses `Share.share(text)` static method
- **Fix:** Changed to `await Share.share(text)` matching actual share_plus 10.1.4 API
- **Files modified:** lib/features/location_sharing/data/services/maps_share_service.dart
- **Verification:** `flutter analyze` passes with no errors
- **Committed in:** c5d1934 (Task 2 commit, included fix)

**2. [Rule 1 - Bug] Fixed GeoJsonFeature coordinate extraction**
- **Found during:** Task 1 (GeocodingService creation)
- **Issue:** Plan cast `f.geometry as ORSCoordinate` but geometry is `GeoJsonFeatureGeometry`, not `ORSCoordinate`
- **Fix:** Used `f.geometry.coordinates[0][0]` to access the ORSCoordinate for point features
- **Files modified:** lib/features/location_sharing/data/services/geocoding_service.dart
- **Verification:** `flutter analyze` passes with no errors
- **Committed in:** c26e5d2 (Task 1 commit)

**3. [Rule 1 - Bug] Fixed ORS autocomplete parameter name**
- **Found during:** Task 1 (GeocodingService creation)
- **Issue:** Plan used `query:` parameter but ORS API uses `text:` for geocodeAutoCompleteGet
- **Fix:** Changed parameter from `query: query` to `text: query`
- **Files modified:** lib/features/location_sharing/data/services/geocoding_service.dart
- **Verification:** Matches ORS package source code signature
- **Committed in:** c26e5d2 (Task 1 commit)

**4. [Rule 3 - Blocking] Added missing share_plus dependency**
- **Found during:** Task 1 (MapsShareService creation)
- **Issue:** share_plus not in pubspec.yaml but required by MapsShareService
- **Fix:** Added `share_plus: ^10.1.4` to pubspec.yaml dependencies
- **Files modified:** pubspec.yaml
- **Verification:** `flutter pub get` succeeds
- **Committed in:** c26e5d2 (Task 1 commit)

---

**Total deviations:** 4 auto-fixed (3 bugs, 1 blocking)
**Impact on plan:** All fixes were necessary for correctness. Plan had incorrect API signatures from share_plus and open_route_service packages. No scope creep.

## Issues Encountered
None beyond the API corrections documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three services ready for UI consumption in plans 03-06
- MapsShareService can be used by LocationShareCard and RideDetailScreen
- LiveLocationRepository can be used by LiveSharingBanner and EmbeddedLiveMap
- GeocodingService can be used by PlaceSearchScreen

## Self-Check: PASSED

All 5 created files verified on disk. Both task commits (c26e5d2, c5d1934) verified in git log.

---
*Phase: 05-live-location-sharing-google-maps-share-and-free-map-features*
*Completed: 2026-03-29*
