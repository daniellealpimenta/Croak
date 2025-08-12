//
//  TimerComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//


import SpriteKit

class TimerComponent {
    
    var timerCount: Int
    var timerLabel: SKLabelNode
    private var parentScene: SKScene

    init(parent: SKScene) {
        self.parentScene = parent
        self.timerCount = 0
        
        self.timerLabel = SKLabelNode(fontNamed: "Arial")
        self.timerLabel.fontSize = 50
        self.timerLabel.fontColor = .white
        self.timerLabel.position = CGPoint(x: 0, y: 300)
    }
    
    func start() {
        
        parentScene.removeAction(forKey: "timerAction")
        
        // Adiciona o rótulo à cena, se ainda não estiver lá
        if self.timerLabel.parent == nil {
            parentScene.addChild(self.timerLabel)
        }
        
        // Cria a ação que irá contar
        let wait = SKAction.wait(forDuration: 1.0)
        let countBlock = SKAction.run {
            self.timerCount += 1
            self.timerLabel.text = "Tempo: \(self.timerCount)"
        }
        
        // Executa a ação na cena pai
        let sequence = SKAction.sequence([wait, countBlock])
        let repeatSequence = SKAction.repeatForever(sequence)
        
        parentScene.run(repeatSequence, withKey: "timerAction")
    }
    
    func stop() {
        // Remove a ação do timer
        parentScene.removeAction(forKey: "timerAction")
        // Remove o rótulo da tela
        self.timerLabel.removeFromParent()
    }
}
