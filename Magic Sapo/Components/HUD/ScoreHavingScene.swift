//
//  ScoreHavingScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 26/08/25.
//

import SpriteKit

protocol ScoreHavingScene: SKScene {
    var scoreComponent: ScoreComponent! { get }
    var coinsComponent: CoinsComponent! { get }
    var killZoneRect: CGRect { get }
}
