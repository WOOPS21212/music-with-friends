import Foundation

struct Session: Identifiable, Codable {
    var id: String
    var name: String
    var hostUserID: String
    var currentUsers: [String]
    var currentSong: Song?
    var playlist: [Song]
    var moodSetting: MoodLevel
    
    enum MoodLevel: String, Codable {
        case chill
        case balanced
        case hype
    }
}
