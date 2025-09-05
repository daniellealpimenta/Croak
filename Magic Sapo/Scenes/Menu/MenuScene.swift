//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - Ciclo de Vida da Cena
    
    override func didMove(to view: SKView) {
        
        // Nomes de todos os labels que você quer configurar
        let labelNames = ["JogarLabel", "TutorialLabel"]
        
        // Passa por cada nome na lista
        for name in labelNames {
            
            if let label = self.childNode(withName: "//\(name)") as? SKLabelNode {
                // Aplica a mesma configuração a todos
                label.fontName = "Ari-W9500Bold"
                label.fontSize = 35
            } else {
                print("AVISO: Não foi possível encontrar o nó com o nome '\(name)' na cena.")
            }
            
            AudioManager.shared.playBackgroundMusic(filename: "croak-menu-music.m4a")
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
    
    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
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
}
