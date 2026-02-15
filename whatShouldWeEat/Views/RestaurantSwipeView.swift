import SwiftUI
import CoreLocation

struct RestaurantSwipeView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var showingResults = false
    
    let preferences: MealPreferences
    let onGoHome: () -> Void
    
    var body: some View {
        ZStack {
            if viewModel.showLocationPermission {
                LocationPermissionView(
                    onLocationGranted: {
                        Task {
                            await viewModel.setupLocationAndFetchRestaurants()
                        }
                    },
                    onUseDefaultLocation: {
                        // Use default location
                        let defaultLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                        Task {
                            await viewModel.fetchRestaurants(near: defaultLocation)
                        }
                    },
                    onZipCodeEntered: { zipCode in
                        Task {
                            await viewModel.fetchRestaurantsWithZipCode(zipCode)
                        }
                    }
                )
            } else if viewModel.isLoading {
                LoadingView()
            } else if viewModel.restaurants.isEmpty {
                EmptyStateView()
            } else if showingResults || viewModel.hasFinishedSwiping {
                ResultsView(
                    likedRestaurants: viewModel.likedRestaurants,
                    allRestaurants: viewModel.restaurants,
                    onBackToSwiping: {
                        showingResults = false
                        // Reset the swiping state
                        viewModel.hasFinishedSwiping = false
                        viewModel.currentRestaurantIndex = 0
                        viewModel.likedRestaurants = []
                    },
                    onGoHome: {
                        // Reset the state
                        viewModel.hasFinishedSwiping = false
                        viewModel.currentRestaurantIndex = 0
                        viewModel.likedRestaurants = []
                        // Call the parent's onGoHome callback
                        onGoHome()
                    }
                )
            } else {
                ModernSwipeInterface(
                    restaurants: viewModel.restaurants,
                    onSwipe: { restaurant, direction in
                        switch direction {
                        case .left:
                            viewModel.swipeLeft()
                        case .right:
                            viewModel.swipeRight()
                        }
                    },
                    onComplete: {
                        viewModel.hasFinishedSwiping = true
                    }
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                // Error will be cleared automatically when showError is set to false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            guard viewModel.restaurants.isEmpty else { return }
            viewModel.mealPreferences = preferences
            await viewModel.setupLocationAndFetchRestaurants()
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("No restaurants found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your preferences or location to find more restaurants.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Results View
struct ResultsView: View {
    let likedRestaurants: [Restaurant]
    let allRestaurants: [Restaurant]
    let onBackToSwiping: () -> Void
    let onGoHome: () -> Void
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Home button
            HStack {
                Button("Back") {
                    onBackToSwiping()
                }
                .foregroundColor(AppConstants.Colors.primary)
                
                Spacer()
                
                Text("Final List")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: onGoHome) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(AppConstants.Colors.primary)
                }
            }
            .padding()
            
            // Modern Tab Selector
            HStack(spacing: 0) {
                TabButton(
                    title: "Group Matches",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabButton(
                    title: "My Votes",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                GroupMatchesTab(likedRestaurants: likedRestaurants)
                    .tag(0)
                
                MyVotesTab(allRestaurants: allRestaurants, likedRestaurants: likedRestaurants)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? AppConstants.Colors.primary : .secondary)
                
                Rectangle()
                    .fill(isSelected ? AppConstants.Colors.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Group Matches Tab
struct GroupMatchesTab: View {
    let likedRestaurants: [Restaurant]
    
    var body: some View {
        VStack {
            if likedRestaurants.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No group matches yet")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("When you add group functionality, restaurants that everyone likes will appear here.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding()
            } else {
                List(likedRestaurants, id: \.id) { restaurant in
                    RestaurantRowView(restaurant: restaurant)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - My Votes Tab
struct MyVotesTab: View {
    let allRestaurants: [Restaurant]
    let likedRestaurants: [Restaurant]
    
    private var restaurantsWithVotes: [RestaurantWithVote] {
        return allRestaurants.map { restaurant in
            let isLiked = likedRestaurants.contains { $0.id == restaurant.id }
            return RestaurantWithVote(restaurant: restaurant, isLiked: isLiked)
        }
    }
    
    var body: some View {
        VStack {
            if allRestaurants.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No restaurants to show")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Start swiping to see your votes here.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding()
            } else {
                List(restaurantsWithVotes, id: \.restaurant.id) { restaurantWithVote in
                    RestaurantVoteRowView(restaurantWithVote: restaurantWithVote)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Restaurant with Vote Model
struct RestaurantWithVote {
    let restaurant: Restaurant
    let isLiked: Bool
}

// MARK: - Restaurant Vote Row View
struct RestaurantVoteRowView: View {
    let restaurantWithVote: RestaurantWithVote
    
    var body: some View {
        HStack {
            // Restaurant Image
            AsyncImage(url: URL(string: restaurantWithVote.restaurant.photos.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurantWithVote.restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(restaurantWithVote.restaurant.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if let rating = restaurantWithVote.restaurant.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                    }
                    
                    if let priceLevel = restaurantWithVote.restaurant.priceLevel {
                        Text(String(repeating: "$", count: priceLevel))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Vote Indicator
            HStack(spacing: 4) {
                Image(systemName: restaurantWithVote.isLiked ? "heart.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(restaurantWithVote.isLiked ? .green : .red)
                
                Text(restaurantWithVote.isLiked ? "Yes" : "No")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(restaurantWithVote.isLiked ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Restaurant Row View
struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: restaurant.photos.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if let rating = restaurant.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                    }
                    
                    if let priceLevel = restaurant.priceLevel {
                        Text(String(repeating: "$", count: priceLevel))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
} 