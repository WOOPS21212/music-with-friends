

// MusicService.swift (enhanced)
import Foundation

enum MusicService: String, Codable, CaseIterable {
    case spotify
    case appleMusic
    
    var displayName: String {
        switch self {
        case .spotify:
            return "Spotify"
        case .appleMusic:
            return "Apple Music"
        }
    }
    
    var icon: String {
        switch self {
        case .spotify:
            return "spotify_icon" // Image asset name
        case .appleMusic:
            return "apple_music_icon" // Image asset name
        }
    }
    
    var primaryColor: String {
        switch self {
        case .spotify:
            return "#1DB954" // Spotify green
        case .appleMusic:
            return "#FC3C44" // Apple Music red
        }
    }
}
