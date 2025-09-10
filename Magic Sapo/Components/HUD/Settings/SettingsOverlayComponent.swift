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
        
        // --- LÓGICA DE POSICIONAMENTO E ESCALA ---
        // 1. Encontra o centro da TELA.
        let viewCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        // 2. Converte essa coordenada para o sistema da CENA.
        settingsOverlay.position = scene.convertPoint(fromView: viewCenter)
        
        // 3. Aplica uma escala inversa para anular o zoom da cena.
        let scaleX = scene.xScale != 0 ? 1.0 / scene.xScale : 1.0
        settingsOverlay.setScale(scaleX) // Usamos setScale para ser mais seguro

        // --- Fundo (usa o tamanho da TELA) ---
        let background = SKShapeNode(rectOf: view.bounds.size)
        background.name = "settingsBackgroundBlocker"
        background.isUserInteractionEnabled = false
        background.position = .zero // Posição (0,0) relativa ao nó 'settingsOverlay'
        background.fillColor = SKColor.black
        background.alpha = 0.7
        settingsOverlay.addChild(background)
        
        // --- Painel (usa o tamanho da TELA para o cálculo) ---
        let panelSize = inMenuScene ? CGSize(width: view.frame.width * 0.8, height: view.frame.height * 0.7) : CGSize(width: view.frame.width * 0.8, height: view.frame.height * 0.45)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = .zero // Centralizado no seu nó pai ('settingsOverlay')
        settingsOverlay.addChild(panel)
        
        // --- O resto do seu código de criação de título e botões não precisa mudar ---
        let titleLabel = SKLabelNode(text: NSLocalizedString("settings_title", comment: "Settings panel title"))
        titleLabel.fontName = "Ari-W9500Bold"
        titleLabel.fontSize = inMenuScene ? 30 : 25
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: (panelSize.height / 2) - 60)
        panel.addChild(titleLabel)
        
        let closeButton = SKSpriteNode(imageNamed: "botaoClose")
        closeButton.name = "closeSettingsButton"
        closeButton.size = inMenuScene ? CGSize(width: 50, height: 50) : CGSize(width: 40, height: 40)
        closeButton.position = inMenuScene ? CGPoint(x: (panelSize.width / 2) - 40, y: (panelSize.height / 2) - 35) : CGPoint(x: (panelSize.width / 2) - 35, y: (panelSize.height / 2) - 35)
        panel.addChild(closeButton)
        
        let cameraToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        cameraToggleButton.name = "cameraToggleButton"
        cameraToggleButton.fontSize = inMenuScene ? 28 : 20
        cameraToggleButton.fontColor = .white
        cameraToggleButton.position = CGPoint(x: 0, y: titleLabel.position.y - 80)
        panel.addChild(cameraToggleButton)
        
        let validationToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        validationToggleButton.name = "validationToggleButton"
        validationToggleButton.fontSize = inMenuScene ? 28 : 20
        validationToggleButton.fontColor = .white
        validationToggleButton.position = CGPoint(x: 0, y: cameraToggleButton.position.y - 60)
        panel.addChild(validationToggleButton)
        
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
