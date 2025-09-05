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
        
        AudioManager.shared.setSoundEffectVolume(to: 0.5)
        
        let stopMusicAction = SKAction.run {
            AudioManager.shared.stopBackgroundMusic(fadeOutDuration: 1.0) // Duração do fade
        }


        let waitAction = SKAction.wait(forDuration: 0.5) // Seu timer de 1.5 segundos

        let playMusicAction = SKAction.run {
            AudioManager.shared.playBackgroundMusic(filename: "croak-music.m4a")
        }


        let musicSequence = SKAction.sequence([stopMusicAction, waitAction, playMusicAction])
        self.run(musicSequence) // 'self' aqui é a sua cena (GameScene, etc.)
    }
    
    private func setupScene() {
        print("Configurando a ButtonScene pela primeira vez.")
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("AppDidBecomeActive"), object: nil)

        
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
        
        // --- MUDANÇA: Tamanho e posição dos botões agora são adaptativos ---
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
        self.addChild(rockButton)
        
        let twoButton = SKSpriteNode(imageNamed: "Two")
        twoButton.name = "twoButton"
        twoButton.size = buttonSize
        twoButton.position = CGPoint(x: twoX, y: buttonYPosition)
        self.addChild(twoButton)
        
        let topButton = SKSpriteNode(imageNamed: "Top")
        topButton.name = "TopButton"
        topButton.size = buttonSize
        topButton.position = CGPoint(x: topX, y: openPBY)
        self.addChild(topButton)
        
        let lButton = SKSpriteNode(imageNamed: "L")
        lButton.name = "lButton"
        lButton.size = buttonSize
        lButton.position = CGPoint(x: lX, y: buttonYPosition)
        self.addChild(lButton)
        
        let hangLButton = SKSpriteNode(imageNamed: "HangLose")
        hangLButton.name = "hangLButton"
        hangLButton.size = buttonSize
        hangLButton.position = CGPoint(x: hangLX, y: buttonYPosition)
        self.addChild(hangLButton)
        
        let openPButton = SKSpriteNode(imageNamed: "OpenPalm")
        openPButton.name = "openPButton"
        openPButton.size = buttonSize
        openPButton.position = CGPoint(x: openPX, y: openPBY)
        self.addChild(openPButton)
    }
    
    // Em ButtonScene.swift, substitua as funções antigas por estas

    // Em ButtonScene.swift

    @objc func pauseGame() {
        // A partir de agora, a "fonte da verdade" sobre a pausa será a VIEW, não a CENA.
        if self.view?.isPaused ?? false {
            return
        }
        
        print("🛑 PAUSANDO JOGO COMPLETAMENTE")

        // 1. Mostra o overlay primeiro.
        pauseOverlayComponent.show()
        
        // 2. Para sistemas que não são controlados pela pausa da cena (como timers).
        enemySpawner.stopSpawningEnemies()
        AudioManager.shared.pauseBackgroundMusic()

        // 3. A MÁGICA: Executa a pausa da VIEW no próximo quadro.
        // Isso dá tempo para o `show()` ser renderizado na tela.
        let wait = SKAction.wait(forDuration: 0) // Espera de 0 segundos = próximo quadro.
        let pauseAction = SKAction.run { [weak self] in
            self?.view?.isPaused = true
        }
        
        // A cena ainda não está pausada, então ela pode rodar esta ação.
        self.run(SKAction.sequence([wait, pauseAction]))
    }


    @objc func resumeGame() {
        // Se a VIEW não está pausada, não há o que resumir.
        guard self.view?.isPaused ?? false else { return }
        
        print("▶️ RETOMANDO JOGO COMPLETAMENTE")

        // 1. DESPAUSA A VIEW PRIMEIRO. Isso "acorda" o motor de renderização.
        self.view?.isPaused = false
        
        // 2. Agora que a tela não está mais congelada, removemos o menu.
        pauseOverlayComponent.hide()
        
        // 3. Reiniciamos a música e os inimigos.
        AudioManager.shared.resumeBackgroundMusic()
        if gameState == .normalPlay {
            enemySpawner.startSpawningEnemies()
        }
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
             
               AudioManager.shared.stopBackgroundMusic()
               
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
           if gameState == .normalPlay && scoreSinceLastBoss >= 25 { // Use 5 para testar
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

        // --- CORREÇÃO AQUI ---
        // Verificamos se a VIEW está pausada. Se estiver, o toque é para o menu.
        if self.view?.isPaused ?? false {
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
        print("Botão Pausar foi tocado na ButtonScene! (via Delegate)")
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
        self.pauseGame()
    }
    
    func didTapResumeButton() {
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
        resumeGame()
    }
    
    func didTapResetButton() {
<<<<<<< HEAD
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
=======
        self.view?.isPaused = false
>>>>>>> 09e1ce81f719259f3ab25f2534f064d1310d4d31
        
        if let newButtonScene = SKScene(fileNamed: "ButtonMode") as? ButtonScene {
            newButtonScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(newButtonScene, transition: transition)
        }
    }
     
    func didTapExitButton() {
<<<<<<< HEAD
        AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)

=======
        self.view?.isPaused = false
        
>>>>>>> 09e1ce81f719259f3ab25f2534f064d1310d4d31
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

