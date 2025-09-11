//
//  SettingsOverlayComponent.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 09/09/25.
//

import SpriteKit
import UIKit


class SettingsOverlayComponent {
    
    func makeOverlay(for scene: SKScene, inMenuScene: Bool) -> SKNode {
        // Garante que a view exista para podermos pegar o tamanho da tela.
        guard let view = scene.view else { return SKNode() }
        
        let inMenuScene = inMenuScene
        
        let settingsOverlay = SKNode()
        settingsOverlay.name = "settingsOverlay"
        settingsOverlay.zPosition = 200
        
        let colorBrown = UIColor(red: 0.2901960784313726, green: 0.1450980392156863, blue: 0.06666666666666667, alpha: 1.0)
        
        if !inMenuScene {
            // 1. Encontra o centro da TELA.
            let viewCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            settingsOverlay.position = scene.convertPoint(fromView: viewCenter)
            
            // 3. Aplica uma escala inversa para anular o zoom da cena.
            let scaleX = scene.xScale != 0 ? 1.0 / scene.xScale : 1.0
            settingsOverlay.setScale(scaleX) // Usamos setScale para ser mais seguro
        }

        // --- Fundo (usa o tamanho da TELA) ---
        let background = SKSpriteNode(color: .black, size: scene.size)
        background.name = "settingsBackgroundBlocker"
        background.isUserInteractionEnabled = false
        background.position = .zero // Posição (0,0) relativa ao nó 'settingsOverlay'
        background.alpha = 0.7
        settingsOverlay.addChild(background)
        
        if DeviceHelper.isIPhone {
            
            let panel = SKSpriteNode(imageNamed: "madeiraIphone")

            // largura alvo (75% da tela) mantendo proporção da textura
            if let texSize = panel.texture?.size() {
                let aspect = texSize.height / texSize.width
                panel.size = CGSize(width: inMenuScene ? scene.frame.width * 1.2 : scene.frame.width * 0.5,
                                    height: inMenuScene ? scene.frame.width * 1.2 * aspect : scene.frame.width * 0.5 * aspect)
            }
            panel.position = .zero
            panel.zPosition = 0
            settingsOverlay.addChild(panel)
            
            let closeButton = SKSpriteNode(imageNamed: "botaoClose")
            closeButton.name = "closeSettingsButton"
            closeButton.size = inMenuScene ? CGSize(width: 85, height: 85) : CGSize(width: 50, height: 50)
            closeButton.position = CGPoint(
                x: inMenuScene ? panel.position.x + (panel.size.width / 4) : panel.position.x + (panel.size.width / 4),
                y: inMenuScene ? panel.position.y + (panel.size.height / 1.59) : panel.position.y + (panel.size.height / 1.7)
            )
            closeButton.zPosition = 1
            settingsOverlay.addChild(closeButton)
            
            let cameraToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
            cameraToggleButton.name = "cameraToggleButton"
            cameraToggleButton.fontSize = inMenuScene ? 26 : 16
            cameraToggleButton.zPosition = 1
            cameraToggleButton.fontColor = colorBrown
            cameraToggleButton.position = CGPoint(x: 0, y: panel.position.y + (panel.size.height / 5.5))
            panel.addChild(cameraToggleButton)
            
            let validationToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
            validationToggleButton.name = "validationToggleButton"
            validationToggleButton.fontSize = inMenuScene ? 26 : 16
            validationToggleButton.zPosition = 1
            validationToggleButton.fontColor = colorBrown
            validationToggleButton.position = CGPoint(x: 0, y: cameraToggleButton.position.y - (panel.size.height / 9))
            panel.addChild(validationToggleButton)
            
        } else {
            
            let panel = SKSpriteNode(imageNamed: "madeiraIpad")

            // largura alvo (75% da tela) mantendo proporção da textura
            if let texSize = panel.texture?.size() {
                let aspect = texSize.height / texSize.width
                panel.size = CGSize(width: view.frame.width * 0.75,
                                    height: view.frame.width * 0.75 * aspect)
            }
            panel.position = .zero
            panel.zPosition = 0
            settingsOverlay.addChild(panel)
            
            let closeButton = SKSpriteNode(imageNamed: "botaoClose")
            closeButton.name = "closeSettingsButton"
            closeButton.size = CGSize(width: 70, height: 70)
            closeButton.position = CGPoint(
                x: panel.position.x + (panel.size.width / 2.02),
                y: inMenuScene ? panel.position.y + (panel.size.height / 3.15) : panel.position.y + (panel.size.height / 2.97)
            )
            settingsOverlay.addChild(closeButton)
            
            let cameraToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
            cameraToggleButton.name = "cameraToggleButton"
            cameraToggleButton.fontSize = 23
            cameraToggleButton.zPosition = 1
            cameraToggleButton.fontColor = colorBrown
            cameraToggleButton.position = CGPoint(x: 0, y: panel.position.y + (panel.size.height / 7.5))
            panel.addChild(cameraToggleButton)
            
            let validationToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
            validationToggleButton.name = "validationToggleButton"
            validationToggleButton.fontSize = 23
            validationToggleButton.zPosition = 1
            validationToggleButton.fontColor = colorBrown
            validationToggleButton.position = CGPoint(x: 0, y: cameraToggleButton.position.y - (panel.size.height / 15))
            panel.addChild(validationToggleButton)
            
        }
        
        updateLabels(on: settingsOverlay)
        
        return settingsOverlay
    }
    
    func updateLabels(on overlay: SKNode) {
        // Encontra os nós de label pelo nome dentro do overlay especificado
        if let validationToggle = overlay.childNode(withName: "//validationToggleButton") as? SKLabelNode {
            let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
            let stateString = isValidationEnabled ? NSLocalizedString("state_on", comment: "") : NSLocalizedString("state_off", comment: "")
            let baseString = NSLocalizedString("settings_validation_mode", comment: "e.g., Validation Mode: On")
            validationToggle.text = String(format: baseString, stateString)
        }
        
        if let cameraToggle = overlay.childNode(withName: "//cameraToggleButton") as? SKLabelNode {
            let isCameraEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
            let stateString = isCameraEnabled ? NSLocalizedString("state_on", comment: "") : NSLocalizedString("state_off", comment: "")
            let baseString = NSLocalizedString("settings_camera_preview", comment: "e.g., Camera Preview: On")
            cameraToggle.text = String(format: baseString, stateString)
        }
    }

}
