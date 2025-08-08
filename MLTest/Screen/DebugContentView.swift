//
//  DebutContentView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 07/08/25.
//

import SwiftUI

// MARK: - Versão com Debug (opcional)
struct DebugContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Informações de debug no topo
                VStack {
                    Text("DEBUG MODE")
                        .font(.caption)
                        .padding(4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    HStack {
                        Text("Gesto: \(viewModel.predictedGesture ?? "Nenhum")")
                        Spacer()
                        Text("Confiança: \(String(format: "%.2f", viewModel.confidence))")
                    }
                    .font(.caption)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // UI principal (mesmo código anterior)
                VStack(spacing: 12) {
                    ConfidenceIndicator(confidence: viewModel.confidence)
                    
                    if let gesture = viewModel.predictedGesture, viewModel.confidence >= 0.95 {
                        switch gesture {
                        case "Two":
                            GestureCardView(backgroundColor: .red, gestureName: gesture)
                        case "OpenPalm":
                            GestureCardView(backgroundColor: .blue, gestureName: gesture)
                        case "Rock":
                            GestureCardView(backgroundColor: .green, gestureName: gesture)
                        case "HangLose":
                            GestureCardView(backgroundColor: .yellow, gestureName: gesture)
                        default:
                            GestureCardView(backgroundColor: .gray, gestureName: gesture)
                        }
                    } else {
                        NoGestureCardView(confidence: viewModel.confidence)
                    }
                }
                .padding(.bottom, 50)
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
    DebugContentView()
}
