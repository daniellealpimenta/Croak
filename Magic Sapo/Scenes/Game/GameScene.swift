//
// GameScene.swift
// Magic Sapo
//
// Created by Pedro Santos on 09/08/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var timerComponent: TimerComponent!
    var backgroundComponent: BackgroundComponent!
    
    // Chamado quando a cena é apresentada
    override func didMove(to view: SKView) {
        
        // Inicializa o componente de background
        if backgroundComponent == nil {
            backgroundComponent = BackgroundComponent(parent: self)
        }
        backgroundComponent.setupAnimatedBackground()
        
        // Inicializa o componente de timer
        if timerComponent == nil {
            timerComponent = TimerComponent(parent: self)
        }
        timerComponent.start()
    }
    
    // Chamado quando a cena está prestes a ser removida da tela
    override func willMove(from view: SKView) {
        timerComponent.stop()
    }
    
    // Chamado quando o usuário toca na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "PauseButton" {
            print("Botão Pausar foi tocado!")
            
            guard let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene else {
                print("ERRO: Não foi possível carregar a PauseScene.")
                return
            }
            
            pauseScene.setGameScene(scene: self)
            pauseScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(pauseScene, transition: transition)
        }
    }
}
