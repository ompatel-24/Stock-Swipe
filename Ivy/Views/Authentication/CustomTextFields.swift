//
//  CustomTextFields.swift
//  Ivy
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var textInputAutocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .textInputAutocapitalization(textInputAutocapitalization)
                .autocorrectionDisabled()
        }
    }
}

struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var showingPassword: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                Group {
                    if showingPassword {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    showingPassword.toggle()
                }) {
                    Image(systemName: showingPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            title: "Email",
            text: .constant(""),
            placeholder: "Enter your email",
            keyboardType: .emailAddress,
            textInputAutocapitalization: .never
        )
        
        CustomSecureField(
            title: "Password",
            text: .constant(""),
            placeholder: "Enter your password",
            showingPassword: .constant(false)
        )
    }
    .padding()
}
