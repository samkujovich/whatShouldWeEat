import Foundation

struct AppConfig {
    // Set to true to use mock data, false to use real Google Places API
    static let useMockData = false
    
    // Google Places API Configuration
    static let googlePlacesAPIKey = Secrets.googlePlacesAPIKey
    
    // App Configuration
    static let appName = "What Should We Eat?"
    static let appVersion = "1.0.0"
    
    // Default Preferences
    static let defaultMaxDistance: Double = 5.0
    static let defaultDeliveryMode: DeliveryMode = .dineIn
    
    // API Configuration
    static let maxRestaurantsPerRequest = 20
    static let defaultSearchRadius: Double = 5000 // meters
    
    // UI Configuration
    static let cardStackSize = 3
    static let swipeThreshold: CGFloat = 150
    static let animationDuration: Double = 0.3
} 