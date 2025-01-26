//
//  MessageTypePopup.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//
import SwiftUI
import MapKit // Add this import

struct MessageTypePopup: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var showMessagePopup: Bool
    @Binding var showTextInput: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Close Button
            Button(action: { showMessagePopup = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }

            // Message Type Buttons
            HStack(spacing: 30) {
                // Text Message
                Button(action: {
                    showTextInput = true
                    showMessagePopup = false
                }) {
                    VStack {
                        Image(systemName: "text.bubble")
                            .font(.largeTitle)
                        Text("Text")
                    }
                }

                // Voice Message (Placeholder)
                Button(action: {}) {
                    VStack {
                        Image(systemName: "mic.circle.fill")
                            .font(.largeTitle)
                        Text("Voice")
                    }
                }
                .disabled(true) // Not implemented yet

                // Video Message (Placeholder)
                Button(action: {}) {
                    VStack {
                        Image(systemName: "video.circle.fill")
                            .font(.largeTitle)
                        Text("Video")
                    }
                }
                .disabled(true) // Not implemented yet
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20)
        .padding()
    }
}
