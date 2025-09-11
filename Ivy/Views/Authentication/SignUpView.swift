//
//  SignUpView.swift
//  Ivy
//

import SwiftUI

struct SignUpView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingPassword = false
    @State private var showingConfirmPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingSuccess = false
    
    @Binding var showingSignUp: Bool
    @Environment(FirebaseAuthService.self) private var authService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerView
                    registrationForm
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
        .alert("Account Created!", isPresented: $showingSuccess) {
            Button("OK") {
                showingSignUp = false
            }
        } message: {
            Text("Please check your email to verify your account before signing in.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Join Ivy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Create your account to start discovering stocks")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var registrationForm: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                CustomTextField(
                    title: "First Name",
                    text: $firstName,
                    placeholder: "First",
                    textInputAutocapitalization: .words
                )
                
                CustomTextField(
                    title: "Last Name", 
                    text: $lastName,
                    placeholder: "Last",
                    textInputAutocapitalization: .words
                )
            }
            
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
                placeholder: "Create a password",
                showingPassword: $showingPassword
            )
            
            CustomSecureField(
                title: "Confirm Password",
                text: $confirmPassword,
                placeholder: "Confirm your password",
                showingPassword: $showingConfirmPassword
            )
            
            if !password.isEmpty {
                passwordValidation
            }
        }
    }
    
    private var passwordValidation: some View {
        VStack(alignment: .leading, spacing: 8) {
            ValidationRow(
                text: "At least 6 characters",
                isValid: password.count >= 6
            )
            
            if !confirmPassword.isEmpty {
                ValidationRow(
                    text: "Passwords match",
                    isValid: password == confirmPassword
                )
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: signUp) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text("Create Account")
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
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign In") {
                    showingSignUp = false
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    private func signUp() {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly."
            showingError = true
            return
        }
        
        guard authService.isFirebaseConfigured else {
            errorMessage = "Firebase is not configured. Please complete the setup first."
            showingError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let displayName = "\(firstName.trimmingCharacters(in: .whitespacesAndNewlines)) \(lastName.trimmingCharacters(in: .whitespacesAndNewlines))"
                
                try await authService.register(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    displayName: displayName
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

struct ValidationRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundColor(isValid ? .green : .red)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isValid ? .green : .red)
            
            Spacer()
        }
    }
}

#Preview {
    SignUpView(showingSignUp: .constant(true))
        .environment(FirebaseAuthService.shared)
}
