//
//  AuthViewModel.swift
//  ChronoPin
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class AuthViewModel: ObservableObject {
    @Published var user: AppUser?
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        handler = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                // Directly fetch from Firestore to get complete user data
                Firestore.firestore().collection("users").document(firebaseUser.uid)
                    .getDocument { snapshot, error in
                        guard let snapshot = snapshot, snapshot.exists else {
                            print("User document not found")
                            self.user = nil
                            return
                        }
                        
                        do {
                            // Decode the full AppUser from Firestore
                            self.user = try snapshot.data(as: AppUser.self)
                        } catch {
                            print("Error decoding user: \(error)")
                            self.user = nil
                        }
                    }
            } else {
                self.user = nil
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
