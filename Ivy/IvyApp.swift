//
//  IvyApp.swift
//  Ivy
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct IvyApp: App {
    init() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            FirebaseApp.configure()
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Stock.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(FirebaseAuthService.shared)
                .environment(InvestmentConfig.shared)
        }
        .modelContainer(sharedModelContainer)
    }
}
