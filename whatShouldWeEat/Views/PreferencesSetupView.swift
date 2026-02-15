import SwiftUI

struct PreferencesSetupView: View {
    @Binding var preferences: MealPreferences
    @State private var selectedDeliveryMode: DeliveryMode = .dineIn
    @State private var maxDistance: Double = AppConfig.defaultMaxDistance
    @State private var excludedCuisines: Set<String> = []
    @State private var selectedPriceRange: PriceRange? = nil
    
    let onContinue: (() -> Void)?
    
    init(preferences: Binding<MealPreferences>, onContinue: (() -> Void)? = nil) {
        self._preferences = preferences
        self.onContinue = onContinue
    }
    
    let availableCuisines = [
        "American", "Italian", "Chinese", "Japanese", "Mexican", "Thai", "Indian", "French", "Greek", "Mediterranean",
        "Korean", "Vietnamese", "Spanish", "German", "British", "Caribbean", "African", "Middle Eastern", "Turkish", "Russian"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    continueButton
                    deliveryModeSection
                    distanceSection
                    priceRangeSection
                    excludedCuisinesSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Let's find your perfect meal!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Tell us your preferences to get personalized restaurant recommendations")
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.navySubtitle)
        }
        .padding(.horizontal)
    }
    
    private var continueButton: some View {
        Button(action: {
            updatePreferences()
        }) {
            Text("Continue")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.Colors.navyPrimary)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var deliveryModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How would you like to eat?")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(DeliveryMode.allCases, id: \.self) { mode in
                    DeliveryModeButton(
                        mode: mode,
                        isSelected: selectedDeliveryMode == mode
                    ) {
                        selectedDeliveryMode = mode
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var distanceSection: some View {
        Group {
            if selectedDeliveryMode != .delivery {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How far are you willing to travel?")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("0 miles")
                            Spacer()
                            Text("\(String(format: "%.1f", maxDistance)) miles")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("20 miles")
                        }
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.navySubtitle)
                        
                        Slider(value: $maxDistance, in: 0.5...20, step: 0.5)
                            .accentColor(AppConstants.Colors.navyPrimary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var priceRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's your budget?")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(PriceRange.allCases, id: \.self) { range in
                    PriceRangeButton(
                        range: range,
                        isSelected: selectedPriceRange == range
                    ) {
                        selectedPriceRange = selectedPriceRange == range ? nil : range
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var excludedCuisinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Any cuisines you'd like to avoid?")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(availableCuisines, id: \.self) { cuisine in
                    CuisineToggleButton(
                        title: cuisine,
                        isSelected: excludedCuisines.contains(cuisine)
                    ) {
                        if excludedCuisines.contains(cuisine) {
                            excludedCuisines.remove(cuisine)
                        } else {
                            excludedCuisines.insert(cuisine)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func updatePreferences() {
        preferences = MealPreferences(
            deliveryMode: selectedDeliveryMode,
            maxDistance: selectedDeliveryMode == .delivery ? 0.0 : maxDistance,
            excludedCuisines: Array(excludedCuisines),
            priceRange: selectedPriceRange
        )
        onContinue?()
    }
}

// MARK: - Supporting Views

struct DeliveryModeButton: View {
    let mode: DeliveryMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                
                Text(mode.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? AppConstants.Colors.navyPrimary : AppConstants.Colors.navyUnselected)
            .foregroundColor(isSelected ? .white : AppConstants.Colors.navyPrimary)
            .cornerRadius(12)
        }
    }
    
    private var iconName: String {
        switch mode {
        case .delivery: return "bicycle"
        case .takeout: return "car"
        case .dineIn: return "fork.knife"
        }
    }
}

struct PriceRangeButton: View {
    let range: PriceRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(range.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? AppConstants.Colors.navyPrimary : AppConstants.Colors.navyUnselected)
                .foregroundColor(isSelected ? .white : AppConstants.Colors.navyPrimary)
                .cornerRadius(8)
        }
    }
}

#Preview {
    PreferencesSetupView(
        preferences: .constant(MealPreferences(
            deliveryMode: .dineIn,
            maxDistance: 5.0,
            excludedCuisines: [],
            priceRange: nil
        ))
    )
} 