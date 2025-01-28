//
//  LoginView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/26/25.
//

import SwiftUI

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isAuthenticated = false
    @EnvironmentObject var authViewModel: AuthViewModel


    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Login") {
                login()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .navigationTitle("Login")
        .fullScreenCover(isPresented: $isAuthenticated) {
            ContentView() // Redirect to main app after login
        }
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isAuthenticated = true
            }
        }
    }
}
#Preview {
    LoginView()
}
