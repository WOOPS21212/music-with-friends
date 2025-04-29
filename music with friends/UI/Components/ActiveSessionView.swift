//
//  ActiveSessionView.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//
import SwiftUI



// ActiveSessionView.swift - Improved version
struct ActiveSessionView: View {
    @ObservedObject var sessionManager: SessionManager
    @ObservedObject var playbackManager: PlaybackManager
    @State private var moodValue: Double = 0.5
    var leaveSession: () -> Void
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Session info
                HStack {
                    VStack(alignment: .leading) {
                        if let session = sessionManager.currentSession {
                            Text(session.name)
                                .font(AppTheme.Typography.heading)
                                .foregroundColor(AppTheme.text)
                            
                            Text("\(session.currentUsers.count) people in this session")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Host badge if applicable
                    if sessionManager.isHost {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppTheme.secondary)
                            
                            Text("Host")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.secondary.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
                .padding()
                
                // Now playing section
                VStack(spacing: 20) {
                    if let currentSong = sessionManager.currentSession?.currentSong {
                        // Album art
                        AlbumArtView(artworkURL: URL(string: currentSong.artworkURL ?? ""), size: 220)

                            .shadow(radius: 10)
                        
                        // Song info
                        VStack(spacing: 8) {
                            Text(currentSong.title)
                                .font(AppTheme.Typography.heading)
                                .foregroundColor(AppTheme.text)
                                .multilineTextAlignment(.center)
                            
                            Text(currentSong.artist)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        // Playback controls
                        HStack(spacing: 30) {
                            Button(action: {}) {
                                Image(systemName: "backward.fill")
                                    .font(.title)
                                    .foregroundColor(AppTheme.text)
                            }
                            
                            Button(action: {
                                if playbackManager.isPlaying {
                                    playbackManager.pause()
                                } else {
                                    playbackManager.resume()
                                }
                            }) {
                                Image(systemName: playbackManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.secondary)
                            }
                            
                            Button(action: {
                                Task {
                                    try? await sessionManager.skipToNextSong()
                                }
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.title)
                                    .foregroundColor(AppTheme.text)
                            }
                        }
                        
                    } else {
                        // No song playing placeholder
                        VStack(spacing: 20) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.surfaceLight)
                            
                            Text("No song playing")
                                .font(AppTheme.Typography.heading)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Button(action: {
                                Task {
                                    try? await sessionManager.skipToNextSong()
                                }
                            }) {
                                Text("Start Playback")
                                    .font(.headline)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.secondary)
                                    .foregroundColor(.white)
                                    .cornerRadius(AppTheme.Shapes.buttonCornerRadius)
                            }
                        }
                        .padding()
                    }
                }
                .padding()
                
                // Mood slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Adjust Vibe")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    MoodSlider(value: $moodValue) { newValue in
                        Task {
                            try? await sessionManager.adjustMood(newValue: newValue)
                        }
                    }
                }
                .padding()
                
                // Up next list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Up Next")
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    List {
                        if let session = sessionManager.currentSession {
                            ForEach(session.playlist) { song in
                                SongRowView(
                                    song: song,
                                    isPlaying: song.id == session.currentSong?.id,
                                    onTap: {}
                                )
                                .listRowBackground(AppTheme.surfaceLight)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(AppTheme.background)
                }
                .padding(.horizontal)
                
                // Leave session button
                Button(action: leaveSession) {
                    Text("Leave Session")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            // Initialize mood value from current session
            if let session = sessionManager.currentSession {
                moodValue = session.moodSetting ?? 0.5
            }
        }
    }
}
