//
//  FirebaseManager.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import Firebase

class FirebaseManager {
  static let shared = FirebaseManager()
  
  init() {
    FirebaseApp.configure()
  }
}
