import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class FirebaseConfig {
    static let shared = FirebaseConfig()

    private init() {}

    func configure() {
        // Configure Firebase from GoogleService-Info.plist
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("Failed to find GoogleService-Info.plist")
            return
        }

        guard let options = FirebaseOptions(contentsOfFile: path) else {
            print("Failed to parse GoogleService-Info.plist")
            return
        }

        FirebaseApp.configure(options: options)

        // Configure Google Sign-In
        guard let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("Failed to load CLIENT_ID from GoogleService-Info.plist")
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }

    func getFirestore() -> Firestore {
        return Firestore.firestore()
    }
}
