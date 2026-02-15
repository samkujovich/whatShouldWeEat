import SwiftUI

struct SocialModeSelectionView: View {
    let onCreateSession: () -> Void
    let onJoinSession: () -> Void
    let onSoloMode: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header
            VStack(spacing: 20) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                Text("How would you like to search?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            // Description
            VStack(spacing: 16) {
                Text("Choose whether to find restaurants on your own or collaborate with friends to make the perfect choice together.")
                    .font(.body)
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Selection Buttons
            VStack(spacing: 20) {
                // Solo Mode Button
                Button(action: onSoloMode) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Search Alone")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Find restaurants just for you")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .cornerRadius(12)
                }
                
                // Create Session Button
                Button(action: onCreateSession) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.2.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create Session")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Start a new group session")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.2, green: 0.6, blue: 0.4))
                    .cornerRadius(12)
                }
                
                // Join Session Button
                Button(action: onJoinSession) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.2.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Join Session")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Join an existing group session")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.6, green: 0.4, blue: 0.2))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    SocialModeSelectionView(
        onCreateSession: {},
        onJoinSession: {},
        onSoloMode: {}
    )
} 