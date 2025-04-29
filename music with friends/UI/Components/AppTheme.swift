// AppTheme.swift - Define the app's visual style
import SwiftUI

struct AppTheme {
    // Colors
    static let primary = Color(hex: "#5C67DE")
    static let secondary = Color(hex: "#42E2B8")
    static let background = Color(hex: "#121212")
    static let surfaceLight = Color(hex: "#2A2A2A")
    static let text = Color.white
    static let textSecondary = Color(hex: "#B3B3B3")
    
    // Gradients
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [primary, secondary]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Typography
    struct Typography {
        static let title = Font.system(size: 28, weight: .bold)
        static let heading = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
    }
    
    // Animations
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
    }
    
    // Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    // Shapes
    struct Shapes {
        static let cornerRadius: CGFloat = 12
        static let buttonCornerRadius: CGFloat = 8
    }
}

// Color extension for hex initialization
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UI Components

// RoundedTextFieldStyle.swift
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.surfaceLight)
            .cornerRadius(AppTheme.Shapes.cornerRadius)
            .foregroundColor(AppTheme.text)
    }
}

// SocialSignInButton.swift
struct SocialSignInButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let backgroundColor: Color
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .padding(.leading, 8)
                
                Text(title)
                    .font(.headline)
                    .padding(.trailing, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.Shapes.buttonCornerRadius)
        }
    }
}

// AlbumArtView.swift
struct AlbumArtView: View {
    let artworkURL: URL?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let artworkURL = artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "music.note")
                            .font(.system(size: size / 3))
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: size / 3))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
        .background(AppTheme.surfaceLight)
        .cornerRadius(AppTheme.Shapes.cornerRadius)
    }
}

// MoodSlider.swift
struct MoodSlider: View {
    @Binding var value: Double
    let onChanged: ((Double) -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Chill")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text("Hype")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.surfaceLight)
                    .frame(height: 8)
                
                // Filled track
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.primaryGradient)
                    .frame(width: max(0, min(UIScreen.main.bounds.width * CGFloat(value), UIScreen.main.bounds.width)), height: 8)
                
                // Thumb
                Circle()
                    .fill(AppTheme.secondary)
                    .frame(width: 24, height: 24)
                    .offset(x: max(0, min(UIScreen.main.bounds.width * CGFloat(value), UIScreen.main.bounds.width)) - 12)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newValue = min(1, max(0, value.location.x / UIScreen.main.bounds.width))
                                self.value = newValue
                                onChanged?(newValue)
                            }
                    )
            }
        }
    }
}

// SongRowView.swift
struct SongRowView: View {
    let song: Song
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Album art
                AlbumArtView(artworkURL: song.artworkURL, size: 50)
                
                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(isPlaying ? .headline.bold() : .headline)
                        .foregroundColor(isPlaying ? AppTheme.secondary : AppTheme.text)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Service icon
                Image(song.serviceType.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                // "Now playing" indicator if applicable
                if isPlaying {
                    Image(systemName: "music.note")
                        .foregroundColor(AppTheme.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// NearbyUserView.swift
struct NearbyUserView: View {
    let userInfo: UserDiscoveryInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // User avatar (placeholder)
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(userInfo.deviceName.prefix(1)).uppercased())
                            .foregroundColor(.white)
                            .font(.headline)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userInfo.deviceName)
                        .font(.headline)
                        .foregroundColor(AppTheme.text)
                    
                    if let sessionID = userInfo.sessionID {
                        Text("In a session")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondary)
                    }
                }
                
                Spacer()
                
                // Signal strength indicator
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Rectangle()
                            .fill(i <= userInfo.signalStrength ? AppTheme.secondary : AppTheme.surfaceLight)
                            .frame(width: 3, height: CGFloat(i) * 3)
                    }
                }
            }
            .padding()
            .background(AppTheme.surfaceLight.opacity(0.3))
            .cornerRadius(AppTheme.Shapes.cornerRadius)
        }
    }
}
