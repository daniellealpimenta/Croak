//
//  GestureCardView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 07/08/25.
//

import SwiftUI

struct GestureCardView: View {
    let backgroundColor: Color
    let gestureName: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Gesto detectado: \(gestureName)")
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            
            if gestureName == "Background" {
                ZStack {
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(width: 160, height: 160)
                }
            } else {
                ZStack {
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(width: 160, height: 160)
                    
                    Image(gestureName)
                        .resizable()
                        .frame(width: 120, height: 120)
                }
            }
        }
    }
}

#Preview {
    GestureCardView(backgroundColor: .red, gestureName: "Rock")
}
