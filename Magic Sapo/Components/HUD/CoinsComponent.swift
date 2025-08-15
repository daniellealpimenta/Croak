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
    
    /// Uma referência à cena principal onde o placar será exibido.
    private var parentScene: SKScene
    
    // MARK: - Inicialização
    
    /// Configura o placar inicial.
    /// - Parameter parent: A cena que será a "dona" deste componente de moedas.
    init(parent: SKScene) {
        self.parentScene = parent
        self.coinsCount = 0
        
        // Cria e estiliza o nó de texto (SKLabelNode).
        self.coinsLabel = SKLabelNode(fontNamed: "PixelifySans-Regular")
        self.coinsLabel.fontSize = 50
        self.coinsLabel.fontColor = .yellow
        self.coinsLabel.position = CGPoint(x: -450, y: 300)
        self.coinsLabel.text = "\(self.coinsCount)"
        
        // Adiciona o label diretamente na cena para que ele se torne visível.
        self.parentScene.addChild(self.coinsLabel)
    }

    // MARK: - Métodos Públicos
    
    /// Adiciona um valor à qnt de moedas  total e atualiza o texto na tela.
    /// - Parameter point: A quantidade de moedas a ser adicionada.
    /// Deixei ela aqui pra gente poder chamar ela de qualquer inimigo, passando so quantos pontos aquele inimigo dropou
    func addCoins(coins: Int) {
        self.coinsCount += coins
        self.coinsLabel.text = "\(self.coinsCount)"
    }
}
