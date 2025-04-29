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
