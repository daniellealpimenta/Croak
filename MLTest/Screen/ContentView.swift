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
                            gestureName: gesture
                        )
                    case "OpenPalm":
                        GestureCardView(
                            backgroundColor: .blue,
                            gestureName: gesture
                        )
                    case "Rock":
                        GestureCardView(
                            backgroundColor: .green,
                            gestureName: gesture
                        )
                    case "HangLose":
                        GestureCardView(
                            backgroundColor: .yellow,
                            gestureName: gesture
                        )
                    default:
                        GestureCardView(
                            backgroundColor: .gray,
                            gestureName: gesture
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
