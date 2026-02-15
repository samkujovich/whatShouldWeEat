import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        print("🔐 Requesting location permission...")
        print("🔐 Current authorization status: \(authorizationStatus.rawValue)")
        print("🔐 Location services enabled: \(CLLocationManager.locationServicesEnabled())")
        
        // Check current authorization status
        switch authorizationStatus {
        case .notDetermined:
            print("📍 Location permission not determined - requesting...")
            print("📍 About to call requestWhenInUseAuthorization()")
            locationManager.requestWhenInUseAuthorization()
            print("📍 requestWhenInUseAuthorization() called")
        case .denied, .restricted:
            print("❌ Location permission denied or restricted")
            locationError = "Location access is required to find restaurants near you. Please enable location services in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location already authorized - starting updates")
            startLocationUpdates()
        @unknown default:
            print("❓ Unknown authorization status")
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startLocationUpdates() {
        print("🔐 Starting location updates...")
        print("🔐 Current authorization status: \(authorizationStatus.rawValue)")
        
        // Try to start updates regardless of status
        locationManager.startUpdatingLocation()
        
        // Also try to get a single location update
        locationManager.requestLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance(from userLocation: CLLocationCoordinate2D, to restaurantLocation: CLLocationCoordinate2D) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let restaurantCLLocation = CLLocation(latitude: restaurantLocation.latitude, longitude: restaurantLocation.longitude)
        
        return userCLLocation.distance(from: restaurantCLLocation) / 1609.34 // Convert meters to miles
    }
    
    func refreshAuthorizationStatus() {
        let currentStatus = locationManager.authorizationStatus
        print("🔐 Refreshing authorization status: \(currentStatus.rawValue)")
        authorizationStatus = currentStatus
    }
    
    // MARK: - Async Location Methods
    
    func requestLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            // Store the continuation to resolve when location is received
            self.locationContinuation = continuation
            
            // Request location permission first
            requestLocationPermission()
            
            // Start location updates
            startLocationUpdates()
            
            // Set a timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if let continuation = self.locationContinuation {
                    self.locationContinuation = nil
                    continuation.resume(throwing: LocationError.timeout)
                }
            }
        }
    }
    
    func getCoordinatesFromZipCode(_ zipCode: String) async throws -> CLLocationCoordinate2D {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(zipCode)&key=\(AppConfig.googlePlacesAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw LocationError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        
        guard let result = response.results.first,
              let location = result.geometry.location else {
            throw LocationError.noResults
        }
        
        return CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
    }
    
    // MARK: - Private Properties
    
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        currentLocation = location.coordinate
        locationError = nil
        
        // Resolve continuation if waiting for location
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        locationError = error.localizedDescription
        
        // Resolve continuation with error if waiting for location
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 Location authorization status changed: \(status.rawValue)")
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized, starting updates")
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ Location access denied")
            locationError = "Location access denied. Please enable location services in Settings."
            
            // Resolve continuation with error if waiting for location
            if let continuation = locationContinuation {
                locationContinuation = nil
                continuation.resume(throwing: LocationError.permissionDenied)
            }
        case .notDetermined:
            print("⏳ Location authorization not determined")
            break
        @unknown default:
            break
        }
    }
} 

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case timeout
    case invalidURL
    case noResults
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Location request timed out"
        case .invalidURL:
            return "Invalid URL"
        case .noResults:
            return "No location found for the provided address"
        case .permissionDenied:
            return "Location permission denied"
        }
    }
}

// MARK: - Geocoding Response Models

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]
    let status: String
}

struct GeocodingResult: Codable {
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: Location?
}

struct Location: Codable {
    let lat: Double
    let lng: Double
} 