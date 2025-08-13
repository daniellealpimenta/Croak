//
//  Guards.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 12/08/25.
//

import Foundation
import SpriteKit

// Conformamos a struct ao protocolo Enemy
struct Guards: Enemy {
    
    static var pointValue: Int = 1
    static let availableGestures = ["Rock", "Two"]


    static func create(at position: CGPoint) -> SKSpriteNode? {
        let evilGuard = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        evilGuard.name = "Guard"
        evilGuard.position = position

        guard let randomGestureName = availableGestures.randomElement() else {
            return nil
        }

        let gestureSprite = SKSpriteNode(imageNamed: randomGestureName)
        gestureSprite.size = CGSize(width: 40, height: 40)
        gestureSprite.position = CGPoint(x: 0, y: 60)
        gestureSprite.name = randomGestureName
        print(gestureSprite.name ?? "Nenhum nome")
        evilGuard.addChild(gestureSprite)

        return evilGuard
    }
}
