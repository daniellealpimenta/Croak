//
//  Mage.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 28/08/25.
//

import Foundation
import SpriteKit

class Mage: SKSpriteNode {
    
    static var texture: SKTexture!
    static var size: CGSize!
    
    static var speed: Double = 1.3
    static var pointValue: Int = 1
    static var coinValue: Int = 10
    
    static var health: Int = 2
    
    static func create(at position: CGPoint) -> SKSpriteNode? {

        let mageSize = DeviceHelper.isIPhone ? CGSize(width: 105, height: 105) : CGSize(width: 150, height: 150)
        
        // 1. Cria o nó principal do Mago (usando uma cor como placeholder)
        let mageNode = SKSpriteNode(color: .orange, size: mageSize)
        mageNode.name = "Mage"
        mageNode.position = position
        mageNode.zPosition = 2
        
        // Configure a física como fez para o Guarda
        mageNode.physicsBody = SKPhysicsBody(rectangleOf: mageNode.size)
        mageNode.physicsBody?.isDynamic = true
        mageNode.physicsBody?.affectedByGravity = false
        mageNode.zPosition = Layer.enemies.rawValue
        
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
