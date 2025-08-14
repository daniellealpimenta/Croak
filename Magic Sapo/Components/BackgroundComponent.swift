//
//  BackgroundComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

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
    
    /// Cria, dimensiona, posiciona e anima o fundo da cena.
    func setupAnimatedBackground() {
        
        // Me pro chat deixar em forma de passo a passo pq a gente vai ter que repetir esse codigo pra cada animacao se pa
        
        // 1. Carrega as texturas (imagens) que serão usadas na animação.
        let backgroundFrames: [SKTexture] = [
            SKTexture(imageNamed: "Background")
            // ,SKTexture(imageNamed: "Background2"),
        ]
        
        // 2. Cria o nó de sprite (a imagem em si) com a primeira textura como base.
        let background = SKSpriteNode(texture: backgroundFrames[0])
        
        // 3. Calcula o fator de escala para que a imagem de fundo preencha a tela
        //    sem distorcer (lógica de "Aspect Fit").
        let scaleFactor = min(parentScene.size.width / background.size.width, parentScene.size.height / background.size.height)
        background.setScale(scaleFactor)
        
        // 4. Centraliza o fundo na tela e define seu zPosition.
        //    zPosition = -1 garante que o fundo fique atrás de TODOS os outros elementos.
        background.position = CGPoint(x: parentScene.frame.midX, y: parentScene.frame.midY)
        background.zPosition = -1
        parentScene.addChild(background)
        
        // 5. Cria a ação de animação que troca entre os frames carregados.
        let animationAction = SKAction.animate(with: backgroundFrames, timePerFrame: 0.5)
        let repeatAction = SKAction.repeatForever(animationAction) // Faz a animação rodar em loop.
        
        // 6. Executa a animação no nó do fundo.
        background.run(repeatAction)
    }
}
