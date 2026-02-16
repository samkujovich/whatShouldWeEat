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
        // Check current authorization status
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = "Location access is required to find restaurants near you. Please enable location services in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func startLocationUpdates() {
        // Try to start updates regardless of status
        locationManager.startUpdatingLocation()

        // Also try to get a single location update
        locationManager.requestLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func refreshAuthorizationStatus() {
        let currentStatus = locationManager.authorizationStatus
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
        let geocoder = CLGeocoder()

        guard let placemarks = try? await geocoder.geocodeAddressString(zipCode),
              let location = placemarks.first?.location else {
            throw LocationError.noResults
        }

        return location.coordinate
    }

    // MARK: - Private Properties

    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        locationError = nil

        // Resolve continuation if waiting for location
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        locationError = error.localizedDescription

        // Resolve continuation with error if waiting for location
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            locationError = "Location access denied. Please enable location services in Settings."

            // Resolve continuation with error if waiting for location
            if let continuation = locationContinuation {
                locationContinuation = nil
                continuation.resume(throwing: LocationError.permissionDenied)
            }
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case timeout
    case noResults
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Location request timed out"
        case .noResults:
            return "No location found for the provided zip code"
        case .permissionDenied:
            return "Location permission denied"
        }
    }
}

