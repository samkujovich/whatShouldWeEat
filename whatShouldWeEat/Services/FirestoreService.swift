import Foundation
import Firebase
import FirebaseFirestore
import Combine

enum FirestoreError: Error, LocalizedError {
    case documentNotFound
    case encodingError
    case decodingError
    case networkError
    case permissionDenied
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .encodingError:
            return "Failed to encode data"
        case .decodingError:
            return "Failed to decode data"
        case .networkError:
            return "Network error occurred"
        case .permissionDenied:
            return "Permission denied"
        case .unknownError(let message):
            return message
        }
    }
}

@MainActor
class FirestoreService: ObservableObject {
    private let db: Firestore
    private var listeners: [String: ListenerRegistration] = [:]
    
    init() {
        self.db = FirebaseConfig.shared.getFirestore()
        print("📊 Firestore service initialized")
    }
    
    deinit {
        // Remove listeners synchronously in deinit
        for (_, listener) in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
    
    // MARK: - User Operations
    
    func createUser(_ user: User) async throws {
        do {
            let data = try encodeUser(user)
            try await db.collection("users").document(user.id).setData(data)
            print("✅ User created successfully: \(user.profile.displayName)")
        } catch {
            print("❌ Failed to create user: \(error)")
            throw FirestoreError.encodingError
        }
    }
    
    func getUser(userId: String) async throws -> User? {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if document.exists {
                let user = try decodeUser(from: document.data() ?? [:])
                print("✅ User retrieved: \(user.profile.displayName)")
                return user
            } else {
                print("📄 User document not found: \(userId)")
                return nil
            }
        } catch {
            print("❌ Failed to get user: \(error)")
            throw FirestoreError.decodingError
        }
    }
    
    func updateUser(_ user: User) async throws {
        do {
            let data = try encodeUser(user)
            try await db.collection("users").document(user.id).setData(data, merge: true)
            print("✅ User updated successfully: \(user.profile.displayName)")
        } catch {
            print("❌ Failed to update user: \(error)")
            throw FirestoreError.encodingError
        }
    }
    
    func deleteUser(userId: String) async throws {
        do {
            try await db.collection("users").document(userId).delete()
            print("✅ User deleted successfully: \(userId)")
        } catch {
            print("❌ Failed to delete user: \(error)")
            throw FirestoreError.unknownError(error.localizedDescription)
        }
    }
    
    // MARK: - Meal Session Operations
    
    func createMealSession(_ session: MealSession) async throws {
        do {
            let data = try encodeMealSession(session)
            try await db.collection("mealSessions").document(session.id).setData(data)
            print("✅ Meal session created successfully: \(session.id)")
        } catch {
            print("❌ Failed to create meal session: \(error)")
            throw FirestoreError.encodingError
        }
    }
    
    func getMealSession(sessionId: String) async throws -> MealSession? {
        do {
            let document = try await db.collection("mealSessions").document(sessionId).getDocument()
            
            if document.exists {
                let session = try decodeMealSession(from: document.data() ?? [:])
                print("✅ Meal session retrieved: \(session.id)")
                return session
            } else {
                print("📄 Meal session document not found: \(sessionId)")
                return nil
            }
        } catch {
            print("❌ Failed to get meal session: \(error)")
            throw FirestoreError.decodingError
        }
    }
    
    func updateMealSession(_ session: MealSession) async throws {
        do {
            let data = try encodeMealSession(session)
            try await db.collection("mealSessions").document(session.id).setData(data, merge: true)
            print("✅ Meal session updated successfully: \(session.id)")
        } catch {
            print("❌ Failed to update meal session: \(error)")
            throw FirestoreError.encodingError
        }
    }
    
    func deleteMealSession(sessionId: String) async throws {
        do {
            try await db.collection("mealSessions").document(sessionId).delete()
            print("✅ Meal session deleted successfully: \(sessionId)")
        } catch {
            print("❌ Failed to delete meal session: \(error)")
            throw FirestoreError.unknownError(error.localizedDescription)
        }
    }
    
    // MARK: - Real-time Listeners
    
    func listenToMealSession(sessionId: String, completion: @escaping (MealSession?) -> Void) -> ListenerRegistration {
        let listener = db.collection("mealSessions").document(sessionId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                if let error = error {
                    print("❌ Meal session listener error: \(error)")
                    completion(nil)
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("📄 Meal session document not found: \(sessionId)")
                    completion(nil)
                    return
                }
                
                do {
                    let session = try self?.decodeMealSession(from: document.data() ?? [:])
                    completion(session)
                } catch {
                    print("❌ Failed to decode meal session: \(error)")
                    completion(nil)
                }
            }
        
        listeners[sessionId] = listener
        return listener
    }
    
    func listenToUserSessions(userId: String, completion: @escaping ([MealSession]) -> Void) -> ListenerRegistration {
        let listener = db.collection("mealSessions")
            .whereField("participants", arrayContains: userId)
            .whereField("status", isEqualTo: SessionStatus.active.rawValue)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("❌ User sessions listener error: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }
                
                let sessions = documents.compactMap { document in
                    try? self?.decodeMealSession(from: document.data())
                }
                
                completion(sessions)
            }
        
        listeners["user_\(userId)"] = listener
        return listener
    }
    
    // MARK: - Helper Methods
    
    private func removeAllListeners() {
        for (_, listener) in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
    
    // MARK: - Encoding/Decoding
    
    private func encodeUser(_ user: User) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        let data = try encoder.encode(user)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FirestoreError.encodingError
        }
        
        return dictionary
    }
    
    private func decodeUser(from data: [String: Any]) throws -> User {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try decoder.decode(User.self, from: jsonData)
    }
    
    private func encodeMealSession(_ session: MealSession) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        let data = try encoder.encode(session)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FirestoreError.encodingError
        }
        
        return dictionary
    }
    
    private func decodeMealSession(from data: [String: Any]) throws -> MealSession {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try decoder.decode(MealSession.self, from: jsonData)
    }
} 