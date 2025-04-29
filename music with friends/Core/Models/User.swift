import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var connectedServices: [MusicService]
    
    // User music preferences
    var favoriteGenres: [String]?
    var favoriteArtists: [String]?
}
