//
// PauseScene.swift
// Magic Sapo
//
// Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class PauseScene: SKScene {
    
    var gameScene: SKScene?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setGameScene(scene: SKScene) {
        self.gameScene = scene
    }
    

    override func didMove(to view: SKView) {

    }
    
    // Esta função é chamada quando o usuário toca na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1. Pegar o primeiro toque e a sua localização
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 2. Encontrar o nó que foi tocado
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "ReturnButton" {
            print("Botão Retomar foi tocado!")
            
            if let gameScene = self.gameScene {
                // Use a cena de jogo armazenada para retornar a ela
                let transition = SKTransition.fade(withDuration: 0.5)
                view?.presentScene(gameScene, transition: transition)
            }
        }
        
        if touchedNode.name == "ResetButton" {
            print("Botão Reiniciar foi tocado!")
            
            // Carregue uma **nova** cena do arquivo .sks para reiniciar o jogo
            if let gameScene = SKScene(fileNamed: "GameScene") {
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
            }
        }
        
        if touchedNode.name == "ExitButton" {
            print("Botão Menu Principal foi tocado!")
            
            // Carregue a MenuScene a partir do arquivo .sks para voltar ao menu
            if let menuScene = SKScene(fileNamed: "MenuScene") {
                menuScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(menuScene, transition: transition)
            }
        }
    }
}
