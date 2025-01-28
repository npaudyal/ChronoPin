//
//  FriendsView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//
import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var friends: [AppUser] = []
    @State private var pendingRequests: [AppUser] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section("Pending Requests") {
                    ForEach(pendingRequests) { user in
                        HStack {
                            Text(user.username)
                            Button("Accept") {
                                Task {
                                    guard let currentUserID = authViewModel.user?.id else { return }
                                    try await UserService().acceptFriendRequest(
                                        userID: currentUserID,
                                        friendID: user.id
                                    )
                                }
                            }
                        }
                    }
                }
                
                Section("Friends") {
                    ForEach(friends) { user in
                        Text(user.username)
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                NavigationLink("Add Friend") {
                    FriendSearchView()
                }
            }
            .onAppear {
                Task {
                    await loadFriends()
                }
            }
        }
    }
    
    @MainActor
        private func loadFriends() async {
            guard let user = authViewModel.user else { return }
            let service = UserService()
            
            // Get friends
            friends = await fetchUsers(ids: user.friends, service: service)
            
            // Get pending requests
            pendingRequests = await fetchUsers(ids: user.friendRequests, service: service)
        }
        
        private func fetchUsers(ids: [String], service: UserService) async -> [AppUser] {
            await withTaskGroup(of: AppUser?.self) { group in
                var users: [AppUser] = []
                
                for id in ids {
                    group.addTask {
                        try? await service.getUser(id: id)
                    }
                }
                
                for await user in group {
                    if let user = user {
                        users.append(user)
                    }
                }
                
                return users
            }
        }
}
