<!-- GSD:project-start source:PROJECT.md -->
## Project

**TagMe**

TagMe is a mobile app for students in Bangladesh to find ride-sharing partners. Students see nearby peers on a map, post or search rides along their route, set transport preferences (rickshaw, bike, bus, car, CNG, plus optional Pathao/Uber/Obhai), match with compatible riders, coordinate via in-app chat, and split fares. Built with Flutter and Firebase, targeting Play Store release.

**Core Value:** Students can quickly find verified fellow students heading the same way and share a ride — making commuting cheaper, safer, and more social.

### Constraints

- **Tech stack**: Flutter + Firebase — user decision, non-negotiable
- **Cost**: All services must have free tiers sufficient for MVP — no paid APIs or services
- **Maps**: Must use free map solution (OpenStreetMap/Leaflet, Mapbox free tier, or similar)
- **Platform**: Android first, Play Store release target
- **Region**: Bangladesh-focused — maps, transport types, and UX tailored for BD students
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Recommended Stack
### Core Framework
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Flutter | 3.x (latest stable) | Cross-platform mobile framework | Non-negotiable project constraint. Android-first, but Flutter keeps iOS option open for v2. | HIGH |
| Dart | 3.x (latest stable) | Programming language | Ships with Flutter. Sound null safety, strong typing. | HIGH |
### Backend & Database
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Firebase Core | ^4.6.0 | Firebase initialization | Required base for all Firebase services. | HIGH |
| Cloud Firestore | ^6.2.0 | Primary database | Real-time sync via WebSockets (no polling), offline persistence, geohash-based geo queries, generous free tier (50K reads/20K writes per day). Perfect for chat + location data. | HIGH |
| Firebase Auth | ^6.3.0 | Authentication | Email/password + Google Sign-In. Free, handles session management. Phone auth also available (useful in BD where phone numbers are primary identifiers). | HIGH |
| Firebase Storage | ^13.2.0 | File storage | Profile photos, chat image attachments. 5GB free on Spark plan. | HIGH |
| Firebase Messaging (FCM) | ^16.1.3 | Push notifications | Free push notifications for ride match alerts, chat messages, ride reminders. No per-message cost. | HIGH |
| Cloud Functions | via Firebase CLI | Server-side logic | Matching algorithms, notification triggers, Firestore document change hooks. Free tier: 2M invocations/month. | HIGH |
### Maps & Location
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| flutter_map | ^8.2.2 | Map widget | Free, vendor-neutral, pure-Flutter, no API key needed for the widget itself. Works with any tile provider. No native platform code -- consistent across platforms. 2.1K+ likes on pub.dev. | HIGH |
| latlong2 | ^0.9.1 | Lat/lng data types | Required by flutter_map for coordinate operations. Lightweight, well-maintained. | HIGH |
| flutter_map_marker_cluster | ^8.2.2 | Marker clustering | When showing many nearby students on the map, clustering prevents visual clutter. Compatible with flutter_map 8.x. Animated clustering. | HIGH |
| geolocator | ^14.0.2 | Device GPS location | The standard Flutter geolocation package. Cross-platform, supports continuous location streams, distance/bearing calculations. By Baseflow (reputable publisher). | HIGH |
| geoflutterfire_plus | ^0.0.34 | Firestore geo queries | Query Firestore documents by geographic radius using geohashes. Fork of GeoFlutterFire, actively maintained (last update 2 months ago). Essential for "find nearby students" feature. | MEDIUM |
| geocoding | ^4.0.0 | Address lookup | Convert coordinates to human-readable addresses and vice versa. By Baseflow. For displaying location names in ride posts. | HIGH |
| permission_handler | ^12.0.1 | Runtime permissions | Handles location permission requests on Android/iOS. Clean API for checking and requesting permissions. | HIGH |
### Tile Provider (Map Tiles)
| Provider | Cost | Limits | When to Use |
|----------|------|--------|-------------|
| OpenStreetMap (dev only) | Free | 1 req/s, must set User-Agent, not for production apps | Development and prototyping only |
| Stadia Maps | Free tier available | 200K tiles/month free | Good free tier for small apps, no credit card required |
| MapTiler | Free tier | 100K tiles/month free | Alternative free option |
| CartoDB/CARTO | Free | Generous free tier | Simple basemaps, limited styles |
### Routing & Directions
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| open_route_service | ^1.2.7 | Route directions API | Free routing API -- 2,000 direction requests/day on free plan. Supports car, bicycle, walking. Returns polyline coordinates that flutter_map can render natively via PolylineLayer. Alternative to Google Directions API (which requires billing). | MEDIUM |
### Geocoding (Address Search)
| Technology | Purpose | Limits | Confidence |
|------------|---------|--------|------------|
| Nominatim (OSM) | Forward/reverse geocoding | 1 request/second, must set User-Agent | MEDIUM |
| OpenRouteService Geocoding | Pelias-based geocoding | Included in ORS free tier | MEDIUM |
### State Management
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| flutter_riverpod | ^3.3.1 | State management | 2025/2026 community consensus: Riverpod is the default for startups and consumer apps. Compile-time safety, less boilerplate than BLoC, excellent testing support. This is a student app, not enterprise banking -- Riverpod's simplicity wins over BLoC's ceremony. | HIGH |
| riverpod_annotation | ^4.0.2 | Code generation for Riverpod | Reduces boilerplate further with `@riverpod` annotations. The modern way to write Riverpod providers. | HIGH |
| riverpod_generator | ^4.0.3 | Riverpod code generator | Generates provider code from annotations. Pairs with riverpod_annotation. | HIGH |
### Navigation
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| go_router | ^17.1.0 | Declarative routing | Official Flutter team recommendation. Deep linking support (useful for "share ride" links), guard-based auth redirects, nested navigation. | HIGH |
### Chat & Messaging
| Approach | Why |
|----------|-----|
| Firestore real-time listeners | Firestore's `snapshots()` provides real-time message delivery without polling. WebSocket-based, instant updates. Free within daily quota. |
| FCM for background notifications | When app is closed, FCM pushes chat notification. Free, no per-message cost. |
### Data Modeling & Serialization
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| freezed | ^3.2.5 | Immutable data classes | Generated `copyWith`, `==`, `toString`, JSON serialization, union types. Eliminates boilerplate for Firestore document models. | HIGH |
| json_serializable | ^6.13.1 | JSON serialization | `toJson`/`fromJson` code generation. Works with freezed for Firestore document mapping. | HIGH |
| build_runner | ^2.13.1 | Code generation runner | Runs freezed and json_serializable generators. Dev dependency. | HIGH |
### Supporting Libraries
| Library | Version | Purpose | When to Use | Confidence |
|---------|---------|---------|-------------|------------|
| cached_network_image | ^3.4.1 | Image caching | Profile photos, university logos. Caches network images to disk. | HIGH |
| image_picker | ^1.2.1 | Camera/gallery picker | Profile photo upload. Official Flutter plugin. | HIGH |
| uuid | ^4.5.3 | Unique ID generation | Ride IDs, message IDs, any document IDs not auto-generated by Firestore. | HIGH |
| intl | ^0.20.2 | Date/time formatting, i18n | Format ride times in Bengali locale, currency formatting for BDT fare splitting. | HIGH |
| flutter_local_notifications | ^21.0.0 | Local notifications | Ride reminders, scheduled departure alerts. Complements FCM for local triggers. | HIGH |
| url_launcher | latest | Open external links | "Open in Pathao/Uber" deep links, phone dialer for shared phone numbers. | HIGH |
### Development & Quality
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| flutter_lints / very_good_analysis | latest | Linting | Enforce consistent code style. `very_good_analysis` is stricter and recommended. |
| mocktail | latest | Mocking | Lightweight mocking for unit tests. No codegen needed unlike mockito. |
| integration_test | Flutter SDK | Integration tests | Built into Flutter SDK. Test full user flows. |
## Alternatives Considered
| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Maps widget | flutter_map | google_maps_flutter | Google Maps requires API key + billing account. Violates free-tier constraint. Also uses native platform views (less pure-Flutter). |
| Maps widget | flutter_map | mapbox_gl_flutter | Mapbox changed to proprietary license in 2020. MapLibre fork exists but flutter_map is simpler, pure-Flutter, and more mature for this use case. |
| Tile provider | Stadia Maps / OSM | Google Maps tiles | Requires billing. Not free. |
| Routing API | OpenRouteService | Google Directions API | Google requires billing account. ORS is free (2K requests/day). |
| State management | Riverpod 3.x | BLoC 9.x | BLoC is better for large enterprise teams. TagMe is a single-dev student project -- Riverpod's lower boilerplate and simpler mental model is the right fit. |
| State management | Riverpod 3.x | GetX | GetX encourages anti-patterns (global mutable state, magic strings). Not recommended by Flutter community for new projects. |
| State management | Riverpod 3.x | Provider | Provider is the predecessor to Riverpod and is now in maintenance mode. Riverpod fixes Provider's limitations (no context dependency, compile-time safety). |
| Chat | Firestore native | Stream Chat SDK | Stream charges per MAU after free tier. Overkill for simple 1:1 ride coordination messages. |
| Chat | Firestore native | Firebase Realtime DB | Firestore is the modern replacement. Realtime DB lacks compound queries, offline sync is weaker, and you'd need two databases. |
| Geo queries | geoflutterfire_plus | Manual geohash | geoflutterfire_plus handles the geohash math, bounding box queries, and distance filtering. Rolling your own is error-prone. |
| Notifications | FCM + flutter_local_notifications | OneSignal | OneSignal adds a third-party dependency and SDK. FCM is already part of Firebase stack -- zero additional cost or integration. |
| Navigation | go_router | auto_route | go_router is officially maintained by Flutter team. auto_route uses more codegen. For this app's navigation complexity, go_router is sufficient. |
## Bangladesh-Specific Considerations
### OpenStreetMap Coverage in Bangladesh
- **Coverage quality:** HIGH for Dhaka and major cities. The OpenStreetMap Bangladesh Foundation (OSMBDF) is active. Pathao Ltd collaborated with BHOOT (Bangladesh Humanitarian OpenStreetMap Operation Team) on "Map Your City" covering Dhaka, Chittagong, Sylhet, Khulna, Rajshahi, Comilla, Mymensingh, Jessore.
- **Implication:** OSM-based tiles will have good coverage for university-dense areas in Bangladesh. flutter_map + OSM tiles is a strong choice specifically for this market.
- **Source:** [OpenStreetMap Bangladesh Foundation](https://osmbdf.org/), [HOT OSM Bangladesh](https://www.hotosm.org/projects/openstreetmap-bangladesh)
### Currency & Locale
- Use `intl` package with `bn_BD` locale for Bengali number/currency formatting
- Fare amounts in BDT (Bangladeshi Taka) -- symbol: `৳`
- Transport names should support both English and Bengali labels
### Transport Types
- Rickshaw, CNG, Bus, Bike, Car (local transport)
- Pathao, Uber, Obhai (ride-hailing apps -- deep-linkable via url_launcher)
## Firebase Free Tier (Spark Plan) Budget
| Service | Free Limit | TagMe Usage Estimate (100 users) | Risk |
|---------|------------|----------------------------------|------|
| Firestore reads | 50K/day | ~20K (map queries + chat) | LOW |
| Firestore writes | 20K/day | ~5K (location updates + messages) | LOW |
| Firestore deletes | 20K/day | ~500 | LOW |
| Storage | 5 GB | ~1 GB (profile photos) | LOW |
| Auth | 10K verifications/month | ~200 | LOW |
| Cloud Functions | 2M invocations/month | ~50K | LOW |
| FCM | Unlimited | N/A | NONE |
| Hosting | 10 GB/month | Not needed (mobile app) | NONE |
## Installation
# Create project
# Core Firebase
# Maps & Location
# Routing
# State Management & Navigation
# Data Modeling
# Supporting
# Dev Dependencies
## Firebase Setup
# Install Firebase CLI
# Configure Firebase project
# This generates firebase_options.dart automatically
## Key Version Pins (verified from pub.dev, March 2026)
| Package | Verified Version | Last Published |
|---------|-----------------|----------------|
| flutter_map | 8.2.2 | ~6 months ago |
| geolocator | 14.0.2 | ~8 months ago |
| geoflutterfire_plus | 0.0.34 | ~2 months ago |
| flutter_riverpod | 3.3.1 | ~17 days ago |
| firebase_core | 4.6.0 | ~3 days ago |
| cloud_firestore | 6.2.0 | ~3 days ago |
| firebase_auth | 6.3.0 | ~3 days ago |
| go_router | 17.1.0 | ~51 days ago |
| freezed | 3.2.5 | ~51 days ago |
| flutter_local_notifications | 21.0.0 | ~21 days ago |
## Sources
- [flutter_map on pub.dev](https://pub.dev/packages/flutter_map) -- verified v8.2.2
- [flutter_map docs](https://docs.fleaflet.dev/) -- tile providers, polyline layer
- [geolocator on pub.dev](https://pub.dev/packages/geolocator) -- verified v14.0.2
- [geoflutterfire_plus on pub.dev](https://pub.dev/packages/geoflutterfire_plus) -- verified v0.0.34
- [flutter_riverpod on pub.dev](https://pub.dev/packages/flutter_riverpod) -- verified v3.3.1
- [Firebase pricing](https://firebase.google.com/pricing) -- Spark plan limits
- [OpenRouteService restrictions](https://openrouteservice.org/restrictions/) -- 2K directions/day free
- [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/) -- 1 req/s limit
- [OSM Bangladesh Foundation](https://osmbdf.org/) -- BD coverage quality
- [Riverpod vs BLoC 2026](https://medium.com/@flutter-app/state-management-in-2026-is-riverpod-replacing-bloc-40e58adcb70f) -- state management consensus
- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations) -- official patterns
- [Firebase Firestore geo queries](https://firebase.google.com/docs/firestore/solutions/geoqueries) -- geohash approach
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
