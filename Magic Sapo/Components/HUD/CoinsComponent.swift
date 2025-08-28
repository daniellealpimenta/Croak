//
//  ScoreComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//

import SpriteKit

/// Um componente que gerencia o estado e a exibição da pontuação do jogador.
class CoinsComponent {
    
    // MARK: - Propriedades
    
    /// O valor numérico atual da pontuação.
    var coinsCount: Int
    
    /// O nó de texto (label) que exibe a pontuação na tela.
    var coinsLabel: SKLabelNode
    
    /// O nó de imagem que representa a moeda.
    var coinIcon: SKSpriteNode // <<< NOVA PROPRIEDADE
    
    /// Uma referência à cena principal onde o placar será exibido.
    private var parentScene: SKScene
    
    // MARK: - Inicialização
    
    /// Configura o placar inicial.
    /// - Parameter parent: A cena que será a "dona" deste componente de moedas.
    init(parent: SKScene) {
        self.parentScene = parent
        self.coinsCount = 0
        
        // --- 1. Cria e estiliza o nó de texto (SKLabelNode) para as moedas. ---
        self.coinsLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        self.coinsLabel.fontSize = 50
        self.coinsLabel.fontColor = .yellow
        self.coinsLabel.horizontalAlignmentMode = .left
        self.coinsLabel.verticalAlignmentMode = .center 
        // A posição será ajustada após a criação do ícone.
        self.coinsLabel.text = "\(self.coinsCount)"
        self.coinsLabel.zPosition = Layer.ui.rawValue // Define as moedas para a camada 100
        
        // --- 2. Cria o nó de imagem para a moeda. ---
        // Certifique-se de ter um asset de imagem chamado "coinIcon" (ou o nome que você usar)
        self.coinIcon = SKSpriteNode(imageNamed: "Coin")
        self.coinIcon.size = CGSize(width: 60, height: 60)
        self.coinIcon.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.coinIcon.zPosition = Layer.ui.rawValue
    
        // A posição base para o conjunto (ícone + label)
        let basePosition = CGPoint(x: -450, y: 300) // Sua posição original
        
        // Posição do ícone: Começa na basePosition
        self.coinIcon.position = basePosition
        
        // Posição do label: Fica à direita do ícone, com um pequeno espaçamento
        self.coinsLabel.position = CGPoint(
            x: self.coinIcon.position.x + self.coinIcon.size.width + 10,
            y: basePosition.y
        )
        
        self.parentScene.addChild(self.coinIcon)
        self.parentScene.addChild(self.coinsLabel)
    }

    // MARK: - Métodos Públicos
    
    /// Adiciona um valor à qnt de moedas total e atualiza o texto na tela.
    /// - Parameter coins: A quantidade de moedas a ser adicionada.
    func addCoins(coins: Int) {
        self.coinsCount += coins
        self.coinsLabel.text = "\(self.coinsCount)"
    }
}
