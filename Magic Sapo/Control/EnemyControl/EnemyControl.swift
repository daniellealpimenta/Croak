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
    var activeEnemies: [SKNode] = []
    
    // Velocidade, velocidade inicial,
    private var V: CGFloat = 5.0
    private let Vi: CGFloat = 5.0
    
    // --- ALTERAÇÃO: Removido ---
    // A pontuação por estágio não é mais necessária, pois a morte do chefe controlará isso.
    // private let scorePerStage: Int = 75
    
    // Padrao 0.02
    // Para o maximo testa com 0.5
    private let speedDecreasePerStage: CGFloat = 0.02
    
    // Sempre 0.5
    // O fator de aceleração agora será aplicado por chefe derrotado.
    private let accelerationFactor: CGFloat = 0.5
    
    // --- ALTERAÇÃO: Renomeado e simplificado ---
    // Esta variável agora rastreia o estágio atual do jogo. Começa em 0.
    private var currentStage: Int = 0
    
    /// Cria uma instância de um tipo de inimigo específico e a adiciona na cena.
    /// - Parameters:
    ///   - enemyType: O tipo do inimigo a ser criado (ex: Guards.self), que deve conformar ao protocolo Enemy.
    ///   - scene: A cena onde o inimigo será adicionado.
    public func createEnemy<T: Enemy>(ofType enemyType: T.Type, in scene: SKScene) {
        
        // Define as posições de início (fora da tela, no topo) e fim (fora da tela, embaixo).
        let startPosition: CGPoint
        let endPosition: CGPoint
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // --- LÓGICA ESPECÍFICA PARA IPAD ---
            let halfWidth = scene.size.width / 2
            let halfHeight = scene.size.height / 2
            
            let startX = CGFloat.random(in: -halfWidth...halfWidth)
            let startY = halfHeight + 50
            startPosition = CGPoint(x: startX, y: startY)
            
            let endX: CGFloat = 0
            let endY = -halfHeight + 200
            endPosition = CGPoint(x: endX, y: endY)
            
        } else {
            // Esta abordagem resolve o problema de inimigos nascendo nas laterais,
            // independentemente da configuração de `scaleMode` da cena.

            // Primeiro, garantimos que a cena já tem uma view (a "janela" do jogo).
            guard let view = scene.view else {
                // Se a view não existir, não fazemos nada para evitar crashes.
                return
            }

            // --- Posição Inicial: Topo da Tela Visível ---

            // 1. Sorteamos um ponto X na LARGURA DA VIEW. A view é a garantia da área visível.
            //    O sistema de coordenadas da view sempre começa com X=0 na esquerda.
            let randomXInView = CGFloat.random(in: 0...view.bounds.width)

            // 2. Criamos um ponto no sistema de coordenadas da VIEW.
            //    Y = -100 significa 100 pontos ACIMA do topo da área visível
            //    (no sistema da view, o Y cresce para baixo, então valores negativos estão acima).
            let topPointInView = CGPoint(x: randomXInView, y: -100)

            // 3. CONVERTEMOS o ponto da view para o sistema de coordenadas da CENA.
            //    Aqui está a mágica: o SpriteKit ajusta o ponto para a escala e posição
            //    corretas dentro da sua cena.
            startPosition = scene.convertPoint(fromView: topPointInView)

            // --- Posição Final: Centro Inferior da Tela Visível ---

            // Fazemos o mesmo para o ponto final para garantir que ele vá para o centro inferior VISÍVEL.
            let bottomCenterInView = CGPoint(x: view.bounds.midX, y: view.bounds.height + 100)
            endPosition = scene.convertPoint(fromView: bottomCenterInView)
        }

        
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
    
    // --- ALTERAÇÃO: Lógica de velocidade refeita ---
    
    /// Avança o jogo para o próximo estágio, geralmente chamado após derrotar um chefe.
    /// Isso aumenta a dificuldade tornando os inimigos mais rápidos.
    public func advanceToNextStage() {
        // 1. Incrementa o contador de estágio.
        currentStage += 1
        
        // 2. Calcula a nova velocidade base com base no novo estágio.
        // A velocidade diminui (o que torna o tempo de movimento menor e o jogo mais rápido).
        let newV = Vi - (CGFloat(currentStage) * accelerationFactor)
        
        // 3. Garante que a velocidade não se torne impossivelmente rápida.
        self.V = max(1.5, newV)
    }
    
    // --- ALTERAÇÃO: Função antiga removida ---
    // A função public func updateSpeed(basedOn score: Int) foi completamente removida.
    
    // MARK: - Lógica de Destruição
    
    /// Procura e destrói um inimigo na cena que corresponda a um gesto.
    /// - Parameters:
    ///   - gesture: O nome do gesto (ex: "Two", "Rock",etc (Tão nesse padrão de Letra maiuscula no inicio)) que deve corresponder ao nome do nó filho do inimigo.
    ///   - scene: A cena onde a busca pelo inimigo será feita.
    /// - Returns: O valor em pontos do inimigo destruído, ou nil se nenhum inimigo for encontrado.
    public func killEnemy(withGesture gesture: String, in scene: SKScene) -> (points: Int, coins: Int)? {
        
        // Define a "Kill Zone" para que os inimigos só possam ser atingidos em uma área específica.
        
        var totalPoints = 0
        var totalCoins = 0
        var anyEnemyHit = false
        
        guard let scene = scene as? ScoreHavingScene else {
            return nil
        }
        
        // Itera por todos os inimigos ativos.
        for (index, enemy) in activeEnemies.enumerated().reversed() {
            
            // Pula o inimigo se ele não estiver dentro da zona de ataque.
            guard scene.killZoneRect.contains(enemy.position) else {
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
                        
                        killedEnemy.removeAllActions()
                        
                        if killedEnemy.name == "Guard" {
                            
                            let animateFrames = SKAction.animate(with: Guards.deathAnimation, timePerFrame: 0.1)
                            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                            
                            let combinedDeathAnimation = SKAction.group([animateFrames, fadeOut])
                                        
                            killedEnemy.run(SKAction.sequence([combinedDeathAnimation, SKAction.removeFromParent()]))
                            
                            totalPoints += Guards.pointValue
                            totalCoins += Guards.coinValue
                            
                        } else if killedEnemy.name == "Thief" {

                            let animateFrames = SKAction.animate(with: Thief.deathAnimation, timePerFrame: 0.2)
                            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
                            let deathSequence = SKAction.group([animateFrames, fadeOut])
                            
                            killedEnemy.run(SKAction.sequence([deathSequence, SKAction.removeFromParent()]))

                            totalPoints += Thief.pointValue
                            totalCoins += Thief.coinValue
                            
                        } else {

                            killedEnemy.removeFromParent()
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
