import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showingSignOutAlert = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.05, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Statistics Section
                        statisticsSection
                        
                        // Preferences Section
                        preferencesSection
                        
                        // Settings Section
                        settingsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarColor(Color(red: 0.05, green: 0.1, blue: 0.2))
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authManager.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: authManager.currentUser) { updatedUser in
                Task {
                    await authManager.updateUserProfile(updatedUser)
                }
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Picture
            if let user = authManager.currentUser,
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
            
            // User Info
            VStack(spacing: 8) {
                Text(authManager.currentUser?.profile.displayName ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(authManager.currentUser?.profile.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Member since \(formatDate(authManager.currentUser?.profile.createdAt))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Edit Profile Button
            Button("Edit Profile") {
                showingEditProfile = true
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.2, green: 0.3, blue: 0.6))
            )
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Stats")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Meals",
                    value: "\(authManager.currentUser?.stats.totalMeals ?? 0)",
                    icon: "fork.knife"
                )
                
                StatCard(
                    title: "Total Swipes",
                    value: "\(authManager.currentUser?.stats.totalSwipes ?? 0)",
                    icon: "hand.tap"
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Favorites",
                    value: "\(authManager.currentUser?.stats.favoriteRestaurants.count ?? 0)",
                    icon: "heart"
                )
                
                StatCard(
                    title: "Sessions",
                    value: "0", // TODO: Add session count
                    icon: "person.2"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.15, blue: 0.3))
        )
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                PreferenceRow(
                    title: "Default Radius",
                    value: "\(Int(authManager.currentUser?.preferences.defaultDriveRadius ?? 15)) miles",
                    icon: "location.circle"
                )
                
                PreferenceRow(
                    title: "Cuisine Restrictions",
                    value: "\(authManager.currentUser?.preferences.cuisineRestrictions.count ?? 0) restrictions",
                    icon: "exclamationmark.triangle"
                )
                
                PreferenceRow(
                    title: "Preferred Times",
                    value: (authManager.currentUser?.preferences.preferredMealTimes ?? []).joined(separator: ", "),
                    icon: "clock"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.15, blue: 0.3))
        )
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                SettingsRow(
                    title: "Notifications",
                    icon: "bell",
                    action: { /* TODO: Open notifications settings */ }
                )
                
                SettingsRow(
                    title: "Privacy",
                    icon: "lock",
                    action: { /* TODO: Open privacy settings */ }
                )
                
                SettingsRow(
                    title: "Help & Support",
                    icon: "questionmark.circle",
                    action: { /* TODO: Open help */ }
                )
                
                SettingsRow(
                    title: "Sign Out",
                    icon: "rectangle.portrait.and.arrow.right",
                    isDestructive: true,
                    action: { showingSignOutAlert = true }
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.15, blue: 0.3))
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.2, blue: 0.4))
        )
    }
}

struct PreferenceRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 8)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .white.opacity(0.8))
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Navigation Bar Extension

extension View {
    func navigationBarColor(_ color: Color) -> some View {
        self.modifier(NavigationBarModifier(color: color))
    }
}

struct NavigationBarModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    ProfileView()
} 