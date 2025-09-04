//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, GestureDetectionDelegate, ScoreHavingScene, PauseButtonDelegate, PauseOverlayDelegate, BossFightScene{
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    // MARK: VARIAVEL PARA TESTE
//    var isOnboarding = true
    
    private var onboardingState: OnboardingState = .inactive
    private var currentOnboardingGestureIndex = 0
    
    private var onboardingInstructionOverlay: UIImageView?
    private var onboardingInstructionBox: UIView?
    private var onboardingFrogImageView: UIImageView?
    private var onboardingDialogueBox: UIView?
    private var onboardingDialogueLabel: UILabel?
    
    private let onboardingGuardGestures = ["Rock", "Two", "L", "HangLose"]
    private let onboardingThiefGestures = ["OpenPalm", "Top"]

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

//        if DeviceHelper.isIPad {
            if let view = self.view {
                self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
            }
            
            if startInGestureMode {
                setupInstructionLabel()
                setupCountdownLabel()
                enterGestureValidationMode()
            }
//        }

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
    
    // MARK: - Parte do código que to mexendo
    
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
        
        if let view = self.view {
            self.gestureManager.setupCameraPreview(in: view, duringOnboarding: isOnboarding)
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
    
    private func startOnboarding() {
        print("🎓 Iniciando onboarding...")
        onboardingState = .spawningEnemy
        currentOnboardingGestureIndex = 0
        spawnOnboardingEnemy()
    }

    private func spawnOnboardingEnemy() {
        // Verifica se o índice atual está dentro da lista de gestos dos guardas
        if currentOnboardingGestureIndex < onboardingGuardGestures.count {
            // --- Lógica para spawnar um GUARDA ---
            let currentGesture = onboardingGuardGestures[currentOnboardingGestureIndex]
            print("🎯 Spawning onboarding GUARD with gesture: \(currentGesture)")
            
            enemySpawner.spawnOnboardingGuard(withGesture: currentGesture) { [weak self] enemy in
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy, gesture: currentGesture)
                print("Current onboarding index: \(String(describing: self?.currentOnboardingGestureIndex))")
                print("OnboardingGuardGesture count: \(String(describing: self?.onboardingGuardGestures.count))")
            }
        }
        // Se já passamos por todos os guardas, é a vez do ladrão
        else if currentOnboardingGestureIndex == onboardingGuardGestures.count {
            // --- Lógica para spawnar o LADRÃO ---
            print("🎯 Spawning onboarding THIEF with gestures: \(onboardingThiefGestures)")
            
            enemySpawner.spawnOnboardingThief(withGestures: onboardingThiefGestures) { [weak self] enemy in
                // Usamos uma string especial "ThiefIntro" para acionar o diálogo correto
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy, gesture: "ThiefIntro")
            }
        }
        // Se já passamos pelo ladrão, o onboarding acabou
        else {
            completeOnboarding()
        }
    }

    private func handleOnboardingEnemyReachedPosition(enemy: SKNode, gesture: String) {
        print("🛑 Enemy reached middle position, pausing and showing instruction")
        
        // Pausa o jogo SEM mostrar o overlay de pause
        self.isPaused = true
        
        // Mostra instrução visual
        showOnboardingInstruction(for: gesture)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("⏰ Delay de 1.5s concluído. Agora esperando a ação do jogador.")
            self.onboardingState = .waitingForPlayerAction
        }
        
        self.gestureManager?.startDetection()
    }

    private func showOnboardingInstruction(for gesture: String) {
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
//        
        let padding: CGFloat = 70       // Espaçamento da borda direita da tela
//        let boxSize: CGFloat = 200         // Largura e altura da CAIXA
//        let imageInternalPadding: CGFloat = 15 // Espaçamento da imagem DENTRO da caixa
//        
//        NSLayoutConstraint.activate([
//            instructionBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -boxPadding),
//            instructionBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            instructionBox.widthAnchor.constraint(equalToConstant: boxSize),
//            instructionBox.heightAnchor.constraint(equalToConstant: boxSize)
//        ])
        
        // Instrução
        
//        let instructionImageView = UIImageView()
//        let instructionImageName = getInstructionImageName(for: gesture)
//        instructionImageView.image = UIImage(named: instructionImageName)
//        instructionImageView.contentMode = .scaleAspectFit
//        instructionImageView.translatesAutoresizingMaskIntoConstraints = false
//        instructionBox.addSubview(instructionImageView)
//        self.onboardingInstructionOverlay = instructionImageView
//        
//        NSLayoutConstraint.activate([
//            instructionImageView.topAnchor.constraint(equalTo: instructionBox.topAnchor, constant: imageInternalPadding),
//            instructionImageView.bottomAnchor.constraint(equalTo: instructionBox.bottomAnchor, constant: -imageInternalPadding),
//            instructionImageView.leadingAnchor.constraint(equalTo: instructionBox.leadingAnchor, constant: imageInternalPadding),
//            instructionImageView.trailingAnchor.constraint(equalTo: instructionBox.trailingAnchor, constant: -imageInternalPadding)
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
        
        // Sapo falando
        
        let frogImageView = UIImageView()
        let frogImageName = getFrogImageName(for: gesture)
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
        
        // Texto do diálogo
        
        let dialogueLabel = UILabel()
        let dialogueText = getDialogueLabelText(for: gesture)
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

    private func getInstructionImageName(for gesture: String) -> String {
        switch gesture {
        case "Two":
            return "instruction_two"
        case "Rock":
            return "instruction_rock"
        case "L":
            return "instruction_l"
        case "OpenPalm":
            return "instruction_openpalm"
        case "HangLose":
            return "instruction_hanglose"
        case "Top":
            return "instruction_top"
        default:
            return "instruction_default"
        }
    }
    
    private func getFrogImageName(for gesture: String) -> String {
        switch gesture {
        case "Rock":
            return "talking-frog"
        case "Two":
            return "talking-frog2"
        case "L":
            return "normal-frog"
        case "HangLose":
            return "enchanted-frog"
        case "ThiefIntro":
            return "worried-frog"
        case "Completed":
            return "enchanted-frog"
        default:
            return "talking-frog"
        }
    }
    
    private func getDialogueLabelText(for gesture: String) -> String {
        switch gesture {
        case "Rock":
            return "Aí vem um guarda! Ele quer tomar o nosso livro mágico, faça o gesto que está na tela com sua mão para lançar uma magia nele!"
        case "Two":
            return "Para derrotar cada guarda, imite o gesto da imagem em sua cabeça!"
        case "L":
            return "Mais um! Só que agora o gesto é diferente!"
        case "HangLose":
            return "Você está ficando bom nisso! Vença esse outro também."
        case "ThiefIntro":
            return "Cuidado... Agora vem um ladrão. Você precisa fazer 2 gestos para derrotá-lo!"
        case "Completed":
            return "Muito bem! Agora você está pronto para começar de verdade. Se defenda como eu te ensinei!"
        default:
            return "Faça o gesto para derrotar o guarda!"
        }
    }

    private func removeOnboardingInstruction() {
        onboardingInstructionBox?.removeFromSuperview()
        onboardingInstructionBox = nil
        
        onboardingInstructionOverlay?.removeFromSuperview()
        onboardingInstructionOverlay = nil
        
        onboardingFrogImageView?.removeFromSuperview()
        onboardingFrogImageView = nil
        
        onboardingDialogueBox?.removeFromSuperview()
        onboardingDialogueBox = nil
        
        onboardingDialogueLabel?.removeFromSuperview()
        onboardingDialogueLabel = nil
    }

    private func handleOnboardingGestureSuccess() {
        print("✅ Player made correct gesture during onboarding!")
        
        // Remove instrução
        removeOnboardingInstruction()
        
        // Despausa jogo para permitir animação de morte
        self.isPaused = false
        
        // Atualiza estado
        onboardingState = .enemyKilled
        
        // Aguarda animação de morte, depois próximo passo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // --- LÓGICA ALTERADA ---
            // Verificamos se ainda existem inimigos ativos na tela.
            // O spawner tem uma propriedade `hasActiveEnemies` para isso.
            if self.enemySpawner.hasActiveEnemies {
                // Se SIM, significa que era o Ladrão e ele ainda está vivo.
                    print("Ladrão atingido, mas ainda vivo. O jogador pode fazer o segundo gesto agora.")
                    self.onboardingState = .waitingForPlayerAction
            } else {
                // Se NÃO, significa que o inimigo (Guarda ou Ladrão no 2º hit) foi derrotado.
                // Então, podemos prosseguir para o próximo passo.
                self.proceedToNextOnboardingStep()
            }
        }
    }

    private func proceedToNextOnboardingStep() {
        currentOnboardingGestureIndex += 1
        
        if currentOnboardingGestureIndex <= onboardingGuardGestures.count {
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
        showOnboardingInstruction(for: "Completed")
        
        // 3. Agenda o início do jogo para daqui a 3 segundos.
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
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
