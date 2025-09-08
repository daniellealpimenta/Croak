//
//  Thief.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 26/08/25.
//

import Foundation
import SpriteKit


class Thief: Enemy {
        
    static var speed: Double = DeviceHelper.isIPhone ? 1.15 : 1.25
    static var pointValue: Int = 1
    static var coinValue: Int = 5
    
    static var gestures: [String] = Gestures.availableGestures
    
    static let gestureCount: Int = 2
    
    static var enemySize = DeviceHelper.isIPhone ? CGSize(width: 70, height: 70) : CGSize(width: 100, height: 100)
    static var gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
    
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
    
    static let walkAnimation = loadFrames(prefix: "thiefWalk", frameCount: 4)
    static let deathAnimation = loadFrames(prefix: "thiefDeath", frameCount: 1)
    
    static func create(at position: CGPoint) -> SKSpriteNode? {
        
        guard let firstFrame = walkAnimation.first else {
            print("Erro: Textura inicial do Ladrão não encontrada.")
            return nil
        }

        
        let spacing: CGFloat = DeviceHelper.isIPhone ? 7.0 : 10.0
        let yOffset: CGFloat = DeviceHelper.isIPhone ? 56.0 : 80.0

        // 1. Cria o nó principal do Ladrão, agora usando o tamanho adaptativo
        let thiefNode = SKSpriteNode(texture: firstFrame, size: self.enemySize)
        thiefNode.name = "Thief"
        thiefNode.position = position
        
        if position.x > 0 {
            thiefNode.xScale = -1.0
        }
        
        let walk = SKAction.animate(with: walkAnimation, timePerFrame: 0.15)
        thiefNode.run(SKAction.repeatForever(walk), withKey: "walkAnimation")
        
        // Configure a física como fez para o Guarda
        thiefNode.physicsBody = SKPhysicsBody(rectangleOf: thiefNode.size)
        thiefNode.physicsBody?.isDynamic = true
        thiefNode.physicsBody?.affectedByGravity = false
        thiefNode.zPosition = Layer.enemies.rawValue
        
        if let pb = thiefNode.physicsBody {
            pb.categoryBitMask = PhysicsCategory.enemy
            pb.collisionBitMask = PhysicsCategory.none
            pb.contactTestBitMask = PhysicsCategory.frog
        }
        
        thiefNode.userData = NSMutableDictionary()
        thiefNode.userData?.setValue(Self.pointValue, forKey: "points")
        thiefNode.userData?.setValue(Self.coinValue, forKey: "coins")
        thiefNode.userData?.setValue(Self.gestureCount, forKey: "health")
        
        let requiredGestures = Self.gestures.shuffled().prefix(gestureCount)
        
        if requiredGestures.isEmpty {
            print("Erro: Ladrão não conseguiu selecionar gestos")
            return nil
        }
        
        let totalWidth = (CGFloat(requiredGestures.count) * gestureSize.width) + (CGFloat(max(0, requiredGestures.count - 1)) * spacing)
        
        var xOffset = -totalWidth / 2 + gestureSize.width / 2
        
        for gestureName in requiredGestures {
            let gestureSprite = SKSpriteNode(imageNamed: gestureName)
            gestureSprite.size = gestureSize
            gestureSprite.position = CGPoint(x: xOffset, y: yOffset)
            gestureSprite.name = gestureName
            
            thiefNode.addChild(gestureSprite)
            
            xOffset += gestureSize.width + spacing 
        }
        
        return thiefNode
        
    }
    
    static func createForOnboarding(at position: CGPoint, withGestures gestures: [String]) -> SKSpriteNode? {
        
        guard let firstFrame = walkAnimation.first else {
            print("Erro: Textura inicial do Ladrão não encontrada.")
            return nil
        }
        
        let thiefSize = DeviceHelper.isIPhone ? CGSize(width: 70, height: 70) : CGSize(width: 100, height: 100)
        let gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
        let spacing: CGFloat = DeviceHelper.isIPhone ? 7.0 : 10.0
        let yOffset: CGFloat = DeviceHelper.isIPhone ? 56.0 : 80.0

        // 1. Cria o nó principal do Ladrão
        let thiefNode = SKSpriteNode(texture: firstFrame, size: thiefSize)
        thiefNode.name = "Thief"
        thiefNode.position = position
        
        let walk = SKAction.animate(with: walkAnimation, timePerFrame: 0.15)
        thiefNode.run(SKAction.repeatForever(walk), withKey: "walkAnimation")
        
        // Configura a física (igual ao create normal)
        thiefNode.physicsBody = SKPhysicsBody(rectangleOf: thiefNode.size)
        thiefNode.physicsBody?.isDynamic = true
        thiefNode.physicsBody?.affectedByGravity = false
        thiefNode.zPosition = Layer.enemies.rawValue
        
        if let pb = thiefNode.physicsBody {
            pb.categoryBitMask = PhysicsCategory.enemy
            pb.collisionBitMask = PhysicsCategory.none
            pb.contactTestBitMask = PhysicsCategory.frog
        }
        
        thiefNode.userData = NSMutableDictionary()
        thiefNode.userData?.setValue(Self.pointValue, forKey: "points")
        thiefNode.userData?.setValue(Self.coinValue, forKey: "coins")
        // A vida é o número de gestos que ele recebe
        thiefNode.userData?.setValue(gestures.count, forKey: "health")
        
        // --- LÓGICA DE POSICIONAMENTO (igual ao create normal) ---
        let totalWidth = (CGFloat(gestures.count) * gestureSize.width) + (CGFloat(max(0, gestures.count - 1)) * spacing)
        var xOffset = -totalWidth / 2 + gestureSize.width / 2
        
        // 3. Adiciona os sprites dos gestos que foram PASSADOS COMO PARÂMETRO
        for gestureName in gestures {
            let gestureSprite = SKSpriteNode(imageNamed: gestureName)
            gestureSprite.size = gestureSize
            gestureSprite.position = CGPoint(x: xOffset, y: yOffset)
            gestureSprite.name = gestureName
            
            thiefNode.addChild(gestureSprite)
            
            xOffset += gestureSize.width + spacing
        }
        
        return thiefNode
    }
}
