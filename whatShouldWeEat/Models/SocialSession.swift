import Foundation
import CoreLocation

struct SocialSession: Identifiable, Codable {
    let id: String
    let hostUserId: String
    let hostName: String
    let sessionName: String
    let preferences: MealPreferences
    let location: CLLocationCoordinate2D
    let createdAt: Date
    let expiresAt: Date
    var participants: [SessionParticipant]
    var restaurants: [Restaurant]
    var status: SessionStatus
    
    enum CodingKeys: String, CodingKey {
        case id, hostUserId, hostName, sessionName, preferences, location, createdAt, expiresAt, participants, restaurants, status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        hostUserId = try container.decode(String.self, forKey: .hostUserId)
        hostName = try container.decode(String.self, forKey: .hostName)
        sessionName = try container.decode(String.self, forKey: .sessionName)
        preferences = try container.decode(MealPreferences.self, forKey: .preferences)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        participants = try container.decode([SessionParticipant].self, forKey: .participants)
        restaurants = try container.decode([Restaurant].self, forKey: .restaurants)
        status = try container.decode(SessionStatus.self, forKey: .status)
        
        // Decode location from nested structure
        let locationContainer = try container.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        let latitude = try locationContainer.decode(Double.self, forKey: .latitude)
        let longitude = try locationContainer.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(hostUserId, forKey: .hostUserId)
        try container.encode(hostName, forKey: .hostName)
        try container.encode(sessionName, forKey: .sessionName)
        try container.encode(preferences, forKey: .preferences)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encode(participants, forKey: .participants)
        try container.encode(restaurants, forKey: .restaurants)
        try container.encode(status, forKey: .status)
        
        // Encode location as nested structure
        var locationContainer = container.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        try locationContainer.encode(location.latitude, forKey: .latitude)
        try locationContainer.encode(location.longitude, forKey: .longitude)
    }
    
    private enum LocationCodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    enum SessionStatus: String, Codable, CaseIterable {
        case waiting = "waiting"
        case active = "active"
        case completed = "completed"
        case expired = "expired"
    }
    
    init(hostUserId: String, hostName: String, sessionName: String, preferences: MealPreferences, location: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.hostUserId = hostUserId
        self.hostName = hostName
        self.sessionName = sessionName
        self.preferences = preferences
        self.location = location
        self.createdAt = Date()
        self.expiresAt = Date().addingTimeInterval(3600) // 1 hour expiration
        self.participants = [SessionParticipant(userId: hostUserId, name: hostName, isHost: true)]
        self.restaurants = []
        self.status = .waiting
    }
    
    var isExpired: Bool {
        return Date() > expiresAt
    }
    
    var likedRestaurants: [Restaurant] {
        return restaurants.filter { restaurant in
            participants.allSatisfy { participant in
                participant.likedRestaurantIds.contains(restaurant.id)
            }
        }
    }
    
    var dislikedRestaurants: [Restaurant] {
        return restaurants.filter { restaurant in
            participants.any { participant in
                participant.dislikedRestaurantIds.contains(restaurant.id)
            }
        }
    }
    
    var matchedRestaurants: [Restaurant] {
        return restaurants.filter { restaurant in
            // All participants must have liked this restaurant
            participants.allSatisfy { participant in
                participant.likedRestaurantIds.contains(restaurant.id)
            }
        }
    }
}

struct SessionParticipant: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let isHost: Bool
    var joinedAt: Date
    var likedRestaurantIds: Set<String>
    var dislikedRestaurantIds: Set<String>
    
    init(userId: String, name: String, isHost: Bool = false) {
        self.id = UUID().uuidString
        self.userId = userId
        self.name = name
        self.isHost = isHost
        self.joinedAt = Date()
        self.likedRestaurantIds = []
        self.dislikedRestaurantIds = []
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, isHost, joinedAt, likedRestaurantIds, dislikedRestaurantIds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        isHost = try container.decode(Bool.self, forKey: .isHost)
        joinedAt = try container.decode(Date.self, forKey: .joinedAt)
        
        // Decode arrays and convert to sets
        let likedArray = try container.decode([String].self, forKey: .likedRestaurantIds)
        likedRestaurantIds = Set(likedArray)
        
        let dislikedArray = try container.decode([String].self, forKey: .dislikedRestaurantIds)
        dislikedRestaurantIds = Set(dislikedArray)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(isHost, forKey: .isHost)
        try container.encode(joinedAt, forKey: .joinedAt)
        
        // Encode sets as arrays
        try container.encode(Array(likedRestaurantIds), forKey: .likedRestaurantIds)
        try container.encode(Array(dislikedRestaurantIds), forKey: .dislikedRestaurantIds)
    }
}

// MARK: - Extensions
extension Array {
    func any(where predicate: (Element) -> Bool) -> Bool {
        return contains(where: predicate)
    }
} 