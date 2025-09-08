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
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
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
        
//        drawDebugKillZone()
    }
    
//    private func drawDebugKillZone() {
//        let zoneRect = self.killZoneRect
//        
//        let killZoneNode = SKSpriteNode(
//            color: UIColor.red.withAlphaComponent(0.3),
//            size: zoneRect.size
//        )
//        
//        killZoneNode.position = CGPoint(x: zoneRect.midX, y: zoneRect.midY)
//        killZoneNode.zPosition = 10
//        
//        self.addChild(killZoneNode)
//
//    }
    
    private func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            // Permissão já concedida, pode configurar a cena.
            self.initializeScene()
            
        case .notDetermined:
            // Permissão ainda não solicitada, vamos pedir.
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        // O usuário concedeu a permissão.
                        self?.initializeScene()
                    } else {
                        // O usuário negou a permissão.
                        self?.handlePermissionDenied()
                    }
                }
            }
            
        case .denied, .restricted:
            // O usuário já negou a permissão ou ela está restrita.
            handlePermissionDenied()
            
        @unknown default:
            // Lida com qualquer outro caso futuro.
            handlePermissionDenied()
        }
    }
    
    private func handlePermissionDenied() {
        let alertController = UIAlertController(
            title: "Acesso à Câmera Necessário",
            message: "Este jogo utiliza a câmera para detectar seus gestos. Por favor, habilite o acesso nas Configurações para poder jogar.",
            preferredStyle: .alert
        )

        // Botão para levar o usuário aos Ajustes do app
        let settingsAction = UIAlertAction(title: "Ir para Ajustes", style: .default) { _ in
            // Abre a URL de configurações do aplicativo
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Opcional: para depuração
                })
            }
        }
        alertController.addAction(settingsAction)

        // Botão para voltar ao menu, agora com o estilo .cancel
        let cancelAction = UIAlertAction(title: "Voltar ao Menu", style: .cancel) { [weak self] _ in
            self?.transitionToMenu()
        }
        alertController.addAction(cancelAction)

        // Apresenta o alerta na thread principal
        DispatchQueue.main.async {
            if let viewController = self.view?.window?.rootViewController {
                viewController.present(alertController, animated: true)
            }
        }
    }
    
    private func transitionToMenu() {
        if let menuScene = SKScene(fileNamed: "MenuScene") {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(menuScene, transition: transition)
        }
    }
    
    private func initializeScene() {
        // Evita que a cena seja inicializada múltiplas vezes.
        guard !sceneIsInitialized else { return }
        
        setupScene()
        sceneIsInitialized = true
    }
    
    // GameScene.swift

    private func setupScene() {
        print("Configurando a GameScene pela primeira vez.")

        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppDidBecomeActive"), object: nil)
            
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
        let frogNode: SKNode

        switch DeviceHelper.current {
        case .iPad:
            frogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 150))
        case .iPhone:
            frogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 100))
        case .unknown:
            frogNode = frog.createNode(at: CGPoint(x: 0, y: -self.size.height/2 + 150))
        }

        self.addChild(frogNode)
            
        setupGestureDetection()

        // Esta seção agora funciona para TODOS os dispositivos, não apenas para o iPad.

        // 1. Verifique se a pré-visualização da câmera está habilitada nas configurações.
        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        if isCameraPreviewEnabled {
            if let view = self.view {
                print("Pré-visualização da câmera está ATIVADA. Configurando a view...")
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
            }
        }

        // 2. Verifique se o jogo deve começar no modo de validação de gestos.
        if startInGestureMode {
            let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
            
            if isValidationEnabled {
                print("Modo de validação está ATIVADO. Iniciando...")
                setupValidationInstructionLabel()
                setupCountdownLabel()
                enterGestureValidationMode()
            } else {
                print("Modo de validação está DESATIVADO. Pulando para o jogo.")
                // Chama cameraDidShrink() para iniciar o onboarding ou o jogo principal.
                cameraDidShrink()
            }
        } else {

            // para que o onboarding ou o jogo comecem. Este é o caminho normal.
            cameraDidShrink()
        }
                    
        if let view = self.view {
            onboardManager = OnboardManager(view: view, spawner: self.enemySpawner, gestureManager: self.gestureManager)
            onboardManager.delegate = self
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
    
    private func setupValidationInstructionLabel() {
        guard let view = self.view else { return }
        
        let fontSize: CGFloat = DeviceHelper.isIPad ? 30 : 20
        
        let label = UILabel()
        label.text = "Mantenha sua mão na área enquanto joga!"
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
    
    func enterGestureValidationMode() {
        guard let view = self.view else { return }
        
        pauseButtonComponent.pauseButtonNode.isHidden = true
        
        // 1. Expande a câmera para tela cheia.
        // --- CORREÇÃO 1: Corrigido o nome da chave para "isCameraPreviewEnabled" ---
        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        
        if !isCameraPreviewEnabled {
                print("Preview estava desativada. Criando temporariamente para a validação.")
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
        }
        
        isOnGestureValidationMode = true
        gestureManager?.expandCameraPreviewToFullScreen(in: view)
        
        countdownValue = 3
        countdownLabel?.text = "\(countdownValue)"
        countdownLabel?.isHidden = false
        instructionLabel?.isHidden = false
        
        // --- CORREÇÃO 2: Trazer os labels para a FRENTE da view ---
        // Isso garante que eles fiquem por cima da preview da câmera que foi criada.
        if let countdown = countdownLabel {
            view.bringSubviewToFront(countdown)
        }
        if let instruction = instructionLabel {
            view.bringSubviewToFront(instruction)
        }
    }
    
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
        
        countdownLabel?.isHidden = true
        instructionLabel?.isHidden = true
        isOnGestureValidationMode = false
        
        if !isOnboarding {
            pauseButtonComponent.pauseButtonNode.isHidden = false
        }
        
        // --- CORREÇÃO: Corrigido o nome da chave para "isCameraPreviewEnabled" ---
        let isCameraPreviewEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        if !isCameraPreviewEnabled {
            print("Validação concluída. Removendo a preview com base nas configurações")
            gestureManager?.removeCameraPreview()
        }
        
        gestureManager?.shrinkCameraPreviewToOriginal(in: view)
    }
    
    private func setupGestureDetection() {
        gestureManager = GestureDetectionManager()
        gestureManager.delegate = self
        gestureManager.startDetection()
    }
    
    // VERSÃO ADAPTATIVA do setup de debug UI
    private func setupGestureDebugUI() {
        // --- Configuração do Label (código existente) ---
        gestureDebugLabel = SKLabelNode(fontNamed: "Arial-Bold")
        if let labelNode = gestureDebugLabel {
            labelNode.fontSize = DeviceHelper.isIPhone ? 16 : 20
            labelNode.fontColor = .yellow
            let topOffset: CGFloat = DeviceHelper.isIPhone ? 80 : 100
            labelNode.position = CGPoint(x: 0, y: self.size.height/3 - topOffset)
            labelNode.text = "Gesto: Nenhum"
            addChild(labelNode)
        }
        
        gestureDebugImageNode = SKSpriteNode() // Inicializa o nó vazio
        if let imageNode = gestureDebugImageNode, let labelNode = gestureDebugLabel {
            imageNode.size = DeviceHelper.isIPad ? CGSize(width: 80, height: 80) : CGSize(width: 50, height: 50)
            imageNode.position = DeviceHelper.isIPhone ?  CGPoint(x: 85, y: -200) : CGPoint(x: 80, y: -170)
            imageNode.isHidden = true
            addChild(imageNode)
        }
        
        let bookNode = SKSpriteNode(imageNamed: "livro")
        bookNode.size = DeviceHelper.isIPad ? CGSize(width: 150, height: 150) : CGSize(width: 100, height: 100)
        bookNode.position = CGPoint(x: 80, y: -250)
        bookNode.isHidden = false
        addChild(bookNode)
        
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
        gestureDebugImageNode?.isHidden = true // NOVO: Oculta a imagem quando o gesto é perdido
        
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
        // 1. Usa a VIEW como "fonte da verdade" para o estado de pausa.
        if self.view?.isPaused ?? false {
            return
        }
        print("🛑 PAUSANDO JOGO COMPLETAMENTE")

        // 2. Mostra a UI de pausa.
        pauseOverlayComponent.show()

        // 3. Para sistemas específicos da GameScene (câmera, gestos, timers).
        enemySpawner.stopSpawningEnemies()
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview() // Garante que a câmera saia ao pausar.
        AudioManager.shared.pauseBackgroundMusic()

        // 4. A MÁGICA: Agenda a pausa da VIEW para o próximo quadro, permitindo que a UI apareça.
        let wait = SKAction.wait(forDuration: 0)
        let pauseAction = SKAction.run { [weak self] in
            self?.view?.isPaused = true
        }
        self.run(SKAction.sequence([wait, pauseAction]))
    }

    @objc func resumeGame() {
        // 1. Usa a VIEW como "fonte da verdade".
        guard self.view?.isPaused ?? false else { return }
        print("▶️ RETOMANDO JOGO COMPLETAMENTE")

        // 2. Despausa a VIEW PRIMEIRO para "acordar" a renderização.
        self.view?.isPaused = false

        // 3. Remove a UI de pausa.
        pauseOverlayComponent.hide()

        // 4. Lógica específica da GameScene para reativar a câmera e os gestos.
        gestureManager.startDetection()
        if let view = self.view {
            self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
        }
        
        // 5. Lógica condicional original para reiniciar a música e os inimigos.
        if !isOnGestureValidationMode && !isOnboarding {
            AudioManager.shared.resumeBackgroundMusic()
            if gameState == .normalPlay {
                enemySpawner.startSpawningEnemies()
            }
        }
    }
    
    // MARK: - Funções do onboarding
    
    
    
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

        // Verifica se a colisão foi entre o jogador e um inimigo
        if (firstBody.categoryBitMask == PhysicsCategory.frog && secondBody.categoryBitMask == PhysicsCategory.enemy) {
            
            isPlayerDead = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                self.gestureManager?.stopDetection()
                self.gestureManager?.removeCameraPreview()
            }
            
            self.coinsComponent.saveSessionCoins()
        
            // Para a música de fundo
            AudioManager.shared.stopBackgroundMusic()
            
            let waitAction = SKAction.wait(forDuration: 0.1)
            let transitionAction = SKAction.run {
                if let gameOverScene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
                    gameOverScene.scaleMode = .aspectFill
                    gameOverScene.finalScore = self.scoreComponent.scoreCount
                    
                    // Informa para a próxima cena qual modo de jogo deve ser reiniciado.
                    gameOverScene.previousSceneName = "GameScene"
                    
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            }
            
            // Roda a sequência: espera um pouco e depois faz a transição.
            self.run(SKAction.sequence([waitAction, transitionAction]))
        }
    }
    
    override func willMove(from view: SKView) {
        enemySpawner?.stopSpawningEnemies()
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
    }
    

    // MARK: - Lógica do Jogo
    
    // Processa a ação do jogador após fazer um gesto.
    func playerDidMake(gesture: String) {
        if isOnboarding {
            if onboardingState == .waitingForPlayerAction {
                // Pega o inimigo atual na tela
                guard let currentEnemy = enemySpawner.enemyControl.activeEnemies.first else { return }
                
                // Verifica se o gesto feito corresponde a algum dos nós de gesto filhos do inimigo
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
                    // Durante a batalha, apenas o chefe responde.
                    mageControl?.handlePlayer(gesture: gesture)
                    
                case .normalPlay, .clearingField:
                    // No jogo normal E na limpeza de campo, a lógica para matar inimigos normais funciona.
                    if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
                        scoreComponent.addScore(point: rewards.points)
                        coinsComponent.addCoins(coins: rewards.coins)
                        
                        enemySpawner.updateEnemySpeed(basedOn: scoreComponent.scoreCount)
                        
                    }
            }
            
            // A verificação do chefe agora só inicia a fase de limpeza.
            checkToStartBossEncounter()
        }
    }
    
    private func checkToStartBossEncounter() {
        let score = scoreComponent.scoreCount
        
        // Se as condições forem atendidas, muda para o estado de LIMPEZA.
        let scoreSinceLastBoss = score - scoreAtLastBossDefeat
        
        // A condição agora é muito mais simples e robusta.
        if gameState == .normalPlay && scoreSinceLastBoss >= 15  { // Use 5 para testar
            
            // Não precisamos mais atualizar 'lastBossTriggerScore'.
            
            gameState = .clearingField
            
            mageControl = MageControl(scene: self, spawner: self.enemySpawner)
            mageControl?.startBossEncounter()
        }
    }
    
    func enterBossFightState() {
        self.gameState = .bossFight
    }
    
    func bossFightDidEnd() {
        self.scoreAtLastBossDefeat = self.scoreComponent.scoreCount
        
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

        // --- CORREÇÃO AQUI ---
        // Verifica se a VIEW está pausada para encaminhar o toque ao menu.
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
            onboardManager.startOnboarding() // Inicia onboarding em vez de spawning normal
        } else {
            enemySpawner.startSpawningEnemies()
        }
    }
    
    func didTapPauseButton() {
        print("Botão Pausar foi tocado (via Delegate)!")
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
        print("GameScene está sendo removida, limpando os observers.")
        NotificationCenter.default.removeObserver(self)
    }
}
