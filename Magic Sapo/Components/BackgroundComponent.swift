//
// BackgroundComponent.swift
// Magic Sapo
//
// Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class BackgroundComponent {
    
    private var parentScene: SKScene
    
    init(parent: SKScene) {
        self.parentScene = parent
    }
    
    func setupAnimatedBackground() {
        // 1. Carregue as texturas da animação
        let backgroundFrames: [SKTexture] = [
            SKTexture(imageNamed: "Background")
//            ,SKTexture(imageNamed: "Background2"),
        ]
        
        // 2. Crie o sprite do fundo com a primeira textura
        let background = SKSpriteNode(texture: backgroundFrames[0])
        
        // 3. Aplique a lógica de "Aspect Fit" para o tamanho
        let scaleFactor = min(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
        background.setScale(scaleFactor)
        
        // 4. Centralize, defina a posição Z e adicione à cena
        background.position = CGPoint(x: parentScene.frame.midX, y: parentScene.frame.midY)
        background.zPosition = -1
        parentScene.addChild(background)
        
        // 5. Crie a ação de animação para o background
        let animationAction = SKAction.animate(with: backgroundFrames, timePerFrame: 0.5)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        // 6. Execute a animação no sprite do fundo
        background.run(repeatAction)
    }
}
