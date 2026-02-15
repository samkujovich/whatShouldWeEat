import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppConstants.Colors.navyBackground,
                    AppConstants.Colors.navyPrimary
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App Logo with animation
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // App Title
                Text("What Should We Eat?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Loading indicator
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
} 