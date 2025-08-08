//
//  ContentView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 30/07/25.
//

import CoreML
import SwiftUI

struct TestContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    @State var randomNumber: Int = 1
    @State var imageNumber: Int = 1
    
    @State var imageName: String = ""
    @State var bgColor: Color = Color.gray
    
    func randomizeImage() {
        repeat {
            randomNumber = Int.random(in: 1...4)
        } while randomNumber == imageNumber
                
        imageNumber = randomNumber
        
        switch randomNumber {
            case 1:
                imageName = "Two"
                bgColor = .red
            case 2:
                imageName = "Rock"
                bgColor = .green
            case 3:
                imageName = "OpenPalm"
                bgColor = .blue
            case 4:
                imageName = "HangLose"
                bgColor = .yellow
            default:
                break
        }
    }
    
    var body: some View {
        ZStack {
            CameraView(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)

            VStack {
                GestureTargetView(backgroundColor: bgColor, gestureName: imageName)
                
                // Indicador de status (opcional)
                if let gesture = viewModel.predictedGesture, viewModel.confidence >= 0.95 {
                    if gesture == imageName {
                        Text("✅ Correto!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    } else {
                        Text("❌ Gesto diferente")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            randomizeImage()
        }
        .onChange(of: viewModel.predictedGesture) { _, gesture in
            if let gesture, viewModel.confidence >= 0.95, gesture == imageName {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    randomizeImage()
                }
            }
        }
        
    }
}

#Preview {
    TestContentView()
}
