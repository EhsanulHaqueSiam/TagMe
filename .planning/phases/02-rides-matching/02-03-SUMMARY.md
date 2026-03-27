---
phase: 02-rides-matching
plan: 03
subsystem: ui
tags: [flutter, riverpod, ride-card, rides-list, search, gender-ranking, shimmer]

# Dependency graph
requires:
  - phase: 02-rides-matching
    plan: 01
    provides: Ride model, RideRepository (geo queries), MatchingService, TransportType enum, ShellScreen, router placeholders
provides:
  - RideCard reusable widget with transport icon, poster info, route, time, fare, seats badge
  - RidesTabScreen with Nearby/My Rides tabs and Post Ride FAB
  - RideSearchScreen with destination picker, transport/time filters, gender-ranked results
  - nearbyRidesProvider, myRidesProvider, searchRidesProvider Riverpod providers
affects: [02-04, 02-05]

# Tech tracking
tech-stack:
  added: []
  patterns: [date-grouped ListView with mixed String headers and Ride items, shimmer via AnimationController + FadeTransition, AsyncValue.when pattern for loading/error/data]

key-files:
  created:
    - lib/features/rides/presentation/widgets/ride_card.dart
    - lib/features/rides/presentation/screens/rides_tab_screen.dart
    - lib/features/rides/presentation/screens/ride_search_screen.dart
    - lib/features/rides/providers/search_providers.dart
  modified:
    - lib/app/router.dart

key-decisions:
  - "Used indexWhere instead of try-catch ArgumentError for TransportType lookup (avoids catching Errors per Dart lint)"
  - "Riverpod 4.x codegen: ProfileNotifier generates profileProvider (consistent with Phase 1 pattern)"
  - "Shimmer implemented package-free via AnimationController + FadeTransition (no external dependency)"

patterns-established:
  - "AsyncValue.when for loading/error/data states across all list screens"
  - "Shimmer skeleton: AnimationController with FadeTransition on surfaceVariant containers"
  - "Date grouping: mixed List<Object> with String headers and model items in ListView.builder"

requirements-completed: [RIDE-02, RIDE-06, PREF-01, PREF-02]

# Metrics
duration: 9min
completed: 2026-03-27
---

# Phase 02 Plan 03: Rides List & Search UI Summary

**RideCard widget, RidesTabScreen with Nearby/My Rides tabs, RideSearchScreen with destination-based search and transport/time filters, and Riverpod search providers with gender-preference ranking**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-27T05:47:52Z
- **Completed:** 2026-03-27T05:56:55Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- RideCard reusable widget showing transport icon, poster info (name + university chip), route visualization (origin/destination dots with connector), departure time, estimated fare, and seats badge with "Full"/"X left" states
- RidesTabScreen with Nearby tab (geo-filtered stream sorted by departure) and My Rides tab (date-grouped sections with Today/Tomorrow headers), plus extended "Post Ride" FAB
- RideSearchScreen with destination map picker, horizontal transport filter chips (All + 5 types), time range bottom sheet, and search results using MatchingService with gender-preference soft ranking
- Three Riverpod stream providers: nearbyRidesProvider, myRidesProvider, searchRidesProvider piping through MatchingService for filtering and ranking
- Router updated: replaced Rides and Search placeholders with real screens

## Task Commits

Each task was committed atomically:

1. **Task 1: RideCard widget and search providers** - `a1d69fe` (feat)
2. **Task 2: RidesTabScreen, RideSearchScreen, and router wiring** - `91fe3c3` (feat)

## Files Created/Modified
- `lib/features/rides/presentation/widgets/ride_card.dart` - Reusable ride card with transport icon, route, time, fare, seats badge, match accent border
- `lib/features/rides/providers/search_providers.dart` - nearbyRidesProvider, myRidesProvider, searchRidesProvider with MatchingService integration
- `lib/features/rides/presentation/screens/rides_tab_screen.dart` - Main rides view with Nearby/My Rides tabs, shimmer loading, empty states per UI-SPEC copywriting
- `lib/features/rides/presentation/screens/ride_search_screen.dart` - Destination-based search with transport/time filters and gender-ranked results
- `lib/app/router.dart` - Replaced _RidesPlaceholder and _RideSearchPlaceholder with real screens

## Decisions Made
- Used indexWhere instead of try-catch ArgumentError for TransportType resolution (Dart lint: avoid_catching_errors)
- Shimmer loading implemented package-free via AnimationController + FadeTransition (no shimmer dependency needed)
- Riverpod 4.x codegen: ProfileNotifier generates profileProvider (confirmed from Phase 1 decision)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Ride list and search UI are fully wired to data layer providers
- RideCard is reusable across RidesTabScreen and RideSearchScreen
- Search filters pipe through searchRidesProvider to MatchingService with gender-preference ranking
- Ready for Plan 02-04 (ride detail and join request flow)

## Self-Check: PASSED

- All 4 created files verified present on disk
- All 2 task commits verified in git log (a1d69fe, 91fe3c3)

---
*Phase: 02-rides-matching*
*Completed: 2026-03-27*
