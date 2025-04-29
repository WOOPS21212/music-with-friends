
// MusicServiceManager.swift
import Foundation
import Combine

class MusicServiceManager: ObservableObject {
    // Published properties for UI updates
    @Published var connectedServices: [MusicService: Bool] = [
        .spotify: false,
        .appleMusic: false
    ]
    
    // Service-specific clients
    private var spotifyClient: SpotifyClient?
    private var appleMusicClient: AppleMusicClient?
    
    // Service IDs
    private var serviceIDs: [MusicService: String] = [:]
    
    // MARK: - Connection Methods
    
    func connectService(_ service: MusicService) async throws {
        switch service {
        case .spotify:
            spotifyClient = SpotifyClient()
            try await connectToSpotify()
        case .appleMusic:
            appleMusicClient = AppleMusicClient()
            try await connectToAppleMusic()
        }
    }
    
    func disconnectService(_ service: MusicService) {
        switch service {
        case .spotify:
            spotifyClient = nil
        case .appleMusic:
            appleMusicClient = nil
        }
        
        // Update connected status
        connectedServices[service] = false
        serviceIDs.removeValue(forKey: service)
    }
    
    private func connectToSpotify() async throws {
        guard let spotifyClient = spotifyClient else {
            throw AppError.playbackError
        }
        
        // Authenticate with Spotify
        let userID = try await spotifyClient.authenticate()
        
        // Update connected status
        await MainActor.run {
            connectedServices[.spotify] = true
            serviceIDs[.spotify] = userID
        }
    }
    
    private func connectToAppleMusic() async throws {
        guard let appleMusicClient = appleMusicClient else {
            throw AppError.playbackError
        }
        
        // Authenticate with Apple Music
        let userID = try await appleMusicClient.authenticate()
        
        // Update connected status
        await MainActor.run {
            connectedServices[.appleMusic] = true
            serviceIDs[.appleMusic] = userID
        }
    }
    
    // Get service ID for a connected service
    func getServiceID(for service: MusicService) -> String? {
        return serviceIDs[service]
    }
    
    // MARK: - Music Data Methods
    
    func getUserTopArtists(service: MusicService) async throws -> [String] {
        switch service {
        case .spotify:
            guard let spotifyClient = spotifyClient, connectedServices[.spotify] == true else {
                throw AppError.noMusicServiceConnected
            }
            return try await spotifyClient.getTopArtists()
            
        case .appleMusic:
            guard let appleMusicClient = appleMusicClient, connectedServices[.appleMusic] == true else {
                throw AppError.noMusicServiceConnected
            }
            return try await appleMusicClient.getTopArtists()
        }
    }
    
    func getUserFavoriteGenres(service: MusicService) async throws -> [String] {
        switch service {
        case .spotify:
            guard let spotifyClient = spotifyClient, connectedServices[.spotify] == true else {
                throw AppError.noMusicServiceConnected
            }
            return try await spotifyClient.getFavoriteGenres()
            
        case .appleMusic:
            guard let appleMusicClient = appleMusicClient, connectedServices[.appleMusic] == true else {
                throw AppError.noMusicServiceConnected
            }
            return try await appleMusicClient.getFavoriteGenres()
        }
    }
    
    func searchForSong(query: String, service: MusicService) async throws -> [Song] {
        switch service {
        case .spotify:
            guard let spotifyClient = spotifyClient, connectedServices[.spotify] == true else {
                throw AppError.noMusicServiceConnected
            }
            return try await spotifyClient.searchSongs(query: query)
            
        case .appleMusic:
            guard let appleMusicClient = appleMusicClient, connectedServices[.appleMusic] == true else {
                throw AppError.noMusicServiceConnected
            }
            return try await appleMusicClient.searchSongs(query: query)
        }
    }
    
    func getRecommendations(seeds: [Song], mood: Double) async throws -> [Song] {
        // Use each available service to get recommendations
        var allRecommendations: [Song] = []
        
        // Try Spotify first if connected
        if connectedServices[.spotify] == true, let spotifyClient = spotifyClient {
            let spotifySeeds = seeds.filter { $0.serviceType == .spotify }
            if !spotifySeeds.isEmpty {
                let recommendations = try await spotifyClient.getRecommendations(
                    seedTracks: spotifySeeds.map { $0.serviceID },
                    energy: mood,
                    limit: 10
                )
                allRecommendations.append(contentsOf: recommendations)
            }
        }
        
        // Then try Apple Music if connected
        if connectedServices[.appleMusic] == true, let appleMusicClient = appleMusicClient {
            let appleMusicSeeds = seeds.filter { $0.serviceType == .appleMusic }
            if !appleMusicSeeds.isEmpty {
                let recommendations = try await appleMusicClient.getRecommendations(
                    seedTracks: appleMusicSeeds.map { $0.serviceID },
                    energy: mood,
                    limit: 10
                )
                allRecommendations.append(contentsOf: recommendations)
            }
        }
        
        return allRecommendations
    }
}
