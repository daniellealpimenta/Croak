//
//  Guards.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 12/08/25.
//

import Foundation
import SpriteKit

// MARK: - Inimigo: Guards

/// Representa o tipo de inimigo "Guarda".
/// Esta struct conforma ao protocolo `Enemy`, fornecendo uma implementação concreta
/// de como um Guarda deve ser criado e qual sua pontuação.
struct Guards: Enemy {
    

    // MARK: - Propriedades Estáticas (do Tipo)
    
    /// Define que derrotar um "Guarda" vale 1 ponto.
    /// Esta é uma exigência do protocolo `Enemy`.
    static var pointValue: Int = 1
    
    /// Exigencia do protocolo Enemy para cada guarda dropar 3 moedas
    static var coinValue: Int = 3
    
    /// Lista de gestos que podem ser associados a um "Guarda".
    /// Quando um "Guarda" é criado, um destes gestos será escolhido aleatoriamente.
    static var gesture = Gestures()
    
    /// Exigencia do protocolo Enemy para velocidade
    static var speed: Int  = 1


    // MARK: - Método de Criação (Fábrica)
    
    /// Cria e configura um nó de sprite para um inimigo "Guarda".
    /// - Parameter position: A posição inicial onde o inimigo deve ser criado na cena.
    /// - Returns: Um `SKSpriteNode` totalmente configurado representando o Guarda.
    static func create(at position: CGPoint) -> SKSpriteNode? {
        
        // 1. Cria o corpo principal do inimigo (o quadrado vermelho).
        let evilGuard = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        evilGuard.name = "Guard" // Nome que to usando para achar o tipo de inimigo e dar a pontuação certa.
        evilGuard.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        evilGuard.physicsBody?.isDynamic = true
        evilGuard.physicsBody?.affectedByGravity = false
        evilGuard.position = position
        
        // AQUI É ADICIONADo A CONFIGURAÇÃO DE FÍSICA DO INIMIGO
        if let pb = evilGuard.physicsBody {
                pb.categoryBitMask = PhysicsCategory.enemy
                pb.collisionBitMask = PhysicsCategory.none // Inimigos também não precisam empurrar nada
                pb.contactTestBitMask = PhysicsCategory.frog // Queremos ser notificados do contato com o sapo
            }
        
        // Troquei aqui para o Guarda guardar as moedas/pontos
        evilGuard.userData = NSMutableDictionary()
        evilGuard.userData?.setValue(Guards.pointValue, forKey: "points")
        evilGuard.userData?.setValue(Guards.coinValue, forKey: "coins")

        // 2. Escolhe um nome de gesto aleatório da lista de gestos disponíveis.
        guard let randomGestureName = Gestures.availableGestures.randomElement() else {
            // Se, por algum motivo, não conseguir escolher um gesto, a criação falha.
            return nil
        }

        // 3. Cria o sprite para o gesto (a imagem que aparece acima do inimigo).
        let gestureSprite = SKSpriteNode(imageNamed: randomGestureName)
        gestureSprite.size = CGSize(width: 40, height: 40)
        gestureSprite.position = CGPoint(x: 0, y: 60) // Posicionado um pouco acima do corpo do inimigo.
        
        // 4. O nome do sprite do gesto é o próprio nome do gesto (ex: "Rock").
        // É assim que a função `killEnemy` vai saber qual inimigo matar.
        gestureSprite.name = randomGestureName
        
        // 5. Adiciona o sprite do gesto como um "filho" do corpo do inimigo.
        // Agora, quando o corpo se mover, o gesto se moverá junto.
        evilGuard.addChild(gestureSprite)

        // 6. Retorna o inimigo completo (corpo + gesto).
        return evilGuard
    }
}
