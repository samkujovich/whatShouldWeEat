import SwiftUI
import CoreLocation
import CoreGraphics

struct ModernSwipeInterface: View {
    let restaurants: [Restaurant]
    let onSwipe: (Restaurant, SwipeDirection) -> Void
    let onComplete: () -> Void
    
    @State private var currentIndex = 0
    @State private var isAnimating = false
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    private var currentRestaurant: Restaurant? {
        guard currentIndex < restaurants.count else { return nil }
        return restaurants[currentIndex]
    }
    
    private var nextRestaurant: Restaurant? {
        guard currentIndex + 1 < restaurants.count else { return nil }
        return restaurants[currentIndex + 1]
    }
    
    private var progress: Double {
        guard restaurants.count > 0 else { return 0 }
        return Double(currentIndex) / Double(restaurants.count - 1)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    AppConstants.Colors.primary.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                headerSection
                
                // Card Stack
                cardStackSection
                
                // Swipe Indicators
                swipeIndicatorsSection
                
                // Action Buttons
                actionButtonsSection
            }
        }
        .onAppear {
            checkCompletion()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Find Your Perfect Meal")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(.label))
            
            // Progress Bar and Counter
            VStack(spacing: 8) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppConstants.Colors.primary)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 8)
                
                // Counter text
                Text("\(currentIndex + 1) of \(restaurants.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Card Stack Section
    private var cardStackSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Next card (background)
                if let nextRestaurant = nextRestaurant {
                    RestaurantCardView(
                        restaurant: nextRestaurant,
                        onLike: {},
                        onDislike: {}
                    )
                    .frame(width: geometry.size.width) // Use full available width
                    .scaleEffect(0.95)
                    .opacity(0.5)
                    .offset(y: 20)
                }
                
                // Current card
                if let currentRestaurant = currentRestaurant {
                    RestaurantCardView(
                        restaurant: currentRestaurant,
                        onLike: {},
                        onDislike: {}
                    )
                    .frame(width: geometry.size.width) // Use full available width
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width) * 0.1))
                    .animation(isDragging ? nil : .easeOut(duration: 0.3), value: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isAnimating {
                                    isDragging = true
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                handleSwipeEnd(value)
                            }
                    )
                    .overlay(
                        swipeOverlay
                    )
                }
            }
            .frame(maxHeight: 500)
            .clipped() // Ensure cards don't overflow their container
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Swipe Overlay
    @ViewBuilder
    private var swipeOverlay: some View {
        if isDragging {
            Group {
                if dragOffset.width > 0 {
                    // Like overlay
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .fill(Color.green.opacity(0.3))
                        .overlay(
                            Circle()
                                .fill(Color.green)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                )
                        )
                        .opacity(min(abs(dragOffset.width) / CGFloat(150), 1))
                } else if dragOffset.width < 0 {
                    // Dislike overlay
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .fill(Color.red.opacity(0.3))
                        .overlay(
                            Circle()
                                .fill(Color.red)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.white)
                                )
                        )
                        .opacity(min(abs(dragOffset.width) / CGFloat(150), 1))
                }
            }
        }
    }
    
    // MARK: - Swipe Indicators Section
    private var swipeIndicatorsSection: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                Text("Swipe left to pass")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Swipe right to like")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 24) {
            // Dislike button
            ActionButton(
                icon: "xmark",
                color: .red,
                action: { handleSwipe(.left) }
            )
            
            // Undo button
            ActionButton(
                icon: "arrow.counterclockwise",
                color: .gray,
                size: .medium,
                action: { undoLastSwipe() }
            )
            .disabled(currentIndex == 0 || isAnimating)
            
            // Like button
            ActionButton(
                icon: "heart.fill",
                color: .green,
                action: { handleSwipe(.right) }
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Helper Methods
    private func handleSwipeEnd(_ value: DragGesture.Value) {
        isDragging = false
        let threshold: CGFloat = 150
        
        if abs(value.translation.width) > threshold {
            let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
            handleSwipe(direction)
        } else {
            // Snap back to center
            withAnimation(.easeOut(duration: 0.3)) {
                dragOffset = .zero
            }
        }
    }
    
    private func handleSwipe(_ direction: SwipeDirection) {
        guard let currentRestaurant = currentRestaurant, !isAnimating else { return }
        
        isAnimating = true
        
        // Animate card out
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = CGSize(
                width: direction == .right ? 500 : -500,
                height: 0
            )
        }
        
        // Call the swipe callback
        onSwipe(currentRestaurant, direction)
        
        // Move to next card after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            dragOffset = .zero
            isAnimating = false
            checkCompletion()
        }
    }
    
    private func undoLastSwipe() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
    
    private func checkCompletion() {
        if currentIndex >= restaurants.count {
            onComplete()
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let color: Color
    var size: ButtonSize = .large
    let action: () -> Void
    
    enum ButtonSize {
        case medium, large
        
        var frameSize: CGFloat {
            switch self {
            case .medium: return 48
            case .large: return 64
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: size.frameSize, height: size.frameSize)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                        .foregroundColor(color)
                )
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Swipe Direction
enum SwipeDirection {
    case left, right
}

// MARK: - Preview
#Preview {
    ModernSwipeInterface(
        restaurants: [
            Restaurant(
                id: "1",
                name: "Sample Restaurant",
                address: "123 Main St, San Francisco, CA",
                phoneNumber: "555-1234",
                website: "https://example.com",
                rating: 4.5,
                priceLevel: 2,
                cuisineTypes: ["italian", "pizza"],
                popularDishes: [],
                photos: [],
                openingHours: nil,
                location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                distance: 2.5
            )
        ],
        onSwipe: { _, _ in },
        onComplete: {}
    )
} 