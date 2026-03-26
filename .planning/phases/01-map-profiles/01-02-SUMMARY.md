---
phase: 01-map-profiles
plan: 02
subsystem: profile
tags: [flutter, riverpod, firestore, shared_preferences, image_picker, material3, form-widgets]

# Dependency graph
requires:
  - phase: 01-map-profiles/01
    provides: Student Freezed model, GoRouter with 4 routes, app theme and design constants
provides:
  - ProfileRepository with Firestore CRUD on students collection
  - ProfileNotifier Riverpod provider with async load/save
  - hasProfileProvider for router redirect guard
  - ProfileSetupScreen with avatar, name, university dropdown, gender selector, save button
  - ProfileEditScreen with pre-populated fields and Update Profile button
  - AvatarPicker widget with image_picker integration
  - UniversityDropdown widget with searchable filtered list
  - GenderSelector widget using Material 3 SegmentedButton
affects: [01-03, 01-04]

# Tech tracking
tech-stack:
  added: [shared_preferences]
  patterns: [firestore-repository-pattern, riverpod-async-notifier, form-validation-pattern, overlay-dropdown-pattern]

key-files:
  created:
    - lib/features/profile/data/repositories/profile_repository.dart
    - lib/features/profile/providers/profile_provider.dart
    - lib/features/profile/presentation/screens/profile_setup_screen.dart
    - lib/features/profile/presentation/screens/profile_edit_screen.dart
    - lib/features/profile/presentation/widgets/avatar_picker.dart
    - lib/features/profile/presentation/widgets/university_dropdown.dart
    - lib/features/profile/presentation/widgets/gender_selector.dart
  modified:
    - pubspec.yaml
    - lib/app/router.dart

key-decisions:
  - "Used shared_preferences for local profile ID persistence (simpler than Firestore query for v1 without auth)"
  - "ProfileRepository.saveProfile returns document ID for local persistence"
  - "Generated Riverpod provider name is profileProvider (not profileNotifierProvider) due to Riverpod 3.x code generation naming convention"
  - "UniversityDropdown uses Overlay for dropdown rendering instead of DropdownButton for custom search behavior"
  - "Used AsyncValue.value instead of valueOrNull (not available in Riverpod 3.1.0)"

patterns-established:
  - "Firestore repository pattern: class with FirebaseFirestore instance, collection reference getter, CRUD methods"
  - "Riverpod AsyncNotifier pattern: build() loads initial state, action methods use AsyncValue.guard()"
  - "Form widget pattern: ConsumerStatefulWidget with _isFormValid getter controlling save button"
  - "Searchable dropdown with Overlay: CompositedTransformTarget/Follower for positioning"

requirements-completed: [PROF-01, PROF-02]

# Metrics
duration: 6min
completed: 2026-03-27
---

# Phase 01 Plan 02: Profile Feature Summary

**Firestore profile repository with Riverpod state management, profile setup/edit screens with avatar picker, searchable university dropdown, and gender segmented button**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-26T22:36:22Z
- **Completed:** 2026-03-26T22:43:08Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- ProfileRepository performs full Firestore CRUD on students collection with serverTimestamp and local ID persistence via shared_preferences
- ProfileNotifier manages async profile state with load/save operations, hasProfileProvider returns profile existence
- Profile setup screen with avatar picker, name field, searchable university dropdown, gender segmented button, and save button with disabled/loading states
- Profile edit screen mirrors setup with pre-populated fields, "Edit Profile" title, and "Update Profile" button
- Router redirect guard wires hasProfileProvider to redirect to /profile-setup when no profile exists

## Task Commits

Each task was committed atomically:

1. **Task 1: Profile repository and Riverpod provider** - `ad18869` (feat)
2. **Task 2: Profile setup screen, edit screen, and form widgets** - `042ebaa` (feat)

## Files Created/Modified
- `lib/features/profile/data/repositories/profile_repository.dart` - Firestore CRUD for student profiles with serverTimestamp
- `lib/features/profile/providers/profile_provider.dart` - ProfileNotifier async state + hasProfileProvider
- `lib/features/profile/presentation/screens/profile_setup_screen.dart` - Profile creation form with all UI-SPEC sections
- `lib/features/profile/presentation/screens/profile_edit_screen.dart` - Profile editing with pre-populated fields
- `lib/features/profile/presentation/widgets/avatar_picker.dart` - 96px circular avatar with camera overlay and image_picker
- `lib/features/profile/presentation/widgets/university_dropdown.dart` - Searchable dropdown filtering bdUniversities
- `lib/features/profile/presentation/widgets/gender_selector.dart` - Material 3 SegmentedButton with male/female/other
- `pubspec.yaml` - Added shared_preferences dependency
- `lib/app/router.dart` - Wired ProfileSetupScreen, ProfileEditScreen, and hasProfile redirect guard

## Decisions Made
- Used shared_preferences for local profile ID persistence -- simpler than Firestore query for v1 without auth
- ProfileRepository.saveProfile returns document ID so provider can persist it locally
- Generated Riverpod provider name is `profileProvider` (not `profileNotifierProvider`) -- Riverpod 3.x code generation strips "Notifier" suffix
- UniversityDropdown uses Overlay widget for dropdown rendering instead of DropdownButton to support custom search/filter behavior
- Used `AsyncValue.value` instead of `valueOrNull` which is not available in the installed Riverpod 3.1.0 version

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed generated Riverpod provider name**
- **Found during:** Task 2 (Profile screens)
- **Issue:** Plan referenced `profileNotifierProvider` but Riverpod 3.x code generator produces `profileProvider` (strips "Notifier" suffix from class name)
- **Fix:** Updated all references from `profileNotifierProvider` to `profileProvider` in both screen files
- **Files modified:** profile_setup_screen.dart, profile_edit_screen.dart
- **Verification:** dart analyze reports no errors
- **Committed in:** 042ebaa (Task 2 commit)

**2. [Rule 1 - Bug] Fixed AsyncValue.valueOrNull not available**
- **Found during:** Task 2 (Router wiring)
- **Issue:** `valueOrNull` getter does not exist on AsyncValue in Riverpod 3.1.0
- **Fix:** Used `AsyncValue.value` (which returns nullable T?) with null coalescing
- **Files modified:** lib/app/router.dart
- **Verification:** dart analyze reports no errors on router.dart
- **Committed in:** 042ebaa (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 bug fixes)
**Impact on plan:** Both fixes necessary for compilation. No scope creep.

## Issues Encountered
None beyond the auto-fixed deviations above.

## Known Stubs
- `lib/app/router.dart:72-89` - _PlaceholderScreen class remains (unused, may be removed by another plan)
- Profile photo upload to Firebase Storage not implemented (photoUrl stores local file path only) -- requires Blaze plan billing; blocked by known blocker in STATE.md

## User Setup Required
None - no external service configuration required for this plan.

## Next Phase Readiness
- Profile repository and providers ready for map screen to query student data (Plan 03/04)
- Router correctly redirects to profile-setup when no profile exists
- Profile photo upload to Firebase Storage deferred until Blaze plan billing is configured (known blocker)
- hasProfileProvider available for any component that needs to check profile existence

## Self-Check: PASSED

All 7 created files verified present. Both task commits (ad18869, 042ebaa) verified in git log.

---
*Phase: 01-map-profiles*
*Completed: 2026-03-27*
