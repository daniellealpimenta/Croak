//
//  PauseOverlayComponent.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 29/08/25.
//

import SpriteKit
import UIKit

// 1. Protocolo de Delegate
// A cena que usar este componente precisará implementar estas funções
// para responder aos toques nos botões.
protocol PauseOverlayDelegate: AnyObject {
    func didTapResumeButton()
    func didTapResetButton()
    func didTapExitButton()
}

/// Um componente reutilizável que gerencia a criação, exibição e
/// interação do overlay de pausa do jogo.
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
                settingsPosition: CGPoint(x: 400, y: 300),
                settingsSize: CGSize(width: 75, height: 75)
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

        // Mesmo com a view pausada, podemos pedir os nós diretamente.
        if let settingsOverlay = scene.childNode(withName: "settingsOverlay") {
            let touchedNodes = scene.nodes(at: location)

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
                    settingsOverlayFactory.updateLabels(on: settingsOverlay)
                    return
                case "validationToggleButton":
                    let currentValue = UserDefaults.standard.bool(forKey: "isValidationModeEnabled")
                    UserDefaults.standard.set(!currentValue, forKey: "isValidationModeEnabled")
                    settingsOverlayFactory.updateLabels(on: settingsOverlay)
                    return
                default:
                    continue
                }
            }
            
            return
        }
        
        let touchedNodes = scene.nodes(at: location)
        for node in touchedNodes {
            switch node.name {
            case "ReturnButton":
                delegate?.didTapResumeButton()
                return
            case "ResetButton":
                delegate?.didTapResetButton()
                return
            case "ExitButton":
                delegate?.didTapExitButton()
                return
            case "SettingsButton":
                if scene.childNode(withName: "settingsOverlay") == nil {
                    let settingsOverlay = settingsOverlayFactory.makeOverlay(for: scene, inMenuScene: false)
                    settingsOverlay.run(SKAction.fadeIn(withDuration: 0.3))
                    scene.addChild(settingsOverlay)
                }
                return
            default:
                continue
            }
        }

    }
}
