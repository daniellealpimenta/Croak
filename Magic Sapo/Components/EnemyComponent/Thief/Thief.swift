//
//  Thief.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 26/08/25.
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
        // 1. Cria o nó principal do Ladrão (usando uma cor como placeholder)
        let thiefNode = SKSpriteNode(color: .purple, size: CGSize(width: 50, height: 50))
        thiefNode.name = "Thief"
        thiefNode.position = position
        
        // Configure a física como fez para o Guarda
        thiefNode.physicsBody = SKPhysicsBody(rectangleOf: thiefNode.size)
        thiefNode.physicsBody?.isDynamic = true
        thiefNode.physicsBody?.affectedByGravity = false
        
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
        let gestureSize = CGSize(width: 50, height: 50)
        let spacing: CGFloat = 10.0 // Espaço entre os gestos
        
        // Calcula a largura total que os gestos + espaços ocuparão
        let totalWidth = (CGFloat(requiredGestures.count) * gestureSize.width) + (CGFloat(max(0, requiredGestures.count - 1)) * spacing)
        
        // Ponto X inicial para o primeiro gesto, para que o grupo fique centralizado
        var xOffset = -totalWidth / 2 + gestureSize.width / 2
        
        // Posição Y é constante, acima da cabeça do ladrão
        let yOffset: CGFloat = 80.0
        
        // 3. Adiciona os sprites dos gestos como filhos
        for gestureName in requiredGestures {
            let gestureSprite = SKSpriteNode(imageNamed: gestureName)
            gestureSprite.size = gestureSize
            gestureSprite.position = CGPoint(x: xOffset, y: yOffset)
            gestureSprite.name = gestureName
            
            thiefNode.addChild(gestureSprite)
            
            // Move o X para a posição do próximo gesto
            xOffset += gestureSize.width + spacing
        }
        
        return thiefNode
        
        
    }
}
