//
//  MenuScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

/// A cena do menu principal. É a primeira tela que o jogador vê.
/// Sua principal responsabilidade é exibir o título e o botão de "Jogar"
/// e iniciar a transição para a `GameScene` quando o botão é pressionado.
class MenuScene: SKScene {

    // MARK: - Ciclo de Vida da Cena
    

    // Essa funcao é importante pra caramba, mas nao estava usando ela na hora, ia usar ela pra caramba dps mas esqueci pra que
    override func didMove(to view: SKView) {
        
    }

    // MARK: - Entrada do Usuário

    /// Método chamado quando o jogador toca na tela.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Pega as informações do toque.
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Identifica o nó que foi tocado.
        let touchedNode = atPoint(location)
        
        // Se o nó tocado for o botão "PlayButton", inicia o jogo.
        if touchedNode.name == "PlayButton" {
            print("Botão Play foi tocado!")
            
            // Inicia a transição para a cena principal do jogo.
            
            // 1. Carrega a GameScene a partir do seu arquivo .sks.
            if let gameScene = SKScene(fileNamed: "GameScene") {
                
                // 2. Define o modo de escala para que a cena se ajuste bem à tela.
                gameScene.scaleMode = .aspectFill
                
                // 3. Cria uma transição suave de fade com 1 segundo de duração.
                let transition = SKTransition.fade(withDuration: 1.0)
                
                // 4. Pede para a view atual apresentar a nova cena usando a transição.
                view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}
