//
//  MenuScene_iphone.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 05/09/25.
//

import SpriteKit

class MenuScene_iphone: SKScene {
    
    // MARK: - Componentes
    
    private let settingsButtonFactory = SettingsButtonComponent()
    private let settingsOverlayFactory = SettingsOverlayComponent()
    
    private var settingsButton: SKSpriteNode?
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        UserDefaults.standard.register(defaults: ["isValidationModeEnabled": true])
        UserDefaults.standard.register(defaults: ["isCameraPreviewEnabled": true])
        
        setupLabels()
        AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")

        if !isOnboarding {
            setupSettingsButton()
        }
    }
    
    // MARK: - Configuração da UI
        
    func setupLabels() {
        
        // Aplica a tradução aos botões existentes
        let labelNames = ["JogarLabel", "TutorialLabel"]
        for name in labelNames {
            if let label = self.childNode(withName: "//\(name)") as? SKLabelNode {
                label.fontName = "Ari-W9500Bold"
                
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
            
            let shadowOffset = CGPoint(x: 4, y: -4)
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
    
    // Usa o componente para criar o botão de configurações
    func setupSettingsButton() {
        settingsButton = settingsButtonFactory.makeButton()
        settingsButton?.name = "SettingsButton"
        
        // Para mover MAIS PARA BAIXO, aumente este valor
        let topPadding: CGFloat = 100
        
        // Para mover MAIS PARA A ESQUERDA, aumente este valor
        let trailingPadding: CGFloat = 150
        
        settingsButton?.position = CGPoint(
            x: self.frame.maxX - trailingPadding,
            y: self.frame.maxY - topPadding
        )
        
        settingsButton?.size = CGSize(width: 90, height: 90)
        settingsButton?.zPosition = 10
        
        if let button = settingsButton {
            self.addChild(button)
        }
    }

    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Verifica se há um settings overlay ativo
        if let settingsOverlay = self.childNode(withName: "settingsOverlay") {
            let touchedNodes = self.nodes(at: location)

            for node in touchedNodes {
                switch node.name {
                case "closeSettingsButton":
                    settingsOverlay.run(SKAction.fadeOut(withDuration: 0.3)) {
                        settingsOverlay.removeFromParent()
                    }
                    return
                case "cameraToggleButton":
                    let currentValue = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
                    UserDefaults.standard.set(!currentValue, forKey: "isCameraPreviewEnabled")
                    settingsOverlayFactory.updateToggleButtons(on: settingsOverlay)
                    return
                case "validationToggleButton":
                    let currentValue = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
                    UserDefaults.standard.set(!currentValue, forKey: "isValidationModeEnabled")
                    settingsOverlayFactory.updateToggleButtons(on: settingsOverlay)
                    return
                default:
                    continue
                }
            }
            
            return
        }
        
        let touchedNode = atPoint(location)
        guard let nodeName = touchedNode.name else { return }

        switch nodeName {
        case "SettingsButton":
            // Usa o componente para mostrar o overlay de settings
            if self.childNode(withName: "settingsOverlay") == nil {
                let settingsOverlay = settingsOverlayFactory.makeOverlay(for: self, inMenuScene: true)
                settingsOverlay.run(SKAction.fadeIn(withDuration: 0.3))
                self.addChild(settingsOverlay)
            }

        case "GestureMode", "JogarLabel":
            let buttonToAnimate = (nodeName == "JogarLabel") ? touchedNode.parent : touchedNode
            if let button = buttonToAnimate {
                button.runButtonAnimation {
                    self.transitionToScene(named: "GameScene", isGestureMode: true)
                }
            }

        case "ButtonMode", "TutorialLabel":
            let buttonToAnimate = (nodeName == "TutorialLabel") ? touchedNode.parent : touchedNode
            if let button = buttonToAnimate {
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
                gameScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
            }
        } else if sceneName == "ButtonMode" {
            if let buttonScene = SKScene(fileNamed: "ButtonMode") {
                buttonScene.scaleMode = self.scaleMode
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
