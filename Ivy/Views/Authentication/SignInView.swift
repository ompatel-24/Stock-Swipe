//
//  SignInView.swift
//  Ivy
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingForgotPassword = false
    
    @Binding var showingSignUp: Bool
    @Environment(FirebaseAuthService.self) private var authService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerView
                    loginForm
                    actionButtons
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Welcome to Ivy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Sign in to discover amazing stocks")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 20) {
            CustomTextField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                textInputAutocapitalization: .never
            )
            
            CustomSecureField(
                title: "Password",
                text: $password,
                placeholder: "Enter your password",
                showingPassword: $showingPassword
            )
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: signIn) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text("Sign In")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isFormValid || isLoading)
            
            Button("Forgot Password?") {
                showingForgotPassword = true
            }
            .foregroundColor(.blue)
            .font(.subheadline)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign Up") {
                    showingSignUp = true
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func signIn() {
        guard authService.isFirebaseConfigured else {
            errorMessage = "Firebase is not configured. Please complete the setup first."
            showingError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.login(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    SignInView(showingSignUp: .constant(false))
        .environment(FirebaseAuthService.shared)
}
