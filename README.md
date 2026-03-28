# TagMe

A mobile app for students in Bangladesh to find ride-sharing partners. See nearby peers on a map, post or search rides, match with compatible riders, chat, and split fares.

## Features

- **Interactive Map** — See nearby students with their name, photo, university, route, and transport type
- **Post & Search Rides** — Create rides or find existing ones by route, time, and transport preference
- **Transport Types** — Rickshaw, bike, bus, car, CNG + optional Pathao/Uber/Obhai tags
- **Smart Matching** — Proximity-based matching by origin, destination, and time overlap
- **Recurring Schedules** — Set weekly class commute patterns (MWF, TTh) and auto-post rides
- **In-App Chat** — Coordinate with matched riders, optionally share phone numbers
- **Fare Splitting** — Estimated cost per transport type, cost-per-person split, and running tab tracker
- **Gender Preference** — Safety-first matching preference for co-riders

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging)
- **Maps:** flutter_map + OpenStreetMap (free, no paid APIs)
- **State Management:** Riverpod
- **Routing:** OpenRouteService API

## Getting Started

See [CONTRIBUTING.md](CONTRIBUTING.md) for full setup instructions.

```bash
git clone https://github.com/EhsanulHaqueSiam/tagme.git
cd tagme
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
```

## License

MIT
