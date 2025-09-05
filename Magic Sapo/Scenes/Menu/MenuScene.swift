//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - Nós da Cena (NOVA SEÇÃO)
    
    // Nós que serão usados para o menu de configurações
    private var settingsButton: SKSpriteNode?
    private var settingsOverlay: SKNode?
    private var cameraToggleButton: SKLabelNode?
    private var validationToggleButton: SKLabelNode?
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        UserDefaults.standard.register(defaults: ["isValidationModeEnabled": true])
        // --- CONFIGURAÇÃO EXISTENTE ---
        setupLabels()
        setupButtonsPixelation()
        
        AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")

        // Nomes de todos os labels que você quer configurar
        let labelNames = ["JogarLabel", "TutorialLabel"]
        
        // --- NOVAS FUNÇÕES ---
        // Cria o botão de configurações e o overlay (que começa escondido)
        setupSettingsButton()
        createSettingsOverlay()
    }
    
    // MARK: - Configuração da UI (NOVA SEÇÃO ORGANIZADA)
    
    // Função para configurar os labels (código que você já tinha)
    func setupLabels() {
        let labelNames = ["LojaLabel", "JogarLabel", "TutorialLabel"]
        for name in labelNames {
          
            if let label = self.childNode(withName: "//\(name)") as? SKLabelNode {
                label.fontName = "Ari-W9500Bold"
                label.fontSize = 35
            } else {
                print("AVISO: Não foi possível encontrar o nó com o nome '\(name)' na cena.")
            }
        }
        
        let buttonNames = ["GestureMode", "ButtonMode"]
        
        for name in buttonNames {
            if let buttonNode = self.childNode(withName: "//\(name)") as? SKSpriteNode {

                buttonNode.texture?.filteringMode = .nearest
                buttonNode.texture?.usesMipmaps = false


                print("Configurado '\(name)' com .nearest e sem mipmaps")
            } else {
                print("AVISO: Não foi possível encontrar o nó do botão com o nome '\(name)' na cena.")
            }
        }
    }
    
    // --- NOVA FUNÇÃO: Criar o Botão de Configurações ---
    func setupSettingsButton() {
        // O nome da sua imagem "botaoSettings" está correto.
        settingsButton = SKSpriteNode(imageNamed: "botaoSettings")
        settingsButton?.name = "settingsButton"
        
        // --- MUDANÇA IMPORTANTE AQUI ---
        // Vamos usar o frame da CENA (self.frame) em vez do frame da VIEW.
        // Isso garante que a posição seja calculada dentro do mundo do jogo.
        let topPadding: CGFloat = 100
        let trailingPadding: CGFloat = 70
        
        // self.frame.maxX é o ponto mais à direita da cena.
        // self.frame.maxY é o ponto mais ao topo da cena.
        settingsButton?.position = CGPoint(
            x: self.frame.maxX - trailingPadding,
            y: self.frame.maxY - topPadding
        )
        // --- FIM DA MUDANÇA ---
        
        settingsButton?.size = CGSize(width: 70, height: 70)
        settingsButton?.zPosition = 10
        
        // Adiciona o botão à cena.
        if let button = settingsButton {
            self.addChild(button)
        }
    }
    
    // --- NOVA FUNÇÃO: Criar o Overlay de Configurações ---
    func createSettingsOverlay() {
        settingsOverlay = SKNode()
        settingsOverlay?.name = "settingsOverlay"
        settingsOverlay?.zPosition = 100 // zPosition bem alto para ficar na frente de tudo
        

        // 1. Fundo semi-transparente para escurecer a cena
        let background = SKShapeNode(rect: self.frame)
        background.fillColor = SKColor.black
        background.alpha = 0.7
        settingsOverlay?.addChild(background)
        
        // 2. Painel principal do overlay
        let panelSize = CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.7)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 15)
        panel.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0) // Cor escura
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        settingsOverlay?.addChild(panel)
        
        // 3. Título do painel
        let titleLabel = SKLabelNode(text: "Configurações")
        // IMPORTANTE: Troque "SuaFonte-Bold" pelo nome real da sua fonte!
        titleLabel.fontName = "Ari-W9500Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: panel.position.x, y: panel.position.y + (panelSize.height / 2) - 60)
        settingsOverlay?.addChild(titleLabel)
        
        // 4. Botão de fechar
        // Substitua "close-button-icon" pelo nome da sua imagem de 'X' ou fechar
        let closeButton = SKSpriteNode(imageNamed: "botaoClose")
        closeButton.name = "closeSettingsButton"
        closeButton.size = CGSize(width: 50, height: 50)
        // Posiciona no canto superior direito do *painel*
        let panelTopRight = CGPoint(x: panel.position.x + (panelSize.width / 2), y: panel.position.y + (panelSize.height / 2))
        closeButton.position = CGPoint(x: panelTopRight.x - 40, y: panelTopRight.y - 35)
        settingsOverlay?.addChild(closeButton)
        
        cameraToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        cameraToggleButton?.name = "cameraToggleButton"
        cameraToggleButton?.fontSize = 28
        cameraToggleButton?.fontColor = .white
        cameraToggleButton?.position = CGPoint(x: panel.position.x, y: titleLabel.position.y - 80)
        settingsOverlay?.addChild(cameraToggleButton!)
        
        validationToggleButton = SKLabelNode(fontNamed: "Ari-W9500")
        validationToggleButton?.name = "validationToggleButton"
        validationToggleButton?.fontSize = 28
        validationToggleButton?.fontColor = .white
        // Posiciona o novo botão 60 pixels abaixo do botão da câmera
        validationToggleButton?.position = CGPoint(x: panel.position.x, y: cameraToggleButton!.position.y - 60)
        settingsOverlay?.addChild(validationToggleButton!)
        
        // O overlay começa escondido
        settingsOverlay?.isHidden = true
        
        if let overlay = settingsOverlay {
            self.addChild(overlay)
        }
    }
    
    func updateValidationToggleButtonText() {
        let isValidationEnabled = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
        if isValidationEnabled {
            validationToggleButton?.text = "Modo de Validação: Ligado"
        } else {
            validationToggleButton?.text = "Modo de Validação: Desligado"
        }
    }
    
    //atualiza o texto do botao com base no valor salvo no UserDefaults
    func updateCameraToggleButtonText() {
            let isCameraEnabled = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
            if isCameraEnabled {
                cameraToggleButton?.text = "Pré-visualização da Câmera: Ligada"
            } else {
                cameraToggleButton?.text = "Pré-visualização da Câmera: Desligada"

        guard let button = touchedNode as? SKSpriteNode else { return }

        if button.name == "GestureMode" || button.name == "JogarLabel" {
            button.runButtonAnimation {
                if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                    gameScene.startInGestureMode = true
                    gameScene.scaleMode = .aspectFill
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(gameScene, transition: transition)
                }
            }
        }
    
    // MARK: - Funções de Controle do Overlay (NOVA SEÇÃO)
    
    func showSettingsOverlay() {
        updateValidationToggleButtonText()
        updateCameraToggleButtonText()
        

        settingsOverlay?.isHidden = false
        // Efeito suave de fade-in
        settingsOverlay?.alpha = 0
        settingsOverlay?.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    func hideSettingsOverlay() {
        // Efeito suave de fade-out e depois esconde o nó
        settingsOverlay?.run(SKAction.fadeOut(withDuration: 0.3), completion: { [weak self] in
            self?.settingsOverlay?.isHidden = true
        })
    }

    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
        if settingsOverlay?.isHidden == false {
            if touchedNode.name == "closeSettingsButton" {
                hideSettingsOverlay()
            }
            
            // --- NOVO: Lógica para o botão da câmera ---
            if touchedNode.name == "cameraToggleButton" {
                // 1. Pega o valor atual
                let currentStatus = UserDefaults.standard.bool(forKey: "isCameraPreviewEnabled")
                // 2. Inverte o valor (true vira false, false vira true)
                UserDefaults.standard.set(!currentStatus, forKey: "isCameraPreviewEnabled")
                // 3. Atualiza o texto do botão para refletir a mudança
                updateCameraToggleButtonText()
            }
            
            
            
            if touchedNode.name == "validationToggleButton" {
                let currentStatus = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
                UserDefaults.standard.set(!currentStatus, forKey: "isValidationModeEnabled")
                updateValidationToggleButtonText()
            }
            return
        }
            
            if touchedNode.name == "settingsButton" {
                showSettingsOverlay()
            }
            
            if touchedNode.name == "GestureMode" || touchedNode.name == "JogarLabel" {
                if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                    gameScene.startInGestureMode = true
                    gameScene.scaleMode = .aspectFill
                    let transition = SKTransition.fade(withDuration: 1.0)
                    view?.presentScene(gameScene, transition: transition)
                }
            }
            
            if touchedNode.name == "ButtonMode" || touchedNode.name == "TutorialLabel" {
                if let buttonScene = SKScene(fileNamed: "ButtonMode") {
                    buttonScene.scaleMode = .aspectFill
                    let transition = SKTransition.fade(withDuration: 1.0)
                    view?.presentScene(buttonScene, transition: transition)

        if button.name == "ButtonMode" || button.name == "TutorialLabel" {
            button.runButtonAnimation {
                if let buttonScene = SKScene(fileNamed: "ButtonMode") {
                    buttonScene.scaleMode = .aspectFill
                    let transition = SKTransition.fade(withDuration: 1.0)
                    self.view?.presentScene(buttonScene, transition: transition)

                }
            }
        }
}
