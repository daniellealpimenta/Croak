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
    let model = try! MLModelV3(configuration: MLModelConfiguration()) // SUBSTITUA pelo nome do seu modelo
    
    weak var delegate: GestureDetectionDelegate?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var cameraView: UIView?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    // Configurações para melhorar a precisão
    private let confidenceThreshold: Double = 0.95
    private let bufferSize = 5
    private var gestureBuffer: [String] = []
    
    override init() {
        super.init()
        setupCamera()
        configureHandPoseRequest()
    }
    
    func configureHandPoseRequest() {
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
    }
    
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
        
        session.commitConfiguration()
    }
    
    func setupCameraPreview(in skView: SKView) {
        // Garante que não vamos criar a view múltiplas vezes
        guard self.cameraView == nil else { return }
        
        DispatchQueue.main.async {
            let cameraViewWidth: CGFloat = 150
            let cameraViewHeight: CGFloat = 200
            let padding: CGFloat = 20
            
            // Cria a UIView que vai conter a imagem da câmera
            let camView = UIView(frame: CGRect(x: skView.bounds.width - cameraViewWidth - padding,
                                                y: padding,
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
            
            // CORREÇÃO DA ORIENTAÇÃO
           self.updatePreviewOrientation(layer: layer)
            
            self.previewLayer = layer
            camView.layer.addSublayer(layer)
            skView.addSubview(camView)
        }
    }
    
    private func updatePreviewOrientation(layer: AVCaptureVideoPreviewLayer) {
        // Configura a orientação baseada no dispositivo
        if DeviceHelper.isIPhone {
            // iPhone - modo portrait
            layer.connection?.videoRotationAngle = 0
        } else {
            // iPad - modo landscape
            layer.connection?.videoRotationAngle = 90
        }
        
        // Também atualiza a orientação da conexão do video output para manter consistência
        if let videoConnection = self.videoOutput?.connection(with: .video) {
            if DeviceHelper.isIPhone {
                videoConnection.videoRotationAngle = 0
            } else {
                videoConnection.videoRotationAngle = 90
            }
        }
    }
    
    // Função para atualizar orientação quando o dispositivo rotaciona
    func updateOrientation() {
        guard let previewLayer = self.previewLayer else { return }
        DispatchQueue.main.async {
            self.updatePreviewOrientation(layer: previewLayer)
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
}


// MARK: - Extension para captura de vídeo
extension GestureDetectionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
//        let orientation = currentVideoOrientation()
        
        // CORREÇÃO DA ORIENTAÇÃO PARA PROCESSAMENTO
        let orientation: CGImagePropertyOrientation
        if DeviceHelper.isIPhone {
            orientation = .up  // Portrait no iPhone
        } else {
            orientation = .right  // Landscape no iPad
        }
        
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
}

// MARK: - Orientação da câmera
private func currentVideoOrientation() -> CGImagePropertyOrientation {
    let deviceOrientation = UIDevice.current.orientation
    let cameraPosition: AVCaptureDevice.Position = .front
    
    switch deviceOrientation {
    case .portrait:
        return cameraPosition == .front ? .leftMirrored : .right
    case .portraitUpsideDown:
        return cameraPosition == .front ? .rightMirrored : .left
    case .landscapeLeft:
        return cameraPosition == .front ? .downMirrored : .up
    case .landscapeRight:
        return cameraPosition == .front ? .upMirrored : .down
    default:
        // Face up, face down, ou unknown - usar portrait como padrão
        return cameraPosition == .front ? .leftMirrored : .right
    }
}
