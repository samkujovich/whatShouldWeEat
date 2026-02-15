//
//  ContentView.swift
//  whatShouldWeEat
//
//  Created by Sam Kujovich on 7/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager: AuthenticationManager
    @StateObject private var appViewModel: AppViewModel
    
    init() {
        let sharedAuthManager = AuthenticationManager()
        self._authManager = StateObject(wrappedValue: sharedAuthManager)
        self._appViewModel = StateObject(wrappedValue: AppViewModel(authenticationManager: sharedAuthManager))
    }
    
    var body: some View {
        ZStack {
            switch appViewModel.currentView {
            case .loading:
                LoadingView()
                
            case .login:
                LoginView()
                    .environmentObject(authManager)
                
            case .welcome:
                WelcomeView(
                    onStart: {
                        appViewModel.currentView = .preferences
                    },
                    onProfileTapped: {
                        appViewModel.currentView = .profile
                    }
                )
                
            case .preferences:
                PreferencesSetupView(
                    preferences: $appViewModel.mealPreferences,
                    onContinue: {
                        appViewModel.completeOnboarding()
                        appViewModel.currentView = .swiping
                    }
                )
                
            case .swiping:
                RestaurantSwipeView(
                    preferences: appViewModel.mealPreferences,
                    onGoHome: {
                        appViewModel.currentView = .preferences
                    }
                )

            case .profile:
                ProfileView(onGoBack: {
                    appViewModel.currentView = .welcome
                })
                .environmentObject(authManager)
            }
        }
        .alert("Error", isPresented: $authManager.showError) {
            Button("OK") {
                authManager.clearError()
            }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onStart: () -> Void
    var onProfileTapped: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 40) {
            // Profile button in top-right
            HStack {
                Spacer()
                if let onProfileTapped = onProfileTapped {
                    Button(action: onProfileTapped) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }
            }

            Spacer()

            // App Icon/Logo
            VStack(spacing: 20) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.primary)
                
                Text("What Should We Eat?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            // Description
            VStack(spacing: 16) {
                Text("Discover amazing restaurants together")
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text("Swipe through restaurants, find your favorites, and let the app match you with the perfect dining spot for your group.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Start Button
            Button(action: onStart) {
                HStack {
                    Text("Get Started")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    ContentView()
} 