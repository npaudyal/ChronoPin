//
//  SpashScreenView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoOpacity = 0.0
    @State private var logoScale = 0.5
    @State private var textOpacity = 0.0
    @State private var isAuthenticated = false // Replace with your auth logic

    var body: some View {
        if isActive {
            if isAuthenticated {
                ContentView() // Replace with your home view
            } else {
                LoginView() // Replace with your auth view
            }
        } else {
            ZStack {
                // Background with a subtle map texture
                Image("map-background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.2) // Make it subtle

                // Logo and App Name
                VStack {
                    // Logo with animation
                    Image("pin-logo") // Add your logo to Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .opacity(logoOpacity)
                        .scaleEffect(logoScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                logoOpacity = 1.0
                                logoScale = 1.0
                            }
                        }

                    // App Name with animation
                    Text("Pin'd")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(textOpacity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                                textOpacity = 1.0
                            }
                        }
                }
            }
            .onAppear {
                // Simulate a delay for the splash screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }

                // Check authentication status (replace with your logic)
                checkAuthentication()
            }
        }
    }

    private func checkAuthentication() {
        // Replace with your authentication logic
        // Example: Check Firebase Auth or UserDefaults
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
    }
}

#Preview {
    SplashScreenView()
}
