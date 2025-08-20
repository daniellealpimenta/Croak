//
//  LoseScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 15/08/25.
//

import SpriteKit

class GameOverScene: SKScene {

    // MARK: - Propriedades
    
    /// Guarda o nome do arquivo da cena que levou ao Game Over (ex: "GameScene" ou "ButtonMode").
    var previousSceneName: String?
    
    var finalScore: Int = 0

    // MARK: - Ciclo de Vida da Cena

    override func didMove(to view: SKView) {
        // Atualiza o label da pontuação final
        if let scoreLabel = self.childNode(withName: "//scoreValue") as? SKLabelNode {
            scoreLabel.text = "\(finalScore)"
        }
    }
    
    // MARK: - Entrada do Usuário
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchedNode = atPoint(location)
        
        // --- Lógica dos Botões ---
        
        // Se o botão "Reiniciar" for tocado
        if touchedNode.name == "ResetButton" {
            print("Botão Reiniciar foi tocado!")
            
            // CORREÇÃO: Usa a variável 'previousSceneName' para carregar a cena correta.
            if let sceneNameToLoad = previousSceneName, let newGameScene = SKScene(fileNamed: sceneNameToLoad) {
                newGameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(newGameScene, transition: transition)
            } else {
                // Se por algum motivo o nome da cena não foi passado, volta ao menu principal como segurança.
                print("Erro: Nome da cena anterior não encontrado. Voltando para o Menu.")
                if let menuScene = SKScene(fileNamed: "MenuScene") {
                    menuScene.scaleMode = .aspectFill
                    view?.presentScene(menuScene, transition: .fade(withDuration: 1.0))
                }
            }
        }
        
        // Se o botão "Sair" for tocado
        if touchedNode.name == "ExitButton" {
            print("Botão Menu Principal foi tocado!")
            
            // Carrega a MenuScene para voltar ao menu principal.
            if let menuScene = SKScene(fileNamed: "MenuScene") {
                menuScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(menuScene, transition: transition)
            }
        }
    }
}
