//
//  EnemyControl.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//
import SpriteKit

class EnemyControl {
    
    public func createEnemy<T: Enemy>(ofType enemyType: T.Type, in scene: SKScene) {
        let halfWidth = scene.size.width / 2
        let halfHeight = scene.size.height / 2
        
        let startX = CGFloat.random(in: -halfWidth...halfWidth)
        let startY = halfHeight + 50
        let startPosition = CGPoint(x: startX, y: startY)

        let endX: CGFloat = 0
        let endY = -halfHeight - 50
        let endPosition = CGPoint(x: endX, y: endY)
        
        guard let enemyEntity = enemyType.create(at: startPosition) else {
            return
        }
        
        scene.addChild(enemyEntity)

        let moveAction = SKAction.move(to: endPosition, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        
        enemyEntity.run(sequence)
    }
    
    public func killEnemy(withGesture gesture: String, in scene: SKScene) -> Int? {
            
            for node in scene.children {
                // Verifica se o nó é um inimigo E se o gesto corresponde
                if node.childNode(withName: gesture) != nil {
                    
                    // Animação de morte
                    let fadeOut = SKAction.fadeOut(withDuration: 0.3)
                    let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
                    let deathAnimation = SKAction.group([fadeOut, scaleDown])
                    let removeNode = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([deathAnimation, removeNode])
                    
                    node.run(sequence)

                    // Verifica o tipo de inimigo pelo nome para retornar os pontos corretos
                    if node.name == "Guard" {
                        // Encontrou, matou, agora retorna os pontos e para o loop
                        return Guards.pointValue
                    }
                }
            }
            
            // Se o loop terminar sem encontrar nenhum inimigo, retorna nulo
            return nil
        }
}
