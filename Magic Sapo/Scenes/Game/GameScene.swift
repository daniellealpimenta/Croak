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
    
    // MARK: - Ciclo de Vida da Cena
    
    /// Método chamado uma única vez quando a cena é apresentada na tela.
    /// Essa func so serve pra configuracao inicial
    override func didMove(to view: SKView) {
                
        // --- Configuração dos Componentes ---
        
        // Inicializa o componente de fundo e o configura.
        if backgroundComponent == nil {
            backgroundComponent = BackgroundComponent(parent: self)
        }
        backgroundComponent.setupAnimatedBackground()
        
        // Inicializa o componente de pontuação.
        if scoreComponent == nil {
            scoreComponent = ScoreComponent(parent: self)
        }
    
        // Inicializa o componente de moedas.
        if coinsComponent == nil {
            coinsComponent = CoinsComponent(parent: self)
        }
        
        // Inicializa o spawner de inimigos e começa a criar inimigos.
        self.enemySpawner = EnemySpawner(scene: self)
        self.enemySpawner.startSpawningEnemies()
        
        // MARK: Vamos trocar pelos gestos do ML depois
        
        let frog = Frog(parent: self)
        
        let frogNode = frog.createNode(at: CGPoint(x: -30, y: -self.size.height/2 + 150))
        
        if self.childNode(withName: "Frog") == nil{
            self.addChild(frogNode)
        }

        
        // --- Configuração dos Botões de Ação ---
        
        let rockButton = SKSpriteNode(imageNamed: "Rock")
        rockButton.name = "rockButton" // Nome para identificação no toque.
        rockButton.size = CGSize(width: 80, height: 80)
        // Posiciona o botão na parte inferior esquerda da tela.
        rockButton.position = CGPoint(x: -200, y: -self.size.height/2 + 100)
        self.addChild(rockButton)
        
        let twoButton = SKSpriteNode(imageNamed: "Two")
        twoButton.name = "twoButton" // Nome para identificação no toque.
        twoButton.size = CGSize(width: 80, height: 80)
        // Posiciona o botão na parte inferior direita da tela.
        twoButton.position = CGPoint(x: 150, y: -self.size.height/2 + 100)
        self.addChild(twoButton)
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

            print("Ganhou \(rewards.coins) moedas!")
        }
    }
    
    // MARK: - Entrada do Usuário
    
    /// Método chamado sempre que o jogador toca na tela.
    // MARK: To usando pros botoes de matar e pause, mas no futuro vai usar so pro pause
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Pega o primeiro toque e sua localização na cena.
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Descobre qual nó (botão, inimigo, etc.) foi tocado.
        // MARK: Esse atPoint vai ser muito util se a gente for colocar o modo de botoes la
        let touchedNode = atPoint(location)
        
        // --- Verificação dos Botões ---
        
        // Lógica para o botão de Pausa.
        // Nota: O botão em si não está sendo criado nesta cena, mas a lógica para ele está aqui.
        if touchedNode.name == "PauseButton" {
            print("Botão Pausar foi tocado!")
            
            // Carrega e apresenta a cena de pausa.
            guard let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene else {
                print("ERRO: Não foi possível carregar a PauseScene.")
                return
            }
            
            pauseScene.setGameScene(scene: self)
            
            pauseScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(pauseScene, transition: transition)
        }
        
        // Se o botão "Rock" foi tocado, chama a lógica do jogo para o gesto "Rock".
        if touchedNode.name == "rockButton" {
            playerDidMake(gesture: "Rock")
        }
        
        // Se o botão "Two" foi tocado, chama a lógica do jogo para o gesto "Two".
        if touchedNode.name == "twoButton" {
            playerDidMake(gesture: "Two")
        }
    }
}
