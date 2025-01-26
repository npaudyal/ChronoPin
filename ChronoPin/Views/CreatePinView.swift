//
//  CreatePinView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import SwiftUI

struct CreatePinView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State private var message = ""
  @State private var unlockDate = Date()
  
  var body: some View {
    NavigationView {
      Form {
        TextField("Enter message", text: $message)
        DatePicker("Unlock Date", selection: $unlockDate, displayedComponents: .date)
        Button("Save Pin") {
          let newPin = Pin(context: viewContext)
          newPin.id = UUID()
          newPin.message = message
          newPin.unlockDate = unlockDate
          try? viewContext.save()
        }
      }
      .navigationTitle("New ChronoPin")
    }
  }
}

#Preview {
    CreatePinView()
}
