//
//  Frog.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 15/08/25.
//

import SpriteKit

struct Frog {
    var texture: [SKTexture]
    var size: CGSize
    private var parent: SKScene?
    
    init(parent: SKScene) {
        self.texture = [SKTexture(image: .frog0), SKTexture(image: .frog1), SKTexture(image: .frog2), SKTexture(image: .frog3)]
        self.size = CGSize(width: 150, height: 150)
        self.parent = parent
        
        self.texture.forEach { tex in
            tex.filteringMode = .nearest
        }
        
    }
    
    func createNode(at position: CGPoint) -> SKSpriteNode {
        let frog = SKSpriteNode(texture: texture[0], size: size)
        frog.physicsBody = SKPhysicsBody(rectangleOf: size)
        frog.physicsBody?.isDynamic = true
        frog.physicsBody?.affectedByGravity = false
        frog.position = position
        frog.name = "Frog"
        
        if let pb = frog.physicsBody {
            pb.categoryBitMask = PhysicsCategory.frog
            
            // Esta é a linha mais importante:
            // Diz ao sapo para NÃO colidir fisicamente com NADA.
            pb.collisionBitMask = PhysicsCategory.none
            
            // Diz ao sapo que queremos ser notificados quando ele tocar um inimigo.
            pb.contactTestBitMask = PhysicsCategory.enemy
        }

        
        let animationAction = SKAction.animate(with: texture, timePerFrame: 0.25)
        let repeatAction = SKAction.repeatForever(animationAction) // Faz a animação rodar em loop.
        
        frog.run(repeatAction)
        
        return frog
    }
    
}
