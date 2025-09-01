//
//  PauseButtonComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 29/08/25.
//

import SpriteKit
import UIKit

protocol PauseButtonDelegate: AnyObject {
    func didTapPauseButton()
}

/// Um componente que gerencia a criação e a aparência do botão de pause.
class PauseButtonComponent {
    
    // MARK: - Propriedades
    
    let pauseButtonNode: SKSpriteNode
    weak var delegate: PauseButtonDelegate?
    private var parentScene: SKScene
    
    // MARK: - Inicialização
    
    init(parent: SKScene) {
        self.parentScene = parent
        
        // --- Estrutura de Configuração ---
        struct LayoutConfig {
            let position: CGPoint
            let size: CGSize
        }
        
        let config: LayoutConfig

        // --- Define as Configurações Baseadas no Dispositivo ---
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            config = LayoutConfig(
                position: CGPoint(x: 100, y: 300),
                size: CGSize(width: 50, height: 50)
            )
        default: // iPad e outros
            config = LayoutConfig(
                position: CGPoint(x: 400, y: 300),
                size: CGSize(width: 75, height: 75)
            )
        }
        
        // --- Aplica as Configurações ---
        self.pauseButtonNode = SKSpriteNode(imageNamed: "PauseButton")
        self.pauseButtonNode.name = "PauseButton"
        self.pauseButtonNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.pauseButtonNode.zPosition = Layer.ui.rawValue
        
        self.pauseButtonNode.position = config.position
        self.pauseButtonNode.size = config.size
        
        // Adiciona o botão na cena.
        parent.addChild(self.pauseButtonNode)
    }
}
