//
//  MainTabView.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//

import SwiftUI

// MainTabView.swift - Main tab container
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab (active session or selection)
            Group {
                if appState.currentSession != nil {
                    ActiveSessionView(
                        sessionManager: SessionManager(
                            playlistGenerator: PlaylistGenerator(),
                            musicServiceManager: MusicServiceManager()
                        ),
                        playbackManager: PlaybackManager(),
                        leaveSession: {
                            appState.leaveCurrentSession()
                        }
                    )
                } else {
                    SessionSelectionView(
                        createNewSession: {
                            Task {
                                try? await appState.createSession(name: "My Session", mode: .roaming)
                            }
                        },
                        joinSession: {
                            // Join selected session
                        }
                    )
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            // Profile tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(1)
        }
        .accentColor(AppTheme.secondary)
        .onAppear {
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(AppTheme.surfaceLight)
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
