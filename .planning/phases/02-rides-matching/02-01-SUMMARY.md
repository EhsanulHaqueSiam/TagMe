---
phase: 02-rides-matching
plan: 01
subsystem: data-layer
tags: [freezed, firestore, geoflutterfire, ors, riverpod, go_router, fare-splitting, ride-matching]

# Dependency graph
requires:
  - phase: 01-map-profiles
    provides: Firestore repository pattern, Student model, location_utils, GoRouter config, app_colors
provides:
  - TransportType enum with BD transport metadata (icon, capacity, farePerKm)
  - Ride, JoinRequest, RecurringSchedule, FareEntry Freezed models
  - RouteService wrapping ORS API (directions + reverse geocoding)
  - MatchingService (proximity + time + gender filtering)
  - FareCalculator (total fare + per-person split)
  - RideRepository with geo queries via geoflutterfire_plus
  - JoinRequestRepository with transactional seat acceptance
  - ScheduleRepository for recurring ride schedules
  - FareRepository with balance computation
  - ShellScreen bottom navigation (Map + Rides tabs)
  - StatefulShellRoute.indexedStack router with all Phase 2 route placeholders
affects: [02-02, 02-03, 02-04, 02-05]

# Tech tracking
tech-stack:
  added: [open_route_service, intl]
  patterns: [nested geo map storage for geoflutterfire_plus, Timestamp-to-DateTime conversion in fromDoc helpers, StatefulShellRoute.indexedStack for tab navigation]

key-files:
  created:
    - lib/core/constants/transport_types.dart
    - lib/core/constants/fare_rates.dart
    - lib/features/rides/data/models/ride.dart
    - lib/features/rides/data/models/join_request.dart
    - lib/features/rides/data/models/recurring_schedule.dart
    - lib/features/fares/data/models/fare_entry.dart
    - lib/features/rides/data/services/route_service.dart
    - lib/features/rides/data/services/matching_service.dart
    - lib/features/fares/data/services/fare_calculator.dart
    - lib/features/rides/data/repositories/ride_repository.dart
    - lib/features/rides/data/repositories/join_request_repository.dart
    - lib/features/rides/data/repositories/schedule_repository.dart
    - lib/features/fares/data/repositories/fare_repository.dart
    - lib/app/shell_screen.dart
  modified:
    - pubspec.yaml
    - lib/app/router.dart

key-decisions:
  - "Nested geo maps (origin/destination) store GeoPoint+geohash+address for geoflutterfire_plus compatibility"
  - "JoinRequest uses top-level collection (not subcollection) for cross-ride querying"
  - "Ride status as String enum (active/full/completed/cancelled) for Firestore simplicity"
  - "FareCalculator rounds up per-person split (ceil) to avoid underpayment"

patterns-established:
  - "Nested geo map: {geopoint, geohash, address} for all location fields needing geo queries"
  - "Timestamp conversion: Firestore Timestamps converted to ISO 8601 strings in _fromDoc helpers before Freezed deserialization"
  - "Required-first parameter ordering in Freezed models to satisfy always_put_required_named_parameters_first lint"

requirements-completed: [RIDE-03, RIDE-04, RIDE-05, FARE-01]

# Metrics
duration: 10min
completed: 2026-03-27
---

# Phase 02 Plan 01: Data Layer & Navigation Foundation Summary

**Freezed models (Ride/JoinRequest/RecurringSchedule/FareEntry), TransportType enum with BD fare rates, ORS route service, fare calculator, geo-enabled Firestore repositories, and bottom nav shell with StatefulShellRoute**

## Performance

- **Duration:** 10 min
- **Started:** 2026-03-27T05:34:02Z
- **Completed:** 2026-03-27T05:44:36Z
- **Tasks:** 3
- **Files modified:** 16

## Accomplishments
- TransportType enum with 5 BD transport types carrying icon, capacity, and BDT fare rates
- 4 Freezed models with Firestore-aligned schemas and generated serialization code
- RouteService wrapping ORS API with Haversine fallback, FareCalculator with per-person split
- MatchingService filtering by 1km destination proximity, 30min time window, gender soft ranking
- 4 Firestore repositories (rides, join requests, schedules, fares) with geo queries and transactions
- Bottom navigation shell with Map and Rides tabs using StatefulShellRoute.indexedStack

## Task Commits

Each task was committed atomically:

1. **Task 1: Models, enums, and constants** - `b59641e` (feat)
2. **Task 2: Services and repositories** - `d0160c6` (feat)
3. **Task 3: Bottom navigation shell and router update** - `76ca00f` (feat)

## Files Created/Modified
- `pubspec.yaml` - Added open_route_service and intl dependencies
- `lib/core/constants/transport_types.dart` - TransportType enum with BD metadata
- `lib/core/constants/fare_rates.dart` - BDT currency constants
- `lib/features/rides/data/models/ride.dart` - Ride Freezed model with geo fields
- `lib/features/rides/data/models/join_request.dart` - JoinRequest Freezed model
- `lib/features/rides/data/models/recurring_schedule.dart` - RecurringSchedule Freezed model
- `lib/features/fares/data/models/fare_entry.dart` - FareEntry Freezed model
- `lib/features/rides/data/services/route_service.dart` - ORS directions + geocoding wrapper
- `lib/features/rides/data/services/matching_service.dart` - Ride filtering and ranking logic
- `lib/features/fares/data/services/fare_calculator.dart` - Fare computation logic
- `lib/features/rides/data/repositories/ride_repository.dart` - Firestore CRUD with geo queries
- `lib/features/rides/data/repositories/join_request_repository.dart` - Join requests with transactional acceptance
- `lib/features/rides/data/repositories/schedule_repository.dart` - Recurring schedule CRUD
- `lib/features/fares/data/repositories/fare_repository.dart` - Fare ledger with balance computation
- `lib/app/shell_screen.dart` - Bottom navigation bar with Map and Rides tabs
- `lib/app/router.dart` - StatefulShellRoute.indexedStack with all Phase 2 route placeholders

## Decisions Made
- Nested geo maps (origin/destination) store GeoPoint+geohash+address for geoflutterfire_plus compatibility
- JoinRequest uses top-level collection (not subcollection) for cross-ride querying
- Ride status as String (active/full/completed/cancelled) for Firestore simplicity
- FareCalculator rounds up per-person split (ceil) to avoid underpayment
- ORS API key stored as placeholder constant (user must configure)

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

- `lib/features/rides/data/services/route_service.dart:9` - `const orsApiKey = ''` -- ORS API key placeholder, must be configured by user before route service works (falls back to Haversine * 1.3)
- `lib/app/router.dart` - 8 placeholder screens (_RidesPlaceholder, _PostRidePlaceholder, etc.) with "Coming Soon" text, replaced by real screens in Plans 02-05

## Issues Encountered
None

## User Setup Required
- ORS API key must be set in `lib/features/rides/data/services/route_service.dart` (line 9) -- sign up at https://openrouteservice.org/dev/#/signup

## Next Phase Readiness
- All data models, services, and repositories are ready for UI plans (02-02 through 02-05)
- Bottom navigation shell is wired up and ready for Rides tab screen
- Route placeholders registered for all Phase 2 screens

## Self-Check: PASSED

- All 14 created files verified present on disk
- All 3 task commits verified in git log (b59641e, d0160c6, 76ca00f)

---
*Phase: 02-rides-matching*
*Completed: 2026-03-27*
