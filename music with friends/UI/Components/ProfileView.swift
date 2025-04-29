import SwiftUI

// ProfileView.swift - User profile
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User profile header
                        VStack(spacing: 16) {
                            // Avatar
                            Circle()
                                .fill(AppTheme.primaryGradient)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(String((appState.currentUser?.name.first ?? "U").uppercased()))
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            // Name
                            Text(appState.currentUser?.name ?? "User")
                                .font(AppTheme.Typography.heading)
                                .foregroundColor(AppTheme.text)
                        }
                        .padding(.top, 24)
                        
                        // Connected services
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Connected Music Services")
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                            
                            ForEach(MusicService.allCases, id: \.self) { service in
                                HStack {
                                    Image(service.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    
                                    Text(service.displayName)
                                        .font(.body)
                                        .foregroundColor(AppTheme.text)
                                    
                                    Spacer()
                                    
                                    if appState.connectedMusicServices.contains(service) {
                                        // Connected indicator
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            
                                            Text("Connected")
                                                .font(.subheadline)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    } else {
                                        // Connect button
                                        Button(action: {
                                            Task {
                                                try? await appState.connectMusicService(service)
                                            }
                                        }) {
                                            Text("Connect")
                                                .font(.subheadline)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color(hex: service.primaryColor).opacity(0.2))
                                                .foregroundColor(Color(hex: service.primaryColor))
                                                .cornerRadius(AppTheme.Shapes.buttonCornerRadius)
                                        }
                                    }
                                }
                                .padding()
                                .background(AppTheme.surfaceLight)
                                .cornerRadius(AppTheme.Shapes.cornerRadius)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Favorite artists/genres
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Music Taste")
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                            
                            // Top artists
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Top Artists")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        let artists = appState.currentUser?.topArtists ?? ["Queen", "Led Zeppelin", "Beatles", "Pink Floyd", "Michael Jackson"]
                                        
                                        ForEach(artists, id: \.self) { artist in
                                            VStack {
                                                Circle()
                                                    .fill(AppTheme.surfaceLight)
                                                    .frame(width: 80, height: 80)
                                                    .overlay(
                                                        Text(String(artist.prefix(1)))
                                                            .font(.title)
                                                            .foregroundColor(AppTheme.textSecondary)
                                                    )
                                                
                                                Text(artist)
                                                    .font(.caption)
                                                    .foregroundColor(AppTheme.text)
                                                    .lineLimit(1)
                                                    .frame(width: 80)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Favorite genres
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Favorite Genres")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                FlowLayout(spacing: 8) {
                                    let genres = appState.currentUser?.favoriteGenres ?? ["Rock", "Pop", "Electronic", "Hip Hop", "R&B", "Metal", "Classical", "Jazz", "Indie"]
                                    
                                    ForEach(genres, id: \.self) { genre in
                                        Text(genre)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppTheme.primary.opacity(0.2))
                                            .foregroundColor(AppTheme.secondary)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(AppTheme.text)
                            
                            // Offline mode toggle
                            Toggle(isOn: Binding<Bool>(
                                get: { appState.useOfflineMode },
                                set: { appState.toggleOfflineMode() }
                            )) {
                                HStack {
                                    Image(systemName: "wifi.slash")
                                        .foregroundColor(AppTheme.text)
                                    
                                    Text("Offline Mode")
                                        .font(.body)
                                        .foregroundColor(AppTheme.text)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: AppTheme.secondary))
                            .padding()
                            .background(AppTheme.surfaceLight)
                            .cornerRadius(AppTheme.Shapes.cornerRadius)
                            
                            // Push notifications toggle
                            Toggle(isOn: Binding<Bool>(
                                get: { appState.pushNotificationsEnabled },
                                set: { appState.togglePushNotifications() }
                            )) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(AppTheme.text)
                                    
                                    Text("Push Notifications")
                                        .font(.body)
                                        .foregroundColor(AppTheme.text)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: AppTheme.secondary))
                            .padding()
                            .background(AppTheme.surfaceLight)
                            .cornerRadius(AppTheme.Shapes.cornerRadius)
                        }
                        .padding(.horizontal)
                        
                        // Sign out button
                        Button(action: {
                            appState.signOut()
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(AppTheme.Shapes.buttonCornerRadius)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Your Profile")
        }
    }
}
