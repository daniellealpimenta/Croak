//
//  Enemy.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//

import Foundation
import SpriteKit

// MARK: - Protocolo Enemy

/// Define o "contrato" que todo tipo de inimigo deve seguir no jogo.
/// Garante que qualquer inimigo tenha uma maneira de ser criado e um valor de pontos.

// MARK: Quero adicionar aqui um gesto tambem, a quantidade de inimigos spawnados seria util tambem 


protocol Enemy {
    
    /// Método estático (chamado no tipo, ex: Guards.create) para criar e configurar o nó do inimigo.
    /// - Parameter position: O ponto inicial onde o inimigo deve aparecer na cena.
    /// - Returns: Um SKSpriteNode configurado para o inimigo, ou nil se a criação falhar.
    static func create(at position: CGPoint) -> SKSpriteNode?

    /// Propriedade estática que define quantos pontos o jogador ganha ao derrotar este tipo de inimigo.
    static var pointValue: Int { get }
    
    /// Propriedade estática que define quantas moedas o jogador ganha ao derrotar este tipo de inimigo.
    static var coinValue: Int { get }
  
    static var gesture: Gestures { get }
    
    static var speed: Int { get }
    
 //   static var gestureQuantity: Int { get }
    // Vai ficar um em cima do outro

}
