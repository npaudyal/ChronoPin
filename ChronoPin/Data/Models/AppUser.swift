//
//  AppUser.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    let id: String               // Non-optional
    let email: String
    var username: String
    var friends: [String]
    var friendRequests: [String]
    
    // Initialize from Firebase User
    init(firebaseUser: FirebaseAuth.User, username: String) {
            self.id = firebaseUser.uid
            self.email = firebaseUser.email ?? ""
            self.username = username
            self.friends = []
            self.friendRequests = []
        }

        // Memberwise initializer for previews
        init(
            id: String,
            email: String,
            username: String,
            friends: [String],
            friendRequests: [String]
        ) {
            self.id = id
            self.email = email
            self.username = username
            self.friends = friends
            self.friendRequests = friendRequests
        }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case friends
        case friendRequests = "friend_requests"
    }
}
