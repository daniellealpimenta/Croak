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
            let viewCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            settingsOverlay.position = scene.convertPoint(fromView: viewCenter)
            
            let scaleX = scene.xScale != 0 ? 1.0 / scene.xScale : 1.0
            settingsOverlay.setScale(scaleX)
        }

        // --- Fundo (usa o tamanho da TELA) ---
        let background = SKSpriteNode(color: .black, size: scene.size)
        background.name = "settingsBackgroundBlocker"
        background.isUserInteractionEnabled = false
        background.position = .zero
        background.alpha = 0.8
        settingsOverlay.addChild(background)
        
        if DeviceHelper.isIPhone {
            
            let panel = SKSpriteNode(imageNamed: "madeiraIphone")

            if let texSize = panel.texture?.size() {
                let aspect = texSize.height / texSize.width
                panel.size = CGSize(width: inMenuScene ? scene.frame.width * 1.3 : scene.frame.width * 0.54,
                                    height: inMenuScene ? scene.frame.width * 1.3 * aspect : scene.frame.width * 0.54 * aspect)
            }
            panel.position = .zero
            panel.zPosition = 0
            settingsOverlay.addChild(panel)
            
            let closeButton = SKSpriteNode(imageNamed: "botaoClose")
            closeButton.name = "closeSettingsButton"
            closeButton.size = inMenuScene ? CGSize(width: 85, height: 85) : CGSize(width: 50, height: 50)
            closeButton.position = CGPoint(
                x: inMenuScene ? panel.position.x + (panel.size.width / 4.36) : panel.position.x + (panel.size.width / 4.37),
                y: inMenuScene ? panel.position.y + (panel.size.height / 1.72) : panel.position.y + (panel.size.height / 1.85)
            )
            closeButton.zPosition = 1
            settingsOverlay.addChild(closeButton)
            
            // Preview Camera
            let cameraYPosition = panel.position.y + (panel.size.height / 7.6)
            
            let cameraLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            cameraLabel.text = NSLocalizedString("settings_camera_preview", comment: "")
            cameraLabel.fontSize = inMenuScene ? 28 : 15
            cameraLabel.fontColor = colorBrown
            cameraLabel.horizontalAlignmentMode = .left
            cameraLabel.position = CGPoint(x: -(panel.size.width / 5), y: cameraYPosition)
            cameraLabel.zPosition = 1
            panel.addChild(cameraLabel)

            let cameraToggleButton = SKSpriteNode(imageNamed: "botaoCameraOff")
            cameraToggleButton.name = "cameraToggleButton"
            cameraToggleButton.size = inMenuScene ? CGSize(width: 75, height: 75) : CGSize(width: 44, height: 44)
            cameraToggleButton.position = inMenuScene ? CGPoint(x: (panel.size.width / 6.8), y: cameraYPosition + 10) : CGPoint(x: (panel.size.width / 6.8), y: cameraYPosition + 6)
            cameraToggleButton.zPosition = 1
            panel.addChild(cameraToggleButton)
            
            // Validação
            let validationYPosition = cameraLabel.position.y - (panel.size.height / 9.1)
            
            let validationLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            validationLabel.text = NSLocalizedString("settings_validation_mode", comment: "")
            validationLabel.fontSize = inMenuScene ? 28 : 15
            validationLabel.fontColor = colorBrown
            validationLabel.horizontalAlignmentMode = .left
            validationLabel.position = CGPoint(x: -(panel.size.width / 5), y: validationYPosition)
            validationLabel.zPosition = 1
            panel.addChild(validationLabel)
            
            let validationToggleButton = SKSpriteNode(imageNamed: "botaoValidationOff")
            validationToggleButton.name = "validationToggleButton"
            validationToggleButton.size = inMenuScene ? CGSize(width: 75, height: 75) : CGSize(width: 44, height: 44)
            validationToggleButton.position = inMenuScene ? CGPoint(x: (panel.size.width / 6.8), y: validationYPosition + 10) : CGPoint(x: (panel.size.width / 6.8), y: validationYPosition + 6)
            validationToggleButton.zPosition = 1
            panel.addChild(validationToggleButton)
            
            // Música
            let musicYPosition = validationLabel.position.y - (panel.size.height / 9.1)
            
            let musicLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            musicLabel.text = NSLocalizedString("settings_music", comment: "")
            musicLabel.fontSize = inMenuScene ? 28 : 15
            musicLabel.fontColor = colorBrown
            musicLabel.horizontalAlignmentMode = .left
            musicLabel.position = CGPoint(x: -(panel.size.width / 5), y: musicYPosition)
            musicLabel.zPosition = 1
            panel.addChild(musicLabel)
            
            let musicToggleButton = SKSpriteNode(imageNamed: "botaoSomOff")
            musicToggleButton.name = "musicToggleButton"
            musicToggleButton.size = inMenuScene ? CGSize(width: 75, height: 75) : CGSize(width: 44, height: 44)
            musicToggleButton.position = inMenuScene ? CGPoint(x: (panel.size.width / 6.8), y: musicYPosition + 10) : CGPoint(x: (panel.size.width / 6.8), y: musicYPosition + 6)
            musicToggleButton.zPosition = 1
            panel.addChild(musicToggleButton)
            
            // Efeito Sonoro
            let sfxYPosition = musicLabel.position.y - (panel.size.height / 9.1)
            
            let sfxLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            sfxLabel.text = NSLocalizedString("settings_sfx", comment: "")
            sfxLabel.fontSize = inMenuScene ? 28 : 15
            sfxLabel.fontColor = colorBrown
            sfxLabel.horizontalAlignmentMode = .left
            sfxLabel.position = CGPoint(x: -(panel.size.width / 5), y: sfxYPosition)
            sfxLabel.zPosition = 1
            panel.addChild(sfxLabel)
            
            let sfxToggleButton = SKSpriteNode(imageNamed: "botaoSomOff")
            sfxToggleButton.name = "sfxToggleButton"
            sfxToggleButton.size = inMenuScene ? CGSize(width: 75, height: 75) : CGSize(width: 44, height: 44)
            sfxToggleButton.position = inMenuScene ? CGPoint(x: (panel.size.width / 6.8), y: sfxYPosition + 10) : CGPoint(x: (panel.size.width / 6.8), y: sfxYPosition + 6)
            sfxToggleButton.zPosition = 1
            panel.addChild(sfxToggleButton)
            
        } else { // Layout para iPad
            
            let panel = SKSpriteNode(imageNamed: "madeiraIpad")

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
            
            // Preview Camera
            let cameraYPosition = panel.position.y + (panel.size.height / 7.2)
            
            let cameraLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            cameraLabel.text = NSLocalizedString("settings_camera_preview", comment: "")
            cameraLabel.fontSize = 28
            cameraLabel.fontColor = colorBrown
            cameraLabel.horizontalAlignmentMode = .left
            cameraLabel.position = CGPoint(x: -(panel.size.width / 4), y: cameraYPosition)
            cameraLabel.zPosition = 1
            panel.addChild(cameraLabel)

            let cameraToggleButton = SKSpriteNode(imageNamed: "botaoCameraOff")
            cameraToggleButton.name = "cameraToggleButton"
            cameraToggleButton.size = CGSize(width: 65, height: 65) // Ajuste o tamanho
            cameraToggleButton.position = CGPoint(x: (panel.size.width / 4.5), y: cameraYPosition + 12)
            cameraToggleButton.zPosition = 1
            panel.addChild(cameraToggleButton)
            
            // Validação
            let validationYPosition = cameraLabel.position.y - (panel.size.height / 11)
            
            let validationLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            validationLabel.text = NSLocalizedString("settings_validation_mode", comment: "")
            validationLabel.fontSize = 28
            validationLabel.fontColor = colorBrown
            validationLabel.horizontalAlignmentMode = .left
            validationLabel.position = CGPoint(x: -(panel.size.width / 4), y: validationYPosition)
            validationLabel.zPosition = 1
            panel.addChild(validationLabel)
            
            let validationToggleButton = SKSpriteNode(imageNamed: "botaoValidationOff")
            validationToggleButton.name = "validationToggleButton"
            validationToggleButton.size = CGSize(width: 65, height: 65) // Ajuste o tamanho
            validationToggleButton.position = CGPoint(x: (panel.size.width / 4.5), y: validationYPosition + 12)
            validationToggleButton.zPosition = 1
            panel.addChild(validationToggleButton)
            
            // Música
            let musicYPosition = validationLabel.position.y - (panel.size.height / 10.5)
            
            let musicLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            musicLabel.text = NSLocalizedString("settings_music", comment: "")
            musicLabel.fontSize = 28
            musicLabel.fontColor = colorBrown
            musicLabel.horizontalAlignmentMode = .left
            musicLabel.position = CGPoint(x: -(panel.size.width / 4), y: musicYPosition)
            musicLabel.zPosition = 1
            panel.addChild(musicLabel)
            
            let musicToggleButton = SKSpriteNode(imageNamed: "botaoSomOff")
            musicToggleButton.name = "musicToggleButton"
            musicToggleButton.size = CGSize(width: 65, height: 65) // Ajuste o tamanho
            musicToggleButton.position = CGPoint(x: (panel.size.width / 4.5), y: musicYPosition + 12)
            musicToggleButton.zPosition = 1
            panel.addChild(musicToggleButton)
            
            // Efeito Sonoro
            let sfxYPosition = musicLabel.position.y - (panel.size.height / 10.6)
            
            let sfxLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            sfxLabel.text = NSLocalizedString("settings_sfx", comment: "")
            sfxLabel.fontSize = 28
            sfxLabel.fontColor = colorBrown
            sfxLabel.horizontalAlignmentMode = .left
            sfxLabel.position = CGPoint(x: -(panel.size.width / 4), y: sfxYPosition)
            sfxLabel.zPosition = 1
            panel.addChild(sfxLabel)
            
            let sfxToggleButton = SKSpriteNode(imageNamed: "botaoSomOff")
            sfxToggleButton.name = "sfxToggleButton"
            sfxToggleButton.size = CGSize(width: 65, height: 65) // Ajuste o tamanho
            sfxToggleButton.position = CGPoint(x: (panel.size.width / 4.5), y: sfxYPosition + 12)
            sfxToggleButton.zPosition = 1
            panel.addChild(sfxToggleButton)
        }
        
        // NOVO: A função agora é chamada de `updateToggleButtons` para maior clareza
        updateToggleButtons(on: settingsOverlay)
        
        return settingsOverlay
    }

    
    func updateToggleButtons(on overlay: SKNode) {
        // --- Atualiza o botão de Validação ---
        if let validationToggle = overlay.childNode(withName: "//validationToggleButton") as? SKSpriteNode {
            let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
            let textureName = isValidationEnabled ? "botaoValidationOn" : "botaoValidationOff"
            validationToggle.texture = SKTexture(imageNamed: textureName)
        }
        
        // --- Atualiza o botão de Câmera ---
        if let cameraToggle = overlay.childNode(withName: "//cameraToggleButton") as? SKSpriteNode {
            let isCameraEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
            let textureName = isCameraEnabled ? "botaoCameraOn" : "botaoCameraOff"
            cameraToggle.texture = SKTexture(imageNamed: textureName)
        }
        
        // --- Atualiza o botão de Musica ---
        if let musicToggle = overlay.childNode(withName: "//musicToggleButton") as? SKSpriteNode {
            let isMusicEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
            let textureName = isMusicEnabled ? "botaoSomOn" : "botaoSomOff"
            musicToggle.texture = SKTexture(imageNamed: textureName)
        }
        
        // --- Atualiza o botão de Efeito sonoro ---
        if let sfxToggle = overlay.childNode(withName: "//sfxToggleButton") as? SKSpriteNode {
            let isSfxEnabled = UserDefaults.standard.bool(forKey: "isSfxEnabled")
            let textureName = isSfxEnabled ? "botaoSomOn" : "botaoSomOff"
            sfxToggle.texture = SKTexture(imageNamed: textureName)
        }
    }

}
