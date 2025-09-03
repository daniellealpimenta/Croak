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
    private var gestureDebugLabel: SKLabelNode? // Corrigido para SKLabelNode?
    private var isTransitioning = false // Flag para evitar transições duplicadas

    // MARK: - Ciclo de Vida da Cena

    override func didMove(to view: SKView) {
        // Atualiza o label da pontuação final
        if let scoreLabel = self.childNode(withName: "//scoreValue") as? SKLabelNode {
            scoreLabel.text = "\(finalScore)"
        }
        
        // Configuração da Detecção de Gestos
        setupGestureDetection(in: view)
        
        // Adiciona as imagens dos gestos ao lado dos botões
        addGestureImagesToButtons()
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
//        gestureManager.setupCameraPreview(in: view)
        
        // Inicia a detecção
        gestureManager.startDetection()
        
        // Adiciona um label para debug, para vermos qual gesto está sendo detectado
//        setupGestureDebugUI()
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
    
    // MARK: - Adicionar Imagens dos Gestos
    
    private func addGestureImagesToButtons() {
        // --- Imagem para o Gesto "Top" (Reiniciar) ---
        if let resetButton = self.childNode(withName: "//ResetButton") {
            let topGestureImage = SKSpriteNode(imageNamed: "Top")
            // --- ALTERADO AQUI: Diminuindo ainda mais o scale para "Top" ---
            topGestureImage.setScale(0.04) // Tente 0.25 ou 0.3 e veja o que fica melhor
            
            topGestureImage.position = CGPoint(
                x: resetButton.position.x, // Centraliza horizontalmente com o botão
                y: resetButton.position.y - resetButton.frame.height / 2 - topGestureImage.size.height / 2 - 20 // Posição abaixo do botão
            )
            
            topGestureImage.zPosition = resetButton.zPosition + 1 // Garante que a imagem apareça acima do botão
            addChild(topGestureImage)
        }
        
        // --- Imagem para o Gesto "L" (Sair) ---
        if let exitButton = self.childNode(withName: "//ExitButton") {
            let lGestureImage = SKSpriteNode(imageNamed: "L")
            lGestureImage.setScale(0.5) // Mantendo o scale que já estava bom para "L"
            
            lGestureImage.position = CGPoint(
                x: exitButton.position.x, // Centraliza horizontalmente com o botão
                y: exitButton.position.y - exitButton.frame.height / 2 - lGestureImage.size.height / 2 - 20 // Posição abaixo do botão
            )
            
            lGestureImage.zPosition = exitButton.zPosition + 1
            addChild(lGestureImage)
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
