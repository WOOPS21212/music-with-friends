//
//  AuthenticationView.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    var onAuthenticate: () -> Void

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.secondary)
                    
                    Text("Music Jukebox")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(AppTheme.text)
                    
                    Text("Share the vibe with everyone in the room")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(AppTheme.surfaceLight)
                        .cornerRadius(AppTheme.Shapes.cornerRadius)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(AppTheme.surfaceLight)
                        .cornerRadius(AppTheme.Shapes.cornerRadius)
                }
                .padding(.horizontal)
                
                Button(action: onAuthenticate) {
                    Text("Sign In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.Shapes.buttonCornerRadius)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 60)
        }
    }
}
