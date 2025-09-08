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
    static var speed: Double = 1.0
    
    /// ESTA É A LINHA QUE FALTAVA.
    /// Adicionando-a de volta, a struct 'Guards' passa a se conformar
    /// novamente ao protocolo 'Enemy'.
    static var gestures: [String] = Gestures.availableGestures
    
    static var enemySize = DeviceHelper.isIPhone ? CGSize(width: 80, height: 80) : CGSize(width: 100, height: 100)
    static var gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
    
    
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
        
        let gestureYPosition: CGFloat = DeviceHelper.isIPhone ? 60 : 80
        // ------------------------------------
        
        // 1. Cria o corpo principal do inimigo usando a animação.
        let evilGuard = SKSpriteNode(texture: firstFrame, size: self.enemySize)
        
        // 2. Cria e executa a animação em loop.
        let animationAction = SKAction.animate(with: animationFrames, timePerFrame: 0.1)
        let loopingAnimation = SKAction.repeatForever(animationAction)
        evilGuard.run(loopingAnimation)
        
        // 3. Aplica as outras configurações
        evilGuard.name = "Guard"
        evilGuard.position = position
        evilGuard.zPosition = Layer.enemies.rawValue
        
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
        evilGuard.userData?.setValue(1, forKey: "health")

        guard let randomGestureName = self.gestures.randomElement() else {
            print("Erro: Não foi possível obter um gesto aleatório.")
            return nil
        }

        let gestureSprite = SKSpriteNode(imageNamed: randomGestureName)
        gestureSprite.size = self.gestureSize
        gestureSprite.position = CGPoint(x: 0, y: gestureYPosition)
        gestureSprite.name = randomGestureName
        
        evilGuard.addChild(gestureSprite)

        return evilGuard
    }
    
    static func createdByMage(at position: CGPoint, withGesture gestureName: String) -> SKSpriteNode? {
                
        guard let firstFrame = animationFrames.first else {
            print("Erro: Texturas de animação para 'Guards' não foram encontradas.")
            return nil
        }
        
        // --- AJUSTES DE TAMANHO E POSIÇÃO ---
        let guardSize = DeviceHelper.isIPhone ? CGSize(width: 70, height: 70) : CGSize(width: 100, height: 100)
        let gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
        let gestureYPosition: CGFloat = DeviceHelper.isIPhone ? 60 : 80
        // ------------------------------------
                
        // 1. Cria o corpo principal do inimigo.
        let evilGuard = SKSpriteNode(texture: firstFrame, size: guardSize)
                
        // 2. Cria e executa a animação em loop.
        let animationAction = SKAction.animate(with: animationFrames, timePerFrame: 0.1)
        let loopingAnimation = SKAction.repeatForever(animationAction)
        evilGuard.run(loopingAnimation)
                
        // 3. Aplica as outras configurações.
        evilGuard.name = "Guard"
        evilGuard.position = position
        evilGuard.zPosition = Layer.enemies.rawValue
                
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
        evilGuard.userData?.setValue(1, forKey: "health")

        // --- MUDANÇA: Usa o gesto fornecido em vez de escolher um aleatório aqui. ---
        let gestureSprite = SKSpriteNode(imageNamed: gestureName)
        gestureSprite.size = gestureSize // <-- MUDANÇA AQUI
        gestureSprite.position = CGPoint(x: 0, y: gestureYPosition) // <-- MUDANÇA AQUI
        gestureSprite.name = gestureName // O nome do nó do gesto é o próprio nome do gesto.
                
        evilGuard.addChild(gestureSprite)

        return evilGuard
    }
    
    static func createForOnboarding(at position: CGPoint, withGesture gestureName: String) -> SKSpriteNode? {
        
        guard let firstFrame = animationFrames.first else {
            print("Erro: Texturas de animação para 'Guards' não foram encontradas.")
            return nil
        }
        
        // --- AJUSTES DE TAMANHO E POSIÇÃO (igual ao createdByMage) ---
        let guardSize = DeviceHelper.isIPhone ? CGSize(width: 70, height: 70) : CGSize(width: 100, height: 100)
        let gestureSize = DeviceHelper.isIPhone ? CGSize(width: 35, height: 35) : CGSize(width: 50, height: 50)
        let gestureYPosition: CGFloat = DeviceHelper.isIPhone ? 60 : 80
        // ------------------------------------
        
        // 1. Cria o corpo principal do inimigo
        let evilGuard = SKSpriteNode(texture: firstFrame, size: guardSize)
        
        // 2. Cria e executa a animação em loop
        let animationAction = SKAction.animate(with: animationFrames, timePerFrame: 0.1)
        let loopingAnimation = SKAction.repeatForever(animationAction)
        evilGuard.run(loopingAnimation)
        
        // 3. Aplica as outras configurações
        evilGuard.name = "Guard"
        evilGuard.position = position
        evilGuard.zPosition = Layer.enemies.rawValue
        
        evilGuard.physicsBody = SKPhysicsBody(rectangleOf: evilGuard.size)
        evilGuard.physicsBody?.isDynamic = true
        evilGuard.physicsBody?.affectedByGravity = false
        
        if let pb = evilGuard.physicsBody {
            pb.categoryBitMask = PhysicsCategory.enemy
            pb.collisionBitMask = PhysicsCategory.none
            pb.contactTestBitMask = PhysicsCategory.frog
        }
        
        // 4. Configuração específica para onboarding
        evilGuard.userData = NSMutableDictionary()
        evilGuard.userData?.setValue(Guards.pointValue, forKey: "points")
        evilGuard.userData?.setValue(Guards.coinValue, forKey: "coins")
        evilGuard.userData?.setValue(1, forKey: "health") // Sempre 1 de vida no onboarding
        
        // 5. Adiciona o gesto específico para o onboarding
        let gestureSprite = SKSpriteNode(imageNamed: gestureName)
        gestureSprite.size = gestureSize
        gestureSprite.position = CGPoint(x: 0, y: gestureYPosition)
        gestureSprite.zPosition = Layer.effects.rawValue
        gestureSprite.name = gestureName
        
        evilGuard.addChild(gestureSprite)
        
        return evilGuard
    }
    
    // Em Guards.swift

    static let deathAnimation: [SKTexture] = {
        var frames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "guardDeath\(i)"
            frames.append(SKTexture(imageNamed: textureName))
        }
        return frames
    }()
}
