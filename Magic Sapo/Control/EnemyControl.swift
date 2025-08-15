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
        scene.addChild(enemyEntity)

        // Cria a sequência de ações: mover de cima para baixo e depois ser removido.
        let moveAction = SKAction.move(to: endPosition, duration: 5)
        let removeAction = SKAction.removeFromParent()
        
        // Essa .sequence faz as funcoes rodarem em sequencia
        let sequence = SKAction.sequence([moveAction, removeAction])
        
        // Executa a sequência de ações no inimigo.
        enemyEntity.run(sequence)
    }
    
    // MARK: - Lógica de Destruição
    
    /// Procura e destrói um inimigo na cena que corresponda a um gesto.
    /// - Parameters:
    ///   - gesture: O nome do gesto (ex: "Two", "Rock",etc (Tão nesse padrão de Letra maiuscula no inicio)) que deve corresponder ao nome do nó filho do inimigo.
    ///   - scene: A cena onde a busca pelo inimigo será feita.
    /// - Returns: O valor em pontos do inimigo destruído, ou nil se nenhum inimigo for encontrado.
    ///
    public func killEnemy(withGesture gesture: String, in scene: SKScene) -> (points: Int, coins: Int)? {
        
        // Percorre todos os nós filhos da cena para encontrar o inimigo certo.
        for node in scene.children {
            
            // Verifica se o nó atual tem um "nó filho" com o nome do gesto.
            // Essa é a nossa forma de identificar qual inimigo corresponde a qual gesto.
            if node.childNode(withName: gesture) != nil {
                
                // Cria uma animação de morte (desaparecer e diminuir (Aqui a gente vai disparar a animacao de morte quando tiver ela pronta)).
                let fadeOut = SKAction.fadeOut(withDuration: 0.3)
                let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
                let deathAnimation = SKAction.group([fadeOut, scaleDown])
                let removeNode = SKAction.removeFromParent()
                let sequence = SKAction.sequence([deathAnimation, removeNode])
                
                node.run(sequence)

                // Verifica o nome do nó principal para saber qual tipo de inimigo era.
                // Isso é necessário para retornar a pontuação correta.
                if node.name == "Guard" {
                    
                    // Encontrou, matou, agora retorna os pontos e para o loop.
                    return (points: Guards.pointValue, coins: Guards.coinValue)
                }
                
                // Se tivéssemos outros inimigos, adicionaríamos mais 'if's aqui.
            }
        }
        
        // Se o loop terminar sem encontrar nenhum inimigo para o gesto, retorna nulo.
        return nil
    }
}
