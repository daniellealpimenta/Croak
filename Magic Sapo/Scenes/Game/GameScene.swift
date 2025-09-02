//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, GestureDetectionDelegate, ScoreHavingScene, PauseButtonDelegate, PauseOverlayDelegate {
    
    func cameraWillExpand() {
        print("Câmera vai expandir, pausando o jogo.")
        self.isPaused = true
        enemySpawner.stopSpawningEnemies()
    }
    
    func cameraDidShrink() {
        print("Câmera encolheu, despausando o jogo.")
        self.isPaused = false
        enemySpawner.startSpawningEnemies()
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
    var enemySpawner: EnemySpawner!
    var pauseOverlayComponent: PauseOverlayComponent!
    
    private var cameraPreviewNode: SKEffectNode!
    private var gestureDebugLabel: SKLabelNode?
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
        setupCountdownLabel()
        setupInstructionLabel()
        
        if startInGestureMode {
            enterGestureValidationMode()
        }
    }
    
    private func setupCountdownLabel() {
        // Garante que a view principal do jogo exista
        guard let view = self.view else { return }

        // Cria uma UILabel, o equivalente a SKLabelNode no UIKit
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 100)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true // Começa invisível

        // Adiciona a label na view principal, por cima de tudo
        view.addSubview(label)
        self.countdownLabel = label

        // Configura as "constraints" para garantir que a label fique sempre centralizada
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setupInstructionLabel() {
        guard let view = self.view else { return }
        
        let label = UILabel()
        label.text = "Mantenha sua mão na área enquanto joga!"
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        
        view.addSubview(label)
        self.instructionLabel = label
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    func enterGestureValidationMode() {
        print("Iniciando modo de validação de gestos...")
        
        guard let view = self.view else { return }
        
        // 1. Expande a câmera para tela cheia.
        isOnGestureValidationMode = true
        gestureManager?.expandCameraPreviewToFullScreen(in: view)
        
        countdownValue = 3
        countdownLabel?.text = "\(countdownValue)"
        countdownLabel?.isHidden = false
        instructionLabel?.isHidden = false
    }
    
//   func enterGestureValidationMode() {
//        print("Iniciando modo de validação de gestos...")
//
//        guard let view = self.view else { return }
//
//        // 1. Expande a câmera para tela cheia.
//        isOnGestureValidationMode = true
//        gestureManager?.expandCameraPreviewToFullScreen(in: view)
//
//        // 2. Prepara o timer.
//        countdownLabel?.text = "3"
//        countdownLabel?.isHidden = false
//        instructionLabel?.isHidden = false
//        var countdown = 3
//
//        // 3. Define a ação que será repetida a cada segundo.
//        let updateAction = SKAction.run { [weak self] in
//            countdown -= 1
//            self?.countdownLabel?.text = "\(countdown)"
//        }
//
//        // Ação de esperar 1 segundo.
//        let waitAction = SKAction.wait(forDuration: 1.0)
//
//        // Combina a espera e a atualização em uma única ação.
//        let sequencePerSecond = SKAction.sequence([waitAction, updateAction])
//
//        // Repete a sequência 2 vezes (para contar 2 e 1).
//        let countdownSequence = SKAction.repeat(sequencePerSecond, count: 3)
//
//        // 4. Define as ações finais após o timer.
//        let finalActions = SKAction.run { [weak self] in
//            guard let self = self, let view = self.view else { return }
//            print("Passaram 5 segundos. Retornando a câmera para a posição original.")
//            
//            // Esconde o label do timer.
//            self.countdownLabel?.isHidden = true
//            self.instructionLabel?.isHidden = true
//            
//            // Chama a função para encolher a câmera.
//            isOnGestureValidationMode = false
//            self.gestureManager?.shrinkCameraPreviewToOriginal(in: view)
//    }
//    
//    // 5. Executa a sequência completa na cena.
//    // A lógica é: Roda a contagem (de 3 para 2, de 2 para 1), espera o último segundo,
//    // e então executa as ações finais.
//    self.run(SKAction.sequence([countdownSequence, waitAction, finalActions]))
//}

    
    private func startOrContinueValidationCountdown() {
        // Se já tem timer rodando, não faz nada
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
        
        print("Contagem concluída. Retornando a câmera para a posição original.")
        
        countdownLabel?.isHidden = true
        instructionLabel?.isHidden = true
        isOnGestureValidationMode = false
        
        gestureManager?.shrinkCameraPreviewToOriginal(in: view)
    }
    
    private func setupGestureDetection() {
        gestureManager = GestureDetectionManager()
        gestureManager.delegate = self
        gestureManager.startDetection()
    }
    
    // VERSÃO ADAPTATIVA do setup de debug UI

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
    }
    
    func gestureDetected(_ gesture: String, confidence: Double) {
        // Atualizar label de debug
        gestureDebugLabel?.text = "Gesto: \(gesture) (\(Int(confidence * 100))%)"
        
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
    

    // MARK: - Lógica do Jogo
    
    /// Processa a ação do jogador após fazer um gesto.
    /// - Parameter gesture: A string que representa o gesto feito (ex: "Rock").
        func playerDidMake(gesture: String) {
        if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
            scoreComponent.addScore(point: rewards.points)
            coinsComponent.addCoins(coins: rewards.coins)
            enemySpawner.updateEnemySpeed(basedOn: scoreComponent.scoreCount)
            print("Ganhou \(rewards.coins) moedas!")
        }
    }
    
    func makeGestureInValidation(gesture: String) {
        if gesture == "OpenPalm" {
            if !isProcessingCorrectGesture {
                print("Acertou o gesto 'OpenPalm'! ✅")
                gestureManager?.updateHandFeedback(status: .correct)
                startOrContinueValidationCountdown()
                isProcessingCorrectGesture = true
            }
        } else {
            if isProcessingCorrectGesture {
                print("Perdeu o gesto correto, voltando para branco. ❌")
            } else {
                print("Gesto errado! Faça o gesto 'OpenPalm'. ❌")
            }
            gestureManager?.updateHandFeedback(status: .neutral)
            resetValidationCountdown()
            isProcessingCorrectGesture = false
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
