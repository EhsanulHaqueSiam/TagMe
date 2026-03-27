# Requirements: TagMe

**Defined:** 2026-03-27
**Core Value:** Students can quickly find verified fellow students heading the same way and share a ride

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Map & Location

- [x] **MAP-01**: Student can see an interactive map centered on their current location
- [x] **MAP-02**: Student can see nearby students on the map with name, photo, university, route, and transport type
- [x] **MAP-03**: Map uses free OpenStreetMap tiles with flutter_map (no paid APIs)
- [x] **MAP-04**: Location updates only in foreground (compliant with Play Store policy)

### Profiles

- [x] **PROF-01**: Student can create a profile with name, photo, and university
- [x] **PROF-02**: Student can set gender for gender preference matching
- [x] **PROF-03**: Student can view other students' profiles from map pins or ride cards

### Rides

- [x] **RIDE-01**: Student can post a ride with origin, destination, departure time, and transport type
- [x] **RIDE-02**: Student can search for rides by route, time, and transport type
- [x] **RIDE-03**: Student can select transport type: rickshaw, bike, bus, car, CNG
- [x] **RIDE-04**: Student can optionally tag ride-hailing services: Pathao, Uber, Obhai
- [x] **RIDE-05**: Student can set available seats based on transport capacity
- [x] **RIDE-06**: System matches rides by proximity (origin near origin, destination near destination, time overlap)
- [x] **RIDE-07**: Student can accept or decline a ride match
- [x] **RIDE-08**: Student can set recurring ride schedule (e.g., MWF at 8am, same route)
- [x] **RIDE-09**: System auto-posts rides based on recurring schedule

### Communication

- [x] **CHAT-01**: Student can chat in-app with matched riders
- [x] **CHAT-02**: Student can optionally share phone number in chat
- [x] **CHAT-03**: Student receives push notification for new ride matches
- [x] **CHAT-04**: Student receives push notification for new chat messages
- [x] **CHAT-05**: Student receives push notification for upcoming departure reminders

### Fare

- [x] **FARE-01**: App estimates fare per transport type based on route distance
- [x] **FARE-02**: App calculates cost-per-person split based on number of riders
- [x] **FARE-03**: App tracks fare splits across multiple rides (running tab between frequent co-riders)
- [x] **FARE-04**: Student can view fare history and outstanding balances with co-riders

### Matching Preferences

- [x] **PREF-01**: Student can set gender preference for co-riders (prefer same gender)
- [x] **PREF-02**: Matching algorithm weighs gender preference when ranking matches

### Play Store Readiness

- [ ] **STORE-01**: App has polished UI suitable for Play Store listing
- [ ] **STORE-02**: App includes privacy policy and terms of service
- [ ] **STORE-03**: App passes Google Play pre-launch report (no crashes, no policy violations)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Authentication

- **AUTH-01**: Student can sign up with email and password
- **AUTH-02**: Student can log in and stay logged in across sessions
- **AUTH-03**: Student can reset password via email link
- **AUTH-04**: Student identity verified via university email domain
- **AUTH-05**: Student identity verified via student ID card photo upload
- **AUTH-06**: Student identity verified via face recognition

### Social

- **SOCL-01**: Student can form persistent ride groups with regular partners
- **SOCL-02**: Ride groups have shared group chat
- **SOCL-03**: Student can filter rides by same university or department

### Advanced Matching

- **MATCH-01**: Route-based matching using full path overlap (not just origin/destination)
- **MATCH-02**: Smart matching using ride history and preferences

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| In-app payment processing (bKash/Nagad) | Complex, requires business registration, compliance. Students pay each other directly. |
| Real-time GPS ride tracking | Heavy battery drain, server costs. Students can share WhatsApp live location instead. |
| Rating/review system | Toxic in peer student context. Report/block for safety only. |
| ML-based matching | Premature — needs large dataset. Simple proximity matching is sufficient. |
| Driver verification / license check | TagMe is not ride-hailing. Students share existing transport. |
| Admin dashboard | Firebase Console sufficient for MVP scale. |
| Intercity rides | Different product entirely. Focus on intra-city commute first. |
| iOS release | Android/Play Store first. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| MAP-01 | Phase 1 | Complete |
| MAP-02 | Phase 1 | Complete |
| MAP-03 | Phase 1 | Complete |
| MAP-04 | Phase 1 | Complete |
| PROF-01 | Phase 1 | Complete |
| PROF-02 | Phase 1 | Complete |
| PROF-03 | Phase 1 | Complete |
| RIDE-01 | Phase 2 | Complete |
| RIDE-02 | Phase 2 | Complete |
| RIDE-03 | Phase 2 | Complete |
| RIDE-04 | Phase 2 | Complete |
| RIDE-05 | Phase 2 | Complete |
| RIDE-06 | Phase 2 | Complete |
| RIDE-07 | Phase 2 | Complete |
| RIDE-08 | Phase 2 | Complete |
| RIDE-09 | Phase 2 | Complete |
| FARE-01 | Phase 2 | Complete |
| FARE-02 | Phase 2 | Complete |
| FARE-03 | Phase 2 | Complete |
| FARE-04 | Phase 2 | Complete |
| PREF-01 | Phase 2 | Complete |
| PREF-02 | Phase 2 | Complete |
| CHAT-01 | Phase 3 | Complete |
| CHAT-02 | Phase 3 | Complete |
| CHAT-03 | Phase 3 | Complete |
| CHAT-04 | Phase 3 | Complete |
| CHAT-05 | Phase 3 | Complete |
| STORE-01 | Phase 4 | Pending |
| STORE-02 | Phase 4 | Pending |
| STORE-03 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0

---
*Requirements defined: 2026-03-27*
*Last updated: 2026-03-27 after roadmap creation*
