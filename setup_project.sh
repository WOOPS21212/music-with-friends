#!/bin/bash

# Define project path - update this to your project directory
PROJECT_DIR="$(pwd)"

# Create physical directories for your project structure
mkdir -p "$PROJECT_DIR/Core/Models"
mkdir -p "$PROJECT_DIR/Core/Services"
mkdir -p "$PROJECT_DIR/Core/Extensions"
mkdir -p "$PROJECT_DIR/Features/Authentication"
mkdir -p "$PROJECT_DIR/Features/PlaylistGeneration"
mkdir -p "$PROJECT_DIR/Features/Proximity"
mkdir -p "$PROJECT_DIR/Features/Session"
mkdir -p "$PROJECT_DIR/Features/UserProfile"
mkdir -p "$PROJECT_DIR/UI/Components"
mkdir -p "$PROJECT_DIR/UI/Screens"
mkdir -p "$PROJECT_DIR/UI/Styles"
mkdir -p "$PROJECT_DIR/Resources"

echo "✅ Folder structure created successfully!"

# Create basic Model files
cat > "$PROJECT_DIR/Core/Models/User.swift" << 'EOF'
import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var connectedServices: [MusicService]
    
    // User music preferences
    var favoriteGenres: [String]?
    var favoriteArtists: [String]?
}
EOF

cat > "$PROJECT_DIR/Core/Models/Song.swift" << 'EOF'
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
EOF

cat > "$PROJECT_DIR/Core/Models/Session.swift" << 'EOF'
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
EOF

cat > "$PROJECT_DIR/Core/Models/MusicService.swift" << 'EOF'
import Foundation

enum MusicService: String, Codable, CaseIterable {
    case spotify
    case appleMusic
}
EOF

# Create service managers
cat > "$PROJECT_DIR/Features/Proximity/BluetoothManager.swift" << 'EOF'
import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject {
    @Published var discoveredUsers: [String] = []
    @Published var isScanning = false
    
    // For demonstration purposes only
    func startScanning() {
        isScanning = true
        
        // Simulate finding users nearby
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.discoveredUsers = [
                "John's iPhone",
                "Sarah's iPhone",
                "Music Party"
            ]
        }
    }
    
    func stopScanning() {
        isScanning = false
    }
}
EOF

cat > "$PROJECT_DIR/Features/Session/SessionManager.swift" << 'EOF'
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
EOF

# Create UI components
cat > "$PROJECT_DIR/UI/Screens/ContentView.swift" << 'EOF'
import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @StateObject var sessionManager = SessionManager()
    @State private var isAuthenticated = false
    @State private var activeSession = false
    
    var body: some View {
        if isAuthenticated {
            if activeSession {
                ActiveSessionView(
                    session: sessionManager.currentSession,
                    leaveSession: { activeSession = false }
                )
            } else {
                SessionSelectionView(
                    createNewSession: { 
                        sessionManager.createSession(name: "My Music Session")
                        activeSession = true 
                    },
                    joinSession: { 
                        sessionManager.joinSession(sessionID: "demo-session")
                        activeSession = true 
                    }
                )
            }
        } else {
            AuthenticationView(onAuthenticate: { isAuthenticated = true })
        }
    }
}

struct AuthenticationView: View {
    var onAuthenticate: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Music Jukebox")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: onAuthenticate) {
                Text("Sign In (Demo)")
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct SessionSelectionView: View {
    var createNewSession: () -> Void
    var joinSession: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Music With Friends")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Start or join a music session")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: createNewSession) {
                Text("Start New Session")
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: joinSession) {
                Text("Join Nearby Session")
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ActiveSessionView: View {
    var session: Session?
    var leaveSession: () -> Void
    
    var body: some View {
        VStack {
            Text("Now Playing")
                .font(.headline)
                .padding(.top)
            
            Text(session?.currentSong?.title ?? "No song playing")
                .font(.title)
                .fontWeight(.bold)
            
            Text(session?.currentSong?.artist ?? "")
                .font(.title2)
                .foregroundColor(.gray)
            
            // Album art placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 200)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                )
                .padding()
            
            // Players controls placeholder
            HStack(spacing: 40) {
                Button(action: {}) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.title)
                }
                
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .padding()
            
            Text("Up Next")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            List {
                ForEach(session?.playlist ?? []) { song in
                    Text("\(song.title) - \(song.artist)")
                }
            }
            
            Button(action: leaveSession) {
                Text("Leave Session")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}
EOF

# Create main app file
cat > "$PROJECT_DIR/MusicWithFriendsApp.swift" << 'EOF'
import SwiftUI

@main
struct MusicWithFriendsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF

echo "✅ Basic project files created successfully!"
echo "Next steps:"
echo "1. Open your Xcode project"
echo "2. Right-click your project in the navigator and select 'Add Files to \"music with friends\"...'"
echo "3. Select all the directories you just created (Core, Features, UI, Resources)"
echo "4. Make sure 'Create groups' is selected and click Add"
echo "5. Also add the MusicWithFriendsApp.swift file to your project"
echo "6. Clean and build your project"

# Create a .gitignore file
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/

## Obj-C/Swift specific
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
.build/

# CocoaPods
Pods/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Mac OS X
.DS_Store
EOF

echo "✅ .gitignore file created"