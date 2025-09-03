//
//  BossFightScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 28/08/25.
//

import SpriteKit

protocol BossFightScene: SKScene, ScoreHavingScene {
    func bossFightDidEnd()
    func enterBossFightState()
}
