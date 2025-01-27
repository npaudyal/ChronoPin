//
//  ChronoPin.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/26/25.
//

import Foundation
import FirebaseFirestore
import MapKit

struct ChronoPin {
    var id: String? // Firestore document ID (optional for new pins)
    let userId: String
    let type: String // "text", "image", or "video"
    let content: String // Text or Firebase Storage URL
    let location: GeoPoint // Firestore GeoPoint
    let createdAt: Timestamp
    var unlockConditions: [String: Any]
    let isPublic: Bool

    // Convert to a Firestore-friendly dictionary
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "type": type,
            "content": content,
            "location": location,
            "createdAt": createdAt,
            "unlockConditions": unlockConditions,
            "isPublic": isPublic
        ]
    }

    // Initialize from a Firestore document
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let userId = data["userId"] as? String,
              let type = data["type"] as? String,
              let content = data["content"] as? String,
              let location = data["location"] as? GeoPoint,
              let createdAt = data["createdAt"] as? Timestamp,
              let unlockConditions = data["unlockConditions"] as? [String: Any],
              let isPublic = data["isPublic"] as? Bool
        else { return nil }

        self.id = document.documentID
        self.userId = userId
        self.type = type
        self.content = content
        self.location = location
        self.createdAt = createdAt
        self.unlockConditions = unlockConditions
        self.isPublic = isPublic
    }
}
