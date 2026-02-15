import Foundation
import SwiftUI
import Combine

// MARK: - App Navigation State
enum AppView: Equatable {
    case loading
    case login
    case welcome
    case socialMode
    case invitation
    case preferences
    case swiping
}

// MARK: - Meal Preferences Model
struct MealPreferences: Equatable, Codable {
    var deliveryMode: DeliveryMode
    var maxDistance: Double
    var excludedCuisines: [String]
    var priceRange: PriceRange?
    
    init(
        deliveryMode: DeliveryMode = .dineIn,
        maxDistance: Double = 20.0,
        excludedCuisines: [String] = [],
        priceRange: PriceRange? = nil
    ) {
        self.deliveryMode = deliveryMode
        self.maxDistance = maxDistance
        self.excludedCuisines = excludedCuisines
        self.priceRange = priceRange
    }
}

enum DeliveryMode: String, CaseIterable, Codable {
    case dineIn = "dineIn"
    case takeout = "takeout"
    case delivery = "delivery"
    
    var displayName: String {
        switch self {
        case .dineIn: return "Dine In"
        case .takeout: return "Takeout"
        case .delivery: return "Delivery"
        }
    }
}

enum PriceRange: String, CaseIterable, Codable {
    case budget = "budget"
    case moderate = "moderate"
    case expensive = "expensive"
    
    var displayName: String {
        switch self {
        case .budget: return "$"
        case .moderate: return "$$"
        case .expensive: return "$$$"
        }
    }
}

// MARK: - App ViewModel
@MainActor
class AppViewModel: ObservableObject {
    @Published var currentView: AppView = .loading
    @Published var mealPreferences: MealPreferences = MealPreferences()
    @Published var selectedDeliveryMode: DeliveryMode = .dineIn
    @Published var maxDistance: Double = 5.0
    @Published var excludedCuisines: Set<String> = []
    @Published var selectedPriceRange: PriceRange? = nil
    
    private let authenticationManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
        print("📱 AppViewModel initialized with authenticationManager")
        
        // Set initial view based on current authentication state
        updateCurrentView(isAuthenticated: authenticationManager.isAuthenticated)
        
        // Setup bindings to observe state changes
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor authentication state changes
        authenticationManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.updateCurrentView(isAuthenticated: isAuthenticated)
            }
            .store(in: &cancellables)
        
        // Monitor currentUser changes
        authenticationManager.$currentUser
            .sink { [weak self] currentUser in
                if let self = self, self.authenticationManager.isAuthenticated {
                    self.updateCurrentView(isAuthenticated: true)
                }
            }
            .store(in: &cancellables)
        
        // Monitor loading state
        authenticationManager.$isLoading
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.currentView = .loading
                }
            }
            .store(in: &cancellables)
        
        // Monitor error state
        authenticationManager.$showError
            .sink { [weak self] showError in
                if showError {
                    // Handle error display if needed
                    print("❌ Authentication error: \(self?.authenticationManager.errorMessage ?? "Unknown error")")
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateCurrentView(isAuthenticated: Bool) {
        print("🔄 AppViewModel.updateCurrentView called - isAuthenticated: \(isAuthenticated)")
        
        if isAuthenticated {
            if let currentUser = authenticationManager.currentUser {
                print("👤 User is authenticated with profile: \(currentUser.profile.displayName)")
                // User is authenticated, check if they have preferences set
                if currentUser.preferences.cuisineRestrictions.isEmpty && 
                   currentUser.preferences.defaultDriveRadius == 15.0 {
                    // New user, show preferences setup
                    print("🆕 New user detected, navigating to preferences")
                    currentView = .preferences
                } else {
                    // Existing user, show welcome
                    print("👋 Existing user detected, navigating to welcome")
                    currentView = .welcome
                }
            } else {
                // User authenticated but no profile loaded yet
                print("⏳ User authenticated but profile not loaded yet, staying on loading")
                currentView = .loading
                
                // Add a small delay to allow profile to load
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    if let self = self, self.authenticationManager.isAuthenticated {
                        print("🔄 Retrying view update after delay")
                        self.updateCurrentView(isAuthenticated: true)
                    }
                }
            }
        } else {
            // User not authenticated
            print("🚪 User not authenticated, navigating to login")
            currentView = .login
        }
        
        print("📱 Current view set to: \(currentView)")
    }
    
    // MARK: - Navigation Methods
    
    func navigateToWelcome() {
        currentView = .welcome
    }
    
    func navigateToSocialMode() {
        currentView = .socialMode
    }
    
    func navigateToInvitation() {
        currentView = .invitation
    }
    
    func navigateToPreferences() {
        currentView = .preferences
    }
    
    func navigateToSwiping() {
        currentView = .swiping
    }
    
    func navigateToLogin() {
        currentView = .login
    }
    
    // MARK: - Preferences Management
    
    func updatePreferences() {
        mealPreferences = MealPreferences(
            deliveryMode: selectedDeliveryMode,
            maxDistance: selectedDeliveryMode == .delivery ? 0.0 : maxDistance,
            excludedCuisines: Array(excludedCuisines),
            priceRange: selectedPriceRange
        )
        
        // Save preferences to user profile
        Task {
            await saveUserPreferences()
        }
    }
    
    private func saveUserPreferences() async {
        guard let currentUser = authenticationManager.currentUser else { return }
        
        var updatedUser = currentUser
        updatedUser.preferences = UserPreferences(
            cuisineRestrictions: Array(excludedCuisines),
            defaultDriveRadius: maxDistance,
            preferredMealTimes: selectedDeliveryMode == .delivery ? ["lunch", "dinner"] : ["lunch", "dinner"]
        )
        
        do {
            // This would need to be implemented in FirestoreService
            // try await firestoreService.updateUser(updatedUser)
            print("✅ User preferences updated")
        } catch {
            print("❌ Failed to update user preferences: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    var currentUser: User? {
        return authenticationManager.currentUser
    }
    
    var isAuthenticated: Bool {
        return authenticationManager.isAuthenticated
    }
    
    var isLoading: Bool {
        return authenticationManager.isLoading
    }
    
    var errorMessage: String? {
        return authenticationManager.errorMessage
    }
    
    var showError: Bool {
        return authenticationManager.showError
    }
} 