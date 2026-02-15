import Foundation
import SwiftUI
import CoreLocation
import Combine

// MARK: - Restaurant ViewModel
@MainActor
class RestaurantViewModel<Service: RestaurantServiceProtocol>: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var currentRestaurantIndex = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showLocationPermission = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var zipCode: String = ""
    @Published var likedRestaurants: [Restaurant] = []
    @Published var hasFinishedSwiping = false

    var mealPreferences: MealPreferences?

    private let restaurantService: Service
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()

    init(
        restaurantService: Service,
        locationService: LocationService = LocationService()
    ) {
        self.restaurantService = restaurantService
        self.locationService = locationService
        setupBindings()
    }

    private func setupBindings() {
        // Bind restaurant service properties via protocol publishers
        restaurantService.isLoadingPublisher
            .sink { [weak self] value in self?.isLoading = value }
            .store(in: &cancellables)

        restaurantService.errorMessagePublisher
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
                self?.showError = errorMessage != nil
            }
            .store(in: &cancellables)

        restaurantService.restaurantsPublisher
            .sink { [weak self] value in self?.restaurants = value }
            .store(in: &cancellables)
    }
    
    // MARK: - Location and Restaurant Fetching
    
    func setupLocationAndFetchRestaurants() async {
        do {
            let location = try await locationService.requestLocation()
            userLocation = location
            await fetchRestaurants(near: location)
        } catch {
            print("Location error: \(error.localizedDescription)")
            // Don't show error immediately, let user try zip code
            showLocationPermission = true
        }
    }
    
    func fetchRestaurantsWithZipCode(_ zipCode: String) async {
        self.zipCode = zipCode
        isLoading = true
        errorMessage = nil
        
        do {
            let location = try await locationService.getCoordinatesFromZipCode(zipCode)
            userLocation = location
            await fetchRestaurants(near: location)
            
            // Hide location permission view after successful fetch
            showLocationPermission = false
            
        } catch {
            handleError("Failed to fetch restaurants for zip code: \(error.localizedDescription)")
        }
    }
    
    func fetchRestaurants(near location: CLLocationCoordinate2D) async {
        isLoading = true
        errorMessage = nil

        // Convert miles to meters for Google Places API
        let radiusInMiles = mealPreferences?.maxDistance ?? 20.0
        let radiusInMeters = radiusInMiles * 1609.34 // Convert miles to meters

        restaurantService.fetchRestaurants(
            near: location,
            radius: radiusInMeters, // Now using meters
            excludedCuisines: mealPreferences?.excludedCuisines ?? []
        )
    }
    
    // MARK: - Helper Methods
    
    private func handleError(_ message: String) {
        errorMessage = message
        showError = true
        isLoading = false
    }
    
    var currentRestaurant: Restaurant? {
        guard currentRestaurantIndex < restaurants.count else { return nil }
        return restaurants[currentRestaurantIndex]
    }
    
    var hasMoreRestaurants: Bool {
        return currentRestaurantIndex < restaurants.count
    }
    
    var progressPercentage: Double {
        guard restaurants.count > 0 else { return 0 }
        return Double(currentRestaurantIndex) / Double(restaurants.count)
    }
} 