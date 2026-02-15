import Foundation
import CoreLocation
import SwiftUI

// MARK: - App Utilities
struct AppUtilities {
    
    /// Formats distance in miles with proper units
    static func formatDistance(_ distance: Double) -> String {
        if distance < 1.0 {
            return "\(Int(distance * 5280)) ft"
        } else {
            return String(format: "%.1f mi", distance)
        }
    }
    
    /// Estimates drive time based on distance
    static func estimateDriveTime(distance: Double) -> String {
        let averageSpeed = 30.0 // mph in city
        let timeInMinutes = (distance / averageSpeed) * 60
        let roundedMinutes = Int(round(timeInMinutes))
        
        if roundedMinutes < 1 {
            return "< 1 min"
        } else if roundedMinutes < 60 {
            return "\(roundedMinutes) min"
        } else {
            let hours = roundedMinutes / 60
            let minutes = roundedMinutes % 60
            if minutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(minutes) min"
            }
        }
    }
    
    /// Formats price level as dollar signs
    static func formatPriceLevel(_ priceLevel: Int) -> String {
        return String(repeating: "$", count: priceLevel)
    }
    
    /// Formats rating with stars
    static func formatRating(_ rating: Double) -> String {
        return String(format: "%.1f", rating)
    }
    
    /// Generates a restaurant description
    static func generateRestaurantDescription(
        cuisineTypes: [String],
        rating: Double?,
        priceLevel: Int?,
        isOpen: Bool?
    ) -> String {
        var description = ""
        
        // Add cuisine type
        if let primaryCuisine = cuisineTypes.first {
            description += primaryCuisine.replacingOccurrences(of: "_", with: " ").capitalized
        }
        
        // Add rating
        if let rating = rating {
            description += " • \(formatRating(rating))★"
        }
        
        // Add price level
        if let priceLevel = priceLevel {
            description += " • \(formatPriceLevel(priceLevel))"
        }
        
        // Add open status
        if let isOpen = isOpen {
            description += " • \(isOpen ? "Open" : "Closed")"
        }
        
        return description
    }
    
    /// Validates zip code format
    static func isValidZipCode(_ zipCode: String) -> Bool {
        let zipCodeRegex = "^\\d{5}(-\\d{4})?$"
        return zipCode.range(of: zipCodeRegex, options: .regularExpression) != nil
    }
    
    /// Formats phone number for display
    static func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleaned.count == 10 {
            let index = cleaned.index(cleaned.startIndex, offsetBy: 3)
            let index2 = cleaned.index(cleaned.startIndex, offsetBy: 6)
            return "(\(cleaned[..<index])) \(cleaned[index..<index2])-\(cleaned[index2...])"
        } else if cleaned.count == 11 && cleaned.first == "1" {
            let index = cleaned.index(cleaned.startIndex, offsetBy: 1)
            let index2 = cleaned.index(cleaned.startIndex, offsetBy: 4)
            let index3 = cleaned.index(cleaned.startIndex, offsetBy: 7)
            return "(\(cleaned[index..<index2])) \(cleaned[index2..<index3])-\(cleaned[index3...])"
        }
        
        return phoneNumber
    }
    
    /// Calculates distance between two coordinates
    static func calculateDistance(
        from location1: CLLocationCoordinate2D,
        to location2: CLLocationCoordinate2D
    ) -> Double {
        let location1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let location2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        
        let distanceInMeters = location1.distance(from: location2)
        let distanceInMiles = distanceInMeters / 1609.34
        
        return distanceInMiles
    }
}

// MARK: - Constants
struct AppConstants {
    static let defaultSearchRadius: Double = AppConfig.defaultMaxDistance // miles
    static let maxSearchRadius: Double = 50.0 // miles
    static let minSearchRadius: Double = 1.0 // miles
    
    static let defaultLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
    
    static let animationDuration: Double = 0.3
    static let quickAnimationDuration: Double = 0.15
    
    static let maxRestaurantsToShow = 50
    static let maxCuisineTypesToShow = 3
    
    struct Colors {
        static let primary = Color.accentColor
        static let secondary = Color.secondary
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.secondarySystemBackground)
        static let navyBackground = Color(red: 0.05, green: 0.1, blue: 0.2)
        static let navyPrimary = Color(red: 0.1, green: 0.2, blue: 0.4)
        static let navyCard = Color(red: 0.1, green: 0.15, blue: 0.3)
        static let navyButton = Color(red: 0.15, green: 0.2, blue: 0.4)
        static let navyHighlight = Color(red: 0.2, green: 0.3, blue: 0.6)
        static let navySubtitle = Color(red: 0.3, green: 0.4, blue: 0.5)
        static let navyUnselected = Color(red: 0.95, green: 0.97, blue: 1.0)
    }
    
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
} 