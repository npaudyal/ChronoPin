//
//  MapView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showMessagePopup = false

    var body: some View {
        ZStack {
            // New iOS 17 Map Syntax
            Map(position: $cameraPosition) {
                // Show user's current location (blue dot)
                UserAnnotation()
            }
            .mapControls {
                // Optional: Add compass, scale, etc.
                MapCompass()
                MapScaleView()
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        selectedCoordinate = locationManager.userLocation?.coordinate
                        showMessagePopup = true
                    }
            )
            .onAppear {
                locationManager.startUpdatingLocation()
                // Center map on user location
                if let location = locationManager.userLocation?.coordinate {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
            }
        }
    }
}

#Preview {
    MapView()
}
