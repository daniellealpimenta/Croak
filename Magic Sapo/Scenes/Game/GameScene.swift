//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, GestureDetectionDelegate, ScoreHavingScene, PauseButtonDelegate, PauseOverlayDelegate {
    
    // MARK: - Componentes
    
    private var isPlayerDead = false
    
    var scoreComponent: ScoreComponent!
    var coinsComponent: CoinsComponent!
    var backgroundComponent: BackgroundComponent!
    var pauseButtonComponent: PauseButtonComponent!
    var gestureManager: GestureDetectionManager!
    var enemySpawner: EnemySpawner!
    var pauseOverlayComponent: PauseOverlayComponent!
    
    private var cameraPreviewNode: SKEffectNode!
    private var gestureDebugLabel: SKNode?
    private var sceneIsInitialized = false
    
    // MARK: - Ciclo de Vida da Cena
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
    
    override func didMove(to view: SKView) {
        if !sceneIsInitialized {
            setupScene()
            sceneIsInitialized = true
        }
    }
    
    private func setupScene() {
        print("Configurando a GameScene pela primeira vez.")
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: NSNotification.Name("AppDidBecomeActive"), object: nil)
        
        self.physicsWorld.contactDelegate = self
        
        // --- Configuração dos Componentes ---
        backgroundComponent = BackgroundComponent(parent: self)
        backgroundComponent.setupAnimatedBackground()
        
        scoreComponent = ScoreComponent(parent: self)
        coinsComponent = CoinsComponent(parent: self)
        
        pauseButtonComponent = PauseButtonComponent(parent: self)
        pauseButtonComponent.delegate = self
        
        pauseOverlayComponent = PauseOverlayComponent(parent: self)
        pauseOverlayComponent.delegate = self

        enemySpawner = EnemySpawner(scene: self)
        enemySpawner.startSpawningEnemies()
        
        let frog = Frog(parent: self)
        let frogNode = frog.createNode(at: CGPoint(x: -30, y: -self.size.height/2 + 150))
        self.addChild(frogNode)

        // ✅ ORDEM CORRETA:
        // 1. Primeiro, chama a função que CRIA o gestureManager.
        setupGestureDetection()
        
        // 2. Agora que ele existe, PODE USÁ-LO com segurança.
        if let view = self.view {
            self.gestureManager.setupCameraPreview(in: view)
        }
        
        // 3. Configura a UI de debug que depende da detecção.
        setupGestureDebugUI()
    }
    
    private func setupGestureDetection() {
        gestureManager = GestureDetectionManager()
        gestureManager.delegate = self
        gestureManager.startDetection()
    }
    
    private func setupGestureDebugUI() {
        gestureDebugLabel = SKLabelNode(fontNamed: "Arial-Bold")
        if let labelNode = gestureDebugLabel as? SKLabelNode {
            labelNode.fontSize = DeviceHelper.isIPhone ? 16 : 20
            labelNode.fontColor = .yellow
            let topOffset: CGFloat = DeviceHelper.isIPhone ? 80 : 100
            labelNode.position = CGPoint(x: 0, y: self.size.height/3 - topOffset)
            labelNode.text = "Gesto: Nenhum"
            addChild(labelNode)
        }
    }
    
    func gestureDetected(_ gesture: String, confidence: Double) {
        (gestureDebugLabel as? SKLabelNode)?.text = "Gesto: \(gesture) (\(Int(confidence * 100))%)"
        playerDidMake(gesture: gesture)
    }
    
    func gestureDetectionLost() {
        (gestureDebugLabel as? SKLabelNode)?.text = "Gesto: Nenhum"
    }
    
    @objc func pauseGame() {
        guard !isPaused else { return }
        print("🛑 PAUSANDO JOGO COMPLETAMENTE")
        enemySpawner.stopSpawningEnemies()
        self.isPaused = true
        pauseOverlayComponent.show()
    }

    @objc func resumeGame() {
        guard isPaused else { return }
        print("▶️ RETOMANDO JOGO COMPLETAMENTE")
        pauseOverlayComponent.hide()
        self.isPaused = false
        enemySpawner.startSpawningEnemies()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isPlayerDead else { return }

        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask == PhysicsCategory.frog && secondBody.categoryBitMask == PhysicsCategory.enemy) {
            isPlayerDead = true
            
            let waitAction = SKAction.wait(forDuration: 0.1)
            let transitionAction = SKAction.run {
                if let gameOverScene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
                    gameOverScene.scaleMode = .aspectFill
                    gameOverScene.finalScore = self.scoreComponent.scoreCount
                    gameOverScene.previousSceneName = "GameScene"
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            }
            self.run(SKAction.sequence([waitAction, transitionAction]))
        }
    }
    
    override func willMove(from view: SKView) {
        enemySpawner?.stopSpawningEnemies()
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
    }
    
    func playerDidMake(gesture: String) {
        if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
            scoreComponent.addScore(point: rewards.points)
            coinsComponent.addCoins(coins: rewards.coins)
            enemySpawner.updateEnemySpeed(basedOn: scoreComponent.scoreCount)
            print("Ganhou \(rewards.coins) moedas!")
        }
    }

    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isPaused {
            pauseOverlayComponent.handleTouch(at: location)
            return
        }

        let touchedNode = atPoint(location)
        if touchedNode == pauseButtonComponent.pauseButtonNode {
            pauseButtonComponent.delegate?.didTapPauseButton()
        }
    }
    
    // MARK: - Delegates
    
    func didTapPauseButton() {
        print("Botão Pausar foi tocado (via Delegate)!")
        self.pauseGame()
    }
    
    func didTapResumeButton() {
        resumeGame()
    }
    
    func didTapResetButton() {
        if let newGameScene = SKScene(fileNamed: "GameScene") as? GameScene {
            newGameScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newGameScene, transition: transition)
        }
    }
    
    func didTapExitButton() {
        if let menuScene = SKScene(fileNamed: "MenuScene") {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(menuScene, transition: transition)
        }
    }
    
    deinit {
        print("GameScene está sendo removida, limpando os observers.")
        NotificationCenter.default.removeObserver(self)
    }
}
