//
//  PlaybackManager.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//


// PlaybackManager.swift - Basic implementation for playback
import Foundation
import Combine

class PlaybackManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    @Published var progress: Double = 0.0
    @Published var volume: Double = 0.7
    
    // Simulate playback with timers
    private var playbackTimer: Timer?
    private var durationInSeconds: TimeInterval = 0
    private var startTime: Date?
    
    // MARK: - Playback Control
    
    func play(song: Song) async throws {
        // In a real app, this would play the song via the appropriate music service
        // For now, we'll just simulate playback
        
        // Stop current playback if any
        pause()
        
        // Set up new song
        self.currentSong = song
        self.durationInSeconds = song.duration
        self.progress = 0.0
        
        // Start playback
        resume()
    }
    
    func pause() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        // Calculate progress based on elapsed time
        if let startTime = startTime {
            let elapsed = Date().timeIntervalSince(startTime)
            progress = min(1.0, elapsed / durationInSeconds)
        }
    }
    
    func resume() {
        guard currentSong != nil else { return }
        
        isPlaying = true
        startTime = Date().addingTimeInterval(-progress * durationInSeconds)
        
        // Update progress periodically
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            self.progress = min(1.0, elapsed / self.durationInSeconds)
            
            // Auto-advance when song ends
            if self.progress >= 1.0 {
                self.pause()
                // In a real app, would notify session manager to advance to next song
            }
        }
    }
    
    func setVolume(_ newVolume: Double) {
        volume = max(0, min(1, newVolume))
        // In a real app, would adjust actual audio volume
    }
}
