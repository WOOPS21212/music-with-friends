//
//  CreateSessionSheet.swift
//  music with friends
//
//  Created by amc on 4/29/25.
//
import SwiftUI
// CreateSessionSheet.swift
struct CreateSessionSheet: View {
    @Binding var sessionName: String
    var onCreate: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var isRoamingMode = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Create New Session")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(AppTheme.text)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Name")
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        TextField("My Awesome Playlist", text: $sessionName)
                            .textFieldStyle(RoundedTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Session Mode")
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        HStack(spacing: 16) {
                            // Roaming mode button
                            Button(action: { isRoamingMode = true }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 28))
                                    
                                    Text("Roaming")
                                        .font(.headline)
                                    
                                    Text("Everyone has equal control")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isRoamingMode ? AppTheme.primary.opacity(0.2) : AppTheme.surfaceLight)
                                .foregroundColor(isRoamingMode ? AppTheme.secondary : AppTheme.textSecondary)
                                .cornerRadius(AppTheme.Shapes.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Shapes.cornerRadius)
                                        .stroke(isRoamingMode ? AppTheme.secondary : Color.clear, lineWidth: 2)
                                )
                            }
                            
                            // Venue mode button
                            Button(action: { isRoamingMode = false }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 28))
                                    
                                    Text("Venue")
                                        .font(.headline)
                                    
                                    Text("You control what plays")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(!isRoamingMode ? AppTheme.primary.opacity(0.2) : AppTheme.surfaceLight)
                                .foregroundColor(!isRoamingMode ? AppTheme.secondary : AppTheme.textSecondary)
                                .cornerRadius(AppTheme.Shapes.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Shapes.cornerRadius)
                                        .stroke(!isRoamingMode ? AppTheme.secondary : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Create button
                    Button(action: onCreate) {
                        Text("Create Session")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(sessionName.isEmpty ? AppTheme.surfaceLight : AppTheme.primaryGradient)
                            .foregroundColor(sessionName.isEmpty ? AppTheme.textSecondary : .white)
                            .cornerRadius(AppTheme.Shapes.buttonCornerRadius)
                    }
                    .disabled(sessionName.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.top, 24)
            }
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppTheme.secondary)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
