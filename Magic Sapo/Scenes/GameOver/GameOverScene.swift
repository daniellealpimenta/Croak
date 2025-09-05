//
//  LoseScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 15/08/25.
//

import SpriteKit
import Vision

// Conformidade com o GestureDetectionDelegate
class GameOverScene: SKScene {
    
    // MARK: - Propriedades
    
    var previousSceneName: String?
    var finalScore: Int = 0
    var totalCoins: Int = 0
    
    private var gestureManager: GestureDetectionManager!
    private var gestureDebugLabel: SKLabelNode?
    private var isTransitioning = false

    // MUDANÇA 1: Definir chaves únicas para cada modo de jogo
    private let gameSceneHighScoreKey = "highScore_GameScene"
    private let buttonModeHighScoreKey = "highScore_ButtonMode"

    // MARK: - Ciclo de Vida da Cena

    override func didMove(to view: SKView) {
        
        handleHighScore()
        
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        
        AudioManager.shared.setSoundEffectVolume(to: 0.4)
        
        AudioManager.shared.playSoundEffect(named: "game-over.mp3")
        
        // Configura o título "GAME OVER"
        if let gameOverLabel = self.childNode(withName: "//GameOver_Label") as? SKLabelNode {
            gameOverLabel.text = "GAME OVER"
            gameOverLabel.fontSize = 80
            gameOverLabel.fontName = "Ari-W9500Bold"
            gameOverLabel.fontColor = .white
            gameOverLabel.zPosition = 4
            addShadow(to: gameOverLabel)
        }
        
        // Configura o label da pontuação final
        if let scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode {
            scoreLabel.text = "\(finalScore)"
            scoreLabel.fontSize = 160
            scoreLabel.fontName = "Ari-W9500Bold"
            scoreLabel.fontColor = .white
            scoreLabel.zPosition = 4
            addShadow(to: scoreLabel)
        }
        
        // Configura o texto "Melhor Pontuação"
        if let record = self.childNode(withName: "//Record_Label") as? SKLabelNode {
            record.text = "Melhor Pontuação:"
            record.fontSize = 24
            record.fontName = "Ari-W9500Bold"
            record.fontColor = .white
            record.zPosition = 4
        }
        
        // Configura o label de moedas
        if let coinsLabel = self.childNode(withName: "//coinsLabel") as? SKLabelNode {
            coinsLabel.text = "\(totalCoins)"
            coinsLabel.fontSize = 48
            coinsLabel.fontName = "Ari-W9500Bold"
            coinsLabel.fontColor = .yellow
        }
        
    }

    // MUDANÇA 2: Nova função para gerenciar a lógica do recorde
    private func handleHighScore() {
        var highScoreKey: String?
        
        // Decide qual chave usar com base na cena anterior
        if previousSceneName == "GameScene" {
            highScoreKey = gameSceneHighScoreKey
        } else if previousSceneName == "ButtonMode" {
            highScoreKey = buttonModeHighScoreKey
        }
        
        guard let key = highScoreKey else {
            print("Nome da cena anterior inválido, não foi possível processar o recorde.")
            return
        }
        
        // Carrega o recorde atual para o modo de jogo específico
        let currentHighScore = UserDefaults.standard.integer(forKey: key)
        var scoreToDisplay = currentHighScore
        
        // Verifica se a pontuação final é um novo recorde
        if finalScore > currentHighScore {
            UserDefaults.standard.set(finalScore, forKey: key)
            scoreToDisplay = finalScore
            print("Novo recorde para \(previousSceneName ?? "modo"): \(finalScore)")
        }
        
        // Configura o número da melhor pontuação (substituindo o valor fixo "1000")
        if let record_n = self.childNode(withName: "//Record_Label_number") as? SKLabelNode {
            record_n.text = "\(scoreToDisplay)" // Exibe o recorde correto
            record_n.fontSize = 40
            record_n.fontName = "Ari-W9500Bold"
            record_n.fontColor = .white
            record_n.zPosition = 4
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Limpeza da Detecção de Gestos
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
        gestureManager = nil
    }
    
    func cameraWillExpand() { }
    func cameraDidShrink() { }
    
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
        guard !isTransitioning, let touch = touches.first else { return }
            
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
            
        if touchedNode.name == "ResetButton" {
            print("Botão Reiniciar foi tocado!")
            
            AudioManager.shared.playSoundEffect(named: "toque-reiniciar.mp3")
            
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let restartAction = SKAction.run { [weak self] in
                self?.restartPreviousScene()
            }
            
            let wait = SKAction.wait(forDuration: 0.1)
            
            let sequence = SKAction.sequence([scaleUp, scaleDown, wait, restartAction])
            
            touchedNode.run(sequence)
        }
            
        if touchedNode.name == "ExitButton" {
            print("Botão Menu Principal foi tocado!")
            
            AudioManager.shared.playSoundEffect(named: "toque-voltar.mp3")
            
            let scaleUp = SKAction.scale(by: 1.1, duration: 0.1)
            let scaleDown = scaleUp.reversed()
            
            let exitAction = SKAction.run { [weak self] in
                self?.exitToMenu()
            }
            
            let wait = SKAction.wait(forDuration: 0.1)
            
            let sequence = SKAction.sequence([scaleUp, scaleDown, wait, exitAction])
            
            touchedNode.run(sequence)
        }
    }
    
    // MARK: - Funções Auxiliares

    private func addShadow(to label: SKLabelNode, withOffset offset: CGPoint = CGPoint(x: 3, y: -3), color: SKColor = .black) {
        let shadowLabel = label.copy() as! SKLabelNode
        
        shadowLabel.fontColor = color
        shadowLabel.position = CGPoint(x: label.position.x + offset.x, y: label.position.y + offset.y)
        
        shadowLabel.zPosition = label.zPosition - 1
        
        self.addChild(shadowLabel)
    }
}
