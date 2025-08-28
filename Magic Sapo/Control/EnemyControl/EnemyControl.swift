//
//  EnemyControl.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//
import SpriteKit

/// Gerencia as ações e o ciclo de vida de um inimigo individual,
/// como sua criação, movimento e destruição.
class EnemyControl {
    
    
    // MARK: - Lógica de Criação e Movimento
    
    //    Adicione um array para manter o controle dos inimigos ativos.
    private(set) var activeEnemies: [SKNode] = []
    
    // Velocidade, velocidade inicial,
    private var V: CGFloat = 5.0
    private let Vi: CGFloat = 5.0
    
    // Pontuacao para subir de estagio
    // Para o maximo: limita em 15
    private let scorePerStage: Int = 75
    
    // Padrao 0.02
    // Para o maximo testa com 0.5
    private let speedDecreasePerStage: CGFloat = 0.02
    
    // Sempre 0.5
    private let accelerationFactor: CGFloat = 0.5
    
    private var lastKnownStage: Int = 0
    
    /// Cria uma instância de um tipo de inimigo específico e a adiciona na cena.
    /// - Parameters:
    ///   - enemyType: O tipo do inimigo a ser criado (ex: Guards.self), que deve conformar ao protocolo Enemy.
    ///   - scene: A cena onde o inimigo será adicionado.
    public func createEnemy<T: Enemy>(ofType enemyType: T.Type, in scene: SKScene) {
        
        // Define as posições de início (fora da tela, no topo) e fim (fora da tela, embaixo).
        let halfWidth = scene.size.width / 2
        let halfHeight = scene.size.height / 2
        
        let startX = CGFloat.random(in: -halfWidth...halfWidth)
        let startY = halfHeight + 50 // +50 para garantir que comece fora da tela
        let startPosition = CGPoint(x: startX, y: startY)

        let endX: CGFloat = 0 // Os inimigos se movem em direção ao centro do eixo X
        let endY = -halfHeight + 200 // -50 para garantir que saia da tela (vai mudar quando tiver o sapo)
        let endPosition = CGPoint(x: endX, y: endY)
        
        // Tenta criar a entidade do inimigo usando o método estático do seu tipo.
        guard let enemyEntity = enemyType.create(at: startPosition) else {
            return // Se a criação falhar, não faz mais nada.
        }
        
        // Adiciona o inimigo na cena.
        activeEnemies.append(enemyEntity)
        scene.addChild(enemyEntity)
        
        // A duração do movimento é calculada dinamicamente.
        // V é a velocidade base, e enemyType.speed é o multiplicador do inimigo.
        let calculatedDuration = V / CGFloat(enemyType.speed)

        // Cria a sequência de ações com a duração calculada.
        let moveAction = SKAction.move(to: endPosition, duration: calculatedDuration)
        
        let removeAction = SKAction.run { [weak self] in
            // Remove o inimigo da lista de ativos quando ele sai da tela.
            self?.activeEnemies.removeAll { $0 === enemyEntity }
            enemyEntity.removeFromParent()
        }
        
        // Essa .sequence faz as funcoes rodarem em sequencia
        let sequence = SKAction.sequence([moveAction, removeAction])
        
        // Executa a sequência de ações no inimigo.
        enemyEntity.run(sequence)
    }
    
    // MARK: Formula de velocidade (as declaracoes da velocidade tao em cima)
    
