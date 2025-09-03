//
//  LoseScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 15/08/25.
//

import SpriteKit
import Vision

// Conformidade com o GestureDetectionDelegate
class GameOverScene: SKScene, GestureDetectionDelegate {
    
    // MARK: - Propriedades
    
    /// Guarda o nome do arquivo da cena que levou ao Game Over (ex: "GameScene" ou "ButtonMode").
    var previousSceneName: String?
    var finalScore: Int = 0
    
    // Propriedades para Detecção de Gestos
    private var gestureManager: GestureDetectionManager!
    private var gestureDebugLabel: SKLabelNode?
    private var isTransitioning = false // Flag para evitar transições duplicadas

    // MARK: - Ciclo de Vida da Cena

    override func didMove(to view: SKView) {
        // Atualiza o label da pontuação final
        if let scoreLabel = self.childNode(withName: "//scoreValue") as? SKLabelNode {
            scoreLabel.text = "\(finalScore)"
        }
        
        // Configuração da Detecção de Gestos
        setupGestureDetection(in: view)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Limpeza da Detecção de Gestos
        gestureManager.stopDetection()
        gestureManager.removeCameraPreview()
        gestureManager = nil
    }
    
    // MARK: - Configuração dos Gestos
    
    private func setupGestureDetection(in view: SKView) {
        // Inicializa e configura o gerenciador
        gestureManager = GestureDetectionManager()
        gestureManager.delegate = self
        
        // Mostra a pequena janela da câmera
        gestureManager.setupCameraPreview(in: view)
        
        // Inicia a detecção
        gestureManager.startDetection()
        
        // Adiciona um label para debug, para vermos qual gesto está sendo detectado
        setupGestureDebugUI()
    }
    
    private func setupGestureDebugUI() {
        gestureDebugLabel = SKLabelNode(fontNamed: "Arial-Bold")
        gestureDebugLabel?.fontSize = 20
        gestureDebugLabel?.fontColor = .yellow
        gestureDebugLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 50)
        gestureDebugLabel?.text = "Gesto: Nenhum"
        if let label = gestureDebugLabel {
            addChild(label)
        }
    }
    
    // MARK: - GestureDetectionDelegate
    
    func gestureDetected(_ gesture: String, confidence: Double) {
        gestureDebugLabel?.text = "Gesto: \(gesture)"
        
        // Lógica para tratar os gestos recebidos
        switch gesture {
        case "L":
            print("Gesto 'L' detectado. Saindo para o menu.")
            exitToMenu()
        case "Top":
            print("Gesto 'Top' detectado. Reiniciando a fase.")
            restartPreviousScene()
        default:
            // Outros gestos são ignorados
            break
        }
    }
    
    func gestureDetectionLost() {
        gestureDebugLabel?.text = "Gesto: Nenhum"
    }
    
    // AQUI ESTÁ A CORREÇÃO: MÉTODOS ADICIONADOS PARA CONFORMAR AO PROTOCOLO
    func cameraWillExpand() {
        // Não precisamos de nenhuma lógica aqui para a GameOverScene
    }
    
    func cameraDidShrink() {
        // Não precisamos de nenhuma lógica aqui para a GameOverScene
    }
    
    // MARK: - Ações de Navegação
    
    private func restartPreviousScene() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        if let sceneNameToLoad = previousSceneName, let newGameScene = SKScene(fileNamed: sceneNameToLoad) {
            newGameScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newGameScene, transition: transition)
        } else {
            print("Erro: Nome da cena anterior não encontrado. Voltando para o Menu.")
            exitToMenu()
        }
    }
    
    private func exitToMenu() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        if let menuScene = SKScene(fileNamed: "MenuScene") {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(menuScene, transition: transition)
        }
    }
    
    // MARK: - Entrada do Usuário (Toque)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // Se o botão "Reiniciar" for tocado
        if touchedNode.name == "ResetButton" {
            print("Botão Reiniciar foi tocado!")
            restartPreviousScene()
        }
        
        // Se o botão "Sair" for tocado
        if touchedNode.name == "ExitButton" {
            print("Botão Menu Principal foi tocado!")
            exitToMenu()
        }
    }
}
