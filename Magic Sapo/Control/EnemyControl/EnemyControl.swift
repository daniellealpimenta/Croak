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
    
    // Velocidade, velocidade inicial, estagios
    private var V: CGFloat = 5.0
    private let Vi: CGFloat = 5.0
    private let scorePerStage: Int = 5
    private let speedDecreasePerStage: CGFloat = 0.5
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
        let VPerStage = Vi - (CGFloat(stage) * speedDecreasePerStage)
        
        // 3. Calcula quantos pontos o jogador fez DENTRO do estágio atual.
        let scoreInStage = score % scorePerStage
    
        // 4. Calcula a velocidade final.
        // Começa com a base do estágio e diminui conforme o jogador pontua dentro desse estágio.
        let newV = VPerStage - (CGFloat(scoreInStage) * accelerationFactor)

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
    public func killEnemy(withGesture gesture: String, in scene: SKScene) -> (points: Int, coins: Int)? {
            
            // --- PASSO 1: Crie variáveis para acumular as recompensas ---
            var totalPoints = 0
            var totalCoins = 0
            var enemiesWereKilled = false

            // Percorre todos os inimigos ativos, de trás para frente para evitar problemas ao remover itens do array.
            for (index, enemy) in activeEnemies.enumerated().reversed() {
                
                // Verifica se o inimigo atual corresponde ao gesto.
                if enemy.childNode(withName: gesture) != nil {
                    
                    // --- PASSO 2: Processe CADA inimigo encontrado ---
                    
                    // Marca que encontramos pelo menos um inimigo.
                    enemiesWereKilled = true
                    
                    // Remove o inimigo da lista de ativos.
                    let killedEnemy = activeEnemies.remove(at: index)
                    
                    
                    // Aqui eu cancelo a acao do boneco de se locomover
                    killedEnemy.removeAllActions()
                    
                    // Roda a animação de morte (exatamente como antes).
                    let fadeOut = SKAction.fadeOut(withDuration: 0.3)
                    let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
                    let deathAnimation = SKAction.group([fadeOut, scaleDown])
                    let removeNode = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([deathAnimation, removeNode])
                    
                    killedEnemy.run(sequence)

                    // Acumula os pontos e moedas.
                    // Checagem pelo tipo e nome do nó
                    if let points = killedEnemy.userData?.value(forKey: "points") as? Int {
                        totalPoints += points
                    }
                    if let coins = killedEnemy.userData?.value(forKey: "coins") as? Int {
                        totalCoins += coins
                    }
                }
            }
            
            // --- PASSO 3: Retorne o resultado DEPOIS que o loop terminar ---
            
            // Se matamos pelo menos um inimigo, retorne a soma total das recompensas.
            if enemiesWereKilled {
                return (points: totalPoints, coins: totalCoins)
            }
            
            // Se o loop terminou e nenhum inimigo foi morto, retorne nulo.
            return nil
        }
}
