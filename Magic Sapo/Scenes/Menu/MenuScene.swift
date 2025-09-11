//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - Nós da Cena
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    private let settingsButtonFactory = SettingsButtonComponent()
    private let settingsOverlayFactory = SettingsOverlayComponent()
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        // Registra um valor padrão para o modo de validação na primeira vez que o app abrir
        UserDefaults.standard.register(defaults: ["isValidationModeEnabled": true])
        UserDefaults.standard.register(defaults: ["isCameraPreviewEnabled": true])
        // --- CONFIGURAÇÃO EXISTENTE ---
        setupLabels()
        AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")
        AudioManager.shared.setSoundEffectVolume(to: 0.5)

        // --- NOVAS FUNÇÕES ---
        // Cria o botão de configurações e o overlay (que começa escondido)
        if !isOnboarding {
            let menuButton = settingsButtonFactory.makeButton()
            menuButton.position = CGPoint(x: frame.maxX - 70, y: frame.maxY - 100)
            addChild(menuButton)
        }
    }
    
    // MARK: - Configuração da UI
    
    // Função para configurar os labels e botões
    func setupLabels() {
        // Aplica a tradução aos botões "Jogar" e "Botões"
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
        
        // --- CÓDIGO CORRIGIDO ---
        // Adiciona a configuração de fonte e sombra para o TitleLabel
        if let titleNode = self.childNode(withName: "//Title"), let titleLabel = titleNode.childNode(withName: "TitleLabel") as? SKLabelNode {
            
            // ✅ CORREÇÃO AQUI: Define o texto do TitleLabel como "Modo de Jogo:"
            titleLabel.text = NSLocalizedString("menu_gamemode_title", comment: "Game mode title")
            
            titleLabel.fontName = "Ari-W9500Bold"
            titleLabel.fontSize = 36
            titleLabel.zPosition = 5
            
            let shadowOffset = CGPoint(x: 5, y: -5) // Sombra ajustada para iPad
            let shadowColor = SKColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1.0)
            
            addShadow(to: titleLabel, in: titleNode, offset: shadowOffset, color: shadowColor)
            
        }
        
        let buttonNames = ["GestureMode", "ButtonMode"]
        for name in buttonNames {
            if let buttonNode = self.childNode(withName: "//\(name)") as? SKSpriteNode {
                // Aplica o modo de filtragem para um visual pixelado
                buttonNode.texture?.filteringMode = .nearest
                buttonNode.texture?.usesMipmaps = false
            }
        }
    }

    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let settingsOverlay = self.childNode(withName: "settingsOverlay") {
            let touchedNode = atPoint(location)
            
            switch touchedNode.name {
            case "closeSettingsButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                // Para "esconder", removemos o nó da cena com uma animação.
                settingsOverlay.run(SKAction.fadeOut(withDuration: 0.3)) {
                    settingsOverlay.removeFromParent()
                }
                
            case "cameraToggleButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let currentStatus = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
                UserDefaults.standard.set(!currentStatus, forKey: "isCameraPreviewEnabled")
                // Chamamos a função de atualização da fábrica, passando o nó do overlay.
                settingsOverlayFactory.updateLabels(on: settingsOverlay)
                
            case "validationToggleButton":
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let currentStatus = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
                UserDefaults.standard.set(!currentStatus, forKey: "isValidationModeEnabled")
                settingsOverlayFactory.updateLabels(on: settingsOverlay)
                
            default:
                // Se tocou em qualquer outro lugar enquanto o overlay está aberto, não fazemos nada.
                break
            }
            return // Impede que o toque continue para os botões do menu principal.
        }

        let touchedNode = atPoint(location)
        guard let nodeName = touchedNode.name else { return }

        switch nodeName {
        case "settingsButton":
            AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
            let overlay = settingsOverlayFactory.makeOverlay(for: self, inMenuScene: true)
            addChild(overlay)

        case "GestureMode", "JogarLabel":
            AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
            let buttonToAnimate = (nodeName == "JogarLabel") ? touchedNode.parent : touchedNode
            
            if let button = buttonToAnimate {
                button.runButtonAnimation {
                    self.transitionToScene(named: "GameScene", isGestureMode: true)
                }
            }

        case "ButtonMode", "TutorialLabel":
            AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
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
