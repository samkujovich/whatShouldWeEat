import Foundation
import SwiftUI
import CoreLocation
import Combine

// MARK: - Restaurant ViewModel
@MainActor
class RestaurantViewModel: ObservableObject {
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
    
    private let restaurantService: RestaurantService
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        restaurantService: RestaurantService = RestaurantService(),
        locationService: LocationService = LocationService()
    ) {
        self.restaurantService = restaurantService
        self.locationService = locationService
        setupBindings()
        print("🍽️ RestaurantViewModel initialized")
    }
    
    private func setupBindings() {
        // Bind restaurant service properties
        restaurantService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        restaurantService.$errorMessage
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
                self?.showError = errorMessage != nil
            }
            .store(in: &cancellables)
        
        restaurantService.$restaurants
            .assign(to: \.restaurants, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Location and Restaurant Fetching
    
    func setupLocationAndFetchRestaurants() async {
        do {
            let location = try await locationService.requestLocation()
            userLocation = location
            await fetchRestaurants(near: location)
        } catch {
            print("❌ Location error: \(error.localizedDescription)")
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
        
        do {
            // Convert miles to meters for Google Places API
            let radiusInMiles = 20.0
            let radiusInMeters = radiusInMiles * 1609.34 // Convert miles to meters
            
            restaurantService.fetchRestaurants(
                near: location,
                radius: radiusInMeters, // Now using meters
                excludedCuisines: []
            )
        } catch {
            handleError("Failed to fetch restaurants: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Swipe Handling
    
    func swipeRight() {
        guard currentRestaurantIndex < restaurants.count else { return }
        
        let restaurant = restaurants[currentRestaurantIndex]
        print("👍 Liked restaurant: \(restaurant.name)")
        
        // Add to liked restaurants
        likedRestaurants.append(restaurant)
        
        // Move to next restaurant
        currentRestaurantIndex += 1
        
        // Check if we've finished swiping through all restaurants
        if currentRestaurantIndex >= restaurants.count {
            hasFinishedSwiping = true
            print("🎉 Finished swiping through all restaurants!")
        }
    }
    
    func swipeLeft() {
        guard currentRestaurantIndex < restaurants.count else { return }
        
        let restaurant = restaurants[currentRestaurantIndex]
        print("👎 Disliked restaurant: \(restaurant.name)")
        
        // Move to next restaurant
        currentRestaurantIndex += 1
        
        // Check if we've finished swiping through all restaurants
        if currentRestaurantIndex >= restaurants.count {
            hasFinishedSwiping = true
            print("🎉 Finished swiping through all restaurants!")
        }
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