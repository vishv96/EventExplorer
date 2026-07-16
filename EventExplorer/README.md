# EventExplorer

A local events explorer for iOS. Lists nearby events, shows distance from the user's current location, supports bookmarking, background refresh, and deep-links into Apple Maps for navigation.

---

## Requirements

- Xcode 16+ (Swift 6 language mode)
- iOS 17.0+ (SwiftData requirement)
- [SwiftLint](https://github.com/realm/SwiftLint) installed locally: `brew install swiftlint`

## Run Steps

1. Clone the repo and open `EventExplorer.xcodeproj`
2. Select the `EventExplorer` scheme and an iOS 17+ simulator
3. Build and run (`⌘R`)
4. On first launch, grant location permission when prompted — this enables the distance-to-event labels
5. In the Simulator, set a location via **Features → Location** (e.g. "Apple" or a Custom Location near Toronto) so distance calculation has a source

### Running Tests

`⌘U`, or Product → Test. Tests use Swift Testing (not XCTest) with an isolated in-memory `ModelContainer` per test case.

---

## Architecture

MVVM with a repository layer, protocol-based dependency injection, and SwiftData as the single source of truth.

```
┌─────────────────────────────────────────────────┐
│  Views (SwiftUI)                                │
│  EventListView · EventDetailView                │
│  reads events reactively via @Query             │
└──────────────┬──────────────────────────────────┘
               │
┌──────────────▼──────────────────────────────────┐
│  ViewModels (@Observable, @MainActor)           │
│  EventLisingViewModel — ViewState enum          │
│  (loading / contentLoaded / error)              │
└──────────────┬──────────────────────────────────┘
               │ EventRepository (protocol)
┌──────────────▼──────────────────────────────────┐
│  EventRepositoryImpl                            │
│  fetch → decode DTOs → upsert into SwiftData    │
└───────┬─────────────────────────┬───────────────┘
        │ NetworkService          │ ModelContext
┌───────▼────────┐        ┌───────▼───────────────┐
│ LiveNetwork-   │        │ SwiftData             │
│ Service        │        │ Event · Location      │
│ (Endpoint enum │        │ (single source of     │
│  + generic     │        │  truth for UI)        │
│  request<T>)   │        └───────────────────────┘
└────────────────┘
```

### Key design decisions

**SwiftData as single source of truth.** The UI reads events reactively via `@Query`; the repository's only job is keeping the store fresh from the network. This avoids the duplicate-source-of-truth problem of holding a second `[Event]` array in the ViewModel.

**DTO / model separation.** Network responses decode into plain `Codable` structs (`EventDTO`, `LocationDTO`) which map into SwiftData `@Model` classes via `toEvent()`.

**Upsert preserves local state.** On refresh, existing events are updated field-by-field rather than blindly re-inserted — deliberately excluding `isBookmarked`, so a background or pull-to-refresh never clobbers the user's bookmarks (bookmark state is a local-only concept the API knows nothing about).

**Graceful failure.** Network errors surface as a `ViewState.error` banner while the list continues showing the last persisted events from SwiftData — the user is never left with a blank screen because the network dropped.

**TTL response cache.** API responses are gated by a TTL-based cache (`EventCache`, 1h TTL) so repeated view appearances within the window don't trigger redundant network calls. Image loading uses a separate `NSCache`-backed `ImageCache` actor with its own TTL, sharing a generic `Cache` protocol with a default implementation (get/set/expiry logic written once).

---

## Feature Notes

### Location & Distance
`LiveLocationService` (behind a `LocationService` protocol for testability) wraps `CLLocationManager`. Permission is requested on the list screen's appearance rather than at cold launch — asking in context tends to convert better. Distances are formatted with `Measurement<UnitLength>` + `.measurement(usage: .road)`, which handles km/miles per the user's locale automatically.

### Maps Deep Link
The detail view embeds a MapKit `Map` for context, and a **Directions** button opens the Maps app in turn-by-turn mode via `MKMapItem.openInMaps`

### Background Refresh
`BGAppRefreshTask` via `BGTaskScheduler`, registered at app launch, with `earliestBeginDate` of 1 hour as a floor. The task re-schedules itself on each run, sets an `expirationHandler`, and always calls `setTaskCompleted`.

To test: run from Xcode, pause, and in LLDB:
```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.eventexplorer.refresh"]
```
Note: `BGTaskScheduler` has known reliability limitations on the Simulator; on-device testing is recommended.

### Mock API
Events are served from `Mocks/events.json` (10 Toronto events with ISO 8601 timestamps and real placeholder image URLs), simulating the REST endpoint using Mock network layer. 
The production network layer can be easly created by adding a new implemention of NetworkService

---

## Engineering Standards

- **Linting:** SwiftLint via a Run Script build phase (`.swiftlint.yml` at repo root). The SPM plugin route was avoided due to a known platform-version resolution conflict in SwiftLint's package graph.
- **Testing:** Swift Testing framework. ViewModel tests inject a `MockNetworkService`. And a fresh in-memory `ModelContainer` per test for full isolation. 
- **Migrations:** the schema is v1 with no prior version to migrate from; SwiftData's lightweight migration covers additive changes, and a `SchemaMigrationPlan` would be introduced if the schema evolved post-release.

## Known Limitations / Production Path

- Image cache is in-memory only (`NSCache`); a production version would add a disk layer to survive relaunch, and set `totalCostLimit` from estimated image byte size for predictable memory bounds.
- `NetworkService` has no retry/backoff or request interceptors — intentionally out of scope for the time box.
- Bookmark is a `Bool` on `Event`; if bookmarks needed metadata (timestamps, sync), they'd graduate to their own model with a relationship.
