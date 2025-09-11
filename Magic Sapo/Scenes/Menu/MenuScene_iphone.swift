//
//  MenuScene_iphone.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 05/09/25.
//

import SpriteKit

class MenuScene_iphone: SKScene {
    
    // MARK: - Nós da Cena
    
    private var settingsButton: SKSpriteNode?
    private var rankingButton: SKSpriteNode?
    private var settingsOverlay: SKNode?
    private var cameraToggleButton: SKLabelNode?
    private var validationToggleButton: SKLabelNode?
    // REMOVIDO: private var gameModeLabel: SKLabelNode? // Não precisamos mais deste
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        UserDefaults.standard.register(defaults: ["isValidationModeEnabled": true])
        UserDefaults.standard.register(defaults: ["isCameraPreviewEnabled": true])
        
        setupLabels()
        // REMOVIDO: setupGameModeLabel() // Não precisamos mais desta função
        AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")

        if !isOnboarding {
            setupSettingsButton()
            setupRankingButton()
        }
        
        createSettingsOverlay()
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
            
            // ✅ CORREÇÃO AQUI: Define o texto do TitleLabel diretamente
            titleLabel.text = NSLocalizedString("menu_gamemode_title", comment: "Game mode title")
            
            // REMOVIDO: (titleNode as? SKLabelNode)?.text = "" // Isso não é mais necessário e causava confusão
            
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
    
    //o botao de configuracoes
    func setupSettingsButton() {
        settingsButton = SKSpriteNode(imageNamed: "botaoSettings")
        settingsButton?.name = "settingsButton"
        
        //para mover MAIS PARA BAIXO, aumente este valor
        let topPadding: CGFloat = 100
        
        //para mover MAIS PARA A ESQUERDA, aumente este valor
        let trailingPadding: CGFloat = 150
        
        // O cálculo da posição usa os novos paddings
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
    
    func setupRankingButton() {
            rankingButton = SKSpriteNode(imageNamed: "ranking_button")
            rankingButton?.name = "ranking_button"
            
            let topPadding: CGFloat = 100
            let trailingPadding: CGFloat = 600
            rankingButton?.position = CGPoint(
                x: self.frame.maxX - trailingPadding,
                y: self.frame.maxY - topPadding
            )
            
            rankingButton?.size = CGSize(width: 90, height: 90)
            rankingButton?.zPosition = 10
            
            if let button = rankingButton {
                self.addChild(button)
            }
        }
    
    func createSettingsOverlay() {
        settingsOverlay = SKNode()
        settingsOverlay?.name = "settingsOverlay"
        settingsOverlay?.zPosition = 100
        
        let background = SKShapeNode(rectOf: self.size)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.fillColor = SKColor.black
        background.alpha = 0.7
        settingsOverlay?.addChild(background)
        
        let panelWidth = self.frame.width * 0.75 // Diminuído para 75% da largura da tela
        let panelHeight = self.frame.height * 0.4 // Aumentado para 40% da altura da tela
        let panelSize = CGSize(width: panelWidth, height: panelHeight)
        
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        settingsOverlay?.addChild(panel)
        
        // Título com fonte escalável e tradução
        let titleLabel = SKLabelNode(text: NSLocalizedString("settings_title", comment: ""))
        titleLabel.fontName = "Ari-W9500Bold"
        titleLabel.fontSize = panelWidth * 0.09
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: (panelSize.height / 2.1) - (titleLabel.fontSize * 1.5))
        panel.addChild(titleLabel)
        
        // Botão de fechar com tamanho relativo e MENOR
        let closeButtonSize = panelWidth * 0.12 // Diminuído para 12% da largura do painel
        let closeButton = SKSpriteNode(imageNamed: "botaoClose")
        closeButton.name = "closeSettingsButton"
        closeButton.size = CGSize(width: closeButtonSize, height: closeButtonSize)
        // Posição ajustada para ficar mais próxima da borda e centralizada com o topo do painel
        closeButton.position = CGPoint(x: (panelSize.width / 2) - (closeButtonSize * 0.7), y: (panelSize.height / 2) - (closeButtonSize * 0.7))
        panel.addChild(closeButton)
        
        // Botões de toggle com fonte e posição relativas
        let toggleFontSize = panelWidth * 0.08 // Aumentado ligeiramente para ser mais legível
        
        cameraToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        cameraToggleButton?.name = "cameraToggleButton"
        cameraToggleButton?.fontSize = toggleFontSize * 0.7
        cameraToggleButton?.fontColor = .white
        // Posição ajustada para ficar abaixo do título e com espaçamento
        cameraToggleButton?.position = CGPoint(x: 0, y: titleLabel.position.y - (titleLabel.fontSize * 2))
        panel.addChild(cameraToggleButton!)
        
        validationToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        validationToggleButton?.name = "validationToggleButton"
        validationToggleButton?.fontSize = toggleFontSize * 0.7
        validationToggleButton?.fontColor = .white
        validationToggleButton?.position = CGPoint(x: 0, y: cameraToggleButton!.position.y - (toggleFontSize * 2))
        panel.addChild(validationToggleButton!)
        
        settingsOverlay?.isHidden = true
        
        if let overlay = settingsOverlay {
            self.addChild(overlay)
        }
    }
    
    // MARK: - Funções de Controle do Overlay
    
    func updateValidationToggleButtonText() {
        let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
        
        let stateString = isValidationEnabled ? NSLocalizedString("state_on", comment: "") : NSLocalizedString("state_off", comment: "")
        let baseString = NSLocalizedString("settings_validation_mode", comment: "")
        validationToggleButton?.text = String(format: baseString, stateString)
    }
    
    func updateCameraToggleButtonText() {
        let isCameraEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        
        let stateString = isCameraEnabled ? NSLocalizedString("state_on", comment: "") : NSLocalizedString("state_off", comment: "")
        let baseString = NSLocalizedString("settings_camera_preview", comment: "")
        cameraToggleButton?.text = String(format: baseString, stateString)
    }
    
    func showSettingsOverlay() {
        updateValidationToggleButtonText()
        updateCameraToggleButtonText()
        
        settingsOverlay?.isHidden = false
        settingsOverlay?.alpha = 0
        settingsOverlay?.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    func hideSettingsOverlay() {
        settingsOverlay?.run(SKAction.fadeOut(withDuration: 0.3), completion: { [weak self] in
            self?.settingsOverlay?.isHidden = true
        })
    }

    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if settingsOverlay?.isHidden == false {
            let touchedNode = atPoint(location)
            
            switch touchedNode.name {
            case "closeSettingsButton":
                hideSettingsOverlay()
                
            case "cameraToggleButton":
                let currentStatus = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
                UserDefaults.standard.set(!currentStatus, forKey: "isCameraPreviewEnabled")
                updateCameraToggleButtonText()
                
            case "validationToggleButton":
                let currentStatus = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
                UserDefaults.standard.set(!currentStatus, forKey: "isValidationModeEnabled")
                updateValidationToggleButtonText()
                
            default:
                break
            }
            return
        }
        
        let touchedNode = atPoint(location)
        guard let nodeName = touchedNode.name else { return }

        switch nodeName {
        case "settingsButton":
            showSettingsOverlay()
            
        case "ranking_button":
            if let button = touchedNode as? SKSpriteNode {
                button.runButtonAnimation {
                    self.transitionToScene(named: "RankingSceneIphone", isGestureMode: false)
                }
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
        else if sceneName == "RankingSceneIphone" {
            if let rankingScene = SKScene(fileNamed: "RankingSceneIphone") {
                rankingScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(rankingScene, transition: transition)
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
