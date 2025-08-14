//
//  PauseScene.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import SpriteKit

/// A cena que é exibida quando o jogo está pausado.
/// Ela oferece opções para o jogador: retomar, reiniciar ou sair para o menu principal.
class PauseScene: SKScene {
    
    // MARK: - Propriedades
    
    /// Uma referência à instância da `GameScene` que estava ativa quando o jogo foi pausado.
    /// Isso é **crucial** para permitir que o jogador retome o jogo do ponto exato onde parou.
    var gameScene: SKScene?

    // MARK: - Inicialização
    
    /// Inicializador padrão, necessário quando a cena é carregada de um arquivo.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Método público para que a `GameScene` possa "se passar" como referência
    /// antes da transição para a cena de pausa acontecer.
    func setGameScene(scene: SKScene) {
        // MENSAGEM DE DEPURAÇÃO
        print("DEBUG (PauseScene): Método 'setGameScene' foi chamado com a cena: \(scene)")
        self.gameScene = scene
    }
    
    // MARK: - Ciclo de Vida da Cena

    /// Método chamado quando a cena é apresentada na tela.
    override func didMove(to view: SKView) {
        // MENSAGEM DE DEPURAÇÃO
        print("DEBUG (PauseScene): 'didMove' foi chamado. O estado de self.gameScene é: \(self.gameScene ?? nil)")
    }
    
    // MARK: - Entrada do Usuário
    
    /// Esta função é chamada quando o usuário toca na tela.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchedNode = atPoint(location)
        
        // --- Lógica dos Botões ---
        
        // Se o botão "Retomar" for tocado...
        if touchedNode.name == "ReturnButton" {
            // MENSAGENS DE DEPURAÇÃO (INÍCIO)
            print("--- TOQUE NO BOTÃO RETOMAR ---")
            print("DEBUG (PauseScene): Bloco 'if' para ReturnButton foi acessado.")
            print("DEBUG (PauseScene): Verificando self.gameScene... Estado ATUAL: \(self.gameScene ?? nil)")
            
            if let gameScene = self.gameScene {
                print("DEBUG (PauseScene): SUCESSO! A referência para gameScene EXISTE: \(gameScene)")
                print("DEBUG (PauseScene): A view da cena de pausa é: \(self.view ?? nil)")
                print("DEBUG (PauseScene): Tentando apresentar a GameScene agora...")
                
                let transition = SKTransition.fade(withDuration: 0.5)
                view?.presentScene(gameScene, transition: transition)
                
            } else {
                print("DEBUG (PauseScene): FALHA! A referência para self.gameScene é NULA. Não é possível retornar.")
            }
            print("--- FIM DO TOQUE ---")
            // MENSAGENS DE DEPURAÇÃO (FIM)
        }
        
        // Se o botão "Reiniciar" for tocado
        if touchedNode.name == "ResetButton" {
            print("Botão Reiniciar foi tocado!")
            
            // Carrega uma **nova instância** da GameScene para começar um jogo do zero.
            if let gameScene = SKScene(fileNamed: "GameScene") {
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(gameScene, transition: transition)
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
