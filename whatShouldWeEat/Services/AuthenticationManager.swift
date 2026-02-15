import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import Combine

enum AuthError: Error, LocalizedError {
    case signInFailed
    case signOutFailed
    case userNotFound
    case networkError
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .signInFailed:
            return "Failed to sign in with Google"
        case .signOutFailed:
            return "Failed to sign out"
        case .userNotFound:
            return "User not found"
        case .networkError:
            return "Network error occurred"
        case .unknownError(let message):
            return message
        }
    }
}

enum AuthState {
    case signedOut
    case signedIn(User)
    case loading
}

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let firestoreService: FirestoreService

    init(firestoreService: FirestoreService? = nil) {
        self.firestoreService = firestoreService ?? FirestoreService()
        setupAuthStateListener()
    }

    // MARK: - Auth State Management

    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.handleUserSignIn(user)
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }

    private func handleUserSignIn(_ firebaseUser: FirebaseAuth.User) async {
        isLoading = true
        errorMessage = nil

        do {
            // Check if user exists in Firestore
            if let existingUser = try await firestoreService.getUser(userId: firebaseUser.uid) {
                // Update last login time
                var updatedUser = existingUser
                updatedUser.profile = UserProfile(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? existingUser.profile.displayName,
                    photoURL: firebaseUser.photoURL?.absoluteString
                )

                try await firestoreService.updateUser(updatedUser)
                isAuthenticated = true
                currentUser = updatedUser

            } else {
                // Create new user profile
                let newProfile = UserProfile(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? "User",
                    photoURL: firebaseUser.photoURL?.absoluteString
                )

                let newUser = User(
                    id: firebaseUser.uid,
                    profile: newProfile
                )

                try await firestoreService.createUser(newUser)
                isAuthenticated = true
                currentUser = newUser
            }

        } catch {
            print("Failed to handle user sign in: \(error)")
            errorMessage = error.localizedDescription
            showError = true
            isAuthenticated = false
            currentUser = nil
        }

        isLoading = false
    }

    // MARK: - Public Properties

    var isSignedIn: Bool {
        return isAuthenticated
    }

    // MARK: - Sign In Methods

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                throw AuthError.signInFailed
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.signInFailed
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)

            await handleUserSignIn(authResult.user)

        } catch {
            print("Google Sign-In failed: \(error)")
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }

    func signOut() async {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()

            isAuthenticated = false
            currentUser = nil

        } catch {
            print("Sign out failed: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - User Management

    func updateUserProfile(_ user: User) async {
        do {
            try await firestoreService.updateUser(user)
            if isAuthenticated {
                currentUser = user
            }
        } catch {
            print("Failed to update user profile: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func refreshUserData() async {
        guard let user = currentUser else { return }

        do {
            if let updatedUser = try await firestoreService.getUser(userId: user.id) {
                currentUser = updatedUser
            }
        } catch {
            print("Failed to refresh user data: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Error Handling

    func clearError() {
        errorMessage = nil
        showError = false
    }
}
