//
//  FriendSearchView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import SwiftUI

struct FriendSearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [AppUser] = []
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List(searchResults) { user in
                HStack {
                    Text(user.username)
                    Spacer()
                    Button("Add Friend") {
                        Task {
                            guard let currentUserID = authViewModel.user?.id else { return }
                            try await UserService().sendFriendRequest(
                                from: currentUserID,
                                to: user.id // No need for ?? since id is non-optional
                            )
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) {
                Task {
                    do {
                        let results = try await UserService().searchUsers(username: searchText)
                        searchResults = results.filter { $0.id != authViewModel.user?.id }
                    } catch {
                        print("Search error: \(error)")
                    }
                }
            }
            .navigationTitle("Find Friends")
        }
    }
}
