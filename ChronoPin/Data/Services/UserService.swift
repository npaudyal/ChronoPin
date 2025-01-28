//
//  UserService.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    
    // Create user profile after signup
    func createUserProfile(user: AppUser) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    // Search users by username
    func searchUsers(username: String) async throws -> [AppUser] {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .limit(to: 10)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: AppUser.self) }
    }
    
    func getUser(id: String) async throws -> AppUser {
            let document = try await db.collection("users").document(id).getDocument()
            guard let user = try? document.data(as: AppUser.self) else {
                throw NSError(domain: "UserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user"])
            }
            return user
        }
    
    // Send friend request
    func sendFriendRequest(from senderID: String, to receiverID: String) async throws {
        let receiverRef = db.collection("users").document(receiverID)
        try await receiverRef.updateData([
            "friend_requests": FieldValue.arrayUnion([senderID])
        ])
    }
    
    // Accept friend request
    func acceptFriendRequest(userID: String, friendID: String) async throws {
        let batch = db.batch()
        let userRef = db.collection("users").document(userID)
        let friendRef = db.collection("users").document(friendID)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([friendID]),
            "friend_requests": FieldValue.arrayRemove([friendID])
        ], forDocument: userRef)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([userID])
        ], forDocument: friendRef)
        
        try await batch.commit()
    }
}
