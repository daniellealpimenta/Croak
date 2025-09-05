//
//  Mage.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 28/08/25.
//

import Foundation
import SpriteKit

class Mage: SKSpriteNode {
    
    static var size: CGSize!
    
    static var speed: Double = 1.3
    static var pointValue: Int = 1
    static var coinValue: Int = 10
    
    private static func loadFrames(prefix: String, frameCount: Int) -> [SKTexture] {
            var frames: [SKTexture] = []
            for i in 0...frameCount {
                let textureName = "\(prefix)\(i)"
                frames.append(SKTexture(imageNamed: textureName))
            }
        
            frames.forEach { texture in
                texture.filteringMode = .nearest
            }
            return frames
        }
    
    static let walkAnimation = loadFrames(prefix: "mageWalk", frameCount: 2)
    static let shieldCrackAnimation = loadFrames(prefix: "shieldCrack", frameCount: 5)
    static let walkCrackedAnimation = loadFrames(prefix: "walkCracked", frameCount: 2)
    static let shieldBreakingAnimation = loadFrames(prefix: "shieldBreaking", frameCount: 8)
    static let mageTurnAnimation = loadFrames(prefix: "mageTurn", frameCount: 4)
    static let mageRanAnimation = loadFrames(prefix: "mageRan", frameCount: 2)
    static let invokingTexture = SKTexture(imageNamed: "mageInvoking")
    static let invokingTextureCrack = SKTexture(imageNamed: "mageInvokingCrack")
    
    static var health: Int = 2
    
    static func create(at position: CGPoint) -> SKSpriteNode? {
        
        guard let firstFrame = walkAnimation.first else {
            print("Erro: Textura inicial do Mago não encontrada.")
            return nil
        }
        
        invokingTexture.filteringMode = .nearest
        invokingTextureCrack.filteringMode = .nearest

        let mageSize = DeviceHelper.isIPhone ? CGSize(width: 105, height: 105) : CGSize(width: 180, height: 180)
        
        // 1. Cria o nó principal do Mago (usando uma cor como placeholder)
        let mageNode = SKSpriteNode(texture: firstFrame, size: mageSize)
        mageNode.name = "Mage"
        mageNode.position = position
        mageNode.zPosition = Layer.boss.rawValue
        
        let walk = SKAction.animate(with: walkAnimation, timePerFrame: 0.25)
        mageNode.run(SKAction.repeatForever(walk), withKey: "walkAnimation")
        
        // Configure a física como fez para o Guarda
        mageNode.physicsBody = SKPhysicsBody(rectangleOf: mageNode.size)
        mageNode.physicsBody?.isDynamic = true
        mageNode.physicsBody?.affectedByGravity = false
        
        if let pb = mageNode.physicsBody {
            pb.categoryBitMask = PhysicsCategory.enemy
            pb.collisionBitMask = PhysicsCategory.none
            pb.contactTestBitMask = PhysicsCategory.frog
        }
        
        mageNode.userData = NSMutableDictionary()
        mageNode.userData?.setValue(Self.pointValue, forKey: "points")
        mageNode.userData?.setValue(Self.coinValue, forKey: "coins")
        mageNode.userData?.setValue(Self.health, forKey: "health")

        return mageNode
        
    }
    
}
