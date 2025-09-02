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
    let model = try! MLiPhoneV2__PRIME_(configuration: MLModelConfiguration())
    
    weak var delegate: GestureDetectionDelegate?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraView: UIView?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var originalCameraFrame: CGRect?
    
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
        session.sessionPreset = .vga640x480
        
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
        
        let cameraViewWidth: CGFloat = 400
        let cameraViewHeight: CGFloat = 200
        let padding: CGFloat = 20
        
        // 1. Cria o frame (a posição e o tamanho) para a câmera.
        let frame = CGRect(x: padding,
                           y: skView.bounds.height - cameraViewHeight - padding,
                           width: cameraViewWidth,
                           height: cameraViewHeight)
        
        // 2. AQUI ESTÁ A CORREÇÃO: Salva o frame na nossa propriedade.
        self.originalCameraFrame = frame
        
        // 3. Usa o frame que acabamos de criar para inicializar a UIView.
        let camView = UIView(frame: frame)
        
        camView.layer.cornerRadius = 10
        camView.layer.borderColor = UIColor.white.cgColor
        camView.layer.borderWidth = 2
        camView.clipsToBounds = true
        self.cameraView = camView
        
        // Cria a camada de preview usando a SESSÃO DA CÂMERA JÁ EXISTENTE
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.frame = camView.bounds
        layer.videoGravity = .resizeAspectFill
        
        if let connection = layer.connection {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // --- Configuração para IPHONE (Retrato) ---
                if #available(iOS 17.0, *) {
                    connection.videoRotationAngle = 90
                } else {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                }
            } else {
                // --- Configuração para IPAD (Paisagem) ---
                if #available(iOS 17.0, *) {
                    connection.videoRotationAngle = 180
                } else {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .landscapeRight
                    }
                }
            }
        }

        self.previewLayer = layer
        camView.layer.addSublayer(layer)
        
        // ADICIONA A IMAGEM DA MÃO COMO OVERLAY
        self.addHandOverlay(to: camView)
        
        skView.addSubview(camView)
    }
    
    func expandCameraPreviewToFullScreen(in skView: SKView) {
        delegate?.cameraWillExpand()
            // 1. Garante que a cameraView já foi criada.
            guard let camView = self.cameraView else {
                print("A cameraView ainda não foi inicializada e não pode ser expandida.")
                return
            }
            
            // 2. Garante que a atualização da UI seja feita na thread principal.
            DispatchQueue.main.async {
                // 3. Define o novo frame como sendo a tela inteira.
                let fullScreenFrame = skView.bounds
                
                // 4. Anima a transição para o novo frame.
                UIView.animate(withDuration: 0.4, animations: {
                    camView.frame = fullScreenFrame
                    
                    // Remove a borda e o canto arredondado para o modo de tela cheia.
                    camView.layer.cornerRadius = 0
                    camView.layer.borderWidth = 0
                    
                    // Ajusta o frame da camada de preview para preencher a nova view.
                    self.previewLayer?.frame = camView.bounds
                })
            }
        }
    
    func shrinkCameraPreviewToOriginal(in skView: SKView) {
            // 1. Garante que a view da câmera e o frame original existam.
            guard let camView = self.cameraView, let originalFrame = self.originalCameraFrame else {
                print("A cameraView ou o frame original não foram inicializados.")
                return
            }
            
            // 2. Garante que a atualização da UI seja feita na thread principal.
            DispatchQueue.main.async {
                // 3. Anima a transição de volta para o frame original.
                UIView.animate(withDuration: 0.4, animations: {
                    camView.frame = originalFrame
                    
                    // Restaura a aparência original (borda e cantos arredondados).
                    camView.layer.cornerRadius = 10
                    camView.layer.borderWidth = 2
                    
                    // Ajusta o frame da camada de preview para preencher a view menor.
                    self.previewLayer?.frame = camView.bounds
                }, completion: {[weak self] _ in
                self?.delegate?.cameraDidShrink()
                })
            }
        }
    private func addHandOverlay(to parentView: UIView) {
        // Cria o ImageView para a mão
        let handImageView = UIImageView()
        
        // Carrega a imagem da mão (substitua "hand_outline" pelo nome da sua imagem)
        if let handImage = UIImage(named: "hand-outline-white") {
            handImageView.image = handImage
        } else {
            print("⚠️ Imagem 'hand_outline' não encontrada nos assets")
            // Fallback: criar uma imagem simples programaticamente se necessário
            handImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
        
        // Configurações do ImageView
        handImageView.contentMode = .scaleAspectFit
        handImageView.translatesAutoresizingMaskIntoConstraints = false
        handImageView.alpha = 0.6 // Transparência para não cobrir muito a câmera
        
        // Adiciona ao container
        parentView.addSubview(handImageView)
        
        // Constraints para centralizar e dimensionar
        NSLayoutConstraint.activate([
            handImageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            handImageView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            handImageView.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.4), // 40% da largura
            handImageView.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: 0.6) // 60% da altura
        ])
        
        // Opcional: Adicionar uma animação sutil de "pulsação"
