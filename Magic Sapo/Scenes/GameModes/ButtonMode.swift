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
    
    var scoreComponent: ScoreComponent!
    var coinsComponent: CoinsComponent!
    var backgroundComponent: BackgroundComponent!
    var pauseButtonComponent: PauseButtonComponent!
    var enemySpawner: EnemySpawner!
    
    private var gameState: GameState = .normalPlay
    private var mageControl: MageControl?
    private var scoreAtLastBossDefeat = 0
    var pauseOverlayComponent: PauseOverlayComponent!
    
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
        print("Configurando a ButtonScene pela primeira vez.")
        
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
        
        // <-- CORREÇÃO 3: Inicializar o novo componente
        pauseOverlayComponent = PauseOverlayComponent(parent: self)
        pauseOverlayComponent.delegate = self
        
        enemySpawner = EnemySpawner(scene: self)
        enemySpawner.startSpawningEnemies()
        
        let frog = Frog(parent: self)
        let frogNode = frog.createNode(at: CGPoint(x: -30, y: -self.size.height/2 + 150))
        self.addChild(frogNode)
        
        // (O código dos botões de gestos permanece o mesmo)
        let rockButton = SKSpriteNode(imageNamed: "Rock")
        rockButton.name = "rockButton"; rockButton.size = CGSize(width: 80, height: 80); rockButton.position = CGPoint(x: -200, y: -self.size.height/2 + 100); self.addChild(rockButton)
        let twoButton = SKSpriteNode(imageNamed: "Two")
        twoButton.name = "twoButton"; twoButton.size = CGSize(width: 80, height: 80); twoButton.position = CGPoint(x: 200, y: -self.size.height/2 + 100); self.addChild(twoButton)
        let lButton = SKSpriteNode(imageNamed: "L")
        lButton.name = "lButton"; lButton.size = CGSize(width: 80, height: 80); lButton.position = CGPoint(x: -300, y: -self.size.height/2 + 100); self.addChild(lButton)
        let hangLButton = SKSpriteNode(imageNamed: "HangLose")
        hangLButton.name = "hangLButton"; hangLButton.size = CGSize(width: 80, height: 80); hangLButton.position = CGPoint(x: 300, y: -self.size.height/2 + 100); self.addChild(hangLButton)
        let openPButton = SKSpriteNode(imageNamed: "OpenPalm")
        openPButton.name = "openPButton"; openPButton.size = CGSize(width: 80, height: 80); openPButton.position = CGPoint(x: 400, y: -self.size.height/2 + 100); self.addChild(openPButton)
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
    
    // (Lógica de contato, movimento e do jogo permanece a mesma)
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
                     gameOverScene.previousSceneName = "ButtonMode"
                     
                     let transition = SKTransition.fade(withDuration: 1.0)
                     self.view?.presentScene(gameOverScene, transition: transition)
                 }
             }
             
             // Roda a sequência: espera um pouco e depois faz a transição.
             self.run(SKAction.sequence([waitAction, transitionAction]))
         }
     }
    
    
    /// Método chamado pouco antes da cena ser removida da tela (ex: ao pausar o jogo).
    /// É o lugar ideal para "limpar" a cena e parar processos contínuos.
    override func willMove(from view: SKView) {
        
        // Para a criação de inimigos para evitar que o timer continue rodando
        // em uma cena que não está mais visível, o que causaria um crash.
        // MARK: Ta com bug quando desliga o Ipad (continua gerando inimigos)
        enemySpawner.stopSpawningEnemies()
    }
    
    func playerDidMake(gesture: String) {
        // A variável "rewards" agora é uma tupla: (points: Int, coins: Int)
//        if let rewards = enemySpawner.killEnemy(withGesture: gesture) {
//            
//            // Tenta matar um inimigo com o gesto.
//            // A função killEnemy retorna os pontos e moedas ganhos se um inimigo for morto.
//            // Acessamos os valores usando .points e .coins
//            scoreComponent.addScore(point: rewards.points)
//            coinsComponent.addCoins(coins: rewards.coins)
//            
//            // Pede ao spawner para atualizar a velocidade dos inimigos
//            // com base na nova pontuação total.
//            enemySpawner.updateEnemySpeed(basedOn: scoreComponent.scoreCount)
//
//            print("Ganhou \(rewards.coins) moedas!")
//        }else {
//            // --- LÓGICA DE PENALIDADE ATUALIZADA ---
//            // ERRO: O gesto não acertou nenhum inimigo válido.
//            // Verificamos se a jogada veio de um botão antes de aplicar a penalidade.
//            // SÓ aplica a penalidade se a pontuação for maior que 0.
//            if scoreComponent.scoreCount > 0 {
//                print("Gesto errado com botão! Aplicando penalidade.")
//                scoreComponent.decreaseScore(point: 1)
//            } else {
//                print("Gesto errado com botão, mas a pontuação já é 0. Nenhuma penalidade aplicada.")
//            }
//        }
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
                        
                    } else {
                        if scoreComponent.scoreCount > 0 {
                            print("Gesto errado com botão! Aplicando penalidade.")
                            scoreComponent.decreaseScore(point: 1)
                        } else {
                            print("Gesto errado com botão, mas a pontuação já é 0. Nenhuma penalidade aplicada.")
                        }
                    }
                }
                
                // Após cada jogada, verifica se é hora de iniciar a luta do chefe
        checkToStartBossEncounter()
    }
    
    private func checkToStartBossEncounter() {
           let score = scoreComponent.scoreCount
           
           // Se as condições forem atendidas, muda para o estado de LIMPEZA.
            let scoreSinceLastBoss = score - scoreAtLastBossDefeat
                
            // A condição agora é muito mais simples e robusta.
            if gameState == .normalPlay && scoreSinceLastBoss >= 75 { // Use 5 para testar
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
            return
        }
        
        if touchedNode.name == "rockButton" { playerDidMake(gesture: "Rock") }
        if touchedNode.name == "twoButton" { playerDidMake(gesture: "Two") }
        if touchedNode.name == "lButton" { playerDidMake(gesture: "L") }
        if touchedNode.name == "hangLButton" { playerDidMake(gesture: "HangLose") }
        if touchedNode.name == "openPButton" { playerDidMake(gesture: "OpenPalm") }
    }
    
    // MARK: - Delegates
    
    func didTapPauseButton() {
        print("Botão Pausar foi tocado na ButtonScene! (via Delegate)")
        self.pauseGame()
    }
    
    func didTapResumeButton() {
        resumeGame()
    }
    
    func didTapResetButton() {
        if let newButtonScene = SKScene(fileNamed: "ButtonMode") as? ButtonScene {
            newButtonScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newButtonScene, transition: transition)
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
        print("ButtonScene está sendo removida, limpando os observers.")
        NotificationCenter.default.removeObserver(self)
    }
}
