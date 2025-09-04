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
    
    var sessionCoins: Int = 0
    
    var coinsLabel: SKLabelNode
    var coinIcon: SKSpriteNode
    private var parentScene: SKScene
    
    // A chave usada para salvar e carregar o TOTAL de moedas no dispositivo.
    private let totalCoinsKey = "totalCoins"
    
    // MARK: - Inicialização

    /// Configura o placar de moedas no canto superior esquerdo da tela.
    /// - Parameter parent: A cena que será a "dona" deste componente.
    init(parent: SKScene) {
        self.parentScene = parent
                
        // --- 1. Cria e estiliza os nós. ---
        self.coinsLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        self.coinIcon = SKSpriteNode(imageNamed: "Coin")
        
        // Lógica de tamanho adaptativo (sem alterações)
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
        
        self.coinsLabel.text = "\(self.sessionCoins)"
        
        self.coinIcon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.coinsLabel.zPosition = 100
        self.coinIcon.zPosition = 100

        // Lógica de posicionamento adaptativo (sem alterações)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.coinIcon.position = CGPoint(x: -150, y: 300)
            self.coinsLabel.position = CGPoint(
                x: self.coinIcon.position.x + self.coinIcon.size.width / 2 + 10,
                y: self.coinIcon.position.y
            )
            
        default:
            self.coinIcon.position = CGPoint(
                x: -450,
                y: 300
            )
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
        self.sessionCoins += coins
        self.coinsLabel.text = "\(self.sessionCoins)"
        
        // 1. Carrega o total que já estava salvo no dispositivo.
        let currentTotal = UserDefaults.standard.integer(forKey: totalCoinsKey)
        
        // 2. Soma as novas moedas ao total.
        let newTotal = currentTotal + coins
        
        // 3. Salva o novo total de volta no dispositivo.
        UserDefaults.standard.set(newTotal, forKey: totalCoinsKey)
    }
}
