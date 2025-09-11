//
//  ContentView.swift
//  Ivy
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(FirebaseAuthService.self) private var authService
    @Environment(InvestmentConfig.self) private var investmentConfig
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if authService.isFirebaseConfigured {
                if authService.isAuthenticated {
                    MainTabView()
                        .onAppear {
                            checkOnboardingStatus()
                        }
                        .fullScreenCover(isPresented: $showingOnboarding) {
                            OnboardingView()
                                .environment(investmentConfig)
                        }
                } else {
                    AuthenticationView()
                }
            } else {
                FirebaseSetupRequiredView()
            }
        }
    }
    
    private func checkOnboardingStatus() {
        if !investmentConfig.hasCompletedOnboarding {
            showingOnboarding = true
        }
    }
}

struct FirebaseSetupRequiredView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Firebase Setup Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("To use authentication features, you need to set up Firebase for this project.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("1.")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Go to the Firebase Console")
                }
                
                HStack {
                    Text("2.")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Create a new project or select existing")
                }
                
                HStack {
                    Text("3.")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Add an iOS app with bundle ID: ompatel.Ivy")
                }
                
                HStack {
                    Text("4.")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Download GoogleService-Info.plist")
                }
                
                HStack {
                    Text("5.")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Add the file to your Xcode project")
                }
                
                HStack {
                    Text("6.")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Enable Email/Password authentication")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button("Open Firebase Console") {
                if let url = URL(string: "https://console.firebase.google.com") {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            
            NavigationLink("Continue Without Authentication (Demo Mode)") {
                MainTabView()
            }
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .padding()
        .navigationTitle("Setup Required")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Stock.self, inMemory: true)
        .environment(FirebaseAuthService.shared)
        .environment(InvestmentConfig.shared)
}
