//
//  ProfileView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = authViewModel.user {
                    VStack(spacing: 20) {
                        Text(user.email ?? "Unknown email")
                            .font(.title2)
                        
                        Button("Log Out") {
                            showingLogoutAlert = true
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    authViewModel.user = AppUser( // Updated type name
        id: "preview-user-123",
        email: "preview@chronopin.com",
        displayName: "Preview User"
    )
    
    return ProfileView()
        .environmentObject(authViewModel)
}
