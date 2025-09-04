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
        let labelNames = ["LojaLabel", "JogarLabel", "TutorialLabel"]
        
        // Passa por cada nome na lista
        for name in labelNames {
            
            // A MUDANÇA ESTÁ AQUI: Adicionamos "//" para procurar em toda a cena
            if let label = self.childNode(withName: "//\(name)") as? SKLabelNode {
                // Aplica a mesma configuração a todos
                label.fontName = "Ari-W9500Bold"
                label.fontSize = 35
            } else {
                print("AVISO: Não foi possível encontrar o nó com o nome '\(name)' na cena.")
            }
        }
        
        let buttonNames = ["GestureMode", "ButtonMode", "Loja"]
        
        for name in buttonNames {
            if let buttonNode = self.childNode(withName: "//\(name)") as? SKSpriteNode {
                // APLIQUE AS DUAS CONFIGURAÇÕES
                buttonNode.texture?.filteringMode = .nearest
                buttonNode.texture?.usesMipmaps = false // <-- ADICIONE ESTA LINHA

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
        
        // --- LINHA DE DEBUG ---
        // Adicione esta linha para ver no console o nome exato do nó que está sendo tocado.
        print("Nó tocado: \(touchedNode.name ?? "Nenhum nome")")
        
        // O resto do seu código continua igual...
        if touchedNode.name == "GestureMode" || touchedNode.name == "JogarLabel" {
            print("Botão GestureMode foi tocado!")
            
            if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                
                // 2. AGORA VOCÊ PODE ACESSAR A SUA VARIÁVEL!
                // Avisa à próxima cena que ela deve iniciar com a câmera expandida.
                gameScene.startInGestureMode = true
                
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
            }
        }
        
        if touchedNode.name == "ButtonMode" || touchedNode.name == "TutorialLabel" {
            print("Botão ButtonMode foi tocado!")
            
            if let buttonScene = SKScene(fileNamed: "ButtonMode") {
                buttonScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(buttonScene, transition: transition)
            }
        }
    }
}
