//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate, GestureDetectionDelegate, ScoreHavingScene, PauseButtonDelegate, PauseOverlayDelegate, BossFightScene{
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    // MARK: VARIAVEL PARA TESTE
//    var isOnboarding = true
    
    private var onboardingState: OnboardingState = .inactive
    private var currentOnboardingGestureIndex = 0
    
    private var onboardingGuardInstructionOverlay: UIImageView?
    private var onboardingThiefInstructionOverlay1: UIImageView?
    private var onboardingThiefInstructionOverlay2: UIImageView?
    private var onboardingInstructionBox: UIView?
    private var onboardingFrogImageView: UIImageView?
    private var onboardingDialogueBox: UIView?
    private var onboardingDialogueLabel: UILabel?
    
    private let onboardingGuardGestures = ["Rock", "Two"]

    enum OnboardingState {
        case inactive
        case spawningEnemy
        case waitingForPlayerAction
        case enemyKilled
        case completed
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
    private var gestureDebugImageNode: SKSpriteNode?
    
    private var gameState: GameState = .normalPlay
    private var mageControl: MageControl?
    private var scoreAtLastBossDefeat = 0
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
      }
    //    Flag para controlar a inicialização da cena.
    private var sceneIsInitialized = false
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        if !sceneIsInitialized {
            checkCameraPermission()
        }
    }
    
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
        
        if isOnboarding {
            scoreComponent.scoreLabel.isHidden = true
            coinsComponent.coinsLabel.isHidden = true
            coinsComponent.coinIcon.isHidden = true
            pauseButtonComponent.pauseButtonNode.isHidden = true
        }
        
        pauseOverlayComponent = PauseOverlayComponent(parent: self)
        pauseOverlayComponent.delegate = self
        
        enemySpawner = EnemySpawner(scene: self)
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

        self.addChild(frogNode)
        
        setupGestureDetection()

        if DeviceHelper.isIPad {
            if let view = self.view {
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
            }
            
            if startInGestureMode {
                setupValidationInstructionLabel()
                setupCountdownLabel()
                enterGestureValidationMode()
            }
        }
        // 3. Configura a UI de debug que depende da detecção.
        setupGestureDebugUI()
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
    
    // MARK: - Funções do modo validação
    
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
    
    // MARK: - Camera WillExpand e DidShrink
    
    func cameraWillExpand() {
        print("Câmera vai expandir, pausando o jogo.")
        self.isPaused = true
        enemySpawner.stopSpawningEnemies()
    }
    
    func cameraDidShrink() {
        print("Câmera encolheu, despausando o jogo.")
        self.isPaused = false
        
        if isOnboarding {
            startOnboarding() // Inicia onboarding em vez de spawning normal
        } else {
            enemySpawner.startSpawningEnemies()
        }
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
        guard !isPaused else { return }
        print("🛑 PAUSANDO JOGO COMPLETAMENTE")
        enemySpawner.stopSpawningEnemies()
        gestureManager?.stopDetection()
        self.isPaused = true
        gestureManager?.removeCameraPreview()
        pauseOverlayComponent.show()
    }

    @objc func resumeGame() {
        guard isPaused else { return }
        print("▶️ RETOMANDO JOGO COMPLETAMENTE")
        gestureManager.startDetection()
        pauseOverlayComponent.hide()
        
        if DeviceHelper.isIPad {
            if let view = self.view {
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
            }
        }
        
        if !isOnGestureValidationMode && !isOnboarding {
            self.isPaused = false
            
            if gameState == .normalPlay {
                enemySpawner.startSpawningEnemies()
            }
        } else {
            return
        }
    }
    
    // MARK: - Funções do onboarding
    
    private func startOnboarding() {
        print("🎓 Iniciando onboarding...")
        onboardingState = .spawningEnemy
        currentOnboardingGestureIndex = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.spawnOnboardingEnemy()
        }
    }

    private func spawnOnboardingEnemy() {
        // Verifica se o índice atual está dentro da lista de gestos dos guardas
        if currentOnboardingGestureIndex < 2 {
            // --- Lógica para spawnar um GUARDA ---
            let currentGesture = onboardingGuardGestures[currentOnboardingGestureIndex]
            print("🎯 Spawning onboarding GUARD with gesture: \(currentGesture)")
            
            enemySpawner.spawnOnboardingGuard(withGesture: currentGesture) { [weak self] enemy in
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy)
                print("Current onboarding index: \(String(describing: self?.currentOnboardingGestureIndex))")
                print("OnboardingGuardGesture count: \(String(describing: self?.onboardingGuardGestures.count))")
            }
        }
        // Se já passamos por todos os guardas, é a vez do ladrão
        else if currentOnboardingGestureIndex >= 2 && currentOnboardingGestureIndex < 4 {
            // --- Lógica para spawnar o LADRÃO ---
            let currentFirstGesture: String
            let currentSecondGesture: String
            
            if currentOnboardingGestureIndex == 2 {
                currentFirstGesture = "OpenPalm"
                currentSecondGesture = "Top"
            } else {
                currentFirstGesture = "L"
                currentSecondGesture = "HangLose"
            }
            
            let currentGestures = [currentFirstGesture, currentSecondGesture]
            
            enemySpawner.spawnOnboardingThief(withGestures: currentGestures) { [weak self] enemy in
                // Usamos uma string especial "ThiefIntro" para acionar o diálogo correto
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy)
            }
        }
        // Se já passamos pelo ladrão, o onboarding acabou
        else {
            completeOnboarding()
        }
    }

    private func handleOnboardingEnemyReachedPosition(enemy: SKNode) {
        print("🛑 Enemy reached middle position, pausing and showing instruction")
        
        // Pausa o jogo SEM mostrar o overlay de pause
        self.isPaused = true
        
        // Mostra instrução visual
        showOnboardingInstruction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("⏰ Delay de 1.5s concluído. Agora esperando a ação do jogador.")
            self.onboardingState = .waitingForPlayerAction
        }
        
        self.gestureManager?.startDetection()
    }

    private func showOnboardingInstruction() {
        guard let view = self.view else { return }
        
        removeOnboardingInstruction()
        
        // Caixa da instrução
        
//        let instructionBox = UIView()
//        instructionBox.backgroundColor = UIColor.white
//        instructionBox.layer.cornerRadius = 8
//        instructionBox.layer.borderColor = UIColor.black.cgColor
//        instructionBox.layer.borderWidth = 4
//        instructionBox.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(instructionBox)
//        self.onboardingInstructionBox = instructionBox // Salva a referência
        
        let padding: CGFloat = 70       // Espaçamento da borda direita da tela
//        let boxSize: CGFloat = 200         // Largura e altura da CAIXA
//        let imageInternalPadding: CGFloat = 15 // Espaçamento da imagem DENTRO da caixa
//        
//        NSLayoutConstraint.activate([
//            instructionBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
//            instructionBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            instructionBox.widthAnchor.constraint(equalToConstant: boxSize),
//            instructionBox.heightAnchor.constraint(equalToConstant: boxSize)
//        ])
        
        // Caixa de diálogo
        
        let dialogueBox = UIView()
        dialogueBox.backgroundColor = UIColor.white
        dialogueBox.layer.cornerRadius = 10
        dialogueBox.layer.borderColor = UIColor.black.cgColor
        dialogueBox.layer.borderWidth = 4
        dialogueBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogueBox)
        self.onboardingDialogueBox = dialogueBox
        
        let dialogueBoxPadding: CGFloat = 20 // Padding das bordas da tela
        let dialogueBoxHeight: CGFloat = 200 // Altura da caixa de diálogo
        
        NSLayoutConstraint.activate([
            dialogueBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            dialogueBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            dialogueBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -dialogueBoxPadding),
            dialogueBox.heightAnchor.constraint(equalToConstant: dialogueBoxHeight)
        ])
        
        // Texto do diálogo
        
        let dialogueLabel = UILabel()
        let dialogueText = getDialogueLabelText()
        dialogueLabel.text = dialogueText
        dialogueLabel.textColor = .black
        dialogueLabel.font = UIFont(name: "Ari-W9500", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
        dialogueLabel.numberOfLines = 0 // Permite múltiplas linhas
        dialogueLabel.textAlignment = .center // Centraliza o texto
        dialogueLabel.translatesAutoresizingMaskIntoConstraints = false
        dialogueBox.addSubview(dialogueLabel) // Adiciona na caixa de diálogo, não na view principal
        self.onboardingDialogueLabel = dialogueLabel
        
        let labelPaddingX: CGFloat = 44 // Padding interno da label dentro da caixa
        let labelPaddingY: CGFloat = 30
        
        NSLayoutConstraint.activate([
            dialogueLabel.topAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: labelPaddingY),
            dialogueLabel.leadingAnchor.constraint(equalTo: dialogueBox.leadingAnchor, constant: labelPaddingX),
            dialogueLabel.trailingAnchor.constraint(equalTo: dialogueBox.trailingAnchor, constant: -labelPaddingX),
            dialogueLabel.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -labelPaddingY)
        ])
        
        // Instrução
        
        if currentOnboardingGestureIndex == 2 || currentOnboardingGestureIndex == 3 {
            let firstInstructionImageView = UIImageView()
            let secondInstructionImageView = UIImageView()
            let instructionImageNames = getInstructionImageName()
            
            firstInstructionImageView.image = UIImage(named: instructionImageNames[0])
            firstInstructionImageView.contentMode = .scaleAspectFit
            firstInstructionImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(firstInstructionImageView)
            
            secondInstructionImageView.image = UIImage(named: instructionImageNames[1])
            secondInstructionImageView.contentMode = .scaleAspectFit
            secondInstructionImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(secondInstructionImageView)
            
            let InstructionImageWidth: CGFloat = 170 // Largura do mago
            let InstructionImageHeight: CGFloat = 170 // Altura do mago
            let InstructionPaddingRight: CGFloat = 100  // Padding da esquerda
            
            self.onboardingThiefInstructionOverlay1 = firstInstructionImageView
            
            NSLayoutConstraint.activate([
                firstInstructionImageView.trailingAnchor.constraint(equalTo: secondInstructionImageView.leadingAnchor, constant: -5),
                firstInstructionImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                firstInstructionImageView.widthAnchor.constraint(equalToConstant: InstructionImageWidth),
                firstInstructionImageView.heightAnchor.constraint(equalToConstant: InstructionImageHeight)
            ])
            
            self.onboardingThiefInstructionOverlay2 = secondInstructionImageView
            
            NSLayoutConstraint.activate([
                secondInstructionImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -InstructionPaddingRight),
                secondInstructionImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                secondInstructionImageView.widthAnchor.constraint(equalToConstant: InstructionImageWidth),
                secondInstructionImageView.heightAnchor.constraint(equalToConstant: InstructionImageHeight)
            ])
            
        } else {
            let instructionImageView = UIImageView()
            let instructionImageName = getInstructionImageName()
            instructionImageView.image = UIImage(named: instructionImageName[0])
            instructionImageView.contentMode = .scaleAspectFit
            instructionImageView.translatesAutoresizingMaskIntoConstraints = false
            dialogueBox.addSubview(instructionImageView)
            self.onboardingGuardInstructionOverlay = instructionImageView
            
            let InstructionImageWidth: CGFloat = 170 // Largura do mago
            let InstructionImageHeight: CGFloat = 170 // Altura do mago
            let InstructionPaddingRight: CGFloat = 172  // Padding da esquerda
            
            NSLayoutConstraint.activate([
                instructionImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -InstructionPaddingRight),
                instructionImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                instructionImageView.widthAnchor.constraint(equalToConstant: InstructionImageWidth),
                instructionImageView.heightAnchor.constraint(equalToConstant: InstructionImageHeight)
            ])
        }
        
        // Sapo falando
        
        let frogImageView = UIImageView()
        let frogImageName = getFrogImageName()
        frogImageView.image = UIImage(named: frogImageName)
        frogImageView.contentMode = .scaleAspectFit
        frogImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frogImageView)
        self.onboardingFrogImageView = frogImageView
            
        let frogImageWidth: CGFloat = 300 // Largura do mago
        let frogImageHeight: CGFloat = 300 // Altura do mago
        let frogPaddingLeft: CGFloat = 90  // Padding da esquerda
        
        NSLayoutConstraint.activate([
            frogImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: frogPaddingLeft),
            frogImageView.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -dialogueBoxHeight),
            frogImageView.widthAnchor.constraint(equalToConstant: frogImageWidth),
            frogImageView.heightAnchor.constraint(equalToConstant: frogImageHeight)
        ])
        
        // Anima aparição dos elementos
