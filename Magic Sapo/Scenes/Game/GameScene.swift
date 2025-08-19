//
//  GameScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0         // 0
    static let frog: UInt32 = 0b1        // 1
    static let enemy: UInt32 = 0b10       // 2
    // Adicione outras categorias aqui se precisar (ex: projétil, parede, etc)
}

// MARK: Essa bomba ta grande demais ja, tem que dar um jeito de diminuir

/// A cena principal do jogo, onde toda a ação acontece.
/// Esta classe atua como um "maestro", orquestrando os diferentes componentes
/// (placar, fundo, inimigos) e respondendo à entrada do jogador.
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Componentes
    
    private var isPlayerDead = false
    
    /// Gerencia a pontuação do jogador.
    var scoreComponent: ScoreComponent!
    
    /// Gerencia as moedas do jogador.
    var coinsComponent: CoinsComponent!
    
    /// Gerencia o fundo da cena.
    var backgroundComponent: BackgroundComponent!
    
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
        
        // --- Configuração dos Botões de Ação ---
        let rockButton = SKSpriteNode(imageNamed: "Rock")
        rockButton.name = "rockButton"
        rockButton.size = CGSize(width: 80, height: 80)
        rockButton.position = CGPoint(x: -200, y: -self.size.height/2 + 100)
        self.addChild(rockButton)
        
        let twoButton = SKSpriteNode(imageNamed: "Two")
        twoButton.name = "twoButton"
        twoButton.size = CGSize(width: 80, height: 80)
        twoButton.position = CGPoint(x: 200, y: -self.size.height/2 + 100)
        self.addChild(twoButton)
        
        let lButton = SKSpriteNode(imageNamed: "L")
        lButton.name = "lButton"
        lButton.size = CGSize(width: 80, height: 80)
        lButton.position = CGPoint(x: -300, y: -self.size.height/2 + 100)
        self.addChild(lButton)
        
        let hangLButton = SKSpriteNode(imageNamed: "HangLoose")
        hangLButton.name = "hangLButton"
        hangLButton.size = CGSize(width: 80, height: 80)
        hangLButton.position = CGPoint(x: 300, y: -self.size.height/2 + 100)
        self.addChild(hangLButton)
        
        let openPButton = SKSpriteNode(imageNamed: "OpenPalm")
        openPButton.name = "openPButton"
        openPButton.size = CGSize(width: 80, height: 80)
        openPButton.position = CGPoint(x: 400, y: -self.size.height/2 + 100)
        self.addChild(openPButton)
        
        
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
        // Esta é a parte mais importante da solução.
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
            // Opcional: Você pode adicionar um pequeno delay para o jogador ver o que aconteceu.
            let waitAction = SKAction.wait(forDuration: 0.1)
            let transitionAction = SKAction.run {
                if let gameOverScene = SKScene(fileNamed: "GameOverScene") as? GameOverScene {
                    gameOverScene.scaleMode = .aspectFill
                    gameOverScene.finalScore = self.scoreComponent.scoreCount
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
        enemySpawner.stopSpawningEnemies()
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
                playerDidMake(gesture: "HangLoose")
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
