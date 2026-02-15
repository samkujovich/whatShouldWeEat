import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.white)
                    
                    Text("What Should We Eat?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Find the perfect restaurant with friends")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Sign In Button
                VStack(spacing: 20) {
                    Button(action: {
                        Task {
                            await authManager.signInWithGoogle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Continue with Google")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.2, green: 0.3, blue: 0.6))
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                    }
                    .disabled(authManager.isLoading)
                    .scaleEffect(authManager.isLoading ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: authManager.isLoading)
                    
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                }
                .padding(.horizontal, 40)
                
                // Terms and Privacy
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Button("Terms of Service") {
                            // TODO: Open terms of service
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        
                        Text("and")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button("Privacy Policy") {
                            // TODO: Open privacy policy
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
            }
        }
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK") {
                authManager.clearError()
            }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: authManager.errorMessage) { _, errorMessage in
            showingError = errorMessage != nil
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 