
// SessionManager.swift - For handling music sessions
import Foundation
import Combine
import FirebaseFirestore

class SessionManager: ObservableObject {
    // Published properties for UI updates
    @Published var availableSessions: [Session] = []
    @Published var currentSession: Session?
    @Published var currentSessionUsers: [User] = []
    @Published var isHost: Bool = false
    
    // Dependencies
    private let playlistGenerator: PlaylistGenerator
    private let musicServiceManager: MusicServiceManager
    private let db = Firestore.firestore()
    
    // Firestore references
    private var sessionsRef: CollectionReference {
        db.collection("sessions")
    }
    
    private var sessionListenersMap: [String: ListenerRegistration] = [:]
    
    // Initialization
    init(playlistGenerator: PlaylistGenerator, musicServiceManager: MusicServiceManager) {
        self.playlistGenerator = playlistGenerator
        self.musicServiceManager = musicServiceManager
    }
    
    deinit {
        // Remove all listeners
        for listener in sessionListenersMap.values {
            listener.remove()
        }
    }
    
    // MARK: - Session Creation and Management
    
    /// Creates a new session and returns it
    func createNewSession(name: String, hostUserID: String, mode: SessionMode = .roaming) async throws -> Session {
        // Create session with empty playlist
        let sessionID = UUID().uuidString
        let session = Session(
            id: sessionID,
            name: name,
            hostUserID: hostUserID,
            currentUsers: [hostUserID],
            mode: mode,
            playlist: [],
            moodSetting: 0.5,
            createdAt: Date(),
            lastActivityAt: Date()
        )
        
        // Save to Firestore
        let sessionData = try Firestore.Encoder().encode(session)
        try await sessionsRef.document(sessionID).setData(sessionData)
        
        // Generate initial playlist
        let initialPlaylist = try await generatePlaylist(for: session)
        
        // Update session with playlist
        var updatedSession = session
        updatedSession.playlist = initialPlaylist
        
        // Update in Firestore
        let updatedData = try Firestore.Encoder().encode(updatedSession)
        try await sessionsRef.document(sessionID).updateData(updatedData)
        
        // Start listening for changes
        startListeningToSession(sessionID: sessionID)
        
        // Set as current session
        await MainActor.run {
            self.currentSession = updatedSession
            self.isHost = true
        }
        
        return updatedSession
    }
    
    /// Join an existing session
    func joinSession(sessionID: String, userID: String) async throws {
        // Get the session
        let snapshot = try await sessionsRef.document(sessionID).getDocument()
        guard snapshot.exists, var session = try? snapshot.data(as: Session.self) else {
            throw AppError.sessionNotFound
        }
        
        // Add user to the session if not already present
        if !session.currentUsers.contains(userID) {
            session.currentUsers.append(userID)
            session.lastActivityAt = Date()
            
            // Update session in Firestore
            try await sessionsRef.document(sessionID).updateData([
                "currentUsers": session.currentUsers,
                "lastActivityAt": session.lastActivityAt
            ])
        }
        
        // Start listening for changes
        startListeningToSession(sessionID: sessionID)
        
        // Set as current session
        await MainActor.run {
            self.currentSession = session
            self.isHost = session.hostUserID == userID
        }
    }
    
