//
//  SignUpView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/26/25.
//

import SwiftUI
import FirebaseAuth

// MARK: - Social Button Style
struct SocialSignInButton: View {
    let image: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: image)
                    .font(.system(size: image == "apple.logo" ? 20 : 16))
                    .foregroundColor(image == "g.circle.fill" ? .red : .black)
                Text(text)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Terms Text View
struct TermsAndPrivacyText: View {
    var body: some View {
        (Text("By creating an account using email, Google, or Apple, I agree to the ")
            .foregroundColor(.black) +
        Text("Terms and Conditions")
            .foregroundColor(.purple)
            .fontWeight(.medium) +
        Text(", and acknowledge the ")
            .foregroundColor(.black) +
        Text("Privacy Policy")
            .foregroundColor(.purple)
            .fontWeight(.medium))
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 14))
    }
}

// MARK: - Divider View
struct OrDivider: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .frame(height: 1)
            Text("or")
                .foregroundColor(.black)
                .font(.system(size: 14))
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .frame(height: 1)
        }
    }
}

// MARK: - Main SignUp View
struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPresented = true
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Back button
                Button(action: {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.dismiss(animated: true)
        }
    }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 20)
                
                // Title
                Text("Let's get your account set up")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Form fields
                VStack(spacing: 16) {
                    CustomTextField(text: $email, placeholder: "Email", keyboardType: .emailAddress)
                    CustomTextField(text: $password, placeholder: "Password", isSecure: true)
                    CustomTextField(text: $confirmPassword, placeholder: "Confirm password", isSecure: true)
                }
                .padding(.top, 20)
                
                TermsAndPrivacyText()
                    .padding(.top, 8)
                
                // Create Account Button
                Button(action: signUp) {
                    Text("Create account")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .cornerRadius(28)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 20)
                
                // Sign In Link
                Button(action: { dismiss() }) {
                    Text("Already have an account? Sign in")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                OrDivider()
                    .padding(.vertical)
                
                // Social Sign In Buttons
                VStack(spacing: 12) {
                    SocialSignInButton(
                        image: "g.circle.fill",
                        text: "Continue With Google",
                        action: signInWithGoogle
                    )
                    
                    SocialSignInButton(
                        image: "apple.logo",
                        text: "Continue With Apple",
                        action: signInWithApple
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .background(Color(hex: "FFE5B4"))
    }
    
    private func signUp() {
        guard password == confirmPassword else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = result?.user {
                let appUser = AppUser(
                    firebaseUser: user,
                    username: email.components(separatedBy: "@").first ?? ""
                )
                authViewModel.user = appUser
            }
        }
    }
    
    private func signInWithGoogle() {
        // Implement Google Sign In
    }
    
    private func signInWithApple() {
        // Implement Apple Sign In
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text)
                    .foregroundColor(.black)
                    .overlay(
                        HStack {
                            Text(text.isEmpty ? placeholder : "")
                                .foregroundColor(.black.opacity(0.5))
                                .font(.system(size: 16))
                            Spacer()
                        }
                    )
            } else {
                TextField("", text: $text)
                    .foregroundColor(.black)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.none)
                    .overlay(
                        HStack {
                            Text(text.isEmpty ? placeholder : "")
                                .foregroundColor(.black.opacity(0.5))
                                .font(.system(size: 16))
                            Spacer()
                        }
                    )
            }
        }
        .font(.system(size: 16))
        .padding()
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .accentColor(.black)
    }
}
