//
//  AnimationNode.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 05/09/25.
//

import SpriteKit

// Adicionamos uma nova função a todos os SKSpriteNodes do nosso jogo
extension SKSpriteNode {
    
    /// Executa uma animação de "pop" e, ao final, executa uma ação de conclusão.
    /// - Parameter completion: O bloco de código que deve ser executado após a animação.
    func runButtonAnimation(completion: @escaping () -> Void) {
        
        let scaleUp = SKAction.scale(by: 1.15, duration: 0.08)
        let scaleDown = scaleUp.reversed()
        
        let finalAction = SKAction.run(completion)
        
        let sequence = SKAction.sequence([scaleUp, scaleDown, finalAction])
        
        self.run(sequence)
    }
}
