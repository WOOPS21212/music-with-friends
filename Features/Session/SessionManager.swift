import Foundation
import Combine

class SessionManager: ObservableObject {
    @Published var activeSessions: [Session] = []
    @Published var currentSession: Session?
    
    // Create a sample session
    func createSession(name: String) -> Session {
        let sampleSongs = [
            Song(id: "1", title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", duration: 354, artworkURL: nil, previewURL: nil, serviceType: .spotify, serviceURI: "spotify:track:sample1"),
            Song(id: "2", title: "Don't Stop Me Now", artist: "Queen", album: "Jazz", duration: 209, artworkURL: nil, previewURL: nil, serviceType: .spotify, serviceURI: "spotify:track:sample2"),
            Song(id: "3", title: "Stairway to Heaven", artist: "Led Zeppelin", album: "Led Zeppelin IV", duration: 482, artworkURL: nil, previewURL: nil, serviceType: .spotify, serviceURI: "spotify:track:sample3")
        ]
        
        let session = Session(
            id: UUID().uuidString,
            name: name,
            hostUserID: "currentUser",
            currentUsers: ["currentUser"],
            currentSong: sampleSongs.first,
            playlist: sampleSongs,
            moodSetting: .balanced
        )
        
        self.currentSession = session
        return session
    }
    
    // Join an existing session
    func joinSession(sessionID: String) {
        // For demonstration purposes
        let sampleSongs = [
            Song(id: "4", title: "Hotel California", artist: "Eagles", album: "Hotel California", duration: 390, artworkURL: nil, previewURL: nil, serviceType: .spotify, serviceURI: "spotify:track:sample4"),
            Song(id: "5", title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", duration: 355, artworkURL: nil, previewURL: nil, serviceType: .spotify, serviceURI: "spotify:track:sample5")
        ]
        
        let session = Session(
            id: sessionID,
            name: "Friend's Party",
            hostUserID: "friend123",
            currentUsers: ["friend123", "currentUser"],
            currentSong: sampleSongs.first,
            playlist: sampleSongs,
            moodSetting: .hype
        )
        
        self.currentSession = session
    }
}
