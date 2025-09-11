//
//  FirebaseAuthService.swift
//  Ivy
//

import Foundation
import FirebaseAuth
import FirebaseCore

@Observable
class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    var isAuthenticated = false
    var currentUser: User?
    var isFirebaseConfigured = false
    
    private init() {
        if FirebaseApp.app() != nil {
            isFirebaseConfigured = true
            currentUser = Auth.auth().currentUser
            isAuthenticated = currentUser != nil
            
            Auth.auth().addStateDidChangeListener { [weak self] _, user in
                DispatchQueue.main.async {
                    self?.currentUser = user
                    self?.isAuthenticated = user != nil
                }
            }
        }
    }
    
    
    func register(email: String, password: String, displayName: String) async throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        DispatchQueue.main.async {
            InvestmentConfig.shared.hasCompletedOnboarding = false
        }
        
        try await result.user.sendEmailVerification()
        
        DispatchQueue.main.async {
            self.currentUser = result.user
            self.isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) async throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        DispatchQueue.main.async {
            self.currentUser = result.user
            self.isAuthenticated = true
        }
    }
    
    func logout() throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        try Auth.auth().signOut()
        
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func resetPassword(email: String) async throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteAccount() async throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        guard let user = currentUser else {
            throw AuthError.noCurrentUser
        }
        
        try await user.delete()
        
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func sendEmailVerification() async throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        guard let user = currentUser else {
            throw AuthError.noCurrentUser
        }
        
        try await user.sendEmailVerification()
    }
    
    func updateDisplayName(_ displayName: String) async throws {
        guard isFirebaseConfigured else {
            throw AuthError.firebaseNotConfigured
        }
        
        guard let user = currentUser else {
            throw AuthError.noCurrentUser
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        DispatchQueue.main.async {
            InvestmentConfig.shared.hasCompletedOnboarding = false
        }
        
        DispatchQueue.main.async {
            self.currentUser = Auth.auth().currentUser
        }
    }
}

enum AuthError: LocalizedError {
    case firebaseNotConfigured
    case noCurrentUser
    case weakPassword
    case emailAlreadyInUse
    case invalidEmail
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured. Please add GoogleService-Info.plist to your project."
        case .noCurrentUser:
            return "No user is currently signed in."
        case .weakPassword:
            return "The password is too weak. Please choose a stronger password."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .userNotFound:
            return "No account found with this email address."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .unknown(let message):
            return message
        }
    }
}
