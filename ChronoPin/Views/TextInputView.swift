//
//  TextInputView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//
import SwiftUI
import MapKit // Add this import
import CoreData

struct TextInputView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    let coordinate: CLLocationCoordinate2D
    @State private var textMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Type your message...", text: $textMessage)
                Button("Save") {
                    saveTextPin()
                    dismiss()
                }
            }
            .navigationTitle("Text Message")
        }
    }

    private func saveTextPin() {
        let newPin = Pin(context: viewContext)
        newPin.id = UUID()
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        newPin.message = textMessage
        newPin.unlockDate = Date() // Temporary
        
        try? viewContext.save()
    }
}
