//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - Componentes
    
    private let settingsButtonFactory = SettingsButtonComponent()
    private let settingsOverlayFactory = SettingsOverlayComponent()
    private var settingsButton: SKSpriteNode?
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        UserDefaults.standard.register(defaults: ["isValidationModeEnabled": true])
        UserDefaults.standard.register(defaults: ["isCameraPreviewEnabled": true])
        UserDefaults.standard.register(defaults: ["isMusicEnabled": true])
        UserDefaults.standard.register(defaults: ["isSfxEnabled": true])
        
        setupLabels()
        AudioManager.shared.applyAudioSettings() // Garante que a música comece com o estado correto
        AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")
        AudioManager.shared.setSoundEffectVolume(to: 0.5)

        if !isOnboarding {
            setupSettingsButton()
        }
    }
    
    // MARK: - Configuração da UI
    
    func setupLabels() {
        let labelNames = ["JogarLabel", "TutorialLabel"]
        for name in labelNames {
            if let label = self.childNode(withName: "//\(name)") as? SKLabelNode {
                label.fontName = "Ari-W9500Bold"
                label.fontSize = 35
                if name == "JogarLabel" {
                    label.text = NSLocalizedString("menu_play", comment: "Play button text")
                } else if name == "TutorialLabel" {
                    label.text = NSLocalizedString("menu_tutorial", comment: "Tutorial/Buttons mode button text")
                }
            }
        }
        
        if let titleNode = self.childNode(withName: "//Title"), let titleLabel = titleNode.childNode(withName: "TitleLabel") as? SKLabelNode {
            titleLabel.text = NSLocalizedString("menu_gamemode_title", comment: "Game mode title")
            titleLabel.fontName = "Ari-W9500Bold"
            titleLabel.fontSize = 36
            titleLabel.zPosition = 5
            let shadowOffset = CGPoint(x: 5, y: -5)
            let shadowColor = SKColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1.0)
            addShadow(to: titleLabel, in: titleNode, offset: shadowOffset, color: shadowColor)
        }
        
        let buttonNames = ["GestureMode", "ButtonMode"]
        for name in buttonNames {
            if let buttonNode = self.childNode(withName: "//\(name)") as? SKSpriteNode {
                buttonNode.texture?.filteringMode = .nearest
                buttonNode.texture?.usesMipmaps = false
            }
        }
    }
    
    func setupSettingsButton() {
        settingsButton = settingsButtonFactory.makeButton()
        settingsButton?.name = "SettingsButton"
        settingsButton?.position = CGPoint(x: 440, y: 300)
        settingsButton?.size = CGSize(width: 70, height: 70)
        settingsButton?.zPosition = 10
        if let button = settingsButton { self.addChild(button) }
    }

    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Verifica se há um settings overlay ativo
        if let settingsOverlay = self.childNode(withName: "settingsOverlay") {
            let nodeAtPoint = settingsOverlay.atPoint(touch.location(in: settingsOverlay))
            switch nodeAtPoint.name {
            case "closeSettingsButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                settingsOverlay.removeFromParent()
                
                return

            case "cameraToggleButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let currentValue = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
                UserDefaults.standard.set(!currentValue, forKey: "isCameraPreviewEnabled")
                settingsOverlayFactory.updateToggleButtons(on: settingsOverlay)
                return

            case "validationToggleButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let currentValue = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
                UserDefaults.standard.set(!currentValue, forKey: "isValidationModeEnabled")
                settingsOverlayFactory.updateToggleButtons(on: settingsOverlay)
                return
            
            // --- LÓGICA CORRIGIDA ---
            case "musicToggleButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let isEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
                UserDefaults.standard.set(!isEnabled, forKey: "isMusicEnabled")
                AudioManager.shared.setMusicMuted(isMuted: isEnabled)
                settingsOverlayFactory.updateToggleButtons(on: settingsOverlay)
                return

            case "sfxToggleButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let isEnabled = UserDefaults.standard.bool(forKey: "isSfxEnabled")
                UserDefaults.standard.set(!isEnabled, forKey: "isSfxEnabled")
                AudioManager.shared.setSfxMuted(isMuted: isEnabled)
                settingsOverlayFactory.updateToggleButtons(on: settingsOverlay)
                return
                
            default:
                // Se tocou no fundo do overlay, não faz nada
                return
            }
        }
        
        let touchedNode = atPoint(location)
        guard let nodeName = touchedNode.name else { return }

        switch nodeName {
        case "SettingsButton":
            if self.childNode(withName: "settingsOverlay") == nil {
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let settingsOverlay = settingsOverlayFactory.makeOverlay(for: self, inMenuScene: true)
                self.addChild(settingsOverlay)
            }

        case "GestureMode", "JogarLabel":
            AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
            let buttonToAnimate = (nodeName == "JogarLabel") ? touchedNode.parent : touchedNode
            if let button = buttonToAnimate {
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                button.runButtonAnimation {
                    self.transitionToScene(named: "GameScene", isGestureMode: true)
                }
            }

        case "ButtonMode", "TutorialLabel":
            AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
            let buttonToAnimate = (nodeName == "TutorialLabel") ? touchedNode.parent : touchedNode
            if let button = buttonToAnimate {
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                button.runButtonAnimation {
                    self.transitionToScene(named: "ButtonMode", isGestureMode: false)
                }
            }
            
        default:
            break
        }
    }
    // MARK: - Navegação
    
    func transitionToScene(named sceneName: String, isGestureMode: Bool) {
        if sceneName == "GameScene" {
            if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                gameScene.startInGestureMode = isGestureMode
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
            }
        } else if sceneName == "ButtonMode" {
            if let buttonScene = SKScene(fileNamed: "ButtonMode") {
                buttonScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(buttonScene, transition: transition)
            }
        }
    }
    
    // MARK: - Funções Auxiliares

    private func addShadow(to label: SKLabelNode, in parentNode: SKNode, offset: CGPoint, color: SKColor) {
        let shadowLabel = label.copy() as! SKLabelNode
        
        shadowLabel.fontColor = color
        
        shadowLabel.position = CGPoint(x: label.position.x + offset.x, y: label.position.y + offset.y)
        
        shadowLabel.zPosition = label.zPosition - 1
        
        parentNode.addChild(shadowLabel)
    }
}

// MARK: - Animação de Botão Adaptativa

extension SKNode {
    func runButtonAnimation(completion: @escaping () -> Void) {
        
        let initialScale = self.xScale

        var pressedScale: CGFloat
        
        if DeviceHelper.isIPad {
            pressedScale = initialScale * 1.1
        } else {
            pressedScale = initialScale * 1.1
        }
        
        let scaleDown = SKAction.scale(to: pressedScale, duration: 0.08)
        let scaleUp = SKAction.scale(to: initialScale, duration: 0.08)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp, SKAction.run(completion)])
        self.run(sequence)
    }
}
