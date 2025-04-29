//
//  PlaybackState.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//



// Additional models for app functionality

// PlaybackState.swift - For synchronizing playback between users
import Foundation

struct PlaybackState: Codable {
    var sessionID: String
    var songID: String
    var position: TimeInterval
    var isPlaying: Bool
    var timestamp: Date
    var updatedBy: String // User ID
    
    // Calculate the current position based on elapsed time since timestamp
    func currentPosition() -> TimeInterval {
        guard isPlaying else { return position }
        let elapsed = Date().timeIntervalSince(timestamp)
        return position + elapsed
    }
}
