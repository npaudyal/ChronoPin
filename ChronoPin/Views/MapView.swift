//
//  MapView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

import SwiftUI
import MapKit
import FirebaseAuth

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showMessagePopup = false
    @State private var showTextInput = false
    @State private var pins: [ChronoPin] = []

    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    UserAnnotation() // Shows the user's live location dot
                    ForEach(pins, id: \.id) { pin in
                        Annotation("", coordinate: CLLocationCoordinate2D(
                            latitude: pin.location.latitude,
                            longitude: pin.location.longitude
                        )) {
                            Image(systemName: "mappin")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onEnded { value in
                            switch value {
                            case .second(_, let drag):
                                if let location = drag?.location {
                                    selectedCoordinate = proxy.convert(location, from: .local)
                                    showMessagePopup = true
                                }
                            default:
                                break
                            }
                        }
                )
                .onAppear {
                    locationManager.startUpdatingLocation()
                    fetchPins()

                    // Set initial map position to user's location (if available)
                    if let userLocation = locationManager.userLocation?.coordinate {
                        let span = MKCoordinateSpan(
                            latitudeDelta: 0.1, // Adjust zoom level (smaller = zoomed in)
                            longitudeDelta: 0.1
                        )
                        cameraPosition = .region(MKCoordinateRegion(
                            center: userLocation,
                            span: span
                        ))
                    }
                }
            }

            if showMessagePopup {
                MessageTypePopup(
                    selectedCoordinate: $selectedCoordinate,
                    showMessagePopup: $showMessagePopup,
                    showTextInput: $showTextInput
                )
                .transition(.scale)
            }
        }
        .sheet(isPresented: $showTextInput) {
            if let coordinate = selectedCoordinate {
                TextInputView(coordinate: coordinate)
            }
        }
    }

    private func fetchPins() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("pins")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                pins = snapshot?.documents.compactMap { ChronoPin(document: $0) } ?? []
            }
    }
}

// Preview
#Preview {
    MapView()
}
