//
//  ForgotPasswordView.swift
//  Ivy
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FirebaseAuthService.self) private var authService
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                headerView
                emailForm
                actionButtons
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Email Sent!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Check your email for password reset instructions.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Forgot Your Password?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Enter your email address and we'll send you instructions to reset your password.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var emailForm: some View {
        CustomTextField(
            title: "Email",
            text: $email,
            placeholder: "Enter your email",
            keyboardType: .emailAddress,
            textInputAutocapitalization: .never
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: resetPassword) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text("Send Reset Email")
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
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    private func resetPassword() {
        guard authService.isFirebaseConfigured else {
            errorMessage = "Firebase is not configured. Please complete the setup first."
            showingError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.resetPassword(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                await MainActor.run {
                    showingSuccess = true
                }
                
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
    ForgotPasswordView()
        .environment(FirebaseAuthService.shared)
}
