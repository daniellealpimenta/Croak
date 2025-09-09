//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate, GestureDetectionDelegate, ScoreHavingScene, PauseButtonDelegate, PauseOverlayDelegate, BossFightScene, OnboardDelegate {
    // comente abaixo se for testar tambem
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    private var gestureFeedbackNode: SKSpriteNode?

    
    // MARK: VARIAVEL PARA TESTE
//    var isOnboarding = true
    
    private var onboardingState: OnboardingState = .inactive
    
    
    enum OnboardingState {
        case inactive
        case waitingForPlayerAction
    }
    
    var isOnGestureValidationMode = false
    
    var gestureValidationTimer: Timer?
    var countdownValue: Int = 3
    private var isProcessingCorrectGesture = false
    
    private var instructionLabel: UILabel?
    private var countdownLabel: UILabel?
    
    var startInGestureMode = false
    // MARK: - Componentes
    
    private var isPlayerDead = false
    
    var scoreComponent: ScoreComponent!
    var coinsComponent: CoinsComponent!
    var backgroundComponent: BackgroundComponent!
    var pauseButtonComponent: PauseButtonComponent!
    var gestureManager: GestureDetectionManager!
    var onboardManager: OnboardManager!
    var enemySpawner: EnemySpawner!

    var pauseOverlayComponent: PauseOverlayComponent!
    
    private var cameraPreviewNode: SKEffectNode!
    private var gestureDebugLabel: SKLabelNode?
    private var gestureDebugImageNode: SKSpriteNode?
    
    // ALTERAÇÃO: Mantemos a referência do sapo para posicionar o livro
    private var frogNode: SKNode?
    
    private var gameState: GameState = .normalPlay
    private var mageControl: MageControl?
    private var scoreAtLastBossDefeat = 0
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
      }
    //    Flag para controlar a inicialização da cena.
    private var sceneIsInitialized = false
    
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
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        if !sceneIsInitialized {
            checkCameraPermission()
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
    
    private func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            self.initializeScene()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.initializeScene()
                    } else {
                        self?.handlePermissionDenied()
                    }
                }
            }
        case .denied, .restricted:
            handlePermissionDenied()
        @unknown default:
            handlePermissionDenied()
        }
    }
    
    private func handlePermissionDenied() {
        let alertController = UIAlertController(
            title: NSLocalizedString("camera_permission_title", comment: ""),
            message: NSLocalizedString("camera_permission_message", comment: ""),
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: NSLocalizedString("go_to_settings_button", comment: ""), style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)

        let cancelAction = UIAlertAction(title: NSLocalizedString("back_to_menu_button", comment: ""), style: .cancel) { [weak self] _ in
            self?.transitionToMenu()
        }
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            if let viewController = self.view?.window?.rootViewController {
                viewController.present(alertController, animated: true)
            }
        }
    }
    
    private func transitionToMenu() {
        let sceneName = DeviceHelper.isIPhone ? "MenuScene_iphone" : "MenuScene"
        if let menuScene = SKScene(fileNamed: sceneName) {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(menuScene, transition: transition)
        }
    }
    
    private func initializeScene() {
        guard !sceneIsInitialized else { return }
        setupScene()
        sceneIsInitialized = true
    }
    
    private func setupScene() {

        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
                
        self.physicsWorld.contactDelegate = self
                
        backgroundComponent = BackgroundComponent(parent: self)
        backgroundComponent.setupAnimatedBackground()
                
        scoreComponent = ScoreComponent(parent: self)
        coinsComponent = CoinsComponent(parent: self)
                
        pauseButtonComponent = PauseButtonComponent(parent: self)
        pauseButtonComponent.delegate = self
                
        if isOnboarding {
            scoreComponent.scoreLabel.isHidden = true
            coinsComponent.coinsLabel.isHidden = true
            coinsComponent.labelShadow.isHidden = true
            coinsComponent.coinIcon.isHidden = true
            pauseButtonComponent.pauseButtonNode.isHidden = true
        }
                
        pauseOverlayComponent = PauseOverlayComponent(parent: self)
        pauseOverlayComponent.delegate = self
                
        enemySpawner = EnemySpawner(scene: self)
                
        let frog = Frog(parent: self)
        let createdFrogNode: SKNode

        switch DeviceHelper.current {
        case .iPad:
            createdFrogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 150))
        case .iPhone:
            createdFrogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 100))
        case .unknown:
            createdFrogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 150))
        }

        self.addChild(createdFrogNode)
        self.frogNode = createdFrogNode
        
        setupMagicBook()
        
        setupGestureFeedbackNode()
                
        setupGestureDetection()

        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        if isCameraPreviewEnabled {
            if let view = self.view {
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
            }
        }

        if startInGestureMode {
            let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
            
            if isValidationEnabled {
                setupValidationInstructionLabel()
                setupCountdownLabel()
                enterGestureValidationMode()
            } else {
                cameraDidShrink()
            }
        } else {
            cameraDidShrink()
        }
                        
        if let view = self.view {
            onboardManager = OnboardManager(view: view, spawner: self.enemySpawner, gestureManager: self.gestureManager)
            onboardManager.delegate = self
        }
    }
    
    private func setupMagicBook() {
        
        guard let frogNode = self.frogNode else {
            print("AVISO: Nó do sapo não encontrado. Não foi possível adicionar o livro.")
            return
        }
        
        let bookNode = MagicBook.createBookNode()
        
        let offset = DeviceHelper.isIPad ? CGVector(dx: 60, dy: 30) : CGVector(dx: 45, dy: 45)
        
        bookNode.zPosition = frogNode.zPosition - 1
        
        bookNode.position = CGPoint(
            x: frogNode.position.x + offset.dx,
            y: frogNode.position.y + offset.dy
        )
        
        
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 2.0)
        
        moveDown.timingMode = .easeInEaseOut
        
        let moveUp = moveDown.reversed()
        
        let floatSequence = SKAction.sequence([moveDown, moveUp])
        
        let floatAnimation = SKAction.repeatForever(floatSequence)
        
        bookNode.run(floatAnimation)
                
        self.addChild(bookNode)
    }

    
    private func setupCountdownLabel() {
        guard let view = self.view else { return }

        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 100)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true

        view.addSubview(label)
        self.countdownLabel = label

        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setupValidationInstructionLabel() {
        guard let view = self.view else { return }
        
        let fontSize: CGFloat = DeviceHelper.isIPad ? 30 : 20
        
        let label = UILabel()
        label.text = NSLocalizedString("validation_instruction", comment: "Instruction for gesture validation mode")
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        
        view.addSubview(label)
        self.instructionLabel = label
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Funções do modo validação
    
    private func setupGestureFeedbackNode() {
        guard let frogNode = self.frogNode else {
            print("AVISO: Nó do sapo não encontrado. Não foi possível adicionar o nó de feedback de gesto.")
            return
        }
        
        let feedbackNodeSize = DeviceHelper.isIPad ? CGSize(width: 50, height: 50) : CGSize(width: 40, height: 40)
        
        let feedbackNode = SKSpriteNode(color: .clear, size: feedbackNodeSize)
        
        let bookOffset = DeviceHelper.isIPad ? CGVector(dx: 70, dy: 30) : CGVector(dx: 55, dy: 40)
        let gestureOffset = CGVector(dx: bookOffset.dx, dy: bookOffset.dy + 40)

        feedbackNode.position = CGPoint(
            x: frogNode.position.x + gestureOffset.dx,
            y: frogNode.position.y + gestureOffset.dy
        )
        
        feedbackNode.zPosition = frogNode.zPosition - 1
        
        feedbackNode.isHidden = true
        

        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 2.0)
        moveDown.timingMode = .easeInEaseOut

        let moveUp = moveDown.reversed()

        let floatSequence = SKAction.sequence([moveDown, moveUp])

        let floatAnimation = SKAction.repeatForever(floatSequence)

        feedbackNode.run(floatAnimation)
        
        self.gestureFeedbackNode = feedbackNode
        self.addChild(feedbackNode)
    }
    
    func enterGestureValidationMode() {
        guard let view = self.view else { return }
        
        pauseButtonComponent.pauseButtonNode.isHidden = true
        
        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        
        if !isCameraPreviewEnabled {
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
        }
        
        isOnGestureValidationMode = true
        gestureManager?.expandCameraPreviewToFullScreen(in: view)
        
        countdownValue = 3
        countdownLabel?.text = "\(countdownValue)"
        countdownLabel?.isHidden = false
        instructionLabel?.isHidden = false
        
        if let countdown = countdownLabel {
            view.bringSubviewToFront(countdown)
        }
        if let instruction = instructionLabel {
            view.bringSubviewToFront(instruction)
        }
    }
    
    private func startOrContinueValidationCountdown() {
        if gestureValidationTimer != nil { return }
        
        gestureValidationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.countdownValue -= 1
            self.countdownLabel?.text = "\(self.countdownValue)"
            
            if self.countdownValue <= 0 {
                timer.invalidate()
                self.gestureValidationTimer = nil
                self.finishGestureValidationMode()
            }
        }
    }
    
    private func resetValidationCountdown() {
        gestureValidationTimer?.invalidate()
        gestureValidationTimer = nil
        countdownValue = 3
        countdownLabel?.text = "\(countdownValue)"
    }
    
    private func finishGestureValidationMode() {
        guard let view = self.view else { return }
        
        countdownLabel?.isHidden = true
        instructionLabel?.isHidden = true
        isOnGestureValidationMode = false
        
        if !isOnboarding {
            pauseButtonComponent.pauseButtonNode.isHidden = false
        }
        
        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        if !isCameraPreviewEnabled {
            gestureManager?.removeCameraPreview()
        }
        
        gestureManager?.shrinkCameraPreviewToOriginal(in: view)
    }
    
    private func setupGestureDetection() {
        gestureManager = GestureDetectionManager()
        gestureManager.delegate = self
        gestureManager.startDetection()
    }
    
    private func setupGestureDebugUI() {
        gestureDebugLabel = SKLabelNode(fontNamed: "Arial-Bold")
        if let labelNode = gestureDebugLabel {
            labelNode.fontSize = DeviceHelper.isIPhone ? 16 : 20
            labelNode.fontColor = .yellow
            let topOffset: CGFloat = DeviceHelper.isIPhone ? 80 : 100
            labelNode.position = CGPoint(x: 0, y: self.size.height/3 - topOffset)
            labelNode.text = "Gesto: Nenhum"
            addChild(labelNode)
        }
        
        gestureDebugImageNode = SKSpriteNode()
        if let imageNode = gestureDebugImageNode {
            imageNode.size = DeviceHelper.isIPad ? CGSize(width: 80, height: 80) : CGSize(width: 50, height: 50)
            imageNode.position = DeviceHelper.isIPhone ?  CGPoint(x: 85, y: -200) : CGPoint(x: 80, y: -170)
            imageNode.isHidden = true
            addChild(imageNode)
        }
    }
    
    func gestureDetected(_ gesture: String, confidence: Double) {
        
        gestureDebugLabel?.text = "Gesto: \(gesture) (\(Int(confidence * 100))%)"
        gestureDebugImageNode?.isHidden = false
        var textureName: String?
        
        switch gesture {
        case "OpenPalm":
            textureName = "OpenPalm_s"
        case "Rock":
            textureName = "Rock_s"
        case "Two":
            textureName = "Two_s"
        case "Top":
            textureName = "Top_s"
        case "L":
            textureName = "L_s"
        case "HangLose":
            textureName = "HangLose_s"
        default:
            textureName = nil
        }
        
        if let name = textureName {
            gestureDebugImageNode?.texture = SKTexture(imageNamed: name)
            
            if let feedbackNode = self.gestureFeedbackNode {
                feedbackNode.texture = SKTexture(imageNamed: name)
                feedbackNode.isHidden = false
                                
                let fadeIn = SKAction.fadeIn(withDuration: 0.1)
                let wait = SKAction.wait(forDuration: 0.5)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
                
                feedbackNode.run(sequence)
            }
            
        } else {
            gestureDebugImageNode?.isHidden = true
        }
        
        if isOnGestureValidationMode {
            makeGestureInValidation(gesture: gesture)
        } else {
            gestureManager?.updateHandFeedback(status: .neutral)
            gestureManager?.handFeedbackOverlayImageView?.alpha = 0.5
            playerDidMake(gesture: gesture)
        }
    }
    
    func gestureDetectionLost() {
        gestureDebugLabel?.text = "Gesto: Nenhum"
        
        if isOnGestureValidationMode {
            gestureManager?.updateHandFeedback(status: .neutral)
            resetValidationCountdown()
            isProcessingCorrectGesture = false
        } else {
            gestureManager?.updateHandFeedback(status: .incorrect)
            gestureManager?.handFeedbackOverlayImageView?.alpha = 1
        }
    }
    
    @objc func pauseGame() {
        if self.view?.isPaused ?? false {
            return
        }

        if isOnboarding || isOnGestureValidationMode {
            return
        }
        
        pauseOverlayComponent.show()

        enemySpawner.stopSpawningEnemies()
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
        AudioManager.shared.pauseBackgroundMusic()
        AudioManager.shared.pauseBossMusic()

        let wait = SKAction.wait(forDuration: 0)
        let pauseAction = SKAction.run { [weak self] in
            self?.view?.isPaused = true
        }
        self.run(SKAction.sequence([wait, pauseAction]))
    }

    @objc func resumeGame() {
        guard self.view?.isPaused ?? false else { return }
        self.view?.isPaused = false

        pauseOverlayComponent.hide()

        gestureManager.startDetection()

        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        if isCameraPreviewEnabled {
            if let view = self.view {
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
            }
        }
        if !isOnGestureValidationMode && !isOnboarding && gameState == .normalPlay {
            AudioManager.shared.resumeBackgroundMusic()
            if gameState == .normalPlay {
                enemySpawner.startSpawningEnemies()
            }
        } else if gameState == .bossFight {
            AudioManager.shared.resumeBossMusic()
        }
    }        
    // MARK: Funções padrão da cena
    
  
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.gestureManager?.stopDetection()
                self.gestureManager?.removeCameraPreview()
            }
            
            self.coinsComponent.saveSessionCoins()
        
            AudioManager.shared.stopBackgroundMusic()
            AudioManager.shared.stopBossMusic()
            
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
    
    // MARK: - Lógica do Jogo
    
    func playerDidMake(gesture: String) {
        if isOnboarding {
            if onboardingState == .waitingForPlayerAction {
                guard let currentEnemy = enemySpawner.enemyControl.activeEnemies.first else { return }
                
                let hasMatchingGesture = currentEnemy.children.contains { node in
                    return node.name == gesture
                }
                
                if hasMatchingGesture {
                    _ = enemySpawner.killEnemy(withGesture: gesture)
                    onboardManager.handleOnboardingGestureSuccess()
                }
            }
        } else {
            switch gameState {
                case .bossFight:
                    mageControl?.handlePlayer(gesture: gesture)
                    
                case .normalPlay, .clearingField:
                    if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
                        scoreComponent.addScore(point: rewards.points)
                        coinsComponent.addCoins(coins: rewards.coins)
                                            
                    }
            }
            
            checkToStartBossEncounter()
        }
    }
    
    private func checkToStartBossEncounter() {
        let score = scoreComponent.scoreCount
        
        let scoreSinceLastBoss = score - scoreAtLastBossDefeat
        
        if gameState == .normalPlay && scoreSinceLastBoss >= 75  {
                               
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

    func makeGestureInValidation(gesture: String) {
        if !isPaused {
            if gesture == "OpenPalm" {
                if !isProcessingCorrectGesture {
                    gestureManager?.updateHandFeedback(status: .correct)
                    startOrContinueValidationCountdown()
                    isProcessingCorrectGesture = true
                }
            } else {
                if isProcessingCorrectGesture {
                } else {
                }
                gestureManager?.updateHandFeedback(status: .neutral)
                resetValidationCountdown()
                isProcessingCorrectGesture = false
            }
        } else {
            return
        }
    }
    
    // MARK: - Entrada do Usuário
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if self.view?.isPaused ?? false {
            pauseOverlayComponent.handleTouch(at: location)
            return
        }
        
        let touchedNode = atPoint(location)
        if touchedNode == pauseButtonComponent.pauseButtonNode {
            pauseButtonComponent.delegate?.didTapPauseButton()
        }
    }
    
    // MARK: - Delegates
    
    func EnterWaitingActionState() {
        onboardingState = .waitingForPlayerAction
    }
    
    func PlayerDidCorrectGesture() {
        onboardingState = .inactive
        
        self.isPaused = false
    }
    
    func OnboardDidComplete() {
        self.isOnboarding = false
        self.scoreComponent.scoreLabel.isHidden = false
        self.coinsComponent.coinsLabel.isHidden = false
        self.coinsComponent.labelShadow.isHidden = false
        self.coinsComponent.coinIcon.isHidden = false
        self.pauseButtonComponent.pauseButtonNode.isHidden = false
        
        onboardingState = .inactive
        
        self.isPaused = false
    }
    
    func cameraWillExpand() {
        self.isPaused = true
        enemySpawner.stopSpawningEnemies()
    }
    
    func cameraDidShrink() {
        self.isPaused = false
        
        if isOnboarding {
            onboardingState = .inactive
            onboardManager.startOnboarding()
        } else {
            enemySpawner.startSpawningEnemies()
        }
    }
    
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

        if let newGameScene = SKScene(fileNamed: "GameScene") as? GameScene {
            newGameScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newGameScene, transition: transition)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
