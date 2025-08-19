//
//  GestureDetectionManager.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 16/08/25.
//

import AVFoundation
import SpriteKit
import Vision
import UIKit
import CoreML

// MARK: - Gerenciador de detecção de gestos
class GestureDetectionManager: NSObject {
    let session = AVCaptureSession()
    let handPoseRequest = VNDetectHumanHandPoseRequest()
    let model = try! MLModelV4(configuration: MLModelConfiguration()) // SUBSTITUA pelo nome do seu modelo
    
    weak var delegate: GestureDetectionDelegate?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraView: UIView?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    // Configurações para melhorar a precisão
    private let confidenceThreshold: Double = 0.95
    private let bufferSize = 5
    private var gestureBuffer: [String] = []
    
    override init() {
        super.init()
        setupCamera()
        configureHandPoseRequest()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(orientationChanged),
//            name: UIDevice.orientationDidChangeNotification,
//            object: nil
//        )
    }
    
    func configureHandPoseRequest() {
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
    }
    
//    private func setupOrientationNotification() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(orientationChanged),
//            name: UIDevice.orientationDidChangeNotification,
//            object: nil
//        )
//    }
//
//    @objc private func orientationChanged() {
//        DispatchQueue.main.async {
//            self.updateVideoOrientation()
//        }
//    }
    
    func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else {
            print("Erro ao configurar a câmera frontal")
            return
        }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.alwaysDiscardsLateVideoFrames = false
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.videoOutput = output
        }
        
        configureVideoConnection(output)
        session.commitConfiguration()
    }
    
    func setupCameraPreview(in skView: SKView) {
        // Garante que não vamos criar a view múltiplas vezes
        guard self.cameraView == nil else { return }
        
        DispatchQueue.main.async {
            let cameraViewWidth: CGFloat = 400
            let cameraViewHeight: CGFloat = 200
            let padding: CGFloat = 20
            
            // Cria a UIView que vai conter a imagem da câmera
            let camView = UIView(frame: CGRect(x: padding,
                                                            y: skView.bounds.height - cameraViewHeight - padding,
                                                            width: cameraViewWidth,
                                                            height: cameraViewHeight))
            
            camView.layer.cornerRadius = 10
            camView.layer.borderColor = UIColor.white.cgColor
            camView.layer.borderWidth = 2
            camView.clipsToBounds = true
            self.cameraView = camView
            
            // Cria a camada de preview usando a SESSÃO DA CÂMERA JÁ EXISTENTE
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.frame = camView.bounds
            layer.videoGravity = .resizeAspectFill
            
            if #available(iOS 17.0, *) {
                layer.connection?.videoRotationAngle = 180
            } else {
                layer.connection?.videoOrientation = .landscapeRight
            }

            self.previewLayer = layer
            camView.layer.addSublayer(layer)
            skView.addSubview(camView)
            
            // Configura orientação inicial
//            self.updateVideoOrientation()
        }
    }

    /// Remove a janela de preview da câmera da tela.
    func removeCameraPreview() {
        DispatchQueue.main.async {
            self.cameraView?.removeFromSuperview()
            self.cameraView = nil
            self.previewLayer = nil
        }
    }
    
    func startDetection() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stopDetection() {
        session.stopRunning()
    }
    
    private func smoothGestureDetection(_ newGesture: String) -> String? {
        gestureBuffer.append(newGesture)
        
        if gestureBuffer.count > bufferSize {
            gestureBuffer.removeFirst()
        }
        
        guard gestureBuffer.count == bufferSize else { return nil }
        
        let gestureCounts = gestureBuffer.reduce(into: [:]) { counts, gesture in
            counts[gesture, default: 0] += 1
        }
        
        if let mostFrequent = gestureCounts.max(by: { $0.value < $1.value }),
           Double(mostFrequent.value) / Double(bufferSize) > 0.6 {
            return mostFrequent.key
        }
        
        return nil
    }
    
    // MARK: - Orientação
        
//    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            return scene.interfaceOrientation
//        }
//        return .landscapeRight // Default para iPad
//    }
    
//    private func updateVideoOrientation() {
//        guard let connection = previewLayer?.connection else { return }
//
//        let io = currentInterfaceOrientation()
//
//        if #available(iOS 17.0, *) {
//            let angle: CGFloat
//            switch io {
//            case .landscapeLeft: angle = 0   // Home à direita
//            case .landscapeRight: angle = 180   // Home à esquerda
//            case .portrait: angle = 270
//            case .portraitUpsideDown: angle = 90
//            default: angle = 0
//            }
//            if connection.isVideoRotationAngleSupported(angle) {
//                connection.videoRotationAngle = angle
//            }
//        } else {
//            guard connection.isVideoOrientationSupported else { return }
//            let videoOrientation: AVCaptureVideoOrientation
//            switch io {
//            case .landscapeLeft: videoOrientation = .landscapeLeft
//            case .landscapeRight: videoOrientation = .landscapeRight
//            case .portrait: videoOrientation = .portrait
//            case .portraitUpsideDown: videoOrientation = .portraitUpsideDown
//            default: videoOrientation = .landscapeRight
//            }
//            connection.videoOrientation = videoOrientation
//        }
//    }
    
    private func configureVideoConnection(_ output: AVCaptureVideoDataOutput) {
        guard let connection = output.connection(with: .video) else { return }

        // Espelhamento para câmera frontal
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false // Desabilita espelhamento para melhor detecção
        }
        
        // Configura orientação inicial
//        updateVideoOrientation()
    }

}


// MARK: - Extension para captura de vídeo
extension GestureDetectionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
//        let orientation = currentVideoOrientation()
        let orientation: CGImagePropertyOrientation = .down
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                DispatchQueue.main.async {
                    self.delegate?.gestureDetectionLost()
                }
                return
            }
            
            guard observation.confidence > 0.5 else {
                DispatchQueue.main.async {
                    self.delegate?.gestureDetectionLost()
                }
                return
            }
            
            let keypoints = try observation.keypointsMultiArray()
            let prediction = try model.prediction(poses: keypoints)
            
            let probabilities = prediction.labelProbabilities
            let maxProbability = probabilities.values.max() ?? 0.0
            
            if maxProbability >= confidenceThreshold {
                if let smoothedGesture = smoothGestureDetection(prediction.label) {
                    DispatchQueue.main.async {
                        self.delegate?.gestureDetected(smoothedGesture, confidence: maxProbability)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if maxProbability < 0.3 {
                        self.delegate?.gestureDetectionLost()
                    }
                }
            }
            
        } catch {
            print("Erro ao processar o frame: \(error)")
        }
    }
    
    // Orientação para processamento de Vision
//    private func currentVideoOrientation() -> CGImagePropertyOrientation {
//       let deviceOrientation = currentInterfaceOrientation()
//       let cameraPosition: AVCaptureDevice.Position = .front
//       
//       switch deviceOrientation {
//       case .landscapeLeft:
//           // Home à direita - para câmera frontal, usar .up
//           return cameraPosition == .front ? .up : .down
//       case .landscapeRight:
//           // Home à esquerda - para câmera frontal, usar .down
//           return cameraPosition == .front ? .down : .up
//       case .portrait:
//           return cameraPosition == .front ? .leftMirrored : .right
//       case .portraitUpsideDown:
//           return cameraPosition == .front ? .rightMirrored : .left
//       default:
//           return cameraPosition == .front ? .up : .down
//       }
//    }
}

