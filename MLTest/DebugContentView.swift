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
                            GestureCardView(backgroundColor: .red, gestureName: gesture, confidence: viewModel.confidence)
                        case "OpenPalm":
                            GestureCardView(backgroundColor: .blue, gestureName: gesture, confidence: viewModel.confidence)
                        case "Rock":
                            GestureCardView(backgroundColor: .green, gestureName: gesture, confidence: viewModel.confidence)
                        case "HangLose":
                            GestureCardView(backgroundColor: .yellow, gestureName: gesture, confidence: viewModel.confidence)
                        default:
                            GestureCardView(backgroundColor: .gray, gestureName: gesture, confidence: viewModel.confidence)
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

#Preview {
    DebugContentView()
}
