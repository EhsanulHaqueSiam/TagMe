---
phase: 05-live-location-sharing-google-maps-share-and-free-map-features
plan: 01
subsystem: chat, infra
tags: [share_plus, AGP, firestore-rules, freezed, location-sharing, android-intents]

# Dependency graph
requires:
  - phase: 03-chat-notifications
    provides: Message model and ChatRepository for chat functionality
provides:
  - Extended Message model with latitude/longitude/locationLabel fields
  - ChatRepository location_shared message type support
  - Android intent queries for Google Maps geo/navigation/https
  - Firestore security rules for liveLocations subcollection
  - share_plus dependency for sharing functionality
affects: [05-02, 05-03, 05-04, 05-05, 05-06]

# Tech tracking
tech-stack:
  added: [share_plus ^12.0.1, AGP 8.12.1]
  patterns: [conditional field persistence in Firestore batch writes, multi-type message model extension]

key-files:
  created: [firestore.rules]
  modified: [android/settings.gradle.kts, pubspec.yaml, android/app/src/main/AndroidManifest.xml, lib/features/chat/data/models/message.dart, lib/features/chat/data/repositories/chat_repository.dart]

key-decisions:
  - "Conditional Firestore field writes: location fields only persisted when non-null to avoid empty fields"

patterns-established:
  - "Message type extension: add nullable fields with type-specific comment, handle in batch.set with conditional inclusion"

requirements-completed: [LOC-01, LOC-03, LOC-04]

# Metrics
duration: 3min
completed: 2026-03-29
---

# Phase 05 Plan 01: Data Foundation Summary

**share_plus dependency with AGP bump, Message model extended with location fields, Firestore liveLocations rules, and Android intent queries for Google Maps**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-28T22:10:50Z
- **Completed:** 2026-03-28T22:14:24Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Added share_plus dependency and bumped AGP from 8.11.1 to 8.12.1 for build compatibility
- Extended Message model with latitude, longitude, and locationLabel fields for location_shared type
- Updated ChatRepository.sendMessage to accept and persist location data conditionally
- Configured Android manifest with geo:, google.navigation:, and https: intent queries for Android 11+
- Added Firestore security rules for conversations/liveLocations subcollection

## Task Commits

Each task was committed atomically:

1. **Task 1: Add share_plus, bump AGP, configure AndroidManifest, add Firestore rules** - `59525b6` (chore)
2. **Task 2: Extend Message model with location fields and update ChatRepository** - `6aa58c4` (feat)

## Files Created/Modified
- `android/settings.gradle.kts` - Bumped AGP version from 8.11.1 to 8.12.1
- `pubspec.yaml` - Added share_plus dependency
- `android/app/src/main/AndroidManifest.xml` - Added geo:, google.navigation:, https: intent queries
- `firestore.rules` - Created with liveLocations subcollection rules
- `lib/features/chat/data/models/message.dart` - Added latitude, longitude, locationLabel fields
- `lib/features/chat/data/repositories/chat_repository.dart` - Extended sendMessage with location params

## Decisions Made
- Conditional Firestore field writes: location fields only persisted when non-null to keep documents clean

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Generated files (message.freezed.dart, message.g.dart) are gitignored so only source files were committed; codegen outputs regenerate on build

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Message model and ChatRepository ready for location sharing UI (Plan 02+)
- Android intents ready for Google Maps deep linking features
- Firestore rules ready for live location tracking subcollection
- share_plus available for share ride/location functionality

---
*Phase: 05-live-location-sharing-google-maps-share-and-free-map-features*
*Completed: 2026-03-29*
