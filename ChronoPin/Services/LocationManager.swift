//
//  LocationManager.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
    
    func convertToCoordinate(_ point: CGPoint) -> CLLocationCoordinate2D {
        // For simplicity, return the user's current location or a default
        return userLocation?.coordinate ?? CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
}
