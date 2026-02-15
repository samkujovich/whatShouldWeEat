import Foundation
import CoreLocation
import Combine

protocol RestaurantServiceProtocol: ObservableObject {
    var restaurants: [Restaurant] { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    var restaurantsPublisher: Published<[Restaurant]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }

    func fetchRestaurants(near location: CLLocationCoordinate2D, radius: Double, excludedCuisines: [String])
} 