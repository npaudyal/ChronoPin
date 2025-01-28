//
//  ContentView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.user != nil {
                // User is logged in
                MainTabView().environmentObject(authViewModel)
            } else {
                // User is not logged in
                LoginView().environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    ContentView().environmentObject(authViewModel)
}
