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
        self.scoreLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
            self.scoreLabel.fontSize = 70
            self.scoreLabel.position = CGPoint(x: 0, y: 215)
            case .pad:
            self.scoreLabel.fontSize = 90
            self.scoreLabel.position = CGPoint(x: 0, y: 250)
            default:
            self.scoreLabel.fontSize = 90
            self.scoreLabel.position = CGPoint(x: 0, y: 250)
        }
       
        self.scoreLabel.fontColor = UIColor(red: 0.294, green: 0.529, blue: 0.192, alpha: 1.0)
        self.scoreLabel.text = "\(self.scoreCount)"
        self.scoreLabel.zPosition = Layer.points.rawValue
        
        // Adiciona o label diretamente na cena para que ele se torne visível.
        self.parentScene.addChild(self.scoreLabel)
    }

    // MARK: - Métodos Públicos
    
    /// Adiciona um valor à pontuação total e atualiza o texto na tela.
    /// - Parameter point: A quantidade de pontos a ser adicionada.
    /// Deixei ela aqui pra gente poder chamar ela de qualquer inimigo, passando so quantos pontos aquele inimigo dropou
    func addScore(point: Int) {
        self.scoreCount += point
        self.scoreLabel.text = "\(self.scoreCount)"
    }
    
    func decreaseScore(point: Int) {
        self.scoreCount -= point
        self.scoreLabel.text = "\(self.scoreCount)"
    }
}
