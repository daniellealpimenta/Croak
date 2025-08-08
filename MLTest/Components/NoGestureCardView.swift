//
//  NoGestureCardView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 07/08/25.
//

import SwiftUI

struct NoGestureCardView: View {
    let confidence: Double
    
    var body: some View {
        VStack {
            Image(systemName: "hand.raised.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Nenhum gesto")
                .font(.title3)
                .foregroundColor(.gray)
            
            if confidence > 0 {
                Text("Confiança baixa: \(Int(confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Posicione sua mão")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 150, height: 120)
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
        )
    }
}

#Preview {
    NoGestureCardView(confidence: 0.92)
}
