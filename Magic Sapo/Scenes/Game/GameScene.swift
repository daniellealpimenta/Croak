//
// GameScene.swift
// Magic Sapo
//
// Created by Pedro Santos on 09/08/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
    var timerCount = 0
    var timerLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        if timerLabel == nil {
            
            timerLabel = SKLabelNode(fontNamed: "Arial")
            timerLabel.fontSize = 50
            timerLabel.fontColor = .white
            timerLabel.position = CGPoint(x: 0, y: 300)
            timerLabel.text = "Tempo: \(timerCount)"
            addChild(timerLabel)
            
        } else {
            
            // Se o rótulo já existe (em caso de retomada), apenas o atualize e o adicione
            timerLabel.text = "Tempo: \(timerCount)"
            addChild(timerLabel)
        }
        
        // Cria a ação de contagem
        let wait = SKAction.wait(forDuration: 1.0)
        let countBlock = SKAction.run {
            self.timerCount += 1
            self.timerLabel.text = "Tempo: \(self.timerCount)"
        }
        
        // Cria uma sequência de ações: esperar 1s e depois contar. Repete para sempre.
        let sequence = SKAction.sequence([wait, countBlock])
        let repeatSequence = SKAction.repeatForever(sequence)
        
        // Executa a ação na cena
        run(repeatSequence, withKey: "timerAction")
    }
    
    override func willMove(from view: SKView) {
        // Remove a ação do timer
        removeAction(forKey: "timerAction")
        // Remove o rótulo da tela para evitar sobreposição
        timerLabel.removeFromParent()
    }

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
