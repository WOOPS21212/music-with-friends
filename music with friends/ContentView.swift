import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @StateObject var sessionManager = SessionManager()
    @StateObject var playbackManager = PlaybackManager()
    @State private var isAuthenticated = false
    @State private var activeSession = false

    var body: some View {
        if isAuthenticated {
            if activeSession {
                ActiveSessionView(
                    sessionManager: sessionManager,
                    playbackManager: playbackManager,
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
                .environmentObject(bluetoothManager)
            }
        } else {
            AuthenticationView(onAuthenticate: { isAuthenticated = true })
        }
    }
}
