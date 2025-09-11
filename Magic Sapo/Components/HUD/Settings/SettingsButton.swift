//
//  SettingsComponent.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 09/09/25.
//

import SpriteKit
import UIKit

//protocol SettingsButtonDelegate: AnyObject {
//    func didTapSettingsButton()
//}

class SettingsButtonComponent {
    
    func makeButton() -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: "botaoSettings")
        button.name = "settingsButton"
        button.size = CGSize(width: 70, height: 70)
        button.zPosition = 200
        return button
    }
    
}
