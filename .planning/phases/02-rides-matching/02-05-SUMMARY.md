---
phase: 02-rides-matching
plan: 05
subsystem: ui
tags: [flutter, riverpod, firestore, recurring-schedules, fare-tracking, widgets]

# Dependency graph
requires:
  - phase: 02-rides-matching-01
    provides: "Data models (RecurringSchedule, FareEntry), repositories (ScheduleRepository, FareRepository, RideRepository), services (RouteService, FareCalculator)"
provides:
  - "RecurringScheduleScreen with day-of-week selection and schedule management"
  - "DaySelector widget for multi-select day chips"
  - "Auto-post logic (processRecurringSchedules) called on app startup"
  - "FareHistoryScreen with Balances and History tabs"
  - "BalanceRow and FareHistoryCard widgets"
  - "Fare providers (fareBalances, fareHistory, coRiderProfile)"
  - "All Phase 2 router placeholders replaced with real screens"
affects: [03-chat-notifications, 04-polish-launch]

# Tech tracking
tech-stack:
  added: []
  patterns: [standalone-function-for-startup-processing, date-grouped-list-view, tab-bar-with-async-providers]

key-files:
  created:
    - lib/features/rides/presentation/widgets/day_selector.dart
    - lib/features/rides/providers/schedule_providers.dart
    - lib/features/rides/presentation/screens/recurring_schedule_screen.dart
    - lib/features/fares/presentation/widgets/balance_row.dart
    - lib/features/fares/presentation/widgets/fare_history_card.dart
    - lib/features/fares/providers/fare_providers.dart
    - lib/features/fares/presentation/screens/fare_history_screen.dart
  modified:
    - lib/main.dart
    - lib/app/router.dart

key-decisions:
  - "processRecurringSchedules is a standalone function (not provider-based) for main.dart startup use"
  - "FareHistoryCard shows 'Split with co-rider' for v1 (FareEntry only has IDs, not names)"
  - "BalanceRow fetches co-rider profile via coRiderProfileProvider for name/university display"

patterns-established:
  - "Standalone startup functions: Functions called from main() use direct repository instances, not Ref-based providers"
  - "Date-grouped lists: Group entries by Today/Yesterday/formatted-date labels in history views"
  - "Auto-post on startup: Non-fatal schedule processing wrapped in try-catch in main()"

requirements-completed: [RIDE-08, RIDE-09, FARE-02, FARE-03, FARE-04]

# Metrics
duration: 9min
completed: 2026-03-27
---

# Phase 02 Plan 05: Recurring Schedules & Fare Tracking Summary

**Recurring ride schedules with day-of-week chips and auto-post on startup, plus fare balance/history screens with color-coded amounts**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-27T06:00:10Z
- **Completed:** 2026-03-27T06:09:10Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- RecurringScheduleScreen with form (route, days, time, transport), preview of next 5 rides, and active schedule list with swipe-to-delete and undo
- Auto-post logic processes active schedules on app open, creating rides for today's matching schedules
- FareHistoryScreen with Balances tab (color-coded: green/red/settled) and History tab (date-grouped entries)
- All Phase 2 router placeholders replaced with real screens

## Task Commits

Each task was committed atomically:

1. **Task 1: DaySelector, RecurringScheduleScreen, and schedule providers** - `3eb056d` (feat)
2. **Task 2: FareHistoryScreen, fare widgets, providers, and router wiring** - `c92f633` (feat)

## Files Created/Modified
- `lib/features/rides/presentation/widgets/day_selector.dart` - 7 circular day-of-week chips with multi-select toggle
- `lib/features/rides/providers/schedule_providers.dart` - mySchedules stream, createSchedule, processRecurringSchedules
- `lib/features/rides/presentation/screens/recurring_schedule_screen.dart` - Schedule creation form with preview and active schedules
- `lib/features/fares/presentation/widgets/balance_row.dart` - Co-rider balance display with color-coded amounts
- `lib/features/fares/presentation/widgets/fare_history_card.dart` - Fare entry card with route, transport, payment direction
- `lib/features/fares/providers/fare_providers.dart` - fareBalances, fareHistory, coRiderProfile providers
- `lib/features/fares/presentation/screens/fare_history_screen.dart` - Tabbed screen with Balances and History views
- `lib/main.dart` - Added processRecurringSchedules call on app startup
- `lib/app/router.dart` - Replaced schedule/fares placeholders with real screens

## Decisions Made
- processRecurringSchedules implemented as standalone function (not provider-based) since main() doesn't have Ref access
- FareHistoryCard shows generic "Split with co-rider" text for v1 since FareEntry only stores IDs
- BalanceRow auto-fetches co-rider profiles via coRiderProfileProvider for name/university display
- Removed all remaining Phase 2 placeholder classes from router.dart

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All Phase 2 screens implemented: map, profile, rides, schedules, fares
- All router placeholders replaced with real screens
- Ready for Phase 3 (chat & notifications) or Phase 4 (polish & launch)

## Self-Check: PASSED

All 9 created/modified files verified on disk. Both task commits (3eb056d, c92f633) verified in git log.

---
*Phase: 02-rides-matching*
*Completed: 2026-03-27*
