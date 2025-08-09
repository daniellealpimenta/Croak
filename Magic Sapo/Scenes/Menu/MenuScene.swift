//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class MenuScene: SKScene {

    override func didMove(to view: SKView) {
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "PlayButton" {
            print("Botão Play foi tocado!")
            
            // 1. Carregue a GameScene a partir do arquivo .sks
            if let gameScene = SKScene(fileNamed: "GameScene") {
                
                // 2. Defina o tamanho da cena para preencher a tela
                gameScene.scaleMode = .aspectFill
                
                // 3. Crie uma transição para a nova cena
                let transition = SKTransition.fade(withDuration: 1.0)
                
                // 4. Apresente a nova cena
                view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}
