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
    
    /// Cria, dimensiona, posiciona e anima o fundo da cena, adaptando a imagem para iPhone ou iPad.
    func setupAnimatedBackground() {
        
        // 2. Determina qual nome de imagem usar.
        let backgroundBaseName: String
        
        // Verificamos o "idioma" da interface do usuário do dispositivo atual.
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            // O dispositivo é um iPhone.
            backgroundBaseName = "Background_iphone"
        case .pad:
            // O dispositivo é um iPad.
            backgroundBaseName = "Background_ipad"
        default:

            backgroundBaseName = "Background_ipad"
        }
        
        
        // 3. Carrega as texturas (imagens) que serão usadas na animação.
        //    Agora usamos a variável `backgroundBaseName` que definimos acima.
        let backgroundFrames: [SKTexture] = [
            SKTexture(imageNamed: backgroundBaseName)
            // Se você tiver animações diferentes para cada dispositivo, pode fazer:
            // SKTexture(imageNamed: "\(backgroundBaseName)_Frame2"),
        ]
        
        backgroundFrames.forEach { tex in
            tex.filteringMode = .nearest
        }
        
        // 4. Cria o nó de sprite (a imagem em si) com a primeira textura como base.
        let background = SKSpriteNode(texture: backgroundFrames[0])
        
        
        // 5. Calcula o fator de escala para que a imagem de fundo preencha a tela
        //    sem distorcer (lógica de "Aspect Fit").
        //    Esta lógica continua a mesma e funciona perfeitamente.
        let scaleFactor = min(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
        background.setScale(scaleFactor)
        
        // 6. Centraliza o fundo na tela e define seu zPosition.
        background.position = CGPoint(x: parentScene.frame.midX, y: parentScene.frame.midY)
        background.zPosition = -1
        parentScene.addChild(background)
        
        // 7. Cria e executa a animação (se houver mais de um frame).
        if backgroundFrames.count > 1 {
            let animationAction = SKAction.animate(with: backgroundFrames, timePerFrame: 0.5)
            let repeatAction = SKAction.repeatForever(animationAction)
            background.run(repeatAction)
        }
    }
}
