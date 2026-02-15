import Foundation

// MARK: - User Profile
struct UserProfile: Codable {
    let uid: String
    let email: String
    let displayName: String
    let photoURL: String?
    let createdAt: Date
    let lastLoginAt: Date
    
    enum CodingKeys: String, CodingKey {
        case uid, email, displayName, photoURL, createdAt, lastLoginAt
    }
    
    init(uid: String, email: String, displayName: String, photoURL: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = Date()
        self.lastLoginAt = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        
        // Handle date decoding with fallback
        if let timestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            createdAt = Date()
        }
        
        if let timestamp = try? container.decode(Double.self, forKey: .lastLoginAt) {
            lastLoginAt = Date(timeIntervalSince1970: timestamp)
        } else {
            lastLoginAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(email, forKey: .email)
        try container.encode(displayName, forKey: .displayName)
        try container.encodeIfPresent(photoURL, forKey: .photoURL)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
        try container.encode(lastLoginAt.timeIntervalSince1970, forKey: .lastLoginAt)
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var cuisineRestrictions: [String]
    var defaultDriveRadius: Double
    var preferredMealTimes: [String]
    
    init(cuisineRestrictions: [String] = [], defaultDriveRadius: Double = 15.0, preferredMealTimes: [String] = ["lunch", "dinner"]) {
        self.cuisineRestrictions = cuisineRestrictions
        self.defaultDriveRadius = defaultDriveRadius
        self.preferredMealTimes = preferredMealTimes
    }
}

// MARK: - User Statistics
struct UserStats: Codable {
    var totalMeals: Int
    var totalSwipes: Int
    var favoriteRestaurants: [String]
    
    init(totalMeals: Int = 0, totalSwipes: Int = 0, favoriteRestaurants: [String] = []) {
        self.totalMeals = totalMeals
        self.totalSwipes = totalSwipes
        self.favoriteRestaurants = favoriteRestaurants
    }
}

// MARK: - Complete User Model
struct User: Identifiable, Codable {
    let id: String
    var profile: UserProfile
    var preferences: UserPreferences
    var stats: UserStats
    
    init(id: String, profile: UserProfile, preferences: UserPreferences = UserPreferences(), stats: UserStats = UserStats()) {
        self.id = id
        self.profile = profile
        self.preferences = preferences
        self.stats = stats
    }
} 