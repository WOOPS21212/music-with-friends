//
//  SpotifyClient.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//



// MARK: - Mock Music Service Clients

// SpotifyClient.swift
class SpotifyClient {
    func authenticate() async throws -> String {
        // In a real app, this would authenticate with Spotify
        // and return the Spotify user ID
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return "spotify_user_123"
    }
    
    func getTopArtists() async throws -> [String] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return ["Queen", "Pink Floyd", "Led Zeppelin", "AC/DC", "Metallica"]
    }
    
    func getFavoriteGenres() async throws -> [String] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return ["Rock", "Metal", "Classic Rock", "Progressive Rock"]
    }
    
    func searchSongs(query: String) async throws -> [Song] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return mock search results
        return [
            Song(id: UUID().uuidString, title: "Search Result 1", artist: "Artist 1",
                 duration: 180, serviceType: .spotify, serviceID: "spotify:track:search1"),
            Song(id: UUID().uuidString, title: "Search Result 2", artist: "Artist 2",
                 duration: 200, serviceType: .spotify, serviceID: "spotify:track:search2")
        ]
    }
    
    func getRecommendations(seedTracks: [String], energy: Double, limit: Int) async throws -> [Song] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return mock recommendations
        var recommendations: [Song] = []
        
        for i in 0..<limit {
            recommendations.append(
                Song(id: UUID().uuidString, title: "Recommendation \(i+1)", artist: "Artist \(i+1)",
                     duration: TimeInterval(180 + i * 10), serviceType: .spotify,
                     serviceID: "spotify:track:rec\(i)")
            )
        }
        
        return recommendations
    }
}
