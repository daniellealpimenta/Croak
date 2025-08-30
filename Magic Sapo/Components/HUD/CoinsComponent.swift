//
//  CoinsComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//

import SpriteKit

/// Um componente que gerencia o estado e a exibição das moedas do jogador.
class CoinsComponent {
    
    // MARK: - Propriedades
    
    var coinsCount: Int
    var coinsLabel: SKLabelNode
    var coinIcon: SKSpriteNode
    private var parentScene: SKScene
    
    // MARK: - Inicialização

    /// Configura o placar de moedas no canto superior esquerdo da tela.
    /// - Parameter parent: A cena que será a "dona" deste componente.
    init(parent: SKScene) {
        self.parentScene = parent
        self.coinsCount = 0
        
        // --- 1. Cria e estiliza os nós. ---
        self.coinsLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        self.coinIcon = SKSpriteNode(imageNamed: "Coin")
        
        // Lógica de tamanho adaptativo
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.coinsLabel.fontSize = 35
            self.coinIcon.size = CGSize(width: 35, height: 35)
        case .pad:
            self.coinsLabel.fontSize = 70
            self.coinIcon.size = CGSize(width: 60, height: 60)
        default:
            self.coinsLabel.fontSize = 70
            self.coinIcon.size = CGSize(width: 60, height: 60)
        }
        
        self.coinsLabel.fontColor = .yellow
        self.coinsLabel.horizontalAlignmentMode = .left
        self.coinsLabel.verticalAlignmentMode = .center
        self.coinsLabel.text = "\(self.coinsCount)"
        
        self.coinIcon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Garante que a UI fique na frente
        self.coinsLabel.zPosition = Layer.ui.rawValue
        self.coinIcon.zPosition = Layer.ui.rawValue

        // --- 2. LÓGICA DE POSICIONAMENTO ADAPTATIVO ---
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            // --- Lógica para iPhone: Posicionar no centro ---
            self.coinIcon.position = CGPoint(x: -150, y: 300)
            
            // Posiciona o LABEL da moeda à direita do ícone (que está no centro).
            self.coinsLabel.position = CGPoint(
                x: self.coinIcon.position.x + self.coinIcon.size.width / 2 + 10,
                y: self.coinIcon.position.y
            )
            
        default: // iPad e outros casos
            // --- Lógica para iPad: Manter no canto superior esquerdo ---
            let sceneWidth = parentScene.size.width
            let yPosition: CGFloat = 250
            let leftMargin: CGFloat = 50
            
            // Posiciona o ÍCONE da moeda no canto superior esquerdo.
            self.coinIcon.position = CGPoint(
                x: -450,
                y: 300
            )
            
            // Posiciona o LABEL da moeda à direita do ícone.
            self.coinsLabel.position = CGPoint(
                x: self.coinIcon.position.x + self.coinIcon.size.width / 2 + 10,
                y: self.coinIcon.position.y
            )
        }
        
        // --- 3. Adiciona os nós na cena ---
        self.parentScene.addChild(self.coinIcon)
        self.parentScene.addChild(self.coinsLabel)
    }
    
    // MARK: - Métodos Públicos
    
    func addCoins(coins: Int) {
        self.coinsCount += coins
        self.coinsLabel.text = "\(self.coinsCount)"
    }
}
