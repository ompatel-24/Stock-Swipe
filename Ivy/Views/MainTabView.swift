//
//  MainTabView.swift
//  Ivy
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    var body: some View {
        TabView {
            StockDiscoveryView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Discover")
                }
            
            PortfolioView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Portfolio")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

struct SettingsView: View {
    @Environment(FirebaseAuthService.self) private var authService
    @Environment(InvestmentConfig.self) private var investmentConfig
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                if let user = authService.currentUser {
                    userProfileSection(user: user)
                }
                
                accountSection
                
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    @ViewBuilder
    private func userProfileSection(user: User) -> some View {
        Section("Profile") {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let displayName = user.displayName, !displayName.isEmpty {
                        Text(displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: user.isEmailVerified ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            .font(.caption)
                            .foregroundColor(user.isEmailVerified ? .green : .orange)
                        
                        Text(user.isEmailVerified ? "Email Verified" : "Email Not Verified")
                            .font(.caption)
                            .foregroundColor(user.isEmailVerified ? .green : .orange)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            if !user.isEmailVerified {
                Button("Verify Email") {
                    sendEmailVerification()
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private var accountSection: some View {
        Section("Account") {
            Button("Sign Out") {
                showingLogoutAlert = true
            }
            .foregroundColor(.blue)
            
            Button("Delete Account") {
                showingDeleteAlert = true
            }
            .foregroundColor(.red)
        }
    }
    
    private func signOut() {
        do {
            try authService.logout()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func deleteAccount() {
        Task {
            do {
                try await authService.deleteAccount()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func resetInvestmentPreferences() {
        investmentConfig.resetOnboarding()
    }
    
    private func sendEmailVerification() {
        Task {
            do {
                try await authService.sendEmailVerification()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Stock.self, inMemory: true)
        .environment(FirebaseAuthService.shared)
        .environment(InvestmentConfig.shared)
}