//        addPulseAnimation(to: handImageView)
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
        var orientation: CGImagePropertyOrientation
        if UIDevice.current.userInterfaceIdiom == .phone {
                // Câmera frontal no iPhone em modo retrato
                orientation = .leftMirrored
        } else {
            // Câmera frontal no iPad em modo paisagem (home à esquerda)
            orientation = .down
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
            print("Mão detectada com confiança: \(observation.confidence)")
            guard observation.confidence > 0.5 else {
                DispatchQueue.main.async {
                    self.delegate?.gestureDetectionLost()
                }
                return
            }
            
            do {
                // Primeiro, tentamos obter os pontos. Se a função falhar, ela "lançará" um erro
                // que será capturado pelo bloco 'catch' abaixo.
                let wristPoint = try observation.recognizedPoint(.wrist)
                let thumbTipPoint = try observation.recognizedPoint(.thumbTip)
                
                // Se o código chegar aqui, significa que os pontos foram obtidos com sucesso.
                // Agora podemos verificar a confiança deles com um 'if' normal.
                if wristPoint.confidence > 0.3 && thumbTipPoint.confidence > 0.3 {
                    print("DEBUG COORDENADAS: Pulso [y: \(String(format: "%.2f", wristPoint.location.y))] | Polegar [y: \(String(format: "%.2f", thumbTipPoint.location.y))]")
                }
            } catch {
                // Se 'try observation.recognizedPoint' falhar, o erro será impresso aqui.
                print("Não foi possível obter os pontos da mão: \(error)")
            }
            
            // 1. Obter os pontos-chave do Vision (que são do tipo Double)
            let keypointsFromVision = try observation.keypointsMultiArray()

            // 2. Criar um novo MLMultiArray com o formato que o modelo espera (Float32)
            let convertedKeypoints = try MLMultiArray(shape: keypointsFromVision.shape, dataType: .float32)

            // 3. Copiar os dados, convertendo cada número de Double para Float32
            let pointer = convertedKeypoints.dataPointer.bindMemory(to: Float32.self, capacity: convertedKeypoints.count)
            let visionPointer = keypointsFromVision.dataPointer.bindMemory(to: Double.self, capacity: keypointsFromVision.count)

            for i in 0..<keypointsFromVision.count {
                pointer[i] = Float32(visionPointer[i])
            }

            // 4. Fazer a predição usando o array CONVERTIDO
            let prediction = try model.prediction(poses: convertedKeypoints)
            
            let probabilities = prediction.labelProbabilities
            let maxProbability = probabilities.values.max() ?? 0.0
            
            print("Gesto previsto: \(prediction.label) com probabilidade: \(maxProbability)")
            
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

