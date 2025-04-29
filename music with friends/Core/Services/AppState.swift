//
//  AppState.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//

// AppState.swift - Central state management
import Foundation
import Combine

class AppState: ObservableObject {
    // Published properties for UI updates
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var connectedMusicServices: [MusicService] = []
    @Published var currentSession: Session?
    @Published var isPlayingMusic: Bool = false
    @Published var currentSong: Song?
    
    // Settings
    @Published var useOfflineMode: Bool = false
    @Published var pushNotificationsEnabled: Bool = true
    
    // Service managers
    private let sessionManager: SessionManager
    private let musicServiceManager: MusicServiceManager
    private let playbackManager: PlaybackManager
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionManager: SessionManager,
         musicServiceManager: MusicServiceManager,
         playbackManager: PlaybackManager) {
        self.sessionManager = sessionManager
        self.musicServiceManager = musicServiceManager
        self.playbackManager = playbackManager
        
        // Subscribe to session changes
        sessionManager.$currentSession
            .sink { [weak self] session in
                self?.currentSession = session
            }
            .store(in: &cancellables)
        
        // Subscribe to playback changes
        playbackManager.$currentSong
            .sink { [weak self] song in
                self?.currentSong = song
            }
            .store(in: &cancellables)
        
        playbackManager.$isPlaying
            .sink { [weak self] isPlaying in
                self?.isPlayingMusic = isPlaying
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication
    
    func signIn(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
        loadUserMusicServices()
    }
    
    func signOut() {
        leaveCurrentSession()
        self.currentUser = nil
        self.isAuthenticated = false
        self.connectedMusicServices = []
    }
    
    // MARK: - Music Services
    
    private func loadUserMusicServices() {
        guard let user = currentUser else { return }
        self.connectedMusicServices = Array(user.connectedServices.keys)
    }
    
    func connectMusicService(_ service: MusicService) async throws {
        try await musicServiceManager.connectService(service)
        
        // Update the current user's connected services
        if var user = currentUser {
            if let serviceID = musicServiceManager.getServiceID(for: service) {
                user.connectedServices[service] = serviceID
                self.currentUser = user
            }
            
            // Update connected services list
            self.connectedMusicServices = Array(user.connectedServices.keys)
        }
    }
    
    func disconnectMusicService(_ service: MusicService) {
        musicServiceManager.disconnectService(service)
        
        // Update the current user's connected services
        if var user = currentUser {
            user.connectedServices.removeValue(forKey: service)
            self.currentUser = user
            
            // Update connected services list
            self.connectedMusicServices = Array(user.connectedServices.keys)
        }
    }
    
    // MARK: - Session Management
    
    func createSession(name: String, mode: SessionMode) async throws {
        guard let userID = currentUser?.id else {
            throw AppError.notAuthenticated
        }
        
        let session = try await sessionManager.createNewSession(name: name,
                                                              hostUserID: userID,
                                                              mode: mode)
        await MainActor.run {
            self.currentSession = session
        }
    }
    
    func joinSession(_ session: Session) async throws {
        guard let userID = currentUser?.id else {
            throw AppError.notAuthenticated
        }
        
        try await sessionManager.joinSession(sessionID: session.id, userID: userID)
    }
    
    func leaveCurrentSession() {
        guard let sessionID = currentSession?.id else { return }
        
        Task {
            try? await sessionManager.leaveSession(sessionID: sessionID)
            await MainActor.run {
                self.currentSession = nil
            }
        }
    }
    
    // MARK: - Playback Control
    
    func playCurrentSong() {
        guard let session = currentSession,
              let song = session.currentSong else { return }
        
        Task {
            try? await playbackManager.play(song: song)
        }
    }
    
    func pausePlayback() {
        playbackManager.pause()
    }
    
    func resumePlayback() {
        playbackManager.resume()
    }
    
    func skipToNextSong() {
        Task {
            try? await sessionManager.skipToNextSong()
        }
    }
    
    // MARK: - Settings
    
    func toggleOfflineMode() {
        useOfflineMode.toggle()
        // Apply offline mode settings to services
    }
    
    func togglePushNotifications() {
        pushNotificationsEnabled.toggle()
        // Update notification settings
    }
}

// Error handling
enum AppError: Error {
    case notAuthenticated
    case noMusicServiceConnected
    case sessionNotFound
    case bluetoothUnavailable
    case networkError
    case playbackError
    
    var localizedDescription: String {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .noMusicServiceConnected:
            return "Please connect a music service first"
        case .sessionNotFound:
            return "The music session was not found"
        case .bluetoothUnavailable:
            return "Bluetooth is unavailable or disabled"
        case .networkError:
            return "Network error. Please check your connection"
        case .playbackError:
            return "Unable to play the requested song"
        }
    }
}
