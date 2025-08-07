//
//  CameraView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 07/08/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    var session: AVCaptureSession

       func makeUIView(context: Context) -> UIView {
           let view = UIView()
           let previewLayer = AVCaptureVideoPreviewLayer(session: session)
           previewLayer.videoGravity = .resizeAspectFill
           previewLayer.frame = UIScreen.main.bounds
           view.layer.addSublayer(previewLayer)
           return view
       }

       func updateUIView(_ uiView: UIView, context: Context) {}
}