//        instructionBox.alpha = 0
//        instructionImageView.alpha = 0
        frogImageView.alpha = 0
        dialogueBox.alpha = 0
        dialogueLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
//            instructionBox.alpha = 1.0
//            instructionImageView.alpha = 1.0
            frogImageView.alpha = 1.0
            dialogueBox.alpha = 1.0
            dialogueLabel.alpha = 1.0
        }
    }

    private func getInstructionImageName() -> [String] {
        switch currentOnboardingGestureIndex {
        case 0:
            return ["instruction_rock"]
        case 1:
            return ["instruction_two"]
        case 2:
            return ["instruction_openpalm", "instruction_top"]
        case 3:
            return ["instruction_l", "instruction_hanglose"]
        default:
            return ["instruction_default"]
        }
    }
    
    private func getFrogImageName() -> String {
        switch currentOnboardingGestureIndex {
        case 0:
            return "talking-frog"
        case 1:
            return "normal-frog"
        case 2:
            return "worried-frog"
        case 3:
            return "talking-frog2"
        case 4:
            return "enchanted-frog"
        default:
            return "talking-frog"
        }
    }
    
    private func getDialogueLabelText() -> String {
        switch currentOnboardingGestureIndex {
        case 0:
            return "Aí vem um guarda! Ele quer tomar o nosso livro mágico, faça o gesto que está na tela com sua mão para lançar uma magia nele!"
        case 1:
            return "Mais uma vez! Para derrotar cada guarda, imite o gesto da imagem em cima da sua cabeça."
        case 2:
            return "Cuidado... Agora vem um ladrão. Você precisa fazer cada um dos 2 gestos para derrotá-lo!"
        case 3:
            return "Derrote esse outro ladrão com o que você aprendeu!"
        case 4:
            return "Muito bem! Agora você está pronto para começar de verdade. Atenção nos gestos dos inimigos!"
        default:
            return "Faça o gesto para derrotar o guarda!"
        }
    }

    private func removeOnboardingInstruction() {
        let frogToRemove = self.onboardingFrogImageView
        let dialogueBoxToRemove = self.onboardingDialogueBox
        let guardInstructionToRemove = self.onboardingGuardInstructionOverlay
        let thiefInstructionToRemove1 = self.onboardingThiefInstructionOverlay1
        let thiefInstructionToRemove2 = self.onboardingThiefInstructionOverlay2
        
        self.onboardingGuardInstructionOverlay = nil
        self.onboardingThiefInstructionOverlay1 = nil
        self.onboardingThiefInstructionOverlay2 = nil
        self.onboardingFrogImageView = nil
        self.onboardingDialogueBox = nil
        self.onboardingDialogueLabel = nil

        UIView.animate(withDuration: 0.3, animations: {
            frogToRemove?.alpha = 0
            dialogueBoxToRemove?.alpha = 0
            guardInstructionToRemove?.alpha = 0
            thiefInstructionToRemove1?.alpha = 0
            thiefInstructionToRemove2?.alpha = 0
        }) { (finished) in
            guard finished else { return }
            frogToRemove?.removeFromSuperview()
            dialogueBoxToRemove?.removeFromSuperview()
            guardInstructionToRemove?.removeFromSuperview()
            thiefInstructionToRemove1?.removeFromSuperview()
            thiefInstructionToRemove2?.removeFromSuperview()
        }
    }

    private func handleOnboardingGestureSuccess() {
        print("✅ Player made correct gesture during onboarding!")
        
        self.isPaused = false
        
        if self.enemySpawner.hasActiveEnemies {
            print("Ladrão atingido, mas ainda vivo. O jogador pode fazer o segundo gesto agora.")
            self.onboardingState = .waitingForPlayerAction
        } else {
            removeOnboardingInstruction()
            onboardingState = .enemyKilled
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.proceedToNextOnboardingStep()
            }
        }
    }

    private func proceedToNextOnboardingStep() {
        currentOnboardingGestureIndex += 1
        
        if currentOnboardingGestureIndex <= 2 {
            onboardingState = .spawningEnemy
            spawnOnboardingEnemy()
        } else if currentOnboardingGestureIndex <= 4 {
            onboardingState = .spawningEnemy
            spawnOnboardingEnemy()
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        print("🎉 Onboarding completed! Showing final dialogue.")
        
        // 1. Limpa qualquer instrução anterior.
        removeOnboardingInstruction()
        
        // 2. Mostra o diálogo final.
        showOnboardingInstruction()
        
        // 3. Agenda o início do jogo para daqui a 3 segundos.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) { [weak self] in
            guard let self = self else { return }
            
            print("🚀 Starting the real game now!")
            
            // Remove a mensagem final
            self.removeOnboardingInstruction()
            
            // Move a câmera para a posição final
            if let view = self.view {
                self.gestureManager.moveCameraPreviewToNormalPosition(in: view)
            }
            
            // Atualiza as flags e a UI do jogo
            self.isOnboarding = false
            self.scoreComponent.scoreLabel.isHidden = false
            self.coinsComponent.coinsLabel.isHidden = false
            self.coinsComponent.coinIcon.isHidden = false
            self.pauseButtonComponent.pauseButtonNode.isHidden = false
            self.onboardingState = .completed
            
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            
            self.isPaused = false
            self.enemySpawner.startSpawningEnemies()
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
                    handleOnboardingGestureSuccess()
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
        if gameState == .normalPlay && scoreSinceLastBoss >= 5  { // Use 5 para testar
            print("--- PREPARANDO PARA O CHEFE! Limpando inimigos restantes... ---")
            
            // Não precisamos mais atualizar 'lastBossTriggerScore'.
            
            gameState = .clearingField
            
            mageControl = MageControl(scene: self, spawner: self.enemySpawner)
            mageControl?.startBossEncounter()
        }
    }
    
    func enterBossFightState() {
        print("A cena entrou no estado de Batalha do Chefe.")
        self.gameState = .bossFight
    }
    
    func bossFightDidEnd() {
        print("--- CHEFE DERROTADO! Retornando ao jogo normal. ---")
        self.scoreAtLastBossDefeat = self.scoreComponent.scoreCount
        
        mageControl = nil
        gameState = .normalPlay
        enemySpawner.startSpawningEnemies()
    }

    func makeGestureInValidation(gesture: String) {
        if !isPaused {
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
        } else {
            return
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
