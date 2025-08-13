//
//  Enemy.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//


// Enemy.swift
import Foundation
import SpriteKit

protocol Enemy {
    static func create(at position: CGPoint) -> SKSpriteNode?
    static var pointValue: Int { get } 
}
