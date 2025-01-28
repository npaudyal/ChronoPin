//
//  PinDetailView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import SwiftUI

struct PinDetailView: View {
    let pin: ChronoPin
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Content")
                .font(.title)
            
            Text(pin.content)
                .padding()
            
            Button("Close") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}
