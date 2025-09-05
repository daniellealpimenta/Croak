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
    
    var coinsComponent: CoinsComponent!
    
    private var gestureManager: GestureDetectionManager!
    private var gestureDebugLabel: SKLabelNode?
    private var isTransitioning = false

    // MUDANÇA 1: Definir chaves únicas para cada modo de jogo
    private let gameSceneHighScoreKey = "highScore_GameScene"
    private let buttonModeHighScoreKey = "highScore_ButtonMode"

    // MARK: - Ciclo de Vida da Cena

    override func didMove(to view: SKView) {
        
        handleHighScore()
        
        // Carrega o total de moedas salvas no dispositivo
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        
        coinsComponent = CoinsComponent(parent: self)
        coinsComponent.updateLabel(with: totalCoins)
        
        // game over
        if let gameOverLabel = self.childNode(withName: "//GameOver_Label") as? SKLabelNode {
            gameOverLabel.text = "GAME OVER"
            if DeviceHelper.isIPhone {
                gameOverLabel.fontSize = 50
                gameOverLabel.position.y -= 10
            } else {
                gameOverLabel.fontSize = 80
            }
            gameOverLabel.fontName = "Ari-W9500Bold"
            gameOverLabel.fontColor = .white
            gameOverLabel.zPosition = 4
            addShadow(to: gameOverLabel)
        }
        
        
        // Pontuacao da ultima run
        if let scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode {
            scoreLabel.text = "\(finalScore)"
            if DeviceHelper.isIPhone {
                scoreLabel.fontSize = 120
            } else {
                scoreLabel.fontSize = 160
            }
            
            scoreLabel.fontName = "Ari-W9500Bold"
            scoreLabel.fontColor = .white
            scoreLabel.zPosition = 4
            addShadow(to: scoreLabel)
        }
        
        // Recorde
        if let record = self.childNode(withName: "//Record_Label") as? SKLabelNode {
            record.text = "Melhor Pontuação:"
            record.fontSize = 24
            record.fontName = "Ari-W9500Bold"
            record.fontColor = .white
            record.zPosition = 4
            
            if DeviceHelper.isIPhone {
                    record.position.y -= 30
            }
        }
        
        // Vitoria Regia
        if let vitoriaRegiaNode = self.childNode(withName: "//VitoriaRegia") as? SKSpriteNode {
            if DeviceHelper.isIPhone {
                vitoriaRegiaNode.setScale(0.5)
            }
        }
        
        //Botoes
        
        if let PlayButtonNode = self.childNode(withName: "//ResetButton") as? SKSpriteNode {
            if DeviceHelper.isIPhone {
                PlayButtonNode.setScale(0.7)
                PlayButtonNode.position.x -= 30
            }
        }
        
        if let ExitButtonNode = self.childNode(withName: "//ExitButton") as? SKSpriteNode {
            if DeviceHelper.isIPhone {
                ExitButtonNode.setScale(1.3)
                ExitButtonNode.position.x += 30
            }
        }
    
        
        // Configuração da Detecção de Gestos
       //  setupGestureDetection(in: view)
    }
    
    // MARK: Verificação do modo de jogo para definição da pontucao recorde

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
            
            if DeviceHelper.isIPhone {
                    record_n.position.y -= 10
            }

        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Limpeza da Detecção de Gestos
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
        gestureManager = nil
    }
    
    // MARK: - Configuração dos Gestos
    
//    private func setupGestureDetection(in view: SKView) {
//        gestureManager = GestureDetectionManager()
//        gestureManager.delegate = self
//        gestureManager.startDetection()
//    }
    
    // MARK: - GestureDetectionDelegate
    
//    func gestureDetected(_ gesture: String, confidence: Double) {
//        gestureDebugLabel?.text = "Gesto: \(gesture)"
//        
//        switch gesture {
//        case "L":
//            print("Gesto 'L' detectado. Saindo para o menu.")
//            exitToMenu()
//        case "Top":
//            print("Gesto 'Top' detectado. Reiniciando")
//            restartPreviousScene()
//        default:
//            break
//        }
//    }
//    
//    func gestureDetectionLost() {
//        gestureDebugLabel?.text = "Gesto: Nenhum"
//    }
//    
//    func cameraWillExpand() { }
//    func cameraDidShrink() { }
    
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
            
            let restartAction = SKAction.run { [weak self] in
                self?.restartPreviousScene()
            }
            let wait = SKAction.wait(forDuration: 0.1)
            
            var sequence: SKAction
            
            if DeviceHelper.isIPhone {
                let scaleUp = SKAction.scale(by: 1.2, duration: 0.1)
                let scaleDown = scaleUp.reversed()
                sequence = SKAction.sequence([scaleUp, scaleDown, wait, restartAction])
                
            }
            
            else if DeviceHelper.isIPad {
                let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                sequence = SKAction.sequence([scaleUp, scaleDown, wait, restartAction])
            }
            else {
                let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                sequence = SKAction.sequence([scaleUp, scaleDown, wait, restartAction])
            }
            
            
            touchedNode.run(sequence)
        }
                
        if touchedNode.name == "ExitButton" {
            print("Botão Menu Principal foi tocado!")
            
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
