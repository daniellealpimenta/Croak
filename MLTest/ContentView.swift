//
//  ContentView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 30/07/25.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                // Só mostra o card se a confiança for maior que 95%
                if let gesture = viewModel.predictedGesture, viewModel.confidence >= 0.95 {
                    switch gesture {
                    case "Two":
                        GestureCardView(
                            backgroundColor: .red,
                            gestureName: gesture,
                            confidence: viewModel.confidence
                        )
                    case "OpenPalm":
                        GestureCardView(
                            backgroundColor: .blue,
                            gestureName: gesture,
                            confidence: viewModel.confidence
                        )
                    case "Rock":
                        GestureCardView(
                            backgroundColor: .green,
                            gestureName: gesture,
                            confidence: viewModel.confidence
                        )
                    case "HangLose":
                        GestureCardView(
                            backgroundColor: .yellow,
                            gestureName: gesture,
                            confidence: viewModel.confidence
                        )
                    default:
                        GestureCardView(
                            backgroundColor: .gray,
                            gestureName: gesture,
                            confidence: viewModel.confidence
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Componentes Auxiliares

struct ConfidenceIndicator: View {
    let confidence: Double
    
    var body: some View {
        HStack {
            Text("Confiança:")
                .font(.caption)
                .foregroundColor(.white)
            
            // Barra de progresso da confiança
            ProgressView(value: confidence, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 100)
                .scaleEffect(y: 2)
            
            Text("\(Int(confidence * 100))%")
                .font(.caption)
                .foregroundColor(confidenceColor)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.9...:
            return .green
        case 0.7..<0.9:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    ContentView()
}
