//
//  ChronoPinApp.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI
import FirebaseCore
@main
struct ChronoPinApp: App {
    let persistenceController = PersistenceController.shared
    init(){
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
