
// Session.swift
import Foundation

struct Session: Identifiable, Codable {
    var id: String
    var name: String
    var hostUserID: String
    var currentUsers: [String] // User IDs
    var mode: SessionMode // Roaming or Venue
    var playlist: [Song]
    var currentSongIndex: Int?
    var moodSetting: Double? // Value between 0.0 (Chill) and 1.0 (Hype)
    var excludedGenres: [String]?
    var excludedArtists: [String]?
    var createdAt: Date
    var lastActivityAt: Date
    var isPrivate: Bool
    
    init(id: String, name: String, hostUserID: String, currentUsers: [String] = [],
         mode: SessionMode = .roaming, playlist: [Song] = [], currentSongIndex: Int? = nil,
         moodSetting: Double? = 0.5, excludedGenres: [String]? = nil,
         excludedArtists: [String]? = nil, createdAt: Date = Date(),
         lastActivityAt: Date = Date(), isPrivate: Bool = false) {
        self.id = id
        self.name = name
        self.hostUserID = hostUserID
        self.currentUsers = currentUsers
        self.mode = mode
        self.playlist = playlist
        self.currentSongIndex = currentSongIndex
        self.moodSetting = moodSetting
        self.excludedGenres = excludedGenres
        self.excludedArtists = excludedArtists
        self.createdAt = createdAt
        self.lastActivityAt = lastActivityAt
        self.isPrivate = isPrivate
    }
    
    // Helper functions
    var currentSong: Song? {
        guard let index = currentSongIndex, playlist.indices.contains(index) else {
            return nil
        }
        return playlist[index]
    }
    
    var nextSongIndex: Int? {
        guard let current = currentSongIndex else { return playlist.isEmpty ? nil : 0 }
        let next = current + 1
        return playlist.indices.contains(next) ? next : nil
    }
    
    var nextSong: Song? {
        guard let index = nextSongIndex else { return nil }
        return playlist[index]
    }
    
    mutating func skipToNextSong() -> Bool {
        guard let next = nextSongIndex else { return false }
        currentSongIndex = next
        return true
    }
}

enum SessionMode: String, Codable {
    case roaming // Equal influence from all users
    case venue // Host has more control
}
