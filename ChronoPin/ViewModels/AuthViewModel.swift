//
//  AuthViewModel.swift
//  ChronoPin
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: AppUser?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.user = AppUser(firebaseUser: firebaseUser)
            } else {
                self?.user = nil
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
