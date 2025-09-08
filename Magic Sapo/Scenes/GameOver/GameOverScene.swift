//
//  GameOverScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 15/08/25.
//

import SpriteKit
import Vision

class GameOverScene: SKScene {
    
    // MARK: - Properties
    
    var previousSceneName: String?
    var finalScore: Int = 0
    var totalCoins: Int = 0
    
    var coinsComponent: CoinsComponent!
    
    private var gestureManager: GestureDetectionManager!
    private var gestureDebugLabel: SKLabelNode?
    private var isTransitioning = false

    // Unique keys for each game mode's high score
    private let gameSceneHighScoreKey = "highScore_GameScene"
    private let buttonModeHighScoreKey = "highScore_ButtonMode"

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        
        handleHighScore()
        
        // Loads the total coins saved on the device
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        
        AudioManager.shared.setSoundEffectVolume(to: 0.4)
                
        AudioManager.shared.playSoundEffect(named: "game-over.mp3")
        
        coinsComponent = CoinsComponent(parent: self)
        coinsComponent.updateLabel(with: totalCoins)
        
        // Game Over Label
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
        
        
        // Last run's score
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
        
        // High Score Label
        if let highScoreLabel = self.childNode(withName: "//Record_Label") as? SKLabelNode {
            // ✅ USING LOCALIZATION
            highScoreLabel.text = NSLocalizedString("gameover_highscore", comment: "High score text label")
            highScoreLabel.fontSize = 24
            highScoreLabel.fontName = "Ari-W9500Bold"
            highScoreLabel.fontColor = .white
            highScoreLabel.zPosition = 4
            
            if DeviceHelper.isIPhone {
                    highScoreLabel.position.y -= 30
            }
        }
        
        // "Vitoria Regia" (Water Lily) Node
        if let waterLilyNode = self.childNode(withName: "//VitoriaRegia") as? SKSpriteNode {
            if DeviceHelper.isIPhone {
                waterLilyNode.setScale(0.5)
            }
        }
        
        //Buttons
        
        if let playButtonNode = self.childNode(withName: "//ResetButton") as? SKSpriteNode {
            if DeviceHelper.isIPhone {
                playButtonNode.setScale(0.7)
                playButtonNode.position.x -= 30
            }
        }
        
        if let exitButtonNode = self.childNode(withName: "//ExitButton") as? SKSpriteNode {
            if DeviceHelper.isIPhone {
                exitButtonNode.setScale(1.3)
                exitButtonNode.position.x += 30
            }
        }
    
    }
    
    // MARK: - Game Mode Check for High Score
    
    private func handleHighScore() {
        var highScoreKey: String?
        
        // Decide which key to use based on the previous scene
        if previousSceneName == "GameScene" {
            highScoreKey = gameSceneHighScoreKey
        } else if previousSceneName == "ButtonMode" {
            highScoreKey = buttonModeHighScoreKey
        }
        
        guard let key = highScoreKey else {
            return
        }
        
        // Load the current high score for the specific game mode
        let currentHighScore = UserDefaults.standard.integer(forKey: key)
        var scoreToDisplay = currentHighScore
        
        // Check if the final score is a new high score
        if finalScore > currentHighScore {
            UserDefaults.standard.set(finalScore, forKey: key)
            scoreToDisplay = finalScore
        }
        
        // Configure the high score number
        if let highScoreNumberLabel = self.childNode(withName: "//Record_Label_number") as? SKLabelNode {
            highScoreNumberLabel.text = "\(scoreToDisplay)" // Display the correct high score
            highScoreNumberLabel.fontSize = 40
            highScoreNumberLabel.fontName = "Ari-W9500Bold"
            highScoreNumberLabel.fontColor = .white
            highScoreNumberLabel.zPosition = 4
            
            if DeviceHelper.isIPhone {
                    highScoreNumberLabel.position.y -= 10
            }
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Gesture Detection Cleanup
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
        gestureManager = nil
    }
    
    // MARK: - Navigation Actions
    
    private func restartPreviousScene() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        if let sceneNameToLoad = previousSceneName, let newGameScene = SKScene(fileNamed: sceneNameToLoad) {
            newGameScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newGameScene, transition: transition)
        } else {
            exitToMenu()
        }
    }
    
    private func exitToMenu() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        let sceneName = DeviceHelper.isIPhone ? "MenuScene_iphone" : "MenuScene"
        
        if let menuScene = SKScene(fileNamed: sceneName) {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(menuScene, transition: transition)
        }
    }
    
    // MARK: - User Input (Touch)
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, let touch = touches.first else { return }
            
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
            
        if touchedNode.name == "ResetButton" {
            
            AudioManager.shared.playSoundEffect(named: "toque-reiniciar.mp3")
            
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
    
    // MARK: - Helper Functions

    private func addShadow(to label: SKLabelNode, withOffset offset: CGPoint = CGPoint(x: 3, y: -3), color: SKColor = .black) {
        let shadowLabel = label.copy() as! SKLabelNode
        
        shadowLabel.fontColor = color
        shadowLabel.position = CGPoint(x: label.position.x + offset.x, y: label.position.y + offset.y)
        
        shadowLabel.zPosition = label.zPosition - 1
        
        self.addChild(shadowLabel)
    }
}
