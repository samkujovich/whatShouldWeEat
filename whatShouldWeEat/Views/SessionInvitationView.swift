import SwiftUI

struct SessionInvitationView: View {
    @State private var inviteMethod: InviteMethod = .phone
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var showingShareSheet = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let sessionId: String
    let hostName: String
    let onInviteSent: () -> Void
    let onSkip: () -> Void
    
    enum InviteMethod: String, CaseIterable {
        case phone = "phone"
        case email = "email"
        case link = "link"
        
        var displayName: String {
            switch self {
            case .phone: return "Phone Number"
            case .email: return "Email"
            case .link: return "Share Link"
            }
        }
        
        var icon: String {
            switch self {
            case .phone: return "phone.circle.fill"
            case .email: return "envelope.circle.fill"
            case .link: return "link.circle.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                
                Text("Invite Friends")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Invite friends to join your dining session and discover restaurants together.")
                    .font(.body)
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Invite Method Selection
            VStack(spacing: 16) {
                Text("Choose how to invite:")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                HStack(spacing: 12) {
                    ForEach(InviteMethod.allCases, id: \.self) { method in
                        Button(action: {
                            inviteMethod = method
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: method.icon)
                                    .font(.title2)
                                    .foregroundColor(inviteMethod == method ? .white : Color(red: 0.1, green: 0.2, blue: 0.4))
                                
                                Text(method.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(inviteMethod == method ? .white : Color(red: 0.1, green: 0.2, blue: 0.4))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(inviteMethod == method ? Color(red: 0.2, green: 0.6, blue: 0.4) : Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Invite Form
            VStack(spacing: 20) {
                switch inviteMethod {
                case .phone:
                    VStack(spacing: 12) {
                        Text("Enter phone number:")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        
                        TextField("(555) 123-4567", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                    }
                    
                case .email:
                    VStack(spacing: 12) {
                        Text("Enter email address:")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        
                        TextField("friend@example.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                    }
                    
                case .link:
                    VStack(spacing: 12) {
                        Text("Share this link:")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        
                        Text("whatshouldweeat://join/\(sessionId)")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                            .padding()
                            .background(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                if inviteMethod != .link {
                    Button(action: sendInvitation) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.title3)
                            }
                            
                            Text(isLoading ? "Sending..." : "Send Invitation")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.2, green: 0.6, blue: 0.4))
                        .cornerRadius(12)
                        .disabled(isLoading || !isValidInput)
                    }
                    .padding(.horizontal, 40)
                } else {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            
                            Text("Share Link")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.2, green: 0.6, blue: 0.4))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                
                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.body)
                        .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                        .padding(.vertical, 8)
                }
            }
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: ["Join my dining session! whatshouldweeat://join/\(sessionId)"])
        }
    }
    
    private var isValidInput: Bool {
        switch inviteMethod {
        case .phone:
            return phoneNumber.count >= 10
        case .email:
            return email.contains("@") && email.contains(".")
        case .link:
            return true
        }
    }
    
    private func sendInvitation() {
        isLoading = true
        errorMessage = nil
        
        // Simulate sending invitation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            
            // In a real app, this would actually send the invitation
            switch inviteMethod {
            case .phone:
                print("📱 Sending SMS invitation to: \(phoneNumber)")
            case .email:
                print("📧 Sending email invitation to: \(email)")
            case .link:
                break
            }
            
            onInviteSent()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SessionInvitationView(
        sessionId: "test-session-123",
        hostName: "John",
        onInviteSent: {},
        onSkip: {}
    )
} 