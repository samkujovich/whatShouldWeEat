import Foundation
import CoreLocation

// MARK: - Meal Session Criteria
struct MealSessionCriteria: Codable {
    var driveRadius: Double
    var deliveryOnly: Bool
    var excludedCuisines: [String]
    var location: CLLocationCoordinate2D?
    
    init(driveRadius: Double = AppConfig.defaultMaxDistance, deliveryOnly: Bool = false, excludedCuisines: [String] = [], location: CLLocationCoordinate2D? = nil) {
        self.driveRadius = driveRadius
        self.deliveryOnly = deliveryOnly
        self.excludedCuisines = excludedCuisines
        self.location = location
    }
    
    enum CodingKeys: String, CodingKey {
        case driveRadius, deliveryOnly, excludedCuisines, location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        driveRadius = try container.decode(Double.self, forKey: .driveRadius)
        deliveryOnly = try container.decode(Bool.self, forKey: .deliveryOnly)
        excludedCuisines = try container.decode([String].self, forKey: .excludedCuisines)
        
        // Handle location decoding
        if let locationData = try? container.decode([String: Double].self, forKey: .location) {
            location = CLLocationCoordinate2D(
                latitude: locationData["latitude"] ?? 0,
                longitude: locationData["longitude"] ?? 0
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(driveRadius, forKey: .driveRadius)
        try container.encode(deliveryOnly, forKey: .deliveryOnly)
        try container.encode(excludedCuisines, forKey: .excludedCuisines)
        
        if let location = location {
            let locationData = [
                "latitude": location.latitude,
                "longitude": location.longitude
            ]
            try container.encode(locationData, forKey: .location)
        }
    }
}

// MARK: - Restaurant Swipe
struct RestaurantSwipe: Codable {
    let userId: String
    let swipe: SwipeDirection
    let timestamp: Date
    
    enum SwipeDirection: String, Codable, CaseIterable {
        case yes = "yes"
        case no = "no"
        case maybe = "maybe"
    }
    
    init(userId: String, swipe: SwipeDirection) {
        self.userId = userId
        self.swipe = swipe
        self.timestamp = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case userId, swipe, timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        swipe = try container.decode(SwipeDirection.self, forKey: .swipe)
        
        // Handle date decoding with fallback
        if let timestamp = try? container.decode(Double.self, forKey: .timestamp) {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timestamp = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(swipe, forKey: .swipe)
        try container.encode(timestamp.timeIntervalSince1970, forKey: .timestamp)
    }
}

// MARK: - Session Restaurant
struct SessionRestaurant: Codable {
    let id: String
    let name: String
    let googlePlaceId: String
    let address: String
    let rating: Double?
    let priceLevel: Int?
    let cuisineTypes: [String]
    let photos: [String]
    let location: CLLocationCoordinate2D
    let swipes: [String: RestaurantSwipe]
    
    init(id: String, name: String, googlePlaceId: String, address: String, rating: Double? = nil, priceLevel: Int? = nil, cuisineTypes: [String] = [], photos: [String] = [], location: CLLocationCoordinate2D, swipes: [String: RestaurantSwipe] = [:]) {
        self.id = id
        self.name = name
        self.googlePlaceId = googlePlaceId
        self.address = address
        self.rating = rating
        self.priceLevel = priceLevel
        self.cuisineTypes = cuisineTypes
        self.photos = photos
        self.location = location
        self.swipes = swipes
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, googlePlaceId, address, rating, priceLevel, cuisineTypes, photos, location, swipes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        googlePlaceId = try container.decode(String.self, forKey: .googlePlaceId)
        address = try container.decode(String.self, forKey: .address)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel)
        cuisineTypes = try container.decode([String].self, forKey: .cuisineTypes)
        photos = try container.decode([String].self, forKey: .photos)
        swipes = try container.decode([String: RestaurantSwipe].self, forKey: .swipes)
        
        // Handle location decoding
        if let locationData = try? container.decode([String: Double].self, forKey: .location) {
            location = CLLocationCoordinate2D(
                latitude: locationData["latitude"] ?? 0,
                longitude: locationData["longitude"] ?? 0
            )
        } else {
            location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(googlePlaceId, forKey: .googlePlaceId)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(priceLevel, forKey: .priceLevel)
        try container.encode(cuisineTypes, forKey: .cuisineTypes)
        try container.encode(photos, forKey: .photos)
        try container.encode(swipes, forKey: .swipes)
        
        let locationData = [
            "latitude": location.latitude,
            "longitude": location.longitude
        ]
        try container.encode(locationData, forKey: .location)
    }
}

// MARK: - Session Status
enum SessionStatus: String, Codable, CaseIterable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

// MARK: - Complete Meal Session Model
struct MealSession: Identifiable, Codable {
    let id: String
    let createdBy: String
    var participants: [String]
    var status: SessionStatus
    var criteria: MealSessionCriteria
    var restaurants: [String: SessionRestaurant]
    let createdAt: Date
    
    init(id: String, createdBy: String, participants: [String] = [], status: SessionStatus = .active, criteria: MealSessionCriteria = MealSessionCriteria(), restaurants: [String: SessionRestaurant] = [:]) {
        self.id = id
        self.createdBy = createdBy
        self.participants = participants
        self.status = status
        self.criteria = criteria
        self.restaurants = restaurants
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, createdBy, participants, status, criteria, restaurants, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        participants = try container.decode([String].self, forKey: .participants)
        status = try container.decode(SessionStatus.self, forKey: .status)
        criteria = try container.decode(MealSessionCriteria.self, forKey: .criteria)
        restaurants = try container.decode([String: SessionRestaurant].self, forKey: .restaurants)
        
        // Handle date decoding with fallback
        if let timestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            createdAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(participants, forKey: .participants)
        try container.encode(status, forKey: .status)
        try container.encode(criteria, forKey: .criteria)
        try container.encode(restaurants, forKey: .restaurants)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
    }
} 