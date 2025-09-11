//
//  PauseOverlayComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 29/08/25.
//

import SpriteKit
import UIKit

protocol PauseOverlayDelegate: AnyObject {
    func didTapResumeButton()
    func didTapResetButton()
    func didTapExitButton()
}

class PauseOverlayComponent {
    
    // MARK: - Propriedades
    
    var overlayNode: SKNode?
    private weak var parentScene: SKScene?
    weak var delegate: PauseOverlayDelegate?
    
    private let settingsButtonFactory = SettingsButtonComponent()
    private let settingsOverlayFactory = SettingsOverlayComponent()
    
    // MARK: - Inicialização
    
    init(parent: SKScene) {
        self.parentScene = parent
    }
    
    // MARK: - Métodos Públicos
    
    /// Cria e exibe o overlay de pausa na cena.
    func show() {
        // Evita criar múltiplos overlays
        guard overlayNode == nil, let scene = parentScene else { return }

        // --- Container Principal ---
        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = 100
        
        // --- Fundo Escurecido ---
        let background = SKSpriteNode(color: .black, size: scene.size)
        background.alpha = 0.7
        overlay.addChild(background)
        
        // --- Estrutura de Configuração para os Elementos ---
        struct LayoutConfig {
            let fenceSize: CGSize
            let fencePosition: CGPoint
            let buttonSize: CGSize
            let resumePosition: CGPoint
            let resetPosition: CGPoint
            let exitPosition: CGPoint
            let settingsPosition: CGPoint
            let settingsSize: CGSize
        }
        
        let config: LayoutConfig

        // --- Define as Configurações Baseadas no Dispositivo ---
        if UIDevice.current.userInterfaceIdiom == .phone {
            config = LayoutConfig(
                fenceSize: CGSize(width: 400, height: 500),
                fencePosition: CGPoint(x: 0, y: -160),
                buttonSize: CGSize(width: 90, height: 90),
                resumePosition: CGPoint(x: 80, y: 70),
                resetPosition: CGPoint(x: -10, y: 70),
                exitPosition: CGPoint(x: -100, y: 70),
                settingsPosition: CGPoint(x: 125, y: 300),
                settingsSize: CGSize(width: 50, height: 50)
            )
        } else {
            config = LayoutConfig(
                fenceSize: CGSize(width: 650, height: 700),
                fencePosition: CGPoint(x: 10, y: -100),
                buttonSize: CGSize(width: 150, height: 150),
                resumePosition: CGPoint(x: 150, y: 95),
                resetPosition: CGPoint(x: 0, y: 95),
                exitPosition: CGPoint(x: -150, y: 95),
                settingsPosition: CGPoint(x: 440, y: 300),
                settingsSize: CGSize(width: 70, height: 70)
            )
        }
        // --- Criação dos Nós com a Configuração Definida ---
        
        let pauseFence = SKSpriteNode(imageNamed: "placa")
        pauseFence.size = config.fenceSize
        pauseFence.position = config.fencePosition
        pauseFence.zPosition = 0
        overlay.addChild(pauseFence)
        
        let resumeButton = SKSpriteNode(imageNamed: "play")
        resumeButton.name = "ReturnButton"
        resumeButton.size = config.buttonSize
        resumeButton.position = config.resumePosition
        resumeButton.zPosition = 1
        pauseFence.addChild(resumeButton) // Adicionado à placa para posições relativas
        
        let resetButton = SKSpriteNode(imageNamed: "reiniciar")
        resetButton.name = "ResetButton"
        resetButton.size = config.buttonSize
        resetButton.position = config.resetPosition
        resetButton.zPosition = 1
        pauseFence.addChild(resetButton)
        
        let exitButton = SKSpriteNode(imageNamed: "sair")
        exitButton.name = "ExitButton"
        exitButton.size = config.buttonSize
        exitButton.position = config.exitPosition
        exitButton.zPosition = 1
        pauseFence.addChild(exitButton)
        
        let settingsButton = settingsButtonFactory.makeButton()
        settingsButton.name = "SettingsButton"
        settingsButton.size = config.settingsSize
        settingsButton.position = config.settingsPosition
        settingsButton.zPosition = 2
        overlay.addChild(settingsButton)
        
        // Adiciona o overlay completo à cena e guarda a referência
        scene.addChild(overlay)
        self.overlayNode = overlay
    }
    
    /// Remove o overlay da cena.
    func hide() {
        overlayNode?.removeFromParent()
        overlayNode = nil
    }
    
    /// Processa um toque na tela, verificando se atingiu um dos botões do overlay.
    /// Deve ser chamado pela cena no método `touchesBegan`.
    func handleTouch(at location: CGPoint) {
        guard let scene = parentScene else { return }

        // Primeiro, verifica se o overlay de configurações está aberto
        if let settingsOverlay = scene.childNode(withName: "settingsOverlay") {
            // Pega todos os nós na localização do toque
            let touchedNodes = scene.nodes(at: location)

            // Itera sobre os nós tocados para encontrar os botões de configuração
            for node in touchedNodes {
                switch node.name {
                case "closeSettingsButton":
                    AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                    settingsOverlay.removeFromParent()
                    return // Sai da função após lidar com o toque

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
                    // Continua o loop se o nó tocado não for um botão de interesse
                    continue
                }
            }
            // Se o toque foi no overlay de settings mas não em um botão, impede que o toque "vaze" para o jogo
            if settingsOverlay.contains(location) {
                 return
            }
        }
        
        // Se o overlay de settings não estiver aberto, processa os botões de pausa
        let touchedNode = scene.atPoint(location)
        switch touchedNode.name {
        case "ReturnButton":
            delegate?.didTapResumeButton()
        case "ResetButton":
            delegate?.didTapResetButton()
        case "ExitButton":
            delegate?.didTapExitButton()
        case "SettingsButton":
            if scene.childNode(withName: "settingsOverlay") == nil {
                AudioManager.shared.playRandomSoundEffect(from: AudioManager.woodenTap)
                let settingsOverlay = settingsOverlayFactory.makeOverlay(for: scene, inMenuScene: false)
                settingsOverlay.alpha = 0
                settingsOverlay.run(SKAction.fadeIn(withDuration: 0.3))
                scene.addChild(settingsOverlay)
            }
        default:
            break
        }
    }
}
