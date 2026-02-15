# CLAUDE.md — whatShouldWeEat

## Project Overview

Tinder-style iOS restaurant discovery app. Users swipe on nearby restaurants, set dining preferences, and match with friends on where to eat. Built with SwiftUI, Firebase (Auth + Firestore), and Google Places API.

## Tech Stack

- **Swift 5.9+** / **SwiftUI** / **iOS 17+**
- **Xcode 15+**
- **Firebase**: Authentication (Google Sign-In), Cloud Firestore
- **Google Places API**: Restaurant search and details
- **Core Location**: User positioning
- **Combine**: Reactive state management
- **Architecture**: MVVM

## Project Structure

```
whatShouldWeEat/
├── Config/           # AppConfig, FirebaseConfig, Secrets (gitignored)
├── Models/           # Restaurant, MealSession, SocialSession, User
├── Services/         # RestaurantService, LocationService, AuthenticationManager, FirestoreService, SocialSessionService
├── ViewModels/       # AppViewModel, RestaurantViewModel
├── Views/            # All SwiftUI views
├── Extensions/       # View+Extensions
└── Utilities/        # AppUtilities (formatting, validation, constants)
```

## Build & Run

```bash
# First-time setup
cp whatShouldWeEat/Config/Secrets.swift.example whatShouldWeEat/Config/Secrets.swift
# Edit Secrets.swift with your Google Places API key
# Place your GoogleService-Info.plist in whatShouldWeEat/
# Open whatShouldWeEat.xcodeproj in Xcode, build and run
```

## Secrets & Security

- **NEVER** hardcode API keys, Firebase credentials, or client IDs in committed files
- `Secrets.swift` is gitignored — all API keys go here
- `GoogleService-Info.plist` is gitignored — Firebase config loaded at runtime
- `Info.plist` contains the Google client ID URL scheme — update it from your plist, but never commit other credentials into it
- Before any commit, verify: `grep -r "AIza" .` and `grep -r "480189" .` return zero results in tracked files

## Architecture Rules

### MVVM Enforcement
- **Views** render UI and bind to ViewModels. No business logic, no direct service calls, no networking in views.
- **ViewModels** are `@MainActor ObservableObject` classes. They own `@Published` state and coordinate between services. Views observe them via `@StateObject` or `@EnvironmentObject`.
- **Models** are plain `struct`s conforming to `Codable` and `Identifiable`. No side effects, no service references.
- **Services** handle external I/O (network, location, Firestore, auth). They are injected into ViewModels, never accessed directly from Views.

### State Management
- Use `@Published` properties in ViewModels for reactive UI updates
- Use `@State` only for local, view-scoped UI state (form fields, toggles, animation flags)
- Do not duplicate state across ViewModels — use a single source of truth
- Always update UI state on `@MainActor`

### Dependency Injection
- Services are injected via initializers or `@EnvironmentObject`, never instantiated inside ViewModels
- Use protocols for services (see `RestaurantServiceProtocol`) to enable testing and mocking
- `AppConfig.useMockData` toggles between real and mock services

## Swift & SwiftUI Standards

### General
- Use `async/await` for all asynchronous work. Do not use `DispatchQueue.main.asyncAfter` or completion handler patterns in new code.
- Use `Task { }` to bridge from synchronous to async contexts
- Always use `[weak self]` in closures that capture `self` to prevent retain cycles
- Never force-unwrap (`!`). Use `guard let`, `if let`, or nil-coalescing (`??`)
- Use `guard` for early returns, `if let` for optional branching

### Error Handling
- Define domain-specific error enums conforming to `Error` and `LocalizedError` (see existing: `AuthError`, `LocationError`, `FirestoreError`, `RestaurantError`)
- Surface errors to the user via the `errorMessage` / `showError` pattern on ViewModels
- Log errors with descriptive context: `print("ServiceName: description - \(error.localizedDescription)")`
- Never silently swallow errors. At minimum, log them.

### Views
- Decompose views that exceed ~200 lines into smaller subviews or extracted components
- Use `ViewBuilder` computed properties to break up complex `body` implementations
- Prefer extracted subviews over deeply nested view hierarchies
- Keep gesture logic in the view but delegate state changes to the ViewModel

### Naming
- Types: `PascalCase` (e.g., `RestaurantCardView`, `MealSession`)
- Properties/methods: `camelCase` (e.g., `currentRestaurantIndex`, `fetchNearbyRestaurants()`)
- Constants: `camelCase` in `AppConfig` or `AppUtilities` (e.g., `defaultSearchRadius`)
- Protocols: descriptive noun or adjective (e.g., `RestaurantServiceProtocol`)
- Boolean properties: prefix with `is`, `has`, `should` (e.g., `isLoading`, `hasFinishedSwiping`)

## Firebase & Firestore

- All Firestore reads/writes go through `FirestoreService` — never call Firestore directly from ViewModels or Views
- Always clean up Firestore listeners in `deinit` — store listener registrations and call `remove()` on them
- Use Firestore's `Codable` support for serialization. Models must conform to `Codable`.
- Batch writes when updating multiple documents atomically
- Handle offline scenarios — Firestore has built-in offline persistence, but UI should indicate stale data

## Google Places API

- All API calls go through `RestaurantService`
- Respect rate limits — debounce search requests, never fire concurrent duplicate searches
- Cache restaurant data within a session to avoid redundant API calls
- Filter results in `RestaurantService`, not in ViewModels or Views
- Always validate API responses — check for expected fields before parsing

## Location

- All location logic lives in `LocationService`
- Always check authorization status before requesting location
- Provide fallback for denied permissions (zip code entry)
- Use `CLLocationManager` async wrappers, not delegate callbacks in new code
- Handle location errors gracefully — show meaningful messages, offer retry

## Performance

- Cache images — do not re-fetch the same restaurant image multiple times
- Use `AsyncImage` with placeholder for remote images in SwiftUI
- Debounce user-triggered API calls (search, filter changes)
- Limit card stack to `AppConfig.cardStackSize` for smooth animations
- Profile with Instruments before optimizing — don't guess at bottlenecks

## Memory Management

- Always capture `[weak self]` in escaping closures and Combine sinks
- Invalidate all timers in `deinit`
- Remove Firestore listeners in `deinit`
- Cancel Combine subscriptions via `AnyCancellable` stored in `Set<AnyCancellable>`

## Testing

- Mock services exist (`MockRestaurantService`) — use them for unit tests
- Test ViewModels by injecting mock services and asserting on `@Published` state changes
- Test Models by verifying `Codable` round-trips and computed properties
- Test service filtering/matching logic with known inputs
- UI tests should cover the critical path: launch -> preferences -> swipe -> results

## Git & Commits

- Never commit secrets, API keys, or `GoogleService-Info.plist`
- Write concise commit messages: imperative mood, explain the "why"
- One logical change per commit
- Run a secrets grep before every commit

## Code Review Checklist

- [ ] No hardcoded secrets or credentials
- [ ] No force-unwraps
- [ ] `[weak self]` in escaping closures
- [ ] Errors surfaced to user, not silently swallowed
- [ ] New async code uses `async/await`, not completion handlers
- [ ] Views under 200 lines, logic delegated to ViewModel
- [ ] Firestore listeners cleaned up in `deinit`
- [ ] State changes happen on `@MainActor`
