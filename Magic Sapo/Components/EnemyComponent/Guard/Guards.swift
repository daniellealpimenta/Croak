//
//  Guards.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 12/08/25.
//

import Foundation
import SpriteKit

struct Guards: Enemy {
    
    // MARK: - Propriedades Estáticas (Exigidas pelo Protocolo 'Enemy')
    
    static var pointValue: Int = 1
    static var coinValue: Int = 3
    static var speed: Int = 1
    
    /// ESTA É A LINHA QUE FALTAVA.
    /// Adicionando-a de volta, a struct 'Guards' passa a se conformar
    /// novamente ao protocolo 'Enemy'.
    static var gesture = Gestures()
    
    // MARK: - Propriedades de Animação (Otimização)
    
    // Pré-carregamos as texturas da animação apenas uma vez para melhor performance.
    static let animationFrames: [SKTexture] = {
        var frames: [SKTexture] = []
        for i in 1...7 {
            let textureName = "guard\(i)"
            frames.append(SKTexture(imageNamed: textureName))
        }
        return frames
    }()

    
    // MARK: - Método de Criação (Fábrica)
    
    static func create(at position: CGPoint) -> SKSpriteNode? {
        
        guard let firstFrame = animationFrames.first else {
            print("Erro: Texturas de animação para 'Guards' não foram encontradas.")
            return nil
        }
        
        // 1. Cria o corpo principal do inimigo usando a animação.
        let evilGuard = SKSpriteNode(texture: firstFrame, size: CGSize(width: 100, height: 100))
        
        // 2. Cria e executa a animação em loop.
        let animationAction = SKAction.animate(with: animationFrames, timePerFrame: 0.1)
        let loopingAnimation = SKAction.repeatForever(animationAction)
        evilGuard.run(loopingAnimation)
        
        // 3. Aplica as outras configurações
        evilGuard.name = "Guard"
        evilGuard.position = position
        
        evilGuard.physicsBody = SKPhysicsBody(rectangleOf: evilGuard.size)
        evilGuard.physicsBody?.isDynamic = true
        evilGuard.physicsBody?.affectedByGravity = false
        
        if let pb = evilGuard.physicsBody {
            pb.categoryBitMask = PhysicsCategory.enemy
            pb.collisionBitMask = PhysicsCategory.none
            pb.contactTestBitMask = PhysicsCategory.frog
        }
        
        evilGuard.userData = NSMutableDictionary()
        evilGuard.userData?.setValue(Guards.pointValue, forKey: "points")
        evilGuard.userData?.setValue(Guards.coinValue, forKey: "coins")

        // Esta linha usa a definição da sua struct Gestures, não a propriedade do protocolo.
        // Isso está correto, mas é bom saber a diferença.
        guard let randomGestureName = Gestures.availableGestures.randomElement() else {
            print("Erro: Não foi possível obter um gesto aleatório.")
            return nil
        }

        let gestureSprite = SKSpriteNode(imageNamed: randomGestureName)
        gestureSprite.size = CGSize(width: 50, height: 50)
        gestureSprite.position = CGPoint(x: 0, y: 80)
        gestureSprite.name = randomGestureName
        
        evilGuard.addChild(gestureSprite)

        return evilGuard
    }
}
