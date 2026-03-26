# TagMe

## What This Is

TagMe is a mobile app for students in Bangladesh to find ride-sharing partners. Students see nearby peers on a map, post or search rides along their route, set transport preferences (rickshaw, bike, bus, car, CNG, plus optional Pathao/Uber/Obhai), match with compatible riders, coordinate via in-app chat, and split fares. Built with Flutter and Firebase, targeting Play Store release.

## Core Value

Students can quickly find verified fellow students heading the same way and share a ride — making commuting cheaper, safer, and more social.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Students can see nearby students on an interactive map with name, photo, university, route, and transport type
- [ ] Students can post a ride with route, time, and transport preference
- [ ] Students can search for rides matching their route and preferences
- [ ] Students can set transport preferences: rickshaw, bike, bus, car, CNG, Pathao, Uber, Obhai
- [ ] Students can match with compatible riders heading the same direction
- [ ] Students can chat in-app with matched riders and optionally share phone numbers
- [ ] Students can split fare costs through the app with estimated cost per person
- [ ] Students can sign up and create a profile with name, photo, and university
- [ ] App works across all cities in Bangladesh
- [ ] App is polished and Play Store ready

### Out of Scope

- Advanced student verification (ID + email + face recognition) — complex, deferred after core map/matching is solid
- Payment gateway integration — fare splitting is calculation/tracking only, no in-app payments for v1
- iOS release — Android/Play Store first
- Admin dashboard — not needed for v1
- Ride history analytics — defer to v2
- Rating/review system — defer to v2

## Context

- Target users: university and college students across Bangladesh
- Transport landscape: rickshaws, buses, CNGs, bikes, cars are common; Pathao, Uber, Obhai are popular ride-hailing apps students already use
- Bangladesh-specific: Dhaka traffic makes ride-sharing highly valuable; university density makes student matching viable
- Must use free-tier services: Firebase free tier, free/open-source map solutions (OpenStreetMap, Mapbox free tier, or similar)
- Flutter for cross-platform mobile development
- The name "TagMe" is the final brand — design and identity should build around it

## Constraints

- **Tech stack**: Flutter + Firebase — user decision, non-negotiable
- **Cost**: All services must have free tiers sufficient for MVP — no paid APIs or services
- **Maps**: Must use free map solution (OpenStreetMap/Leaflet, Mapbox free tier, or similar)
- **Platform**: Android first, Play Store release target
- **Region**: Bangladesh-focused — maps, transport types, and UX tailored for BD students

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter + Firebase | User preference, free tier, fast development | — Pending |
| Defer student verification | Complex (ID + email + face), focus on core map/matching first | — Pending |
| Free maps only | Budget constraint, sufficient free options exist | — Pending |
| Android/Play Store first | Primary market, simpler release process | — Pending |
| TagMe as final brand | User confirmed — design identity around it | — Pending |
| In-app chat + phone sharing | Both for flexibility — chat for quick coordination, phone for fallback | — Pending |
| Fare splitting (calculation only) | Show cost estimates, no actual payment processing in v1 | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-27 after initialization*
