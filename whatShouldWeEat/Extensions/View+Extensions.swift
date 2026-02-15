import SwiftUI

// MARK: - View Extensions
extension View {
    
    /// Applies a custom card style with shadow and corner radius
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Applies a custom button style with accent color
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
    }
    
    /// Applies a secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(.accentColor)
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
    }
    
    /// Applies a custom text field style
    func customTextFieldStyle() -> some View {
        self
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
    }
    
    /// Hides the keyboard when tapped outside
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Applies a loading overlay
    func loadingOverlay(_ isLoading: Bool) -> some View {
        ZStack {
            self
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
    
    /// Applies a custom navigation bar style
    func customNavigationBar(title: String) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
    }
    
    /// Applies a custom list style
    func customListStyle() -> some View {
        self
            .listStyle(InsetGroupedListStyle())
    }
}

// MARK: - Color Extensions
extension Color {
    static let customBackground = Color(.systemBackground)
    static let customSecondaryBackground = Color(.secondarySystemBackground)
    static let customLabel = Color(.label)
    static let customSecondaryLabel = Color(.secondaryLabel)
}

// MARK: - Animation Extensions
extension Animation {
    static let smoothTransition = Animation.easeInOut(duration: 0.3)
    static let quickTransition = Animation.easeInOut(duration: 0.15)
    static let slowTransition = Animation.easeInOut(duration: 0.5)
} 