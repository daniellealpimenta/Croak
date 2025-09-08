//
//  BackgroundComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit
import UIKit // 1. Importe o UIKit para acessar informações do dispositivo.

/// Um componente responsável por configurar e gerenciar o fundo (background) da cena.
class BackgroundComponent {
    
    // MARK: - Propriedades
    
    /// Uma referência à cena principal onde o fundo será exibido.
    private var parentScene: SKScene
    
    // MARK: - Inicialização
    
    init(parent: SKScene) {
        self.parentScene = parent
    }
    
    // MARK: - Configuração do Background
    
    /// Cria, dimensiona, posiciona e anima o fundo da cena, adaptando a imagem e a lógica de escala para iPhone ou iPad.
    func setupAnimatedBackground() {
        
        let backgroundBaseName: String
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            backgroundBaseName = "Background_iphone"
        case .pad:
            backgroundBaseName = "Background_ipad"
        default:
            backgroundBaseName = "Background_ipad"
        }
        
        let initialTexture = SKTexture(imageNamed: backgroundBaseName)
        initialTexture.filteringMode = .nearest
        let background = SKSpriteNode(texture: initialTexture)

        let scaleFactor: CGFloat
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                scaleFactor = min(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
            case .pad:
                scaleFactor = max(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
            case .unspecified:
                scaleFactor = max(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
            case .tv:
                fallthrough
            case .carPlay:
                fallthrough
            case .mac:
                fallthrough
            case .vision:
                fallthrough
            @unknown default:
                scaleFactor = max(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
            
        }
        
        background.setScale(scaleFactor)
        
        background.position = CGPoint(x: parentScene.frame.midX, y: parentScene.frame.midY)
        background.zPosition = -1
        parentScene.addChild(background)
        

        let backgroundFrames: [SKTexture] = [initialTexture]
        
        if backgroundFrames.count > 1 {
            backgroundFrames.forEach { $0.filteringMode = .nearest }
            
            let animationAction = SKAction.animate(with: backgroundFrames, timePerFrame: 0.5)
            let repeatAction = SKAction.repeatForever(animationAction)
            background.run(repeatAction)
        }
    }
}
