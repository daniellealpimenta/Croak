//
//  ScoreComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//

import SpriteKit

/// Um componente que gerencia o estado e a exibição da pontuação do jogador.
class ScoreComponent {
    
    // MARK: - Propriedades
    
    /// O valor numérico atual da pontuação.
    var scoreCount: Int
    
    /// O nó de texto (label) que exibe a pontuação na tela.
    var scoreLabel: SKLabelNode
    
    /// Uma referência à cena principal onde o placar será exibido.
    private var parentScene: SKScene
    
    // MARK: - Inicialização
    
    /// Configura o placar inicial.
    /// - Parameter parent: A cena que será a "dona" deste componente de pontuação.
    init(parent: SKScene) {
        self.parentScene = parent
        self.scoreCount = 0
        
        // Cria e estiliza o nó de texto (SKLabelNode).
        self.scoreLabel = SKLabelNode(fontNamed: "PixelifySans-Regular")
        self.scoreLabel.fontSize = 50
        self.scoreLabel.fontColor = .white
        self.scoreLabel.position = CGPoint(x: 0, y: 300) 
        self.scoreLabel.text = "Pontuação: \(self.scoreCount)"
        
        // Adiciona o label diretamente na cena para que ele se torne visível.
        self.parentScene.addChild(self.scoreLabel)
    }

    // MARK: - Métodos Públicos
    
    /// Adiciona um valor à pontuação total e atualiza o texto na tela.
    /// - Parameter point: A quantidade de pontos a ser adicionada.
    /// Deixei ela aqui pra gente poder chamar ela de qualquer inimigo, passando so quantos pontos aquele inimigo dropou
    func addScore(point: Int) {
        self.scoreCount += point
        self.scoreLabel.text = "Pontuação: \(self.scoreCount)"
    }
    
    func decreaseScore(point: Int) {
        self.scoreCount -= point
        self.scoreLabel.text = "Pontuação: \(self.scoreCount)"
    }
}
