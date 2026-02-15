# What Should We Eat?

A SwiftUI iOS app that helps you discover restaurants through a Tinder-style swiping interface. Set your preferences, swipe through nearby restaurants, and build a shortlist of where to eat.

## The Problem

Deciding where to eat — especially in a group — is surprisingly painful. You open a maps app, scroll through an overwhelming list of restaurants, and spend more time deliberating than eating. This app turns restaurant discovery into a quick, opinionated swipe session: see a card, swipe right if it looks good, swipe left if not. Done.

## Features

- **Swipe Interface**: Tinder-style card swiping with undo support and progress tracking
- **Preference Filters**: Set delivery mode (dine-in, takeout, delivery), max distance, excluded cuisines, and budget
- **Location-Aware**: Uses Core Location for nearby search, or enter a zip code manually
- **Google Places Integration**: Real restaurant data including photos, ratings, review counts, and price levels
- **Firebase Auth**: Google Sign-In with persistent user profiles
- **Results View**: Review your liked restaurants and full swipe history after each session

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | SwiftUI (iOS 17+) |
| Architecture | MVVM with Combine bindings |
| Restaurant Data | Google Places API (New) |
| Authentication | Firebase Auth + Google Sign-In |
| Database | Cloud Firestore |
| Location | Core Location |
| Navigation | NavigationStack |

## Architecture

The app follows MVVM with protocol-based dependency injection:

- **Views** bind to **ViewModels** via `@StateObject`, `@Binding`, and `@EnvironmentObject`
- `RestaurantViewModel` is generic over `RestaurantServiceProtocol`, enabling mock injection for testing
- `AuthenticationManager` is shared across views via `@EnvironmentObject`
- Color constants and utility functions are consolidated in `AppConstants` and `AppUtilities`

## Setup

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- A Google Cloud project with Places API (New) enabled
- A Firebase project with Authentication and Firestore enabled

### Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/samkujovich/whatShouldWeEat.git
   cd whatShouldWeEat
   ```

2. **Set up API keys**
   ```bash
   cp whatShouldWeEat/Config/Secrets.swift.example whatShouldWeEat/Config/Secrets.swift
   ```
   Edit `Secrets.swift` and add your Google Places API key.

3. **Set up Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add an iOS app with bundle ID `Kujo.whatShouldWeEat`
   - Enable **Authentication** (Google Sign-In provider)
   - Enable **Cloud Firestore**
   - Download `GoogleService-Info.plist` and place it at `whatShouldWeEat/GoogleService-Info.plist`
   - See `GoogleService-Info.plist.example` for the expected structure

4. **Update Info.plist**
   Replace `YOUR_CLIENT_ID` in `whatShouldWeEat/Info.plist` with the `REVERSED_CLIENT_ID` and `CLIENT_ID` values from your `GoogleService-Info.plist`.

5. **Build and Run**
   - Open `whatShouldWeEat.xcodeproj` in Xcode
   - Select your target device or simulator
   - Build and run (Cmd + R)

## Project Structure

```
whatShouldWeEat/
├── Config/
│   ├── AppConfig.swift              # App-wide configuration and defaults
│   ├── FirebaseConfig.swift         # Firebase initialization from plist
│   ├── Secrets.swift                # API keys (gitignored)
│   └── Secrets.swift.example        # Template for contributors
├── Models/
│   ├── Restaurant.swift             # Restaurant data model (Places API)
│   ├── MealSession.swift            # Session criteria and status
│   └── User.swift                   # User profile and preferences
├── ViewModels/
│   ├── AppViewModel.swift           # App navigation state and preferences
│   └── RestaurantViewModel.swift    # Restaurant fetching and swipe state (generic)
├── Views/
│   ├── ModernSwipeInterface.swift   # Card stack swiping UI
│   ├── RestaurantCardView.swift     # Individual restaurant card
│   ├── RestaurantSwipeView.swift    # Swipe session coordinator
│   ├── PreferencesSetupView.swift   # Preference selection (onboarding)
│   ├── LocationPermissionView.swift # Location access and zip code entry
│   ├── LoginView.swift              # Google Sign-In
│   ├── ProfileView.swift            # User profile display
│   ├── EditProfileView.swift        # Profile editing
│   └── LoadingView.swift            # Loading state
├── Services/
│   ├── RestaurantService.swift      # Google Places API client
│   ├── RestaurantServiceProtocol.swift # Protocol for DI/testing
│   ├── MockRestaurantService.swift  # Mock implementation for development
│   ├── AuthenticationManager.swift  # Firebase Auth + Google Sign-In
│   ├── FirestoreService.swift       # Firestore CRUD operations
│   └── LocationService.swift        # Core Location wrapper
├── Utilities/
│   └── AppUtilities.swift           # Shared constants, formatters, color palette
├── Extensions/
│   └── View+Extensions.swift        # SwiftUI view helpers
├── ContentView.swift                # Root view coordinator
├── whatShouldWeEatApp.swift         # App entry point
└── Info.plist                       # App configuration
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
