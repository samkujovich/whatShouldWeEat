import SwiftUI

struct EditProfileView: View {
    let user: User?
    let onSave: (User) -> Void
    
    @State private var displayName: String
    @State private var defaultDriveRadius: Double
    @State private var cuisineRestrictions: [String]
    @State private var preferredMealTimes: [String]
    @State private var showingCuisinePicker = false
    @State private var showingMealTimePicker = false
    @State private var isLoading = false
    
    @Environment(\.dismiss) private var dismiss
    
    init(user: User?, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        
        _displayName = State(initialValue: user?.profile.displayName ?? "")
        _defaultDriveRadius = State(initialValue: user?.preferences.defaultDriveRadius ?? 15.0)
        _cuisineRestrictions = State(initialValue: user?.preferences.cuisineRestrictions ?? [])
        _preferredMealTimes = State(initialValue: user?.preferences.preferredMealTimes ?? ["lunch", "dinner"])
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppConstants.Colors.navyBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Picture Section
                        profilePictureSection
                        
                        // Basic Info Section
                        basicInfoSection
                        
                        // Preferences Section
                        preferencesSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarColor(AppConstants.Colors.navyBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(.white)
                    .disabled(isLoading || displayName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingCuisinePicker) {
            CuisineRestrictionsPicker(selectedCuisines: $cuisineRestrictions)
        }
        .sheet(isPresented: $showingMealTimePicker) {
            MealTimePicker(selectedTimes: $preferredMealTimes)
        }
    }
    
    // MARK: - Profile Picture Section
    
    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            // Profile Picture
            if let user = user,
               let photoURL = user.profile.photoURL,
               let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 3))
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text("Profile picture managed by Google")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Basic Info Section
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    TextField("Enter your name", text: $displayName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(user?.profile.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppConstants.Colors.navyCard)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppConstants.Colors.navyCard)
        )
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                // Default Drive Radius
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Default Drive Radius")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(defaultDriveRadius)) miles")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Slider(value: $defaultDriveRadius, in: 1...50, step: 1)
                        .accentColor(AppConstants.Colors.navyHighlight)
                }
                
                // Cuisine Restrictions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Cuisine Restrictions")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Edit") {
                            showingCuisinePicker = true
                        }
                        .font(.subheadline)
                        .foregroundColor(AppConstants.Colors.navyHighlight)
                    }
                    
                    if cuisineRestrictions.isEmpty {
                        Text("No restrictions set")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppConstants.Colors.navyCard)
                            )
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(cuisineRestrictions, id: \.self) { cuisine in
                                Text(cuisine.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppConstants.Colors.navyHighlight)
                                    )
                            }
                        }
                    }
                }
                
                // Preferred Meal Times
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Preferred Meal Times")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Edit") {
                            showingMealTimePicker = true
                        }
                        .font(.subheadline)
                        .foregroundColor(AppConstants.Colors.navyHighlight)
                    }
                    
                    if preferredMealTimes.isEmpty {
                        Text("No preferred times set")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppConstants.Colors.navyCard)
                            )
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(preferredMealTimes, id: \.self) { time in
                                Text(time.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppConstants.Colors.navyHighlight)
                                    )
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppConstants.Colors.navyCard)
        )
    }
    
    // MARK: - Helper Methods
    
    private func saveProfile() {
        guard let user = user else { return }
        
        isLoading = true
        
        let updatedPreferences = UserPreferences(
            cuisineRestrictions: cuisineRestrictions,
            defaultDriveRadius: defaultDriveRadius,
            preferredMealTimes: preferredMealTimes
        )
        
        let updatedProfile = UserProfile(
            uid: user.profile.uid,
            email: user.profile.email,
            displayName: displayName,
            photoURL: user.profile.photoURL
        )
        
        let updatedUser = User(
            id: user.id,
            profile: updatedProfile,
            preferences: updatedPreferences,
            stats: user.stats
        )
        
        onSave(updatedUser)
        isLoading = false
        dismiss()
    }
}

// MARK: - Supporting Views

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppConstants.Colors.navyCard)
            )
    }
}

struct CuisineRestrictionsPicker: View {
    @Binding var selectedCuisines: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let availableCuisines = [
        "vegetarian", "vegan", "gluten-free", "dairy-free", "nut-free",
        "seafood-free", "halal", "kosher", "low-carb", "keto"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.Colors.navyBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Select Cuisine Restrictions")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(availableCuisines, id: \.self) { cuisine in
                                CuisineToggleButton(
                                    title: cuisine.capitalized,
                                    isSelected: selectedCuisines.contains(cuisine)
                                ) {
                                    if selectedCuisines.contains(cuisine) {
                                        selectedCuisines.removeAll { $0 == cuisine }
                                    } else {
                                        selectedCuisines.append(cuisine)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(AppConstants.Colors.navyBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct CuisineToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppConstants.Colors.navyHighlight : AppConstants.Colors.navyCard)
                )
        }
    }
}

struct MealTimePicker: View {
    @Binding var selectedTimes: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let availableTimes = ["breakfast", "lunch", "dinner", "late-night"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppConstants.Colors.navyBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Select Preferred Meal Times")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(availableTimes, id: \.self) { time in
                            MealTimeToggleButton(
                                title: time.capitalized,
                                isSelected: selectedTimes.contains(time)
                            ) {
                                if selectedTimes.contains(time) {
                                    selectedTimes.removeAll { $0 == time }
                                } else {
                                    selectedTimes.append(time)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(AppConstants.Colors.navyBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct MealTimeToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppConstants.Colors.navyHighlight : AppConstants.Colors.navyCard)
            )
        }
    }
}

#Preview {
    EditProfileView(user: nil) { _ in }
} 