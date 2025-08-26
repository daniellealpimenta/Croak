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
        // Configuração inicial da cena, se necessário.
    }
    
    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // --- TRANSIÇÃO PARA O MODO GESTURE ---
        if touchedNode.name == "GestureMode" {
            print("Botão GestureMode foi tocado!")
            
            if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                
                // 2. AGORA VOCÊ PODE ACESSAR A SUA VARIÁVEL!
                // Avisa à próxima cena que ela deve iniciar com a câmera expandida.
                gameScene.startInGestureMode = true
                
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
            }
            
            // --- NOVA TRANSIÇÃO PARA O MODO BUTTON ---
            // Adicione esta parte
            if touchedNode.name == "ButtonMode" {
                print("Botão ButtonMode foi tocado!")
                
                // 1. Carrega a ButtonScene a partir do seu arquivo .sks.
                // O nome do arquivo é "ButtonMode.sks", mas a classe associada é "ButtonScene".
                if let buttonScene = SKScene(fileNamed: "ButtonMode") {
                    
                    // 2. Define o modo de escala.
                    buttonScene.scaleMode = .aspectFill
                    
                    // 3. Cria a transição.
                    let transition = SKTransition.fade(withDuration: 1.0)
                    
                    // 4. Apresenta a nova cena.
                    view?.presentScene(buttonScene, transition: transition)
                }
            }
        }
    }
}