    /// Atualiza a velocidade base (V) com base na pontuação do jogador.
    /// - Parameter score: A pontuação atual do jogador.
    public func updateSpeed(basedOn score: Int) {
        
        // 1. Calcula em qual "estágio" de dificuldade o jogador está..
        let stage = score / scorePerStage
        
        if stage > lastKnownStage {
                    print("-----------------------------------------")
                    print("🏆🏆🏆 MUDANÇA DE ESTÁGIO! 🏆🏆🏆")
                    print("Score atingiu \(score). Entrando no Estágio \(stage).")
                    print("-----------------------------------------")
                    
                    // Atualiza nossa memória para o novo estágio.
                    lastKnownStage = stage
                }
        
        // 2. Calcula a velocidade "base" para o estágio atual.
        let VPerStage = Vi - (CGFloat(stage) * accelerationFactor)
        
        // 3. Calcula quantos pontos o jogador fez DENTRO do estágio atual.
        let scoreInStage = score % scorePerStage
    
        // 4. Calcula a velocidade final.
        // Começa com a base do estágio e diminui conforme o jogador pontua dentro desse estágio.
        let newV = VPerStage - (CGFloat(scoreInStage) * speedDecreasePerStage)

        // 5. Garante que a duração nunca seja menor que 1.5s para não quebrar o jogo.
        self.V = max(1.5, newV)
         
        print("Score: \(score) | Stage: \(stage) | VperStage: \(VPerStage) | Final V: \(self.V)")
        print("Nova velocidade base V: \(self.V)")
    }

    
    // MARK: - Lógica de Destruição
    
    /// Procura e destrói um inimigo na cena que corresponda a um gesto.
    /// - Parameters:
    ///   - gesture: O nome do gesto (ex: "Two", "Rock",etc (Tão nesse padrão de Letra maiuscula no inicio)) que deve corresponder ao nome do nó filho do inimigo.
    ///   - scene: A cena onde a busca pelo inimigo será feita.
    /// - Returns: O valor em pontos do inimigo destruído, ou nil se nenhum inimigo for encontrado.
    ///
    // Em EnemyControl.swift

    public func killEnemy(withGesture gesture: String, in scene: SKScene) -> (points: Int, coins: Int)? {
        
        // Define a "Kill Zone" para que os inimigos só possam ser atingidos em uma área específica.
        let killZoneTopY: CGFloat = scene.size.height / 2 - 150
        let killZoneBottomY: CGFloat = -scene.size.height / 2 + 300
        
        var totalPoints = 0
        var totalCoins = 0
        var anyEnemyHit = false
        
        // Itera por todos os inimigos ativos.
        for (index, enemy) in activeEnemies.enumerated().reversed() {
            
            // Pula o inimigo se ele não estiver dentro da zona de ataque.
            guard enemy.position.y < killZoneTopY && enemy.position.y > killZoneBottomY else {
                continue
            }
            
            // Verifica se o inimigo possui um gesto correspondente.
            if let gestureNode = enemy.childNode(withName: gesture) {
                
                anyEnemyHit = true
                
                // --- CORREÇÃO PRINCIPAL CONTRA O BUG DE TOQUES RÁPIDOS ---
                // 1. "Desarma" o gesto imediatamente, mudando seu nome.
                //    Isso impede que o mesmo toque rápido seja contado duas vezes.
                gestureNode.name = "hit"
                
                // 2. Roda a animação de remoção visual do gesto.
                gestureNode.run(SKAction.sequence([
                    SKAction.scale(to: 0, duration: 0.2),
                    SKAction.removeFromParent()
                ]))
                
                // 3. Acessa o contador 'health' e o diminui em 1.
                if let health = enemy.userData?["health"] as? Int {
                    let newHealth = health - 1
                    enemy.userData?.setValue(newHealth, forKey: "health")
                    
                    // 4. Se a vida chegou a zero, o inimigo é derrotado.
                    if newHealth <= 0 {
                        let killedEnemy = activeEnemies.remove(at: index)
                        
                        // Roda a animação de morte do inimigo.
                        let deathAnimation = SKAction.group([
                            SKAction.fadeOut(withDuration: 0.3),
                            SKAction.scale(to: 0.1, duration: 0.3)
                        ])
                        killedEnemy.run(SKAction.sequence([deathAnimation, SKAction.removeFromParent()]))
                        
                        // Acumula os pontos e moedas.
                        if killedEnemy.name == "Guard" {
                            totalPoints += Guards.pointValue
                            totalCoins += Guards.coinValue
                        } else if killedEnemy.name == "Thief" {
                            totalPoints += Thief.pointValue
                            totalCoins += Thief.coinValue
                        }
                    }
                }
            }
        }
        
        // Retorna os ganhos totais se algum inimigo foi atingido.
        if anyEnemyHit {
            return (points: totalPoints, coins: totalCoins)
        } else {
            return nil
        }
    }
}
