import Foundation
import CoreLocation
import Combine

class RestaurantService: RestaurantServiceProtocol {
    private let apiKey = AppConfig.googlePlacesAPIKey
    private let baseURL = "https://maps.googleapis.com/maps/api/place"

    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchRestaurants(near location: CLLocationCoordinate2D, radius: Double, excludedCuisines: [String] = []) {
        isLoading = true
        errorMessage = nil

        let urlString = "\(baseURL)/nearbysearch/json?location=\(location.latitude),\(location.longitude)&radius=\(radius)&type=restaurant&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PlacesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Restaurant API error: \(error.localizedDescription)")
                        if let decodingError = error as? DecodingError {
                            print("Decoding error details: \(decodingError)")
                        }
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    let filteredRestaurants = response.results.filter { restaurant in
                        // Filter out excluded cuisines
                        let excludedCuisineMatch = excludedCuisines.contains { excludedCuisine in
                            restaurant.cuisineTypes.contains { cuisineType in
                                cuisineType.lowercased().contains(excludedCuisine.lowercased())
                            }
                        }

                        // Filter to only show open restaurants
                        let isOpen = restaurant.openingHours?.openNow ?? false

                        // More nuanced restaurant filtering
                        let hasRestaurantType = restaurant.cuisineTypes.contains { cuisineType in
                            let cuisine = cuisineType.lowercased()
                            return cuisine == "restaurant" ||
                                   cuisine.contains("food") ||
                                   cuisine.contains("meal") ||
                                   cuisine.contains("dining") ||
                                   cuisine.contains("cafe") ||
                                   cuisine.contains("bistro") ||
                                   cuisine.contains("eatery") ||
                                   cuisine.contains("kitchen") ||
                                   cuisine.contains("grill") ||
                                   cuisine.contains("diner") ||
                                   cuisine.contains("bakery")
                        }

                        // Exclude hotels, bars, and other non-restaurant establishments
                        let isNotHotelOrBar = !restaurant.cuisineTypes.contains { cuisineType in
                            let cuisine = cuisineType.lowercased()
                            return cuisine == "lodging" ||
                                   cuisine == "hotel" ||
                                   cuisine == "bar" ||
                                   cuisine == "night_club" ||
                                   cuisine == "shopping_mall" ||
                                   cuisine == "store"
                        }

                        // Additional check: if it has both restaurant AND bar types, prioritize restaurant
                        let hasRestaurantAndBar = restaurant.cuisineTypes.contains("restaurant") &&
                                                restaurant.cuisineTypes.contains("bar")

                        // If it has both restaurant and bar types, include it (many restaurants serve alcohol)
                        if hasRestaurantAndBar {
                            return !excludedCuisineMatch && isOpen
                        }

                        // For establishments with only bar type, exclude them
                        let isOnlyBar = restaurant.cuisineTypes.contains("bar") &&
                                      !restaurant.cuisineTypes.contains("restaurant")

                        return !excludedCuisineMatch && hasRestaurantType && isNotHotelOrBar && !isOnlyBar && isOpen
                    }

                    // Calculate distances for each restaurant
                    let restaurantsWithDistance = filteredRestaurants.map { restaurant in
                        let distance = self?.calculateDistance(from: location, to: restaurant.location)
                        return Restaurant(
                            id: restaurant.id,
                            name: restaurant.name,
                            address: restaurant.address,
                            phoneNumber: restaurant.phoneNumber,
                            website: restaurant.website,
                            rating: restaurant.rating,
                            userRatingsTotal: restaurant.userRatingsTotal,
                            priceLevel: restaurant.priceLevel,
                            cuisineTypes: restaurant.cuisineTypes,
                            popularDishes: restaurant.popularDishes,
                            photos: restaurant.photos,
                            openingHours: restaurant.openingHours,
                            location: restaurant.location,
                            distance: distance
                        )
                    }

                    self?.restaurants = restaurantsWithDistance
                }
            )
            .store(in: &cancellables)
    }

    func fetchRestaurantDetails(placeId: String) -> AnyPublisher<Restaurant, Error> {
        let urlString = "\(baseURL)/details/json?place_id=\(placeId)&fields=name,formatted_address,formatted_phone_number,website,rating,user_ratings_total,price_level,types,photos,opening_hours,geometry&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            return Fail(error: RestaurantError.invalidURL)
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PlaceDetailsResponse.self, decoder: JSONDecoder())
            .map(\.result)
            .eraseToAnyPublisher()
    }

    private func calculateDistance(from userLocation: CLLocationCoordinate2D, to restaurantLocation: CLLocationCoordinate2D) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let restaurantCLLocation = CLLocation(latitude: restaurantLocation.latitude, longitude: restaurantLocation.longitude)

        let distanceInMeters = userCLLocation.distance(from: restaurantCLLocation)
        let distanceInMiles = distanceInMeters / 1609.34 // Convert meters to miles

        return distanceInMiles
    }
}

// MARK: - Response Models
struct PlacesResponse: Codable {
    let results: [Restaurant]
    let status: String
}

struct PlaceDetailsResponse: Codable {
    let result: Restaurant
    let status: String
}

enum RestaurantError: Error, LocalizedError {
    case invalidURL
    case noResults
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noResults:
            return "No restaurants found"
        case .apiError(let message):
            return message
        }
    }
}
