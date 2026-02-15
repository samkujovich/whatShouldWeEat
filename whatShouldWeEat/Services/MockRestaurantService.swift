import Foundation
import CoreLocation
import Combine

class MockRestaurantService: RestaurantServiceProtocol {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchRestaurants(near location: CLLocationCoordinate2D, radius: Double, excludedCuisines: [String] = []) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.restaurants = self.generateMockRestaurants(near: location, excludedCuisines: excludedCuisines)
            self.isLoading = false
        }
    }
    
    private func generateMockRestaurants(near location: CLLocationCoordinate2D, excludedCuisines: [String]) -> [Restaurant] {
        let mockRestaurants = [
            Restaurant(
                id: "1",
                name: "Pizza Palace",
                address: "123 Main St, Downtown",
                phoneNumber: "555-1234",
                website: "https://pizzapalace.com",
                rating: 4.5,
                priceLevel: 2,
                cuisineTypes: ["pizza", "italian", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude + 0.001, longitude: location.longitude + 0.001),
                distance: 0.5
            ),
            Restaurant(
                id: "2",
                name: "Sushi Express",
                address: "456 Oak Ave, Midtown",
                phoneNumber: "555-5678",
                website: "https://sushiexpress.com",
                rating: 4.2,
                priceLevel: 3,
                cuisineTypes: ["japanese", "sushi", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude - 0.002, longitude: location.longitude + 0.002),
                distance: 1.2
            ),
            Restaurant(
                id: "3",
                name: "Burger Joint",
                address: "789 Pine St, Uptown",
                phoneNumber: "555-9012",
                website: "https://burgerjoint.com",
                rating: 4.0,
                priceLevel: 1,
                cuisineTypes: ["american", "burger", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude + 0.003, longitude: location.longitude - 0.001),
                distance: 2.1
            ),
            Restaurant(
                id: "4",
                name: "Taco Fiesta",
                address: "321 Elm St, Downtown",
                phoneNumber: "555-3456",
                website: "https://tacofiesta.com",
                rating: 4.3,
                priceLevel: 1,
                cuisineTypes: ["mexican", "tacos", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude - 0.001, longitude: location.longitude - 0.002),
                distance: 0.8
            ),
            Restaurant(
                id: "5",
                name: "Thai Garden",
                address: "654 Maple Dr, Midtown",
                phoneNumber: "555-7890",
                website: "https://thaigarden.com",
                rating: 4.7,
                priceLevel: 2,
                cuisineTypes: ["thai", "asian", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude + 0.002, longitude: location.longitude - 0.003),
                distance: 1.5
            ),
            Restaurant(
                id: "6",
                name: "Steakhouse Prime",
                address: "987 Cedar Ln, Uptown",
                phoneNumber: "555-2345",
                website: "https://steakhouseprime.com",
                rating: 4.8,
                priceLevel: 4,
                cuisineTypes: ["american", "steakhouse", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude - 0.003, longitude: location.longitude + 0.003),
                distance: 2.8
            ),
            Restaurant(
                id: "7",
                name: "Pasta House",
                address: "147 Birch Ave, Downtown",
                phoneNumber: "555-6789",
                website: "https://pastahouse.com",
                rating: 4.1,
                priceLevel: 2,
                cuisineTypes: ["italian", "pasta", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude + 0.004, longitude: location.longitude + 0.004),
                distance: 3.2
            ),
            Restaurant(
                id: "8",
                name: "Chinese Dragon",
                address: "258 Spruce St, Midtown",
                phoneNumber: "555-0123",
                website: "https://chinesedragon.com",
                rating: 4.4,
                priceLevel: 2,
                cuisineTypes: ["chinese", "asian", "restaurant"],
                popularDishes: [],
                photos: [],
                openingHours: Restaurant.OpeningHours(openNow: true),
                location: CLLocationCoordinate2D(latitude: location.latitude - 0.004, longitude: location.longitude - 0.004),
                distance: 3.5
            )
        ]
        
        // Filter out excluded cuisines
        return mockRestaurants.filter { restaurant in
            !excludedCuisines.contains { excludedCuisine in
                restaurant.cuisineTypes.contains { cuisineType in
                    cuisineType.lowercased().contains(excludedCuisine.lowercased())
                }
            }
        }
    }
} 