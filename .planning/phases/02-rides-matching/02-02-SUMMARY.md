---
phase: 02-rides-matching
plan: 02
subsystem: ui
tags: [flutter_map, riverpod, go_router, geocoding, ride-posting, map-picker, transport-selector]

# Dependency graph
requires:
  - phase: 02-rides-matching
    plan: 01
    provides: Ride model, RouteService, FareCalculator, RideRepository, TransportType enum, GoRouter placeholder routes
provides:
  - MapPinPickerScreen for map-based location selection with reverse geocoding
  - TransportSelector widget with 5 BD transport chips (radio selection)
  - SeatStepper widget with min/max constrained increment/decrement
  - PostRideScreen form with all 7 sections per UI-SPEC
  - postRide Riverpod provider chaining profile -> route -> fare -> repository
  - Router wiring replacing PostRide and MapPinPicker placeholders with real screens
affects: [02-03, 02-04, 02-05]

# Tech tracking
tech-stack:
  added: []
  patterns: [context.push<Map<String, dynamic>> for map picker result passing, debounced reverse geocoding on map pan events, radio-style chip selection with TransportType enum iteration]

key-files:
  created:
    - lib/features/rides/presentation/screens/map_pin_picker_screen.dart
    - lib/features/rides/presentation/screens/post_ride_screen.dart
    - lib/features/rides/presentation/widgets/transport_selector.dart
    - lib/features/rides/presentation/widgets/seat_stepper.dart
    - lib/features/rides/providers/ride_providers.dart
  modified:
    - lib/app/router.dart

key-decisions:
  - "Used context.push<Map<String, dynamic>> with context.pop(result) for MapPinPicker -> PostRide data flow"
  - "Debounced 500ms reverse geocoding on map pan events to avoid excessive API calls"
  - "Transport selection auto-adjusts seats to maxCapacity - 1 (poster takes one seat)"
  - "Departure time auto-bumps to tomorrow if selected time is in the past"

patterns-established:
  - "Map picker result passing: push route returns Map<String, dynamic> with lat, lng, address keys"
  - "Form state management: ConsumerStatefulWidget with local state for form fields, providers for async operations"

requirements-completed: [RIDE-01]

# Metrics
duration: 7min
completed: 2026-03-27
---

# Phase 02 Plan 02: Ride Posting Flow Summary

**PostRideScreen form with origin/dest map pickers, transport chips, ride-hailing tags, time picker, seat stepper, and postRide provider chaining ORS route data through fare calculation to Firestore**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-27T05:47:37Z
- **Completed:** 2026-03-27T05:54:30Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- MapPinPickerScreen with full-screen flutter_map, center pin overlay, debounced reverse geocoding, and confirm-to-pop result passing
- TransportSelector with 5 BD transport chips (rickshaw, bike, bus, car, CNG) in radio-style selection
- SeatStepper with constrained increment/decrement and disabled states at bounds
- PostRideScreen with all 7 UI-SPEC sections: origin/dest selectors, transport, ride-hailing, time, seats, post button
- postRide provider assembling profile data, ORS route, fare calculation, and Firestore write
- Router wiring replacing placeholders with PostRideScreen and MapPinPickerScreen

## Task Commits

Each task was committed atomically:

1. **Task 1: MapPinPickerScreen and reusable widgets** - `3f44d55` (feat)
2. **Task 2: PostRideScreen, providers, and router wiring** - `bae817a` (feat)

## Files Created/Modified
- `lib/features/rides/presentation/screens/map_pin_picker_screen.dart` - Full-screen map pin picker with reverse geocoding
- `lib/features/rides/presentation/screens/post_ride_screen.dart` - Ride posting form with 7 sections
- `lib/features/rides/presentation/widgets/transport_selector.dart` - Transport type chip row widget
- `lib/features/rides/presentation/widgets/seat_stepper.dart` - Seat count stepper widget
- `lib/features/rides/providers/ride_providers.dart` - postRide provider for Firestore ride creation
- `lib/app/router.dart` - Replaced PostRide and MapPinPicker placeholders with real screens

## Decisions Made
- Used context.push<Map<String, dynamic>> for MapPinPicker result passing (clean data flow without extra state)
- Debounced 500ms on map pan for reverse geocoding (balances responsiveness with API rate limits)
- Transport selection auto-adjusts seat count to maxCapacity - 1 (accounts for poster taking a seat)
- Departure time auto-bumps to tomorrow when selected time is already past

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None - all data sources are wired to real providers and Firestore repositories.

## Issues Encountered

- `profileNotifierProvider` name incorrect for Riverpod 4.x codegen -- the generated name is `profileProvider` (consistent with STATE.md decision). Fixed in ride_providers.dart.
- Generated .g.dart files are in .gitignore, so only source files committed (codegen runs via build_runner).

## User Setup Required

ORS API key must be set in `lib/features/rides/data/services/route_service.dart` (line 9) for reverse geocoding in MapPinPickerScreen and route distance in postRide provider. Falls back to Haversine * 1.3 without it.

## Next Phase Readiness
- PostRideScreen is navigable from `/rides/post` route
- MapPinPickerScreen available at `/rides/post/pick-location`
- Both integrate with Plan 01 data layer (RouteService, FareCalculator, RideRepository)
- Ready for Plan 03 (RidesTabScreen with FAB linking to PostRideScreen)

## Self-Check: PASSED

- All 5 created files verified present on disk
- All 2 task commits verified in git log (3f44d55, bae817a)

---
*Phase: 02-rides-matching*
*Completed: 2026-03-27*
