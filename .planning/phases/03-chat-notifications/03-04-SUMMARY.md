---
phase: 03-chat-notifications
plan: 04
subsystem: notifications
tags: [firebase-functions, fcm, cloud-functions, typescript, firestore-triggers]

# Dependency graph
requires:
  - phase: 03-chat-notifications/02
    provides: "Firestore chat schema (conversations + messages subcollection)"
  - phase: 03-chat-notifications/03
    provides: "FCM token storage in students/{id}/tokens subcollection"
provides:
  - "onMessageCreated Cloud Function: FCM to chat recipient on new message"
  - "onRequestAccepted Cloud Function: FCM to both parties on ride match"
  - "Server-side unread count increment via FieldValue.increment(1)"
  - "Automatic stale FCM token cleanup"
affects: [deployment, firebase-config]

# Tech tracking
tech-stack:
  added: [firebase-functions@6.3.0, firebase-admin@13.0.0, typescript@5.7.0]
  patterns: [cloud-functions-v2, sendEachForMulticast, firestore-triggers]

key-files:
  created:
    - functions/package.json
    - functions/tsconfig.json
    - functions/.eslintrc.js
    - functions/src/index.ts
    - functions/src/onMessageCreated.ts
    - functions/src/onRequestAccepted.ts
  modified:
    - .gitignore

key-decisions:
  - "Used FieldValue.increment(1) for atomic unread count update instead of read-then-write"
  - "Extracted sendNotificationToStudent helper in onRequestAccepted for DRY token fetch + send + cleanup"
  - "Handled both nested origin.address and flat originAddress field paths for ride document compatibility"
  - "Skipped system messages in onMessageCreated to avoid spurious notifications"

patterns-established:
  - "Cloud Functions v2 pattern: onDocumentCreated/onDocumentUpdated from firebase-functions/v2/firestore"
  - "Stale token cleanup: check error code after sendEachForMulticast, delete invalid tokens"

requirements-completed: [CHAT-03, CHAT-04]

# Metrics
duration: 3min
completed: 2026-03-27
---

# Phase 3 Plan 4: Cloud Functions for Push Notifications Summary

**Firebase Cloud Functions (Node.js/TypeScript) with two Firestore triggers: onMessageCreated sends FCM to chat recipients with unread count increment, onRequestAccepted notifies both parties on ride match acceptance**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-27T07:05:40Z
- **Completed:** 2026-03-27T07:09:31Z
- **Tasks:** 2 (1 auto + 1 checkpoint auto-approved)
- **Files modified:** 8

## Accomplishments
- Created deployable Cloud Functions project in functions/ directory with TypeScript compilation
- onMessageCreated sends FCM push notification to chat recipient (not sender) and atomically increments unread count
- onRequestAccepted sends FCM to both requester and poster when a join request is accepted, with ride context in payload
- Both functions handle stale FCM token cleanup automatically (removes invalid/unregistered tokens)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Cloud Functions Node.js project with notification triggers** - `9919a2b` (feat)
2. **Task 2: Verify Cloud Functions and deployment readiness** - auto-approved (checkpoint:human-verify)

## Files Created/Modified
- `functions/package.json` - Node.js project config with firebase-functions ^6.3.0 and firebase-admin ^13.0.0
- `functions/tsconfig.json` - TypeScript compiler config targeting es2022 with strict mode
- `functions/.eslintrc.js` - ESLint config with TypeScript plugin
- `functions/src/index.ts` - Firebase Admin init and function exports
- `functions/src/onMessageCreated.ts` - Firestore trigger on message creation: FCM to recipient, unread count increment, stale token cleanup
- `functions/src/onRequestAccepted.ts` - Firestore trigger on join request status update: FCM to both parties with ride context
- `.gitignore` - Added functions/lib/ and functions/node_modules/ exclusions

## Decisions Made
- Used `FieldValue.increment(1)` for atomic unread count update instead of read-then-write pattern, avoiding race conditions
- Extracted `sendNotificationToStudent` helper function in onRequestAccepted to share token fetch, send, and cleanup logic
- Handled both nested (`origin.address`) and flat (`originAddress`) field paths when reading ride documents, since the Flutter RideRepository stores addresses in nested geo maps
- Skip system messages in onMessageCreated to avoid sending notifications for automated messages

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Handled nested geo map field paths for ride addresses**
- **Found during:** Task 1
- **Issue:** Plan referenced `originAddress` and `destinationAddress` as flat fields on ride documents, but the Flutter RideRepository stores them as `origin.address` and `destination.address` in nested geo maps
- **Fix:** Added fallback field path resolution: `rideData?.origin?.address ?? rideData?.originAddress`
- **Files modified:** functions/src/onRequestAccepted.ts
- **Verification:** TypeScript compiles without errors
- **Committed in:** 9919a2b

**2. [Rule 2 - Missing Critical] Skip system messages in onMessageCreated**
- **Found during:** Task 1
- **Issue:** System messages (type "system", empty senderId) would trigger spurious notifications with no meaningful sender
- **Fix:** Added early return when senderId is empty or type is "system"
- **Files modified:** functions/src/onMessageCreated.ts
- **Verification:** TypeScript compiles, logic verified by code review
- **Committed in:** 9919a2b

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing critical)
**Impact on plan:** Both fixes necessary for correctness. No scope creep.

## Issues Encountered
None

## User Setup Required

**External services require manual configuration** for deployment:
- **Firebase Blaze plan:** Required for Cloud Functions deployment. Firebase Console -> Project Settings -> Usage and billing -> Modify plan
- **Firebase CLI:** Required for deployment. Install via `npm install -g firebase-tools && firebase login`
- **Note:** The app works fully without deploying these functions. Chat works via Firestore real-time listeners, departure reminders work via flutter_local_notifications. Cloud Functions add push notifications as an enhancement.

## Next Phase Readiness
- Phase 3 (Chat & Notifications) is now complete
- All four plans delivered: Firestore chat models/repository, chat UI with phone sharing, notification services, and Cloud Functions
- Deployment of Cloud Functions requires Blaze plan upgrade (additive enhancement, not blocking)
- Ready for Phase 4 (UI polish / Play Store readiness)

---
*Phase: 03-chat-notifications*
*Completed: 2026-03-27*
