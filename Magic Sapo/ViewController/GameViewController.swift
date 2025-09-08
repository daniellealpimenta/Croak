//
//  GameViewController.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
          
        if let view = self.view as! SKView? {
            
            // 1. Determina o nome do arquivo da cena com base no dispositivo
            let sceneName = DeviceHelper.isIPhone ? "MenuScene_iphone" : "MenuScene"
              
            // 2. Tenta carregar a SKScene a partir do nome do arquivo definido acima
            if let scene = SKScene(fileNamed: sceneName) {
                  
                // A configuração adaptativa do scale mode continua a mesma
                if DeviceHelper.isIPhone {
                    scene.scaleMode = .aspectFill  // Melhor para iPhone
                } else {
                    scene.scaleMode = .aspectFill   // Melhor para iPad
                }
                  
                // Apresenta a cena correta
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Adapta as orientações suportadas baseado no dispositivo
        if DeviceHelper.isIPhone {
            return .portrait  // iPhone 
        } else {
            return .landscapeRight  // iPad
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