    /// Leave a session
    func leaveSession(sessionID: String) async throws {
        guard let userID = UserDefaults.standard.string(forKey: "currentUserID") else {
            throw AppError.notAuthenticated
        }
        
        // Get the session
        let snapshot = try await sessionsRef.document(sessionID).getDocument()
        guard snapshot.exists, var session = try? snapshot.data(as: Session.self) else {
            throw AppError.sessionNotFound
        }
        
        // Remove user from the session
        session.currentUsers.removeAll { $0 == userID }
        session.lastActivityAt = Date()
        
        // If this was the host and there are other users, transfer host status
        if session.hostUserID == userID && !session.currentUsers.isEmpty {
            session.hostUserID = session.currentUsers[0]
        }
        
        // If no users left, mark session for cleanup (or delete)
        if session.currentUsers.isEmpty {
            // Option 1: Delete session
            try await sessionsRef.document(sessionID).delete()
        } else {
            // Option 2: Update session in Firestore
            try await sessionsRef.document(sessionID).updateData([
                "currentUsers": session.currentUsers,
                "hostUserID": session.hostUserID,
                "lastActivityAt": session.lastActivityAt
            ])
        }
        
        // Stop listening for changes
        stopListeningToSession(sessionID: sessionID)
        
        // Clear current session if it was this one
        await MainActor.run {
            if self.currentSession?.id == sessionID {
                self.currentSession = nil
                self.isHost = false
            }
        }
    }
    
    // MARK: - Playlist Management
    
    /// Skip to the next song in the session
    func skipToNextSong() async throws {
        guard var session = currentSession, isHost || session.mode == .roaming else {
            throw AppError.notAuthenticated
        }
        
        // Try to skip to next song
        if session.skipToNextSong() {
            // Success, update in Firestore
            try await sessionsRef.document(session.id).updateData([
                "currentSongIndex": session.currentSongIndex as Any,
                "lastActivityAt": Date()
            ])
        } else {
            // No more songs, generate more
            let newSongs = try await generatePlaylist(for: session)
            
            // Add new songs to playlist
            session.playlist.append(contentsOf: newSongs)
            
            // Set to first new song
            if session.currentSongIndex == nil {
                session.currentSongIndex = 0
            } else {
                session.currentSongIndex = session.currentSongIndex! + 1
            }
            
            // Update full playlist in Firestore
            try await sessionsRef.document(session.id).updateData([
                "playlist": session.playlist,
                "currentSongIndex": session.currentSongIndex as Any,
                "lastActivityAt": Date()
            ])
        }
    }
    
    /// Adjust the mood setting (only host in venue mode, anyone in roaming mode)
    func adjustMood(newValue: Double) async throws {
        guard var session = currentSession, isHost || session.mode == .roaming else {
            throw AppError.notAuthenticated
        }
        
        // Update mood setting
        session.moodSetting = min(1.0, max(0.0, newValue)) // Clamp between 0 and 1
        
        // Update in Firestore
        try await sessionsRef.document(session.id).updateData([
            "moodSetting": session.moodSetting as Any,
            "lastActivityAt": Date()
        ])
        
        // Regenerate playlist with new mood if host
        if isHost {
            Task {
                do {
                    let newSongs = try await generatePlaylist(for: session)
                    
                    // Keep current song, replace rest of playlist
                    var updatedPlaylist: [Song] = []
                    
                    if let currentIndex = session.currentSongIndex,
                       session.playlist.indices.contains(currentIndex) {
                        updatedPlaylist.append(session.playlist[currentIndex])
                    }
                    
                    updatedPlaylist.append(contentsOf: newSongs)
                    
                    // Reset index if needed
                    let newIndex = updatedPlaylist.isEmpty ? nil : 0
                    
                    // Update in Firestore
                    try await sessionsRef.document(session.id).updateData([
                        "playlist": updatedPlaylist,
                        "currentSongIndex": newIndex as Any
                    ])
                } catch {
                    print("Error regenerating playlist: \(error)")
                }
            }
        }
    }
    
    /// Add genre to excluded list (host only in venue mode)
    func excludeGenre(_ genre: String) async throws {
        guard var session = currentSession, isHost || session.mode == .roaming else {
            throw AppError.notAuthenticated
        }
        
        // Add genre to excluded list if not already there
        var excludedGenres = session.excludedGenres ?? []
        if !excludedGenres.contains(genre) {
            excludedGenres.append(genre)
        }
        
        // Update in Firestore
        try await sessionsRef.document(session.id).updateData([
            "excludedGenres": excludedGenres,
            "lastActivityAt": Date()
        ])
    }
    
