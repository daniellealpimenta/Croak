//
// GameScene.swift
// Magic Sapo
//
// Created by Pedro Santos on 09/08/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    // Este método é chamado quando o usuário toca na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1. Obtenha o primeiro toque e a localização
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 2. Encontre o nó que foi tocado
        let touchedNode = atPoint(location)
        
        // 3. Verifique se o nó tocado é o botão de pausa
        if touchedNode.name == "PauseButton" {
            print("Botão Pausar foi tocado!")
            
            // Tente carregar o arquivo .sks como uma SKScene genérica
            guard let sceneFromSKS = SKScene(fileNamed: "PauseScene") else {
                print("ERRO 1: O arquivo PauseScene.sks não foi encontrado. Verifique a grafia e o 'Target Membership'.")
                return
            }
            
            // Se o arquivo foi encontrado, tente convertê-lo para a classe PauseScene
            guard let pauseScene = sceneFromSKS as? PauseScene else {
                print("ERRO 2: O arquivo foi encontrado, mas a classe não corresponde a PauseScene. Verifique a associação do 'Custom Class' no editor do .sks.")
                return
            }
            
            // Se o código chegou aqui, a cena foi carregada e convertida com sucesso.
            print("SUCESSO: A PauseScene foi carregada corretamente. Iniciando a transição.")

            pauseScene.setGameScene(scene: self)
            pauseScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(pauseScene, transition: transition)
        }
    }
}
