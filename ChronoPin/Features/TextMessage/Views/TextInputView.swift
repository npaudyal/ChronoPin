//
//  TextInputView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//
import SwiftUI
import CoreData
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct TextInputView: View {
    @Environment(\.dismiss) var dismiss
    let coordinate: CLLocationCoordinate2D
    @State private var message: String = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Display selected coordinate for verification
            Text("Saving at: \(coordinate.latitude.formatted(.number.precision(.fractionLength(5)))), \(coordinate.longitude.formatted(.number.precision(.fractionLength(5))))")
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField("Enter your message", text: $message)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Save Pin") {
                savePinToFirestore()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func savePinToFirestore() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to save a pin."
            showErrorAlert = true
            return
        }
        
        // Convert CLLocationCoordinate2D to Firestore GeoPoint
        let geoPoint = GeoPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        // Create pin data
        let pinData: [String: Any] = [
            "userId": user.uid,
            "type": "text",
            "content": message,
            "location": geoPoint,
            "createdAt": Timestamp(date: Date()),
            "unlockConditions": ["type": "time", "unlockTime": Timestamp(date: Date())], // Temporary placeholder
            "isPublic": false
        ]
        
        // Save to Firestore
        Firestore.firestore().collection("pins").addDocument(data: pinData) { error in
            if let error = error {
                errorMessage = "Failed to save: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                dismiss() // Close the sheet on success
            }
        }
    }
}