    /// Add artist to excluded list (host only in venue mode)
    func excludeArtist(_ artist: String) async throws {
        guard var session = currentSession, isHost || session.mode == .roaming else {
            throw AppError.notAuthenticated
        }
        
        // Add artist to excluded list if not already there
        var excludedArtists = session.excludedArtists ?? []
        if !excludedArtists.contains(artist) {
            excludedArtists.append(artist)
        }
        
        // Update in Firestore
        try await sessionsRef.document(session.id).updateData([
            "excludedArtists": excludedArtists,
            "lastActivityAt": Date()
        ])
    }
    
    // MARK: - Private Methods
    
    /// Start listening for session changes
    private func startListeningToSession(sessionID: String) {
        // Remove existing listener if any
        stopListeningToSession(sessionID: sessionID)
        
        // Add new listener
        let listener = sessionsRef.document(sessionID).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists,
                  let updatedSession = try? snapshot.data(as: Session.self) else {
                return
            }
            
            // Update current session
            DispatchQueue.main.async {
                self.currentSession = updatedSession
                
                // Check if still host
                if let userID = UserDefaults.standard.string(forKey: "currentUserID") {
                    self.isHost = updatedSession.hostUserID == userID
                }
                
                // Update user list (would fetch actual user objects in real app)
                self.loadSessionUsers(userIDs: updatedSession.currentUsers)
            }
        }
        
        // Store listener for cleanup
        sessionListenersMap[sessionID] = listener
    }
    
    /// Stop listening for session changes
    private func stopListeningToSession(sessionID: String) {
        if let listener = sessionListenersMap[sessionID] {
            listener.remove()
            sessionListenersMap.removeValue(forKey: sessionID)
        }
    }
    
    /// Load user information for session participants
    private func loadSessionUsers(userIDs: [String]) {
        // In a real app, this would fetch user data from Firestore
        // For now, we'll create placeholder users
        
        let users = userIDs.map { userID in
            User(
                id: userID,
                name: "User \(userID.prefix(4))",
                deviceID: UUID().uuidString
            )
        }
        
        DispatchQueue.main.async {
            self.currentSessionUsers = users
        }
    }
    
    /// Generate a playlist based on session parameters
    private func generatePlaylist(for session: Session) async throws -> [Song] {
        // In a real app, this would use the PlaylistGenerator to create a customized playlist
        // based on the musical tastes of the users in the session
        
        // For this implementation, we'll use a placeholder method that returns random songs
        let sampleSongs = [
            Song(id: UUID().uuidString, title: "Bohemian Rhapsody", artist: "Queen",
                 duration: 354, serviceType: .spotify, serviceID: "spotify:track:1",
                 genres: ["Rock"], year: 1975, popularity: 0.95, addedBy: session.hostUserID),
            Song(id: UUID().uuidString, title: "Stairway to Heaven", artist: "Led Zeppelin",
                 duration: 482, serviceType: .spotify, serviceID: "spotify:track:2",
                 genres: ["Rock"], year: 1971, popularity: 0.9, addedBy: session.hostUserID),
            Song(id: UUID().uuidString, title: "Sweet Child O' Mine", artist: "Guns N' Roses",
                 duration: 356, serviceType: .spotify, serviceID: "spotify:track:3",
                 genres: ["Rock"], year: 1987, popularity: 0.85, addedBy: session.hostUserID),
            Song(id: UUID().uuidString, title: "Billie Jean", artist: "Michael Jackson",
                 duration: 294, serviceType: .spotify, serviceID: "spotify:track:4",
                 genres: ["Pop"], year: 1982, popularity: 0.9, addedBy: session.hostUserID),
            Song(id: UUID().uuidString, title: "Superstition", artist: "Stevie Wonder",
                 duration: 240, serviceType: .spotify, serviceID: "spotify:track:5",
                 genres: ["R&B"], year: 1972, popularity: 0.8, addedBy: session.hostUserID)
        ]
        
        return sampleSongs
    }
}
