//
//  MagicBook.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/09/25.
//

import SpriteKit

class MagicBook {
    
    /// Cria e configura o nó do livro mágico.
    /// - Returns: Um nó SKSpriteNode configurado para o livro.
    static func createBookNode() -> SKSpriteNode {
        let bookNode = SKSpriteNode(imageNamed: "livro")
        bookNode.name = "magicBook"
        
        // Define o tamanho adaptativo para iPhone e iPad
        bookNode.size = DeviceHelper.isIPad ? CGSize(width: 80, height: 80) : CGSize(width: 70, height: 70)
        
        return bookNode
    }
}
