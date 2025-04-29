import Foundation

struct Song: Identifiable, Codable {
    var id: String
    var title: String
    var artist: String
    var album: String?
    var duration: TimeInterval
    var artworkURL: String?
    var previewURL: String?
    var serviceType: MusicService
    var serviceURI: String
}
