import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let address: String
    let phoneNumber: String?
    let website: String?
    let rating: Double?
    let priceLevel: Int?
    let cuisineTypes: [String]
    let popularDishes: [String]
    let photos: [String]
    let openingHours: OpeningHours?
    
    struct OpeningHours: Codable {
        let openNow: Bool
        
        enum CodingKeys: String, CodingKey {
            case openNow = "open_now"
        }
    }
    let location: CLLocationCoordinate2D
    let distance: Double?
    
    struct Photo: Codable {
        let photoReference: String
        let width: Int
        let height: Int
        
        enum CodingKeys: String, CodingKey {
            case photoReference = "photo_reference"
            case width
            case height
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name
        case address = "vicinity"
        case phoneNumber = "formatted_phone_number"
        case website
        case rating
        case priceLevel = "price_level"
        case cuisineTypes = "types"
        case popularDishes
        case photos
        case openingHours = "opening_hours"
        case location = "geometry"
        case distance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel)
        cuisineTypes = try container.decodeIfPresent([String].self, forKey: .cuisineTypes) ?? []
        popularDishes = try container.decodeIfPresent([String].self, forKey: .popularDishes) ?? []
        
        // Decode photos - convert Photo objects to photo references
        let photoObjects = try container.decodeIfPresent([Photo].self, forKey: .photos) ?? []
        photos = photoObjects.map { $0.photoReference }
        openingHours = try container.decodeIfPresent(OpeningHours.self, forKey: .openingHours)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        
        // Decode location from geometry
        let geometryContainer = try container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .location)
        let locationContainer = try geometryContainer.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        let lat = try locationContainer.decode(Double.self, forKey: .lat)
        let lng = try locationContainer.decode(Double.self, forKey: .lng)
        location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    // Custom initializer for creating restaurants with known data
    init(id: String, name: String, address: String, phoneNumber: String?, website: String?, rating: Double?, priceLevel: Int?, cuisineTypes: [String], popularDishes: [String], photos: [String], openingHours: OpeningHours?, location: CLLocationCoordinate2D, distance: Double?) {
        self.id = id
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
        self.rating = rating
        self.priceLevel = priceLevel
        self.cuisineTypes = cuisineTypes
        self.popularDishes = popularDishes
        self.photos = photos
        self.openingHours = openingHours
        self.location = location
        self.distance = distance
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(priceLevel, forKey: .priceLevel)
        try container.encode(cuisineTypes, forKey: .cuisineTypes)
        try container.encode(popularDishes, forKey: .popularDishes)
        try container.encode(photos, forKey: .photos)
        try container.encodeIfPresent(openingHours, forKey: .openingHours)
        try container.encodeIfPresent(distance, forKey: .distance)
        
        // Encode location
        var geometryContainer = container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .location)
        var locationContainer = geometryContainer.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        try locationContainer.encode(location.latitude, forKey: .lat)
        try locationContainer.encode(location.longitude, forKey: .lng)
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case location
    }
    
    private enum LocationCodingKeys: String, CodingKey {
        case lat
        case lng
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }
} 