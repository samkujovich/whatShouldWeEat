import Foundation
import CoreLocation
import Combine

class SocialSessionService: ObservableObject {
    @Published var currentSession: SocialSession?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Session Management
    
    func createSession(hostUserId: String, hostName: String, sessionName: String, preferences: MealPreferences, location: CLLocationCoordinate2D) {
        print("🔄 Creating new social session")
        isLoading = true
        errorMessage = nil
        
        let session = SocialSession(
            hostUserId: hostUserId,
            hostName: hostName,
            sessionName: sessionName,
            preferences: preferences,
            location: location
        )
        
        // In a real app, this would be saved to a backend service
        // For now, we'll simulate the creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentSession = session
            self.isLoading = false
            print("✅ Social session created: \(session.id)")
        }
    }
    
    func joinSession(sessionId: String, userId: String, userName: String) {
        print("🔄 Joining session: \(sessionId)")
        isLoading = true
        errorMessage = nil
        
        guard var session = currentSession, session.id == sessionId else {
            errorMessage = "Session not found"
            isLoading = false
            return
        }
        
        let participant = SessionParticipant(userId: userId, name: userName)
        session.participants.append(participant)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentSession = session
            self.isLoading = false
            print("✅ User \(userName) joined session")
        }
    }
    
    func leaveSession(userId: String) {
        print("🔄 User \(userId) leaving session")
        
        guard var session = currentSession else { return }
        
        session.participants.removeAll { $0.userId == userId }
        
        if session.participants.isEmpty {
            // Session is empty, delete it
            currentSession = nil
            print("🗑️ Session deleted - no participants remaining")
        } else {
            currentSession = session
            print("✅ User left session")
        }
    }
    
    // MARK: - Restaurant Management
    
    func addRestaurants(_ restaurants: [Restaurant]) {
        guard var session = currentSession else { return }
        
        session.restaurants = restaurants
        currentSession = session
        print("🍽️ Added \(restaurants.count) restaurants to session")
    }
    
    func likeRestaurant(restaurantId: String, userId: String) {
        guard var session = currentSession else { return }
        
        if let participantIndex = session.participants.firstIndex(where: { $0.userId == userId }) {
            session.participants[participantIndex].likedRestaurantIds.insert(restaurantId)
            session.participants[participantIndex].dislikedRestaurantIds.remove(restaurantId)
            currentSession = session
            print("👍 User \(userId) liked restaurant \(restaurantId)")
        }
    }
    
    func dislikeRestaurant(restaurantId: String, userId: String) {
        guard var session = currentSession else { return }
        
        if let participantIndex = session.participants.firstIndex(where: { $0.userId == userId }) {
            session.participants[participantIndex].dislikedRestaurantIds.insert(restaurantId)
            session.participants[participantIndex].likedRestaurantIds.remove(restaurantId)
            currentSession = session
            print("👎 User \(userId) disliked restaurant \(restaurantId)")
        }
    }
    
    // MARK: - Session Status
    
    func startSession() {
        guard var session = currentSession else { return }
        session.status = .active
        currentSession = session
        print("🚀 Session started")
    }
    
    func completeSession() {
        guard var session = currentSession else { return }
        session.status = .completed
        currentSession = session
        print("✅ Session completed")
    }
    
    // MARK: - Analytics
    
    func getSessionProgress() -> (totalParticipants: Int, participantsCompleted: Int, matchedRestaurants: Int) {
        guard let session = currentSession else { return (0, 0, 0) }
        
        let totalParticipants = session.participants.count
        let participantsCompleted = session.participants.filter { participant in
            participant.likedRestaurantIds.count + participant.dislikedRestaurantIds.count >= session.restaurants.count
        }.count
        let matchedRestaurants = session.matchedRestaurants.count
        
        return (totalParticipants, participantsCompleted, matchedRestaurants)
    }
    
    func getParticipantProgress(userId: String) -> (liked: Int, disliked: Int, total: Int) {
        guard let session = currentSession,
              let participant = session.participants.first(where: { $0.userId == userId }) else {
            return (0, 0, 0)
        }
        
        let liked = participant.likedRestaurantIds.count
        let disliked = participant.dislikedRestaurantIds.count
        let total = session.restaurants.count
        
        return (liked, disliked, total)
    }
    
    // MARK: - Push Notifications (Simulated)
    
    func sendInvitation(to userId: String, sessionId: String, hostName: String) {
        print("📱 Sending invitation to user \(userId) for session \(sessionId)")
        
        // In a real app, this would send a push notification
        // For now, we'll simulate the notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("📨 Push notification sent to \(userId): '\(hostName) invited you to join their dining session!'")
        }
    }
    
    func sendSessionUpdate(to userId: String, message: String) {
        print("📱 Sending session update to user \(userId): \(message)")
        
        // In a real app, this would send a push notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("📨 Push notification sent to \(userId): '\(message)'")
        }
    }
    
    // MARK: - Real-time Sync (Simulated)
    
    func startRealTimeSync() {
        print("🔄 Starting real-time synchronization")
        
        // In a real app, this would establish WebSocket connection or use Firebase
        // For now, we'll simulate periodic updates
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.syncSessionUpdates()
            }
            .store(in: &cancellables)
    }
    
    private func syncSessionUpdates() {
        guard let session = currentSession else { return }
        
        // Simulate receiving updates from other participants
        print("🔄 Syncing session updates...")
        
        // In a real app, this would fetch updates from the backend
        // For now, we'll just log the sync
        let progress = getSessionProgress()
        print("📊 Session progress: \(progress.participantsCompleted)/\(progress.totalParticipants) participants completed, \(progress.matchedRestaurants) matched restaurants")
    }
    
    // MARK: - Session Cleanup
    
    func cleanupExpiredSessions() {
        guard let session = currentSession, session.isExpired else { return }
        
        print("⏰ Session expired, cleaning up...")
        currentSession = nil
    }
} 