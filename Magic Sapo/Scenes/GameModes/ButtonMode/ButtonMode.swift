//
//  ButtonScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

class ButtonScene: SKScene, SKPhysicsContactDelegate, ScoreHavingScene, PauseButtonDelegate, PauseOverlayDelegate, BossFightScene {
    
    // MARK: - Componentes
    
    private var isPlayerDead = false
    private var isManuallyPaused = false
    
    let worldNode = SKNode() // Para todos os elementos do jogo (sapo, inimigos)
    let uiNode = SKNode()    // Para todos os elementos de UI (botões, score, overlays)
    
    var scoreComponent: ScoreComponent!
    var coinsComponent: CoinsComponent!
    var backgroundComponent: BackgroundComponent!
    var pauseButtonComponent: PauseButtonComponent!
    var enemySpawner: EnemySpawner!
    
    private var gameState: GameState = .normalPlay
    private var mageControl: MageControl?
    private var scoreAtLastBossDefeat = 0
    
    var pauseOverlayComponent: PauseOverlayComponent!
    
    var killZoneRect: CGRect {
        // Borda SUPERIOR da zona: Começa da base da tela e sobe.
        let topY: CGFloat = (+self.size.height / 2) - (Guards.enemySize.height + Guards.gestureSize.height / 2)
        
        // Borda INFERIOR da zona: A base da tela.
        let bottomY: CGFloat = (-self.size.height / 2) + 125
        
        // Calcula a altura da zona
        let height = topY - bottomY
        
        // Cria e retorna o retângulo
        return CGRect(x: -self.size.width / 2, y: bottomY, width: self.size.width, height: height)
    }
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
    
    // Flag para controlar a inicialização da cena.
    private var sceneIsInitialized = false
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        if !sceneIsInitialized {
            setupScene()
            sceneIsInitialized = true
        }
        
        AudioManager.shared.setSoundEffectVolume(to: 0.5)
        
        let stopMusicAction = SKAction.run {
            AudioManager.shared.stopBackgroundMusic(fadeOutDuration: 1.0)
        }

        let waitAction = SKAction.wait(forDuration: 0.5)

        let playMusicAction = SKAction.run {
            AudioManager.shared.playBackgroundMusic(filename: "croak-music.m4a")
        }

