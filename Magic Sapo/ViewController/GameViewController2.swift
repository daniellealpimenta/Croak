//
//  GameViewController.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import Vision
import CoreML

class GameViewController2: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var captureSession: AVCaptureSession!
    private var poseClassifier: MLModelV4!
    private let videoOutputQueue = DispatchQueue(label: "videoOutputQueue", qos: .userInitiated)

    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var cameraView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModel()
        setupCamera()
        
        // MARK: Recebendo o aviso que o jogo vai ficar inativo
        NotificationCenter.default.addObserver(self, selector: #selector(PauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
        
    private func setupModel() {
            guard let modelURL = Bundle.main.url(forResource: "MLModelV3", withExtension: "mlmodelc") else {
                fatalError("Falha Crítica: Arquivo 'PoseClassifierModel.mlmodelc' não encontrado no bundle do aplicativo.")
            }
            
            do {
                let configuration = MLModelConfiguration()
                self.poseClassifier = try MLModelV4(contentsOf: modelURL, configuration: configuration)
                print("Modelo de gestos carregado com sucesso via URL.")
                
            } catch {
                fatalError("Erro ao carregar o modelo a partir do URL: \(error)")
            }
        }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Erro ao acessar a câmera frontal.")
            return
        }

        captureSession.addInput(input)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        captureSession.addOutput(dataOutput)

        DispatchQueue.main.async {
            let cameraViewWidth: CGFloat = 150
            let cameraViewHeight: CGFloat = 200
            let padding: CGFloat = 20
            
            self.cameraView = UIView(frame: CGRect(x: self.view.bounds.width - cameraViewWidth - padding,
                                                    y: padding,
                                                    width: cameraViewWidth,
                                                    height: cameraViewHeight))
            
            self.cameraView.layer.cornerRadius = 10
            self.cameraView.layer.borderColor = UIColor.white.cgColor
            self.cameraView.layer.borderWidth = 2
            self.cameraView.clipsToBounds = true
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer.frame = self.cameraView.bounds
            self.previewLayer.videoGravity = .resizeAspectFill
            self.cameraView.layer.addSublayer(self.previewLayer)

            self.view.addSubview(self.cameraView)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
        
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // A Câmera roda o tempo todo, mas só processamos os gestos se a cena atual for a GameScene.
        guard let gameScene = (self.view as? SKView)?.scene as? GameScene, !gameScene.isPaused else {
            return // Se não for a GameScene ou se o jogo estiver pausado, não faz nada.
        }
        
        let handPoseRequest = VNDetectHumanHandPoseRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNHumanHandPoseObservation], observations.count > 0 else {
                return
            }
            self?.classifyHandPose(observations[0])
        }
        handPoseRequest.maximumHandCount = 1

        // --- INÍCIO DA ALTERAÇÃO ---
        // Converte a orientação física do dispositivo para a orientação de imagem que o Vision entende.
        let imageOrientation: CGImagePropertyOrientation

        switch UIDevice.current.orientation {
        case .portrait:
            imageOrientation = .up
        case .portraitUpsideDown:
            imageOrientation = .down
        case .landscapeLeft:
            // Quando o iPad está na horizontal com o botão Home à direita,
            // a imagem da câmera frontal chega "virada" para a direita.
            imageOrientation = .right
        case .landscapeRight:
            // Quando o iPad está na horizontal com o botão Home à esquerda,
            // a imagem da câmera frontal chega "virada" para a esquerda.
            imageOrientation = .left
        default:
            // Se não soubermos a orientação, usamos a padrão.
            imageOrientation = .up
        }
        
        // Usa a orientação dinâmica em vez de um valor fixo.
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: imageOrientation, options: [:])
        // --- FIM DA ALTERAÇÃO ---
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            // Silenciosamente ignora erros para não poluir o console.
        }
    }

    private func classifyHandPose(_ observation: VNHumanHandPoseObservation) {
        guard let keypointsMultiArray = try? observation.keypointsMultiArray() else { return }
        guard let prediction = try? self.poseClassifier.prediction(poses: keypointsMultiArray) else {
            return
        }
        
        let gesture = prediction.label
        let confidence = prediction.labelProbabilities[gesture] ?? 0
        
        if let gameScene = (self.view as? SKView)?.scene as? GameScene {
            if confidence > 0.95 {
                DispatchQueue.main.async {
                    gameScene.playerDidMake(gesture: gesture)
                }
            }
        }
    }
        
    @objc func PauseGame() {
        print("Pausando o jogo")
        if let view = self.view as! SKView? {
            if let gameScene = view.scene as? GameScene {
                if let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene {
                    pauseScene.setGameScene(scene: gameScene)
                    pauseScene.scaleMode = .aspectFill
                    let transicao = SKTransition.fade(withDuration: 0.5)
                    view.presentScene(pauseScene, transition: transicao)
                }
            }
        }
    }
    
    // --- NOVO: Adicionado para corrigir a orientação da câmera ---
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // Garante que a camada de preview e a view da câmera sejam atualizadas
            // sempre que o layout da tela mudar (ex: rotação).
            if let connection = self.previewLayer?.connection {
                // Pega a orientação da interface atual
                let interfaceOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .unknown
                
                // Converte a orientação da interface para a orientação do vídeo
                switch interfaceOrientation {
                case .portrait:
                    connection.videoOrientation = .portrait
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeRight:
                    connection.videoOrientation = .landscapeRight
                default:
                    connection.videoOrientation = .portrait // Padrão
                }
            }
            
            // Reposiciona a janela da câmera se necessário
            if let camView = self.cameraView {
                let cameraViewWidth: CGFloat = 150
                let cameraViewHeight: CGFloat = 200
                let padding: CGFloat = 20
                
                camView.frame = CGRect(x: self.view.bounds.width - cameraViewWidth - padding,
                                       y: padding,
                                       width: cameraViewWidth,
                                       height: cameraViewHeight)
                
                self.previewLayer?.frame = camView.bounds
            }
        }
    // --- FIM DO CÓDIGO NOVO ---

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
