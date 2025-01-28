//
//  MainTabView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import SwiftUI
import Firebase
import FirebaseCore

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(0)
            
            // Pins Tab
            PinsView()
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Pins")
                }
                .tag(1)
            
            // Friends Tab
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Friends")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue) // Set global tint color
    }
}

#Preview {
    // Create mock auth state
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
   return MainTabView()
        .environmentObject(authViewModel)
}
