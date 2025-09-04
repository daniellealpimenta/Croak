//
//  Thief.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 26/08/25.
//

import Foundation
import SpriteKit


class Thief: Enemy {
    
    static var texture: SKTexture!
    static var size: CGSize!
    
    static var speed: Double = 1.25
    static var pointValue: Int = 1
    static var coinValue: Int = 5
    
    static var gestures: [String] = Gestures.availableGestures
    
    static let gestureCount: Int = 2
    
    static func create(at position: CGPoint) -> SKSpriteNode? {
        

        let thiefSize = DeviceHelper.isIPhone ? CGSize(width: 70, height: 70) : CGSize(width: 100, height: 100)
        let gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
        let spacing: CGFloat = DeviceHelper.isIPhone ? 7.0 : 10.0
        let yOffset: CGFloat = DeviceHelper.isIPhone ? 56.0 : 80.0

        // 1. Cria o nó principal do Ladrão, agora usando o tamanho adaptativo
        let thiefNode = SKSpriteNode(color: .purple, size: thiefSize) // <-- MUDANÇA AQUI
        thiefNode.name = "Thief"
        thiefNode.position = position
        
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
        
        // --- LÓGICA DE POSICIONAMENTO HORIZONTAL ---
        // A lógica continua a mesma, mas agora usa as variáveis adaptativas
        
        // Calcula a largura total que os gestos + espaços ocuparão
        let totalWidth = (CGFloat(requiredGestures.count) * gestureSize.width) + (CGFloat(max(0, requiredGestures.count - 1)) * spacing)
        
        // Ponto X inicial para o primeiro gesto, para que o grupo fique centralizado
        var xOffset = -totalWidth / 2 + gestureSize.width / 2
        
        // 3. Adiciona os sprites dos gestos como filhos
        for gestureName in requiredGestures {
            let gestureSprite = SKSpriteNode(imageNamed: gestureName)
            gestureSprite.size = gestureSize // <-- MUDANÇA AQUI
            gestureSprite.position = CGPoint(x: xOffset, y: yOffset) // <-- MUDANÇA AQUI
            gestureSprite.name = gestureName
            
            thiefNode.addChild(gestureSprite)
            
            // Move o X para a posição do próximo gesto
            xOffset += gestureSize.width + spacing // <-- MUDANÇA AQUI
        }
        
        return thiefNode
        
    }
    
    static func createForOnboarding(at position: CGPoint, withGestures gestures: [String]) -> SKSpriteNode? {
        let thiefSize = DeviceHelper.isIPhone ? CGSize(width: 70, height: 70) : CGSize(width: 100, height: 100)
        let gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
        let spacing: CGFloat = DeviceHelper.isIPhone ? 7.0 : 10.0
        let yOffset: CGFloat = DeviceHelper.isIPhone ? 56.0 : 80.0

        // 1. Cria o nó principal do Ladrão
        let thiefNode = SKSpriteNode(color: .purple, size: thiefSize)
        thiefNode.name = "Thief"
        thiefNode.position = position
        
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
