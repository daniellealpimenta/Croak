//
//  LoseScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 15/08/25.
//

import SpriteKit

/// A cena do menu principal. É a primeira tela que o jogador vê.
/// Sua principal responsabilidade é exibir o título e o botão de "Jogar"
/// e iniciar a transição para a `GameScene` quando o botão é pressionado.
class GameOverScene: SKScene {

    // MARK: - Propriedades
    
    /// Uma referência à instância da `GameScene` que estava ativa quando o jogo foi pausado.
    /// Isso é **crucial** para permitir que o jogador retome o jogo do ponto exato onde parou.
    var gameScene: SKScene?
    
    var finalScore: Int = 0

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
        if let scoreLabel = self.childNode(withName: "//scoreValue") as? SKLabelNode {
            
            // 3. ATUALIZE O TEXTO DO LABEL
            //    Agora você usa a variável 'finalScore' para definir o texto.
            scoreLabel.text = "\(finalScore)"
        }
    }
    
    // MARK: - Entrada do Usuário
    
    /// Esta função é chamada quando o usuário toca na tela.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchedNode = atPoint(location)
        
        // --- Lógica dos Botões ---
        
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
