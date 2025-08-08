import AVFoundation
import Vision
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    let handPoseRequest = VNDetectHumanHandPoseRequest()
    let model = try! PoseClassifierModel(configuration: MLModelConfiguration())

    @Published var predictedGesture: String?
    @Published var confidence: Double = 0.0
    
    // Configurações para melhorar a precisão
    private let confidenceThreshold: Double = 0.95 // 95% de confiança mínima
    private let smoothingBuffer: [String] = [] // Buffer para suavização
    private let bufferSize = 5 // Tamanho do buffer para suavização
    private var gestureBuffer: [String] = []

    override init() {
        super.init()
        setupCamera()
        configureHandPoseRequest()
    }
    
    func configureHandPoseRequest() {
        // Configurar a requisição para melhor detecção
        handPoseRequest.maximumHandCount = 1 // Detectar apenas uma mão
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
    }

    func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // Seleciona a câmera frontal
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
        
        // Configurações importantes para melhor qualidade
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        // Reduzir frames descartados
        output.alwaysDiscardsLateVideoFrames = false
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    private func smoothGestureDetection(_ newGesture: String) -> String? {
        gestureBuffer.append(newGesture)
        
        // Manter apenas os últimos N gestos
        if gestureBuffer.count > bufferSize {
            gestureBuffer.removeFirst()
        }
        
        // Se ainda não temos buffer suficiente, retorna nil
        guard gestureBuffer.count == bufferSize else { return nil }
        
        // Contar frequência de cada gesto no buffer
        let gestureCounts = gestureBuffer.reduce(into: [:]) { counts, gesture in
            counts[gesture, default: 0] += 1
        }
        
        // Retornar o gesto mais frequente se aparecer mais de 60% das vezes
        if let mostFrequent = gestureCounts.max(by: { $0.value < $1.value }),
           Double(mostFrequent.value) / Double(bufferSize) > 0.6 {
            return mostFrequent.key
        }
        
        return nil
    }
    
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // IMPORTANTE: Ajustar orientação baseada na câmera frontal
        let orientation: CGImagePropertyOrientation = .leftMirrored
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                DispatchQueue.main.async {
                    self.predictedGesture = nil
                    self.confidence = 0.0
                }
                return
            }

            // Verificar se a mão foi detectada com confiança suficiente
            guard observation.confidence > 0.5 else {
                DispatchQueue.main.async {
                    self.predictedGesture = nil
                    self.confidence = 0.0
                }
                return
            }

            let keypoints = try observation.keypointsMultiArray()
            let prediction = try model.prediction(poses: keypoints)
            
            // Obter as probabilidades de cada classe
            let probabilities = prediction.labelProbabilities
            let maxProbability = probabilities.values.max() ?? 0.0
            
            // Só aceitar predições com alta confiança
            if maxProbability >= confidenceThreshold {
                // Aplicar suavização
                if let smoothedGesture = smoothGestureDetection(prediction.label) {
                    DispatchQueue.main.async {
                        self.predictedGesture = smoothedGesture
                        self.confidence = maxProbability
                    }
                }
            } else {
                // Confiança baixa - não atualizar o gesto
                DispatchQueue.main.async {
                    self.confidence = maxProbability
                    // Manter o gesto anterior se a confiança for muito baixa
                    if maxProbability < 0.3 {
                        self.predictedGesture = nil
                    }
                }
            }

        } catch {
            print("Erro ao processar o frame: \(error)")
        }
    }
}
