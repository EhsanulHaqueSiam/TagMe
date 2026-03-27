---
phase: 03-chat-notifications
plan: 01
subsystem: chat
tags: [firestore, freezed, riverpod, firebase_messaging, flutter_local_notifications, chat]

# Dependency graph
requires:
  - phase: 02-rides-matching
    provides: "Ride and JoinRequest models, repository patterns, Riverpod provider patterns"
provides:
  - "Freezed Conversation model with participantIds, rideId, ride context, unreadCounts"
  - "Freezed Message model with senderId, senderName, text, type, phoneNumber"
  - "ChatRepository with createConversation (dedup), sendMessage (batch), streams, markAsRead"
  - "Riverpod providers: conversationList, chatMessages, totalUnreadCount, conversationDetail"
  - "Android manifest configured for flutter_local_notifications (receivers + permissions)"
  - "firebase_messaging, flutter_local_notifications, timezone, url_launcher dependencies"
affects: [03-chat-notifications]

# Tech tracking
tech-stack:
  added: [firebase_messaging, flutter_local_notifications, timezone, url_launcher]
  patterns: [firestore-conversations-subcollection, batch-write-for-messages, timestamp-to-iso8601-conversion]

key-files:
  created:
    - lib/features/chat/data/models/conversation.dart
    - lib/features/chat/data/models/message.dart
    - lib/features/chat/data/repositories/chat_repository.dart
    - lib/features/chat/providers/chat_providers.dart
  modified:
    - pubspec.yaml
    - android/app/build.gradle.kts
    - android/app/src/main/AndroidManifest.xml

key-decisions:
  - "timezone ^0.11.0 instead of ^0.10.0 (required by flutter_local_notifications 21)"
  - "Cascade batch operations (set+update) to satisfy cascade_invocations lint"
  - "Generated files (.freezed.dart, .g.dart) are gitignored -- only source committed"

patterns-established:
  - "Conversation + messages subcollection pattern for Firestore chat"
  - "Batch writes for message send + conversation metadata update"
  - "Timestamp-to-ISO8601 conversion in repository helper methods"
  - "unreadCounts map with per-participant integer tracking"

requirements-completed: [CHAT-01]

# Metrics
duration: 4min
completed: 2026-03-27
---

# Phase 3 Plan 1: Chat Data Layer Summary

**Freezed Conversation/Message models, ChatRepository with Firestore CRUD and real-time streams, Riverpod chat providers, plus firebase_messaging and flutter_local_notifications dependencies**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-27T06:46:17Z
- **Completed:** 2026-03-27T06:50:28Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Installed firebase_messaging, flutter_local_notifications, timezone, url_launcher with all dependency conflicts resolved
- Android build configured: coreLibraryDesugaring enabled, notification permissions and broadcast receivers added
- Conversation and Message Freezed models compile and generate correct fromJson/toJson
- ChatRepository implements createConversation (with dedup check), sendMessage (batch write), conversationsForStudent, messagesForConversation, markAsRead, getConversation
- Riverpod providers expose conversation list stream, message stream, total unread count, and conversation detail

## Task Commits

Each task was committed atomically:

1. **Task 1: Install dependencies and configure Android build** - `d8436af` (chore)
2. **Task 2: Create Freezed chat models and ChatRepository** - `f5d30d9` (feat)

## Files Created/Modified
- `pubspec.yaml` - Added firebase_messaging, flutter_local_notifications, timezone, url_launcher
- `android/app/build.gradle.kts` - Enabled coreLibraryDesugaring, added desugar_jdk_libs dependency
- `android/app/src/main/AndroidManifest.xml` - Added RECEIVE_BOOT_COMPLETED, POST_NOTIFICATIONS permissions and notification receivers
- `lib/features/chat/data/models/conversation.dart` - Freezed Conversation model with participantIds, rideId, ride context, unreadCounts
- `lib/features/chat/data/models/message.dart` - Freezed Message model with senderId, senderName, text, type, phoneNumber
- `lib/features/chat/data/repositories/chat_repository.dart` - Firestore CRUD with createConversation, sendMessage, streams, markAsRead
- `lib/features/chat/providers/chat_providers.dart` - Riverpod providers for conversation list, messages, unread count

## Decisions Made
- Used timezone ^0.11.0 instead of ^0.10.0 specified in plan (flutter_local_notifications 21 requires ^0.11.0)
- Generated files (.freezed.dart, .g.dart) are gitignored per project convention -- only source files committed
- Used cascade notation for batch.set+update to satisfy cascade_invocations lint rule

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed timezone version constraint**
- **Found during:** Task 1 (Install dependencies)
- **Issue:** Plan specified timezone ^0.10.0 but flutter_local_notifications ^21.0.0 requires timezone ^0.11.0
- **Fix:** Changed timezone constraint to ^0.11.0 in pubspec.yaml
- **Files modified:** pubspec.yaml
- **Verification:** flutter pub get succeeds with exit code 0
- **Committed in:** d8436af (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Minor version bump for timezone package. No scope creep.

## Issues Encountered
None beyond the timezone version conflict documented above.

## Known Stubs
None - all data layer code is fully wired to Firestore with real implementations.

## Next Phase Readiness
- Chat data layer complete: models, repository, and providers ready for UI consumption
- Plan 02 (Chat UI) can build screens against conversationListProvider, chatMessagesProvider, and ChatRepository
- Plan 03 (Notifications) can use firebase_messaging and flutter_local_notifications already installed
- Android manifest and build.gradle fully configured for notification support

## Self-Check: PASSED

All 5 created/source files verified on disk. Both commit hashes (d8436af, f5d30d9) confirmed in git log.

---
*Phase: 03-chat-notifications*
*Completed: 2026-03-27*
