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
    @StateObject private var authViewModel = AuthViewModel()
    init(){
        FirebaseApp.configure()
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
            WindowGroup {
                Group {
                    if authViewModel.user != nil {
                        MainTabView()
                            .environmentObject(authViewModel)
                    } else {
                        LoginView() // Make sure you have a LoginView
                            .environmentObject(authViewModel)
                    }
                }
            }
        }
}
