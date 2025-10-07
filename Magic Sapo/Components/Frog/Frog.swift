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
    var colisionSize: CGSize
    
    init(parent: SKScene) {
        self.texture = [SKTexture(image: .frog0), SKTexture(image: .frog1), SKTexture(image: .frog2), SKTexture(image: .frog3)]
        
        self.size = DeviceHelper.isIPhone ? CGSize(width: 105, height: 105) : CGSize(width: 150, height: 150)
        self.colisionSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
        
        self.parent = parent
        
        self.texture.forEach { tex in
            tex.filteringMode = .nearest
        }
        
    }
    
    func createNode(at position: CGPoint) -> SKSpriteNode {
        let frog = SKSpriteNode(texture: texture[0], size: size)
        frog.physicsBody = SKPhysicsBody(rectangleOf: colisionSize)
        frog.physicsBody?.isDynamic = true
        frog.physicsBody?.affectedByGravity = false
        frog.position = position
        frog.zPosition = Layer.player.rawValue
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
