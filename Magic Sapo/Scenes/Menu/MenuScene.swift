//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - Nós da Cena
    
    // Nós que serão usados para o menu de configurações
    private var settingsButton: SKSpriteNode?
    private var settingsOverlay: SKNode?
    private var cameraToggleButton: SKLabelNode?
    private var validationToggleButton: SKLabelNode?
    
    var isOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        // Registra um valor padrão para o modo de validação na primeira vez que o app abrir
        UserDefaults.standard.register(defaults: ["isValidationModeEnabled": true])
        UserDefaults.standard.register(defaults: ["isCameraPreviewEnabled": true])
        // --- CONFIGURAÇÃO EXISTENTE ---
        setupLabels()
        AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")

        // --- NOVAS FUNÇÕES ---
        // Cria o botão de configurações e o overlay (que começa escondido)
        if !isOnboarding {
            setupSettingsButton()
        }
        
        createSettingsOverlay()
    }
    
    // MARK: - Configuração da UI
    
    // Função para configurar os labels e botões
    func setupLabels() {
        // Removido "LojaLabel" para manter consistência com a versão do iPhone
        let labelNames = ["JogarLabel", "TutorialLabel"]
        for name in labelNames {
            if let label = self.childNode(withName: "//\(name)") as? SKLabelNode {
                label.fontName = "Ari-W9500Bold"
                label.fontSize = 35
            } else {
                print("AVISO: Não foi possível encontrar o nó com o nome '\(name)' na cena.")
            }
        }
        
        // --- NOVO CÓDIGO ---
        // Adiciona a configuração de fonte e sombra para o TitleLabel
        if let titleNode = self.childNode(withName: "//Title"), let titleLabel = titleNode.childNode(withName: "TitleLabel") as? SKLabelNode {
            titleLabel.fontName = "Ari-W9500Bold"
            titleLabel.fontSize = 36
            titleLabel.zPosition = 5
            
            let shadowOffset = CGPoint(x: 5, y: -5) // Sombra ajustada para iPad
            let shadowColor = SKColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1.0)
            
            addShadow(to: titleLabel, in: titleNode, offset: shadowOffset, color: shadowColor)
            
        } else {
            print("AVISO: Não foi possível encontrar o nó 'TitleLabel' dentro de 'Title'.")
        }
        
        let buttonNames = ["GestureMode", "ButtonMode"]
        for name in buttonNames {
            if let buttonNode = self.childNode(withName: "//\(name)") as? SKSpriteNode {
                // Aplica o modo de filtragem para um visual pixelado
                buttonNode.texture?.filteringMode = .nearest
                buttonNode.texture?.usesMipmaps = false
                print("Configurado '\(name)' com .nearest e sem mipmaps")
            } else {
                print("AVISO: Não foi possível encontrar o nó do botão com o nome '\(name)' na cena.")
            }
        }
    }
    
    // Cria o Botão de Configurações
    func setupSettingsButton() {
        settingsButton = SKSpriteNode(imageNamed: "botaoSettings")
        settingsButton?.name = "settingsButton"
        
        let topPadding: CGFloat = 100
        let trailingPadding: CGFloat = 70
        
        // Usa o frame da cena para garantir o posicionamento correto em diferentes tamanhos de tela
        settingsButton?.position = CGPoint(
            x: self.frame.maxX - trailingPadding,
            y: self.frame.maxY - topPadding
        )
        
        settingsButton?.size = CGSize(width: 70, height: 70)
        settingsButton?.zPosition = 10
        
        if let button = settingsButton {
            self.addChild(button)
        }
    }
    
    // Cria o Overlay de Configurações (VERSÃO CORRIGIDA)
    func createSettingsOverlay() {
        settingsOverlay = SKNode()
        settingsOverlay?.name = "settingsOverlay"
        settingsOverlay?.zPosition = 100 // zPosition alto para ficar na frente de tudo
        
        // 1. Fundo semi-transparente
        let background = SKShapeNode(rectOf: self.size)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.fillColor = SKColor.black
        background.alpha = 0.7
        settingsOverlay?.addChild(background)
        
        // 2. Painel principal
        let panelSize = CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.7)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        settingsOverlay?.addChild(panel)
        
        // 3. Título (agora filho do painel)
        let titleLabel = SKLabelNode(text: "Configurações")
        titleLabel.fontName = "Ari-W9500Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: (panelSize.height / 2) - 60)
        panel.addChild(titleLabel)
        
        // 4. Botão de fechar (agora filho do painel)
        let closeButton = SKSpriteNode(imageNamed: "botaoClose")
        closeButton.name = "closeSettingsButton"
        closeButton.size = CGSize(width: 50, height: 50)
        closeButton.position = CGPoint(x: (panelSize.width / 2) - 40, y: (panelSize.height / 2) - 35)
        panel.addChild(closeButton)
        
        // 5. Botão de toggle para a câmera (agora filho do painel)
        cameraToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        cameraToggleButton?.name = "cameraToggleButton"
        cameraToggleButton?.fontSize = 28
        cameraToggleButton?.fontColor = .white
        cameraToggleButton?.position = CGPoint(x: 0, y: titleLabel.position.y - 80)
        panel.addChild(cameraToggleButton!)
        
        // 6. Botão de toggle para o modo de validação (agora filho do painel)
        validationToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        validationToggleButton?.name = "validationToggleButton"
        validationToggleButton?.fontSize = 28
        validationToggleButton?.fontColor = .white
        validationToggleButton?.position = CGPoint(x: 0, y: cameraToggleButton!.position.y - 60)
        panel.addChild(validationToggleButton!)
        
        // O overlay começa escondido
        settingsOverlay?.isHidden = true
        
        if let overlay = settingsOverlay {
            self.addChild(overlay)
        }
    }
    
    // MARK: - Funções de Controle do Overlay
    
    func updateValidationToggleButtonText() {
        let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
        validationToggleButton?.text = isValidationEnabled ? "Modo de Validação: Ligado" : "Modo de Validação: Desligado"
    }
    
    func updateCameraToggleButtonText() {
        let isCameraEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
        cameraToggleButton?.text = isCameraEnabled ? "Câmera Preview: Ligada" : "Câmera Preview: Desligada"
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
        
        // Verifica se o overlay de configurações está ativo
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
        
        // Lógica para os botões do menu principal (só executa se o overlay estiver fechado)
        let touchedNode = atPoint(location)
        guard let nodeName = touchedNode.name else { return }

        switch nodeName {
        case "settingsButton":
            showSettingsOverlay()

        case "GestureMode", "JogarLabel":
            // Se tocamos no label, pegamos o seu pai (a imagem).
            // Se tocamos na própria imagem, usamos ela mesma.
            let buttonToAnimate = (nodeName == "JogarLabel") ? touchedNode.parent : touchedNode
            
            if let button = buttonToAnimate {
                button.runButtonAnimation {
                    self.transitionToScene(named: "GameScene", isGestureMode: true)
                }
            }

        case "ButtonMode", "TutorialLabel":
            // A mesma lógica para o outro botão
            let buttonToAnimate = (nodeName == "TutorialLabel") ? touchedNode.parent : touchedNode
            
            if let button = buttonToAnimate {
                // (Bônus) Aplica a mesma animação aqui para consistência
                button.runButtonAnimation {
                    self.transitionToScene(named: "ButtonMode", isGestureMode: false)
                }
            }
            
        default:
            break // Tocou em uma área sem botão
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
        // Cria uma cópia exata do label original
        let shadowLabel = label.copy() as! SKLabelNode
        
        // Define a cor da sombra
        shadowLabel.fontColor = color
        
        // Posiciona a sombra com um pequeno deslocamento
        shadowLabel.position = CGPoint(x: label.position.x + offset.x, y: label.position.y + offset.y)
        
        // Garante que a sombra fique atrás do label original
        shadowLabel.zPosition = label.zPosition - 1
        
        // Adiciona a sombra ao mesmo nó pai do label original
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
