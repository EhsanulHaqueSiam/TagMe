# Roadmap: TagMe

## Overview

TagMe delivers a student ride-sharing partner finder for Bangladesh in four phases. Phase 1 establishes the visual foundation -- Flutter app with interactive map, local profiles, and nearby student markers. Phase 2 builds the core value: ride posting, searching, proximity-based matching, fare estimation, and gender preferences. Phase 3 adds the coordination layer with in-app chat and push notifications. Phase 4 hardens everything for Play Store submission. Auth is deferred to v2; v1 uses a simple local/mock profile setup so development can focus on the map and ride-matching experience.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Map & Profiles** - Flutter shell with interactive map, local profiles, and nearby student markers
- [ ] **Phase 2: Rides & Matching** - Ride posting, searching, proximity matching, fare estimation, and preferences
- [ ] **Phase 3: Chat & Notifications** - In-app messaging with matched riders and push notifications
- [ ] **Phase 4: Play Store Launch** - UI polish, policy compliance, and Play Store submission

## Phase Details

### Phase 1: Map & Profiles
**Goal**: Students can see themselves and nearby students on an interactive map with profile information
**Depends on**: Nothing (first phase)
**Requirements**: MAP-01, MAP-02, MAP-03, MAP-04, PROF-01, PROF-02, PROF-03
**Success Criteria** (what must be TRUE):
  1. Student opens the app and sees an interactive map centered on their current GPS location
  2. Student can create a local profile with name, photo, university, and gender
  3. Student can see nearby students as markers on the map showing name, photo, university, route, and transport type
  4. Student can tap a map marker and view another student's profile
  5. Map renders using free OpenStreetMap tiles with no paid API keys, and location updates only in foreground
**Plans**: 4 plans
Plans:
- [x] 01-01-PLAN.md -- Project foundation: Flutter scaffold, dependencies, models, theme, routing
- [x] 01-02-PLAN.md -- Profile feature: Firestore repository, setup screen, edit screen, form widgets
- [x] 01-03-PLAN.md -- Map and location: permission screen, GPS providers, map screen with OSM tiles
- [x] 01-04-PLAN.md -- Nearby students: geo query provider, markers, clustering, bottom sheet, seed data
**UI hint**: yes

### Phase 2: Rides & Matching
**Goal**: Students can post rides, search for compatible rides, match with co-riders, and see fare estimates
**Depends on**: Phase 1
**Requirements**: RIDE-01, RIDE-02, RIDE-03, RIDE-04, RIDE-05, RIDE-06, RIDE-07, RIDE-08, RIDE-09, FARE-01, FARE-02, FARE-03, FARE-04, PREF-01, PREF-02
**Success Criteria** (what must be TRUE):
  1. Student can post a ride with origin, destination, departure time, transport type (rickshaw/bike/bus/car/CNG), optional ride-hailing tag (Pathao/Uber/Obhai), and available seats
  2. Student can search for rides and see results filtered by route proximity, time window, and transport type
  3. System matches rides by origin proximity, destination proximity, and time overlap -- student can accept or decline matches
  4. Student can set up a recurring ride schedule and the system auto-posts rides based on that schedule
  5. Student can see estimated fare per transport type and cost-per-person split, view fare history, and track outstanding balances with co-riders
**Plans**: 5 plans
Plans:
- [x] 02-01-PLAN.md -- Data foundation: Freezed models, TransportType enum, ORS route service, fare calculator, repositories, bottom nav shell
- [x] 02-02-PLAN.md -- Ride posting: PostRideScreen form, MapPinPickerScreen, transport selector, seat stepper, ride providers
- [x] 02-03-PLAN.md -- Rides list and search: RideCard, RidesTabScreen (Nearby/My Rides), RideSearchScreen with matching
- [ ] 02-04-PLAN.md -- Ride detail and join requests: RideDetailScreen, JoinRequestsScreen, accept/decline with atomic seat update
- [ ] 02-05-PLAN.md -- Schedules and fares: RecurringScheduleScreen, auto-post logic, FareHistoryScreen, balance tracking
**UI hint**: yes

### Phase 3: Chat & Notifications
**Goal**: Matched students can coordinate rides through in-app messaging and receive timely push notifications
**Depends on**: Phase 2
**Requirements**: CHAT-01, CHAT-02, CHAT-03, CHAT-04, CHAT-05
**Success Criteria** (what must be TRUE):
  1. Student can open an in-app chat with any matched rider and exchange messages in real time
  2. Student can optionally share their phone number within a chat conversation
  3. Student receives push notifications for new ride matches, new chat messages, and upcoming departure reminders
**Plans**: TBD
**UI hint**: yes

### Phase 4: Play Store Launch
**Goal**: App is polished, policy-compliant, and successfully submitted to Google Play Store
**Depends on**: Phase 3
**Requirements**: STORE-01, STORE-02, STORE-03
**Success Criteria** (what must be TRUE):
  1. App has a polished, consistent UI across all screens suitable for a Play Store listing
  2. App includes a hosted privacy policy and terms of service accessible from within the app
  3. App passes Google Play pre-launch report with no crashes and no policy violations (no background location, correct targetSdk, AAB format)
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Map & Profiles | 4/4 | Complete | 2026-03-27 |
| 2. Rides & Matching | 0/5 | Planning complete | - |
| 3. Chat & Notifications | 0/TBD | Not started | - |
| 4. Play Store Launch | 0/TBD | Not started | - |
