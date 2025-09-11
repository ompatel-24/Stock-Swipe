//
//  AuthenticationView.swift
//  Ivy
//

import SwiftUI

struct AuthenticationView: View {
    @State private var showingSignUp = false
    
    var body: some View {
        if showingSignUp {
            SignUpView(showingSignUp: $showingSignUp)
        } else {
            SignInView(showingSignUp: $showingSignUp)
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(FirebaseAuthService.shared)
}
