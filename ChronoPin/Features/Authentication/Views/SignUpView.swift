//
//  SignUpView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/26/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
            
            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
            
            Button("Sign Up") {
                Task {
                    do {
                        // 1. Create Firebase auth user
                        let result = try await Auth.auth().createUser(withEmail: email, password: password)
                        
                        // 2. Create AppUser with proper initialization
                        let appUser = AppUser(
                            firebaseUser: result.user,
                            username: username
                        )
                        
                        // 3. Save to Firestore
                        try await UserService().createUserProfile(user: appUser)
                        
                        // 4. Update auth state
                        authViewModel.user = appUser
                    } catch {
                        print("Signup error: \(error.localizedDescription)")
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    
    // Configure mock user
    authViewModel.user = AppUser(
        id: "preview-user-123",
        email: "preview@chronopin.com",
        username: "PreviewUser",
        friends: [],
        friendRequests: []
    )
    
    // Return the view (implicit return)
    return SignUpView()
        .environmentObject(authViewModel)
}
