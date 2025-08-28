//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

// MARK: Essa bomba ta grande demais ja, tem que dar um jeito de diminuir

/// A cena principal do jogo, onde toda a ação acontece.
/// Esta classe atua como um "maestro", orquestrando os diferentes componentes
/// (placar, fundo, inimigos) e respondendo à entrada do jogador.
class GameScene: SKScene, SKPhysicsContactDelegate, GestureDetectionDelegate, ScoreHavingScene {
    
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
    
    private var instructionLabel: UILabel?
    private var countdownLabel: UILabel?
    
    var startInGestureMode = false
    // MARK: - Componentes
    
    private var isPlayerDead = false
    
    /// Gerencia a pontuação do jogador.
    var scoreComponent: ScoreComponent!
    
    /// Gerencia as moedas do jogador.
    var coinsComponent: CoinsComponent!
    
    /// Gerencia o fundo da cena.
    var backgroundComponent: BackgroundComponent!
    
    var gestureManager: GestureDetectionManager!
    
    private var cameraPreviewNode: SKEffectNode!
    
    // NOVA PROPRIEDADE - para debug (opcional)
    private var gestureDebugLabel: SKLabelNode?
    
    /// Gerencia a criação e as ações dos inimigos.
    var enemySpawner: EnemySpawner!
    
    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
      }
    //    Flag para controlar a inicialização da cena.
    private var sceneIsInitialized = false
    
    private var pauseOverlay: SKNode?
    
    // MARK: - Ciclo de Vida da Cena
    
    /// Método chamado uma única vez quando a cena é apresentada na tela.
    /// Essa func so serve pra configuracao inicial
    override func didMove(to view: SKView) {
        
        // Este método é chamado toda vez que a cena é apresentada.
        // Nós só queremos configurar tudo na primeira vez.
        if !sceneIsInitialized {
            setupScene()
            sceneIsInitialized = true
        }
    }
    
    private func setupScene() {
        print("Configurando a GameScene pela primeira vez.")
        
        // --- Adiciona os Observers ---
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: NSNotification.Name("AppDidBecomeActive"), object: nil)
        
        // --- Mundo da Física ---
        self.physicsWorld.contactDelegate = self
        
        // --- Configuração dos Componentes ---
        backgroundComponent = BackgroundComponent(parent: self)
        backgroundComponent.setupAnimatedBackground()
        
        scoreComponent = ScoreComponent(parent: self)
        coinsComponent = CoinsComponent(parent: self)
        
        // --- Spawner de Inimigos ---
        enemySpawner = EnemySpawner(scene: self)
        enemySpawner.startSpawningEnemies()
        
        // --- Configuração do Jogador (Sapo) ---
        let frog = Frog(parent: self)
        let frogNode = frog.createNode(at: CGPoint(x: -30, y: -self.size.height/2 + 150))
        self.addChild(frogNode)

        // Configurar detecção de gestos
        setupGestureDetection()
        
        // Setup camera preview
        if let view = self.view {
            self.gestureManager.setupCameraPreview(in: view)
        }
        
        // Opcional: Label para debug dos gestos
        setupGestureDebugUI()
        
        setupCountdownLabel()
        setupInstructionLabel()
        
        let pauseButton = SKSpriteNode(imageNamed: "PauseButton") // Certifique-se de que "PauseButton" exista nos seus Assets.
        pauseButton.name = "PauseButton"
        pauseButton.size = CGSize(width: 100, height: 100)
        pauseButton.position = CGPoint(x: self.size.width / 2 - 70, y: self.size.height / 2 - 70)
        
        pauseButton.zPosition = 50 // Garante que ele fique acima de outros elementos da UI, se houver.
        self.addChild(pauseButton)
        
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
            gestureManager?.expandCameraPreviewToFullScreen(in: view)
            
            // 2. Prepara o timer.
            countdownLabel?.text = "3"
            countdownLabel?.isHidden = false
            instructionLabel?.isHidden = false
            var countdown = 3
            
            // 3. Define a ação que será repetida a cada segundo.
            let updateAction = SKAction.run { [weak self] in
                countdown -= 1
                self?.countdownLabel?.text = "\(countdown)"
            }
            
            // Ação de esperar 1 segundo.
            let waitAction = SKAction.wait(forDuration: 1.0)
            
            // Combina a espera e a atualização em uma única ação.
            let sequencePerSecond = SKAction.sequence([waitAction, updateAction])
            
            // Repete a sequência 2 vezes (para contar 2 e 1).
            let countdownSequence = SKAction.repeat(sequencePerSecond, count: 3)
            
            // 4. Define as ações finais após o timer.
            let finalActions = SKAction.run { [weak self] in
                guard let self = self, let view = self.view else { return }
                print("Passaram 5 segundos. Retornando a câmera para a posição original.")
                
                // Esconde o label do timer.
                self.countdownLabel?.isHidden = true
                self.instructionLabel?.isHidden = true
                
                // Chama a função para encolher a câmera.
                self.gestureManager?.shrinkCameraPreviewToOriginal(in: view)
            }
            
            // 5. Executa a sequência completa na cena.
            // A lógica é: Roda a contagem (de 3 para 2, de 2 para 1), espera o último segundo,
            // e então executa as ações finais.
            self.run(SKAction.sequence([countdownSequence, waitAction, finalActions]))
        }
    
    private func setupGestureDetection() {
        gestureManager = GestureDetectionManager()
        gestureManager.delegate = self
        gestureManager.startDetection()
    }
    
    // VERSÃO ADAPTATIVA do setup de debug UI
    private func setupGestureDebugUI() {
        gestureDebugLabel = SKLabelNode(fontNamed: "Arial-Bold")
        gestureDebugLabel?.fontSize = DeviceHelper.isIPhone ? 16 : 20
        gestureDebugLabel?.fontColor = .yellow
        let topOffset: CGFloat = DeviceHelper.isIPhone ? 80 : 100
        gestureDebugLabel?.position = CGPoint(x: 0, y: self.size.height/3 - topOffset)
        gestureDebugLabel?.text = "Gesto: Nenhum"
        
        if let label = gestureDebugLabel {
            addChild(label)
        }
    }
        
    func gestureDetected(_ gesture: String, confidence: Double) {
        // Atualizar label de debug
        gestureDebugLabel?.text = "Gesto: \(gesture) (\(Int(confidence * 100))%)"
        
        // AQUI É ONDE A MÁGICA ACONTECE - chama o método que já existe!
        playerDidMake(gesture: gesture)
    }
    
    func gestureDetectionLost() {
        gestureDebugLabel?.text = "Gesto: Nenhum"
    }
    
    @objc func pauseGame() {
        // 1. Garante que o jogo não está pausado e que a camada de pausa não existe
        guard !isPaused else { return }
        
        print("🛑 PAUSANDO JOGO COMPLETAMENTE")
        
        // 2. Para a criação de novos inimigos
        enemySpawner.stopSpawningEnemies()
        
        // 3. Pausa a cena inteira. Isso congela TODAS as ações e a física.
        // A ordem aqui é crucial. Pausar a cena primeiro garante que nada se mova
        // enquanto você constrói a tela de pausa.
        self.isPaused = true
        
        // 4. Cria e mostra a camada de pausa (o menu)
        createPauseOverlay()
    }

    /// Retoma o jogo.
    @objc func resumeGame() {
        // 1. Garante que o jogo está realmente pausado
        guard isPaused else { return }
        
        print("▶️ RETOMANDO JOGO COMPLETAMENTE")
        
        // 2. Remove a camada de pausa da tela
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
        
        // 3. Despausa a cena
        self.isPaused = false
        
        // 4. Retoma o spawn de novos inimigos
        enemySpawner.startSpawningEnemies()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1. VERIFICA A TRAVA: Se o jogador já morreu, não faz mais nada.
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
            
            // 2. ATIVA A TRAVA: Impede que esta lógica seja executada novamente.
            isPlayerDead = true
            
            // 3. EXECUTA A LÓGICA DE GAME OVER (agora de forma segura)
            let waitAction = SKAction.wait(forDuration: 0.1)
            let transitionAction = SKAction.run {
                if let gameOverScene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
                    gameOverScene.scaleMode = .aspectFill
                    gameOverScene.finalScore = self.scoreComponent.scoreCount
                    
                    // --- LINHA ADICIONADA ---
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
    
      func didEnd(_ contact: SKPhysicsContact) {
        //Acabou o contato
      }
    
    /// Método chamado pouco antes da cena ser removida da tela (ex: ao pausar o jogo).
    /// É o lugar ideal para "limpar" a cena e parar processos contínuos.
    override func willMove(from view: SKView) {
        
        // Para a criação de inimigos para evitar que o timer continue rodando
        // em uma cena que não está mais visível, o que causaria um crash.
        // MARK: Ta com bug quando desliga o Ipad (continua gerando inimigos)
        enemySpawner?.stopSpawningEnemies()
        gestureManager?.stopDetection()
        gestureManager?.removeCameraPreview()
    }
    
    // MARK: - Lógica do Jogo
    
    /// Processa a ação do jogador após fazer um gesto.
    /// - Parameter gesture: A string que representa o gesto feito (ex: "Rock").
    
    func playerDidMake(gesture: String) {
        // A variável "rewards" agora é uma tupla: (points: Int, coins: Int)
        if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
            
            // Tenta matar um inimigo com o gesto.
            // A função killEnemy retorna os pontos e moedas ganhos se um inimigo for morto.
            // Acessamos os valores usando .points e .coins
            scoreComponent.addScore(point: rewards.points)
            coinsComponent.addCoins(coins: rewards.coins)
            
            // Pede ao spawner para atualizar a velocidade dos inimigos
            // com base na nova pontuação total.
            enemySpawner.updateEnemySpeed(basedOn: scoreComponent.scoreCount)

            print("Ganhou \(rewards.coins) moedas!")
        }
    }
    
    // MARK: - Entrada do Usuário
    
    /// Método chamado sempre que o jogador toca na tela.
    // MARK: To usando pros botoes de matar e pause, mas no futuro vai usar so pro pause
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            // --- LÓGICA DE PAUSA ---
            // Se o jogo está pausado, apenas os botões do menu de pausa devem funcionar.
            if isPaused {
                
                // Se o botão "Retomar" for tocado...
                if touchedNode.name == "ReturnButton" {
                    resumeGame()
                }
                
                // Se o botão "Reiniciar" for tocado
                if touchedNode.name == "ResetButton" {
                    // Cria e apresenta uma cena de jogo totalmente nova
                    if let newGameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                        newGameScene.scaleMode = .aspectFill
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view?.presentScene(newGameScene, transition: transition)
                    }
                }
                
                // Se o botão "Sair" for tocado
                if touchedNode.name == "ExitButton" {
                    // Carrega a MenuScene
                    if let menuScene = SKScene(fileNamed: "MenuScene") {
                        menuScene.scaleMode = .aspectFill
                        let transition = SKTransition.fade(withDuration: 1.0)
                        view?.presentScene(menuScene, transition: transition)
                    }
                }
                
                // Importante: Sai da função para não processar toques do jogo (como atacar)
                return
            }

            // --- LÓGICA DO JOGO (só executa se o jogo NÃO estiver pausado) ---
            
            // Se o botão de Pausa do jogo (que fica na HUD) for tocado
            if touchedNode.name == "PauseButton" {
                print("Botão Pausar foi tocado!")
                self.pauseGame()
            }
            
            // Se o botão "Rock" foi tocado
            if touchedNode.name == "rockButton" {
                playerDidMake(gesture: "Rock")
            }
            
            // Se o botão "Two" foi tocado
            if touchedNode.name == "twoButton" {
                playerDidMake(gesture: "Two")
            }
        
            // Se o botão "L" foi tocado
            if touchedNode.name == "lButton" {
                playerDidMake(gesture: "L")
            }
        
            if touchedNode.name == "hangLButton"{
                playerDidMake(gesture: "HangLose")
            }
        
            if touchedNode.name == "openPButton"{
                playerDidMake(gesture: "OpenPalm")
            }

    
        }
    
        // Cria os nós que compõem o menu de pausa e os adiciona à cena.
            private func createPauseOverlay() {
                // Cria um nó pai para todos os elementos do menu
                pauseOverlay = SKNode()
                pauseOverlay?.zPosition = 100 // Garante que fique na frente de tudo
                
                // Cria um fundo semitransparente para escurecer o jogo
                let background = SKSpriteNode(color: .black, size: self.size)
                background.alpha = 0.7
                pauseOverlay?.addChild(background)
                
                // Adiciona os botões (você pode carregar suas imagens aqui)
                let resumeButton = SKLabelNode(text: "Retomar")
                resumeButton.name = "ReturnButton" // Usamos o mesmo nome da sua PauseScene
                resumeButton.fontName = "Helvetica-Bold"
                resumeButton.fontSize = 50
                resumeButton.position = CGPoint(x: 0, y: 100)
                pauseOverlay?.addChild(resumeButton)
                
                let resetButton = SKLabelNode(text: "Reiniciar")
                resetButton.name = "ResetButton"
                resetButton.fontName = "Helvetica-Bold"
                resetButton.fontSize = 50
                resetButton.position = CGPoint(x: 0, y: 0)
                pauseOverlay?.addChild(resetButton)
                
                let exitButton = SKLabelNode(text: "Sair")
                exitButton.name = "ExitButton"
                exitButton.fontName = "Helvetica-Bold"
                exitButton.fontSize = 50
                exitButton.position = CGPoint(x: 0, y: -100)
                pauseOverlay?.addChild(exitButton)
                
                // Adiciona a camada completa na cena
                if let overlay = pauseOverlay {
                    self.addChild(overlay)
                }
            }
        
        // Este método é chamado quando a cena é removida da memória.
        deinit {
            print("GameScene está sendo removida, limpando os observers.")
            // Remove todos os observers associados a esta cena para evitar vazamentos de memória.
            NotificationCenter.default.removeObserver(self)
        }
}
