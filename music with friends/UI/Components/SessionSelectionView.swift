//
//  SessionSelectionView.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//

import SwiftUI

struct SessionSelectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var showingCreateSessionSheet = false
    @State private var sessionName = ""

    var createNewSession: () -> Void
    var joinSession: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack {
                    Text("Music Jukebox")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(AppTheme.text)
                        .padding(.top)

                    Button(action: { showingCreateSessionSheet = true }) {
                        HStack {
                            Image(systemName: "music.note.house.fill")
                                .font(.title2)

                            Text("Create New Session")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.Shapes.cornerRadius)
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Nearby Music Sessions")
                            .font(AppTheme.Typography.heading)
                            .foregroundColor(AppTheme.text)
                            .padding(.horizontal)

                        if bluetoothManager.discoveredUsers.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.surfaceLight)

                                Text("Scanning for nearby sessions...")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.textSecondary)

                                if bluetoothManager.isScanning {
                                    ProgressView()
                                        .tint(AppTheme.secondary)
                                } else {
                                    Button(action: { bluetoothManager.startScanning() }) {
                                        Text("Start Scanning")
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(bluetoothManager.discoveredUsers.values)) { userInfo in
                                        NearbyUserView(userInfo: userInfo, onTap: joinSession)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer()
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingCreateSessionSheet) {
                CreateSessionSheet(sessionName: $sessionName, onCreate: {
                    createNewSession()
                    showingCreateSessionSheet = false
                })
            }
            .onAppear {
                bluetoothManager.startScanning()
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
        }
    }
}
