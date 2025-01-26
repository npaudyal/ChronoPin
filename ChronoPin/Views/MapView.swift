//
//  MapView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showMessagePopup = false
    @State private var showTextInput = false

    var body: some View {
        ZStack {
            // Map View
            Map(position: $cameraPosition) {
                UserAnnotation() // Show user's current location
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .onLongPressGesture {
                // Use the map's center as the selected coordinate
                selectedCoordinate = locationManager.userLocation?.coordinate ?? cameraPosition.region?.center
                showMessagePopup = true
            }
            .onAppear {
                locationManager.startUpdatingLocation()
                if let location = locationManager.userLocation?.coordinate {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
            }

            // Popup for Message Type Selection
            if showMessagePopup {
                MessageTypePopup(
                    selectedCoordinate: $selectedCoordinate,
                    showMessagePopup: $showMessagePopup,
                    showTextInput: $showTextInput
                )
                .transition(.scale) // Optional animation
            }
        }
        .sheet(isPresented: $showTextInput) {
            if let coordinate = selectedCoordinate {
                TextInputView(coordinate: coordinate)
            }
        }
    }
}

// Preview
#Preview {
    MapView()
}
