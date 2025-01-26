//
//  ChronoPinApp.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI
@main
struct ChronoPinApp: App {
    let persistenceController = PersistenceController.shared
    init(){
        FirebaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
