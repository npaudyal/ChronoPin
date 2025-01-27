//
//  AppUser.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import Foundation
import FirebaseAuth

struct AppUser: Identifiable {
    let id: String
    let email: String?
    let displayName: String?
    
    // Initialize from Firebase User
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
    }
    
    // For previews/mocking
    init(id: String, email: String?, displayName: String?) {
        self.id = id
        self.email = email
        self.displayName = displayName
    }
}