        let musicSequence = SKAction.sequence([stopMusicAction, waitAction, playMusicAction])
        self.run(musicSequence)
    }
    
    private func setupScene() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name("AppWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wakeUpView), name: NSNotification.Name("AppDidBecomeActive"), object: nil)
        
        self.physicsWorld.contactDelegate = self
        
        // Adiciona os nós principais
        addChild(worldNode)
        addChild(uiNode)
        
        // --- Configuração dos Componentes ---
        backgroundComponent = BackgroundComponent(parent: self)
        backgroundComponent.setupAnimatedBackground()
        
        scoreComponent = ScoreComponent(parent: self)
        coinsComponent = CoinsComponent(parent: self)

        pauseButtonComponent = PauseButtonComponent(parent: self)
        pauseButtonComponent.delegate = self
        
        // Inicializar o componente de pause overlay
        pauseOverlayComponent = PauseOverlayComponent(parent: self)
        pauseOverlayComponent.delegate = self
        
        // Move elementos de UI para o uiNode
        scoreComponent.scoreLabel.move(toParent: uiNode)
        coinsComponent.coinsLabel.move(toParent: uiNode)
        coinsComponent.labelShadow.move(toParent: uiNode)
        coinsComponent.coinIcon.move(toParent: uiNode)
        pauseButtonComponent.pauseButtonNode.move(toParent: uiNode)
        
        // CORREÇÃO: Inicializar o EnemySpawner corretamente
        enemySpawner = EnemySpawner(parentNode: worldNode, scene: self)
        enemySpawner.startSpawningEnemies()
        
        let frog = Frog(parent: self)
        let frogNode: SKNode

        switch DeviceHelper.current {
        case .iPad:
            frogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 150))
        case .iPhone:
            frogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 100))
        case .unknown:
            frogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 150))
        }

        worldNode.addChild(frogNode)
        
        // --- Tamanho e posição dos botões agora são adaptativos ---
        let buttonSize = DeviceHelper.isIPhone ? CGSize(width: 60, height: 60) : CGSize(width: 80, height: 80)
        let buttonYPosition = DeviceHelper.isIPhone ? (-self.size.height/2 + 80) : (-self.size.height/2 + 100)
        
        let openPBY = DeviceHelper.isIPhone ? -243 : (-self.size.height/2 + 100)
        
        let lX: CGFloat = DeviceHelper.isIPhone ? -80 : -320
        let rockX: CGFloat = DeviceHelper.isIPhone ? -140 : -240
        let openPX: CGFloat = DeviceHelper.isIPhone ? -80 : -160
        let twoX: CGFloat = DeviceHelper.isIPhone ? 80 : 160
        let hangLX: CGFloat = DeviceHelper.isIPhone ? 140 : 240
        let topX: CGFloat = DeviceHelper.isIPhone ? 80 : 320
        
        let rockButton = SKSpriteNode(imageNamed: "Rock")
        rockButton.name = "rockButton"
        rockButton.size = buttonSize
        rockButton.position = CGPoint(x: rockX, y: buttonYPosition)
        uiNode.addChild(rockButton)
        
        let twoButton = SKSpriteNode(imageNamed: "Two")
        twoButton.name = "twoButton"
        twoButton.size = buttonSize
        twoButton.position = CGPoint(x: twoX, y: buttonYPosition)
        uiNode.addChild(twoButton)
        
        let topButton = SKSpriteNode(imageNamed: "Top")
        topButton.name = "TopButton"
        topButton.size = buttonSize
        topButton.position = CGPoint(x: topX, y: openPBY)
        uiNode.addChild(topButton)
        
        let lButton = SKSpriteNode(imageNamed: "L")
        lButton.name = "lButton"
        lButton.size = buttonSize
        lButton.position = CGPoint(x: lX, y: buttonYPosition)
        uiNode.addChild(lButton)
        
        let hangLButton = SKSpriteNode(imageNamed: "HangLose")
        hangLButton.name = "hangLButton"
        hangLButton.size = buttonSize
        hangLButton.position = CGPoint(x: hangLX, y: buttonYPosition)
        uiNode.addChild(hangLButton)
        
        let openPButton = SKSpriteNode(imageNamed: "OpenPalm")
        openPButton.name = "openPButton"
        openPButton.size = buttonSize
        openPButton.position = CGPoint(x: openPX, y: openPBY)
        uiNode.addChild(openPButton)
    }
    
    @objc func pauseGame() {
        print("🔴 TENTATIVA DE PAUSAR O JOGO (`pauseGame`)")
        if worldNode.isPaused {
            print("    -> Jogo já estava pausado. Ação ignorada.")
            return
        }
        
        print("    -> PAUSANDO O JOGO AGORA.")
        isManuallyPaused = true

        // Pausa o jogo
        worldNode.isPaused = true
        pauseOverlayComponent.show()

        enemySpawner.stopSpawningEnemies()
        AudioManager.shared.pauseBackgroundMusic()
        AudioManager.shared.pauseBossMusic()
    }

    @objc func resumeGame() {
        print("🔴 TENTATIVA DE DESPAUSAR O JOGO (`resumeGame`)")
        if !worldNode.isPaused {
            print("    -> Jogo já estava despausado. Ação ignorada.")
            return
        }

        print("    -> DESPAUSANDO O JOGO AGORA.")
        isManuallyPaused = false
        
        worldNode.isPaused = false
        pauseOverlayComponent.hide()

        // Reinicia a música e os inimigos dependendo do estado do jogo.
        if gameState == .normalPlay {
            AudioManager.shared.resumeBackgroundMusic()
            enemySpawner.startSpawningEnemies()
        } else if gameState == .bossFight {
            AudioManager.shared.resumeBossMusic()
        }
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

        // Verifica se a colisão foi entre o jogador e um inimigo
        if (firstBody.categoryBitMask == PhysicsCategory.frog && secondBody.categoryBitMask == PhysicsCategory.enemy) {
            
            isPlayerDead = true
            
            self.coinsComponent.saveSessionCoins()
        
            // Para a música de fundo
            AudioManager.shared.stopBackgroundMusic()
            AudioManager.shared.stopBossMusic()
            
            let waitAction = SKAction.wait(forDuration: 0.1)
            let transitionAction = SKAction.run {
                if let gameOverScene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
                    gameOverScene.scaleMode = .aspectFill
                    gameOverScene.finalScore = self.scoreComponent.scoreCount
                    
                    // Informa para a próxima cena qual modo de jogo deve ser reiniciado.
                    gameOverScene.previousSceneName = "ButtonMode"
                    
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            }
            
            // Roda a sequência: espera um pouco e depois faz a transição.
            self.run(SKAction.sequence([waitAction, transitionAction]))
        }
    }
    
    /// Método chamado pouco antes da cena ser removida da tela
    override func willMove(from view: SKView) {
        enemySpawner?.stopSpawningEnemies()
    }
    
    func playerDidMake(gesture: String) {
        switch gameState {
        case .bossFight:
            // Durante a batalha, apenas o chefe responde.
            mageControl?.handlePlayer(gesture: gesture)
            
        case .normalPlay, .clearingField:
            // No jogo normal E na limpeza de campo, a lógica para matar inimigos normais funciona.
            if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
                scoreComponent.addScore(point: rewards.points)
                coinsComponent.addCoins(coins: rewards.coins)
            } else {
                if scoreComponent.scoreCount > 0 {
                    scoreComponent.decreaseScore(point: 1)
                }
            }
        }
        
        // Após cada jogada, verifica se é hora de iniciar a luta do chefe
        checkToStartBossEncounter()
    }
    
    private func checkToStartBossEncounter() {
        let score = scoreComponent.scoreCount
        
        let scoreSinceLastBoss = score - scoreAtLastBossDefeat
            
        if gameState == .normalPlay && scoreSinceLastBoss >= 75 {
                           
            gameState = .clearingField
            
            AudioManager.shared.pauseBackgroundMusic()
            AudioManager.shared.playBossMusic()
            
            mageControl = MageControl(scene: self, spawner: self.enemySpawner)
            mageControl?.startBossEncounter()
        }
    }

    func enterBossFightState() {
        self.gameState = .bossFight
    }

    func bossFightDidEnd() {
        self.scoreAtLastBossDefeat = self.scoreComponent.scoreCount
        
        AudioManager.shared.stopBossMusic()
        AudioManager.shared.resumeBackgroundMusic()

        enemySpawner.enemyControl.advanceToNextStage()
        
        mageControl = nil
        gameState = .normalPlay
        enemySpawner.startSpawningEnemies()
    }
    
    // MARK: - Entrada do Usuário
     
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if worldNode.isPaused {
            pauseOverlayComponent.handleTouch(at: location)
            return
        }

        let touchedNode = atPoint(location)
        if touchedNode == pauseButtonComponent.pauseButtonNode {
            pauseButtonComponent.delegate?.didTapPauseButton()
            return
        }
        
        if touchedNode.name == "rockButton" { playerDidMake(gesture: "Rock") }
        if touchedNode.name == "twoButton" { playerDidMake(gesture: "Two") }
        if touchedNode.name == "lButton" { playerDidMake(gesture: "L") }
        if touchedNode.name == "hangLButton" { playerDidMake(gesture: "HangLose") }
        if touchedNode.name == "openPButton" { playerDidMake(gesture: "OpenPalm") }
        if touchedNode.name == "TopButton" { playerDidMake(gesture: "Top") }
    }
    
    // MARK: - Delegates
    
    func didTapPauseButton() {
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
        self.pauseGame()
    }
    
    func didTapResumeButton() {
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
        resumeGame()
    }
    
    func didTapResetButton() {
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
        
        self.view?.isPaused = false
        
        if let newButtonScene = SKScene(fileNamed: "ButtonMode") as? ButtonScene {
            newButtonScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newButtonScene, transition: transition)
        }
    }
     
    func didTapExitButton() {
        AudioManager.shared.stopBackgroundMusic()
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
        
        self.view?.isPaused = false
        
        let sceneName = DeviceHelper.isIPhone ? "MenuScene_iphone" : "MenuScene"
        
        if let menuScene = SKScene(fileNamed: sceneName) {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(menuScene, transition: transition)
        }
    }
    
    @objc private func appWillResignActive() {
        print("🔴 APP VAI SER MINIMIZADO (`appWillResignActive`)")
        self.pauseGame()
    }

    @objc private func wakeUpView() {
        // A única função disso é garantir que a view não esteja com a pausa do sistema.
        if self.view?.isPaused == true {
            self.view?.isPaused = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isManuallyPaused && !worldNode.isPaused {
            worldNode.isPaused = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
