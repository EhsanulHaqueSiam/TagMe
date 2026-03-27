---
phase: 03-chat-notifications
plan: 03
subsystem: notifications
tags: [fcm, firebase_messaging, flutter_local_notifications, riverpod, push-notifications, departure-reminders]

# Dependency graph
requires:
  - phase: 03-chat-notifications
    plan: 01
    provides: "firebase_messaging, flutter_local_notifications, timezone dependencies and Android build configuration"
provides:
  - "FcmService with token lifecycle, permission request, foreground message display"
  - "LocalNotificationService with zonedSchedule departure reminders and showNow for foreground FCM"
  - "Riverpod keepAlive providers for both notification services"
  - "App startup notification initialization with graceful Firebase fallback"
affects: [03-chat-notifications, 04-polish-launch]

# Tech tracking
tech-stack:
  added: []
  patterns: [fcm-token-subcollection, foreground-fcm-local-notification-bridge, inexact-alarm-scheduling]

key-files:
  created:
    - lib/features/notifications/data/services/fcm_service.dart
    - lib/features/notifications/data/services/local_notification_service.dart
    - lib/features/notifications/providers/notification_providers.dart
  modified:
    - lib/main.dart

key-decisions:
  - "flutter_local_notifications v21 uses all-named-parameter API (not positional like older versions)"
  - "LocalNotificationService initialized before FCM in main.dart (no Firebase dependency)"
  - "FCM init wrapped in try-catch matching existing Firebase-dependent code pattern"
  - "Generated .g.dart files gitignored per project convention"

patterns-established:
  - "FCM token stored at students/{id}/tokens/{token} with token as doc ID for dedup"
  - "Foreground FCM messages displayed via LocalNotificationService.showNow bridge"
  - "AndroidScheduleMode.inexactAllowWhileIdle for non-critical reminders (Android 14+)"
  - "Explicit notification channel creation during init for chat_messages and departure_reminders"

requirements-completed: [CHAT-05]

# Metrics
duration: 4min
completed: 2026-03-27
---

# Phase 3 Plan 3: Notification Services Summary

**FCM token management with Firestore persistence, local departure reminders via zonedSchedule, and foreground FCM-to-local-notification bridge wired into app startup**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-27T06:52:59Z
- **Completed:** 2026-03-27T06:57:08Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- FcmService handles permission request, token save to Firestore subcollection, token refresh listener, and foreground message display via LocalNotificationService
- LocalNotificationService initializes timezone data, creates Android notification channels (chat_messages, departure_reminders), schedules departure reminders 15 min before departure, and shows immediate notifications for foreground FCM
- App startup initializes local notifications (no Firebase dependency) then FCM with try-catch fallback, preserving existing seed data and recurring schedule blocks

## Task Commits

Each task was committed atomically:

1. **Task 1: Create FCM and local notification services** - `b3f6935` (feat)
2. **Task 2: Wire notification services into app startup** - `9c48d0a` (feat)

## Files Created/Modified
- `lib/features/notifications/data/services/fcm_service.dart` - FCM token management, permission request, foreground message handler
- `lib/features/notifications/data/services/local_notification_service.dart` - Local notification init, zonedSchedule departure reminders, showNow for foreground display
- `lib/features/notifications/providers/notification_providers.dart` - Riverpod keepAlive providers for FcmService and LocalNotificationService
- `lib/main.dart` - Notification initialization in app startup with graceful fallback

## Decisions Made
- flutter_local_notifications v21.0.0 uses all-named-parameter API for initialize(), zonedSchedule(), show(), cancel() -- adjusted from plan's positional parameter examples
- LocalNotificationService initialized before FCM in main.dart since it has no Firebase dependency
- FCM init wrapped in try-catch matching existing Firebase-dependent code pattern in main.dart
- Generated .g.dart files gitignored per project convention (only source files committed)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed flutter_local_notifications v21 API calls**
- **Found during:** Task 1 (Create notification services)
- **Issue:** Plan examples used positional parameters for initialize(), zonedSchedule(), show(), cancel() but flutter_local_notifications v21.0.0 changed all methods to named parameters
- **Fix:** Converted all method calls to named parameter syntax (e.g., `_plugin.initialize(settings: settings, ...)` instead of `_plugin.initialize(settings, ...)`)
- **Files modified:** lib/features/notifications/data/services/local_notification_service.dart
- **Verification:** dart analyze reports no errors
- **Committed in:** b3f6935 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** API syntax change required for v21 compatibility. No scope creep.

## Issues Encountered
None beyond the API change documented above.

## Known Stubs
None - all notification services are fully implemented with real Firebase and local notification APIs.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Notification infrastructure complete: FCM tokens stored, departure reminders schedulable, foreground messages displayed
- Plan 04 (Chat UI) can call LocalNotificationService.scheduleDepartureReminder when rides are confirmed
- Cloud Functions (future Blaze plan) can use stored FCM tokens to send push notifications
- App works fully without Cloud Functions -- departure reminders are client-side

## Self-Check: PASSED
