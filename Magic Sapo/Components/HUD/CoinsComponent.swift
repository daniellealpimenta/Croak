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
    var labelShadow: SKLabelNode! // Propriedade para a sombra
    var coinIcon: SKSpriteNode
    private var parentScene: SKScene
    
    private let totalCoinsKey = "totalCoins"
    
    // MARK: - Inicialização

    init(parent: SKScene) {
        self.parentScene = parent
                
        self.coinsLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        self.coinIcon = SKSpriteNode(imageNamed: "Coin")
        
    switch UIDevice.current.userInterfaceIdiom {
        case .phone:
        self.coinsLabel.fontSize = 25
        self.coinIcon.size = CGSize(width: 35, height: 35)
        case .pad:
        self.coinsLabel.fontSize = 50
        self.coinIcon.size = CGSize(width: 60, height: 60)
        default:
        self.coinsLabel.fontSize = 70
        self.coinIcon.size = CGSize(width: 60, height: 60)
    }
        
        self.coinsLabel.fontColor = UIColor(red: 1, green: 0.7764705882352941, blue: 0.3568627450980392, alpha: 1.0)
        self.coinsLabel.horizontalAlignmentMode = .left
        self.coinsLabel.verticalAlignmentMode = .center
        self.coinsLabel.text = "\(self.sessionCoins)"
        self.coinIcon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.coinsLabel.zPosition = 100
        self.coinIcon.zPosition = 100

        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.coinIcon.position = CGPoint(x: -150, y: 300)
        default:
            self.coinIcon.position = CGPoint(x: -450, y: 300)
        }
        self.coinsLabel.position = CGPoint(
            x: self.coinIcon.position.x + self.coinIcon.size.width / 2,
            y: self.coinIcon.position.y
        )
        
        let shadowOffset = CGPoint(x: 3, y: -3)

        // Atribui à PROPRIEDADE da classe
        self.labelShadow = self.coinsLabel.copy() as? SKLabelNode
        self.labelShadow.fontColor = .black
        self.labelShadow.position = CGPoint(x: self.coinsLabel.position.x + shadowOffset.x,
                                       y: self.coinsLabel.position.y + shadowOffset.y)
        self.labelShadow.zPosition = self.coinsLabel.zPosition - 1
        
        //        // Cria e configura a SOMBRA PARA O ÍCONE
        //        let iconShadow = self.coinIcon.copy() as! SKSpriteNode
        //        iconShadow.color = .black
        //        iconShadow.colorBlendFactor = 1.0
        //        iconShadow.position = CGPoint(x: self.coinIcon.position.x + shadowOffset.x,
        //                                      y: self.coinIcon.position.y + shadowOffset.y)
        //        iconShadow.zPosition = self.coinIcon.zPosition - 1
                
                //self.parentScene.addChild(iconShadow)

        self.parentScene.addChild(self.coinIcon)
        self.parentScene.addChild(self.labelShadow)
        self.parentScene.addChild(self.coinsLabel)
    }
    
    // MARK: - Métodos Públicos

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            let milhao = Double(number) / 1_000_000.0
            let milhaoCerto = floor(milhao * 10) / 10.0
            return String(format: "%.1fM", milhaoCerto)
            
        } else if number >= 1_000 {
            let mil = Double(number) / 1_000.0
            let milCerto = floor(mil * 10) / 10.0
            return String(format: "%.1fK", milCerto)
            
        } else {
            return "\(number)"
        }
    }

    func addCoins(coins: Int) {
        self.sessionCoins += coins
        
        let formattedText = formatNumber(self.sessionCoins)
        self.coinsLabel.text = formattedText
        self.labelShadow.text = formattedText
        
    }
    
    func saveSessionCoins() {
        // Se não houver moedas na sessão, não faz nada.
        guard sessionCoins > 0 else { return }
        
        let currentTotal = UserDefaults.standard.integer(forKey: totalCoinsKey)
        let newTotal = currentTotal + self.sessionCoins
        UserDefaults.standard.set(newTotal, forKey: totalCoinsKey)
        
        print("\(self.sessionCoins) moedas da sessão foram salvas. Novo total: \(newTotal)")
    }


    /// Atualiza o texto do placar para um valor específico.
    func updateLabel(with value: Int) {
        // USA A FUNÇÃO DE FORMATAÇÃO
        let formattedText = formatNumber(value)
        self.coinsLabel.text = formattedText
        self.labelShadow.text = formattedText
    }
    
    
}
