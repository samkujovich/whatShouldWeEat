# What Should We Eat?

A Tinder-like iOS app for discovering restaurants with friends. Swipe through restaurants, find your favorites, and let the app match you with the perfect dining spot for your group.

## Features

- **Tinder-like Swiping**: Swipe left or right on restaurant cards
- **Location-based Search**: Find restaurants near your current location
- **Customizable Preferences**: Set delivery mode, distance, excluded cuisines, and budget
- **Group Matching**: See overlapping restaurant preferences with friends
- **Real-time Results**: View your liked restaurants and all seen restaurants
- **Firebase Auth**: Google Sign-In for user accounts

## Tech Stack

- **SwiftUI** with MVVM architecture
- **Google Places API** for restaurant data
- **Firebase** (Auth, Firestore) for user accounts and group sessions
- **Core Location** for nearby search

## Setup

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- A Google Cloud project with Places API enabled
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
   - Replace `YOUR_CLIENT_ID` in `whatShouldWeEat/Info.plist` with the `REVERSED_CLIENT_ID` and `CLIENT_ID` values from your `GoogleService-Info.plist`

5. **Build and Run**
   - Open `whatShouldWeEat.xcodeproj` in Xcode
   - Select your target device or simulator
   - Build and run (Cmd + R)

## Project Structure

```
whatShouldWeEat/
├── Config/
│   ├── AppConfig.swift              # App configuration
│   ├── FirebaseConfig.swift         # Firebase initialization
│   ├── Secrets.swift                # API keys (gitignored)
│   └── Secrets.swift.example        # Template for API keys
├── Models/
│   ├── Restaurant.swift             # Restaurant data model
│   └── MealSession.swift            # Session and preferences models
├── Services/
│   ├── RestaurantService.swift      # Google Places API integration
│   ├── LocationService.swift        # Core Location integration
│   └── FirebaseService.swift        # Firestore operations
├── Views/
│   ├── ModernSwipeInterface.swift   # Main swiping interface
│   ├── PreferencesSetupView.swift   # User preferences setup
│   ├── RestaurantCardView.swift     # Swipeable restaurant card
│   └── ...
├── ContentView.swift                # Main app coordinator
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
