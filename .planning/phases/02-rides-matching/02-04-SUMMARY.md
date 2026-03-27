---
phase: 02-rides-matching
plan: 04
subsystem: ui
tags: [flutter, riverpod, ride-detail, join-request, route-visualization, firestore-transaction]

# Dependency graph
requires:
  - phase: 02-rides-matching
    plan: 01
    provides: Ride model, RideRepository, JoinRequestRepository with Firestore transaction, FareCalculator
  - phase: 02-rides-matching
    plan: 03
    provides: RideCard widget, RidesTabScreen, router placeholders for ride detail and join requests
provides:
  - RideDetailScreen with poster info, route card, fare estimate, and context-aware action button
  - JoinRequestsScreen with accept/decline flow using Firestore transactions
  - RouteVisualization reusable widget (vertical origin-to-destination dots + line)
  - Riverpod providers: rideDetail, existingJoinRequest, joinRequestsForRide, sendJoinRequest
affects: [02-05]

# Tech tracking
tech-stack:
  added: []
  patterns: [context-aware action button pattern based on ride ownership and request status, Firestore transaction for atomic seat increment on accept]

key-files:
  created:
    - lib/features/rides/presentation/screens/ride_detail_screen.dart
    - lib/features/rides/presentation/screens/join_requests_screen.dart
    - lib/features/rides/presentation/widgets/route_visualization.dart
  modified:
    - lib/features/rides/providers/ride_providers.dart
    - lib/app/router.dart

key-decisions:
  - "RideDetailScreen uses StatefulWidget for shimmer animation controller and join request loading state"
  - "JoinRequestsScreen tracks processing/removing IDs in local state for card animation without external animation library"
  - "RouteVisualization uses simple Container-based dots and line (no external package needed)"

patterns-established:
  - "Context-aware action button: own ride -> View Requests, no request -> Join, pending -> disabled amber, accepted -> You're In, full -> Ride Full"
  - "Relative time formatting (min ago, hours ago) for join request timestamps"

requirements-completed: [RIDE-07]

# Metrics
duration: 8min
completed: 2026-03-27
---

# Phase 02 Plan 04: Ride Detail & Join Request Flow Summary

**RideDetailScreen with poster info, route card, fare estimate, and context-aware join/pending/accepted/full actions; JoinRequestsScreen with accept/decline using Firestore transactions; RouteVisualization reusable widget**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-27T05:59:44Z
- **Completed:** 2026-03-27T06:08:33Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- RideDetailScreen showing full ride info: poster header with university-colored avatar, route card with RouteVisualization + mini FlutterMap preview, horizontal info chips (transport/time/seats/ride-hailing), fare estimate card with per-person split and rate basis
- Context-aware action button handling 5 states: own ride (View Requests with pending count), join available (Join This Ride), request pending (amber disabled), request accepted (You're In + Leave Ride), ride full (Ride Full label)
- JoinRequestsScreen with pending request cards showing requester avatar, name, university, relative time, and accept/decline circle icon buttons with snackbar on accept and full-ride disabling
- RouteVisualization reusable widget with vertical filled/outlined circle dots, connecting line, and Pick-up/Drop-off captions
- Four new Riverpod providers: rideDetail, existingJoinRequest, joinRequestsForRide, sendJoinRequest

## Task Commits

Each task was committed atomically:

1. **Task 1: RouteVisualization widget and RideDetailScreen** - `ae36d70` (feat)
2. **Task 2: JoinRequestsScreen and router wiring** - `f96a4c9` (feat)

## Files Created/Modified
- `lib/features/rides/presentation/widgets/route_visualization.dart` - Vertical origin-to-destination visualization with dots, line, and address labels
- `lib/features/rides/presentation/screens/ride_detail_screen.dart` - Full ride detail with poster header, route card, fare estimate, context-aware action button, cancel ride dialog
- `lib/features/rides/presentation/screens/join_requests_screen.dart` - Pending join request list with accept/decline buttons, full-ride handling, relative time display
- `lib/features/rides/providers/ride_providers.dart` - Added rideDetail, existingJoinRequest, joinRequestsForRide, sendJoinRequest providers
- `lib/app/router.dart` - Replaced RideDetail and JoinRequests placeholders with real screens

## Decisions Made
- RideDetailScreen uses StatefulWidget (not StatelessWidget) for AnimationController-based shimmer and join request loading state management
- JoinRequestsScreen tracks processing/removing request IDs in local Set state for card removal without needing an external animation library
- RouteVisualization uses simple Container-based circles and line, keeping the widget dependency-free

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Ride detail and join request flow is fully wired end-to-end
- RideCard taps navigate to RideDetailScreen via router
- Join requests use Firestore transactions for atomic seat increment
- Ready for Plan 02-05 (recurring schedules, fare history, and remaining screens)

## Self-Check: PASSED

- All 3 created files verified present on disk
- All 2 task commits verified in git log (ae36d70, f96a4c9)

---
*Phase: 02-rides-matching*
*Completed: 2026-03-27*
