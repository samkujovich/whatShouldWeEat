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
    static let defaultMaxDistance: Double = 20.0 // miles
    static let defaultDeliveryMode: DeliveryMode = .dineIn
    
    // API Configuration
    static let maxRestaurantsPerRequest = 20
    static let defaultSearchRadius: Double = 20.0 * 1609.34 // meters (for Google Places API)
    
    // UI Configuration
    static let cardStackSize = 3
    static let swipeThreshold: CGFloat = 150
    static let animationDuration: Double = 0.3
} 