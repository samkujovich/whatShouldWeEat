import SwiftUI
import CoreLocation

struct RestaurantCardView: View {
    let restaurant: Restaurant
    let onLike: () -> Void
    let onDislike: () -> Void

    @State private var restaurantImage: UIImage?
    @State private var isLoadingImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Image Section
            heroImageSection

            // Content Section
            contentSection
        }
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .onAppear {
            loadRestaurantImage()
        }
        .onChange(of: restaurant.id) { _, _ in
            // Reset image state when restaurant changes
            restaurantImage = nil
            isLoadingImage = false
            loadRestaurantImage()
        }
        .id(restaurant.id) // Force SwiftUI to create a new view instance for each restaurant
    }

    // MARK: - View Components

    private var heroImageSection: some View {
        ZStack {
            // Constrain the entire image section to prevent overflow
            // Hero Image
            if let image = restaurantImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, height: 256) // Constrain width to container
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 256)
                    .overlay(
                        Group {
                            if isLoadingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "fork.knife.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            }
                        }
                    )
            }

            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.4),
                    Color.clear,
                    Color.clear
                ]),
                startPoint: .bottom,
                endPoint: .top
            )

            // Status Badge (Open/Closed)
            VStack {
                HStack {
                    Spacer()

                    if let isOpen = restaurant.openingHours?.openNow {
                        BadgeView(
                            text: isOpen ? "Open" : "Closed",
                            backgroundColor: isOpen ? Color.green : Color.red,
                            textColor: Color.white
                        )
                    }
                }
                .padding(.top, 24)
                .padding(.trailing, 16)

                Spacer()
            }

            // Price Range Badge
            VStack {
                HStack {
                    BadgeView(
                        text: renderPriceRange(restaurant.priceLevel ?? 0),
                        backgroundColor: Color.black.opacity(0.5),
                        textColor: Color.white
                    )
                    .padding(.leading, 16)

                    Spacer()
                }
                .padding(.top, 24)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity) // Ensure the image section doesn't overflow
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Content padding to prevent overflow
            // Restaurant Name & Cuisine
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.label))
                    .lineLimit(1)

                if !restaurant.cuisineTypes.isEmpty {
                    BadgeView(
                        text: getPrimaryCuisineType(),
                        backgroundColor: AppConstants.Colors.primary.opacity(0.1),
                        textColor: AppConstants.Colors.primary,
                        isOutlined: true
                    )
                }
            }

            // Rating
            if let rating = restaurant.rating {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(index < Int(rating) ? .yellow : Color(.tertiaryLabel))
                        }
                    }

                    Text(String(format: "%.1f", rating))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.label))

                    if let reviewCount = restaurant.userRatingsTotal {
                        Text("(\(reviewCount) reviews)")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }

            // Location & Time
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                    Text("\(AppUtilities.formatDistance(restaurant.distance ?? 0))")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                    Text("\(AppUtilities.estimateDriveTime(distance: restaurant.distance ?? 0))")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            // Description (using address as description)
            Text(restaurant.address)
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
                .lineLimit(2)

            // Popular Dishes
            if !restaurant.popularDishes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Popular dishes:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.label))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(restaurant.popularDishes.prefix(3), id: \.self) { dish in
                            BadgeView(
                                text: dish,
                                backgroundColor: AppConstants.Colors.primary.opacity(0.1),
                                textColor: AppConstants.Colors.primary
                            )
                        }
                    }
                }
            }
        }
        .padding(24)
    }

    // MARK: - Helper Methods

    private func renderPriceRange(_ level: Int) -> String {
        // Handle edge cases
        let adjustedLevel = max(1, min(level, 4)) // Ensure at least 1, max 4
        let priceString = String(repeating: "$", count: adjustedLevel)
        return priceString
    }

    private func loadRestaurantImage() {
        guard let firstPhoto = restaurant.photos.first else {
            return
        }

        isLoadingImage = true

        // Construct Google Places photo URL from photo reference
        let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(firstPhoto)&key=\(AppConfig.googlePlacesAPIKey)"

        guard let url = URL(string: photoURL) else {
            isLoadingImage = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingImage = false
                if let data = data, let image = UIImage(data: data) {
                    self.restaurantImage = image
                } else if let error = error {
                    print("Failed to load image for \(self.restaurant.name): \(error.localizedDescription)")
                }
            }
        }.resume()
    }



    private func getFilteredCuisineTypes() -> [String] {
        let genericTerms = ["food", "point_of_interest", "establishment", "meal_takeaway"]
        let barTerms = ["bar", "night_club"]

        // If it's primarily a restaurant (has restaurant type), filter out bar terms
        let isPrimarilyRestaurant = restaurant.cuisineTypes.contains("restaurant")

        let termsToFilter = isPrimarilyRestaurant ? genericTerms + barTerms : genericTerms

        let filteredTypes = restaurant.cuisineTypes
            .filter { cuisine in
                !termsToFilter.contains(cuisine.lowercased())
            }
            .prefix(3)
            .map { $0 }

        // If no filtered types, fall back to showing some basic types
        if filteredTypes.isEmpty && !restaurant.cuisineTypes.isEmpty {
            let fallbackTypes = restaurant.cuisineTypes
                .filter { cuisine in
                    !["bar", "night_club"].contains(cuisine.lowercased())
                }
                .prefix(2)
                .map { $0 }
            return Array(fallbackTypes)
        }

        return Array(filteredTypes)
    }

    private func getPrimaryCuisineType() -> String {
        let filteredTypes = getFilteredCuisineTypes()
        let primaryType = filteredTypes.first ?? restaurant.cuisineTypes.first ?? "Restaurant"
        return primaryType.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Badge View Component
struct BadgeView: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    var icon: String? = nil
    var isOutlined: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }

            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isOutlined ? Color.clear : backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOutlined ? backgroundColor : Color.clear, lineWidth: 1)
                )
        )
        .foregroundColor(textColor)
    }
}

// MARK: - Preview
#Preview {
    RestaurantCardView(
        restaurant: Restaurant(
            id: "1",
            name: "Sample Restaurant",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "555-1234",
            website: "https://example.com",
            rating: 4.5,
            priceLevel: 2,
            cuisineTypes: ["italian", "pizza"],
            popularDishes: ["Margherita Pizza", "Carbonara", "Tiramisu"],
            photos: [],
            openingHours: nil,
            location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            distance: 2.5
        ),
        onLike: {},
        onDislike: {}
    )
    .padding()
}
