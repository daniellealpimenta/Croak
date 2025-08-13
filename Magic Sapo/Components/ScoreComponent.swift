//
//  ScoreComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//

import SpriteKit

class ScoreComponent {
    
    var scoreCount: Int
    var scoreLabel: SKLabelNode
    private var parentScene: SKScene
    
    init(parent: SKScene) {
        self.parentScene = parent
        self.scoreCount = 0
        
        self.scoreLabel = SKLabelNode(fontNamed: "PixelifySans-Regular")
        self.scoreLabel.fontSize = 50
        self.scoreLabel.fontColor = .white
        self.scoreLabel.position = CGPoint(x: 0, y: 300)
        self.scoreLabel.text = "Pontuação: \(self.scoreCount)"
        
        self.parentScene.addChild(self.scoreLabel)
    }

    func addScore(point: Int) {
        self.scoreCount += point
        self.scoreLabel.text = "Pontuação: \(self.scoreCount)"
    }
    
    
}
