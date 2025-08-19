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
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                
                // CONFIGURAÇÃO ADAPTATIVA DO SCALE MODE
                if DeviceHelper.isIPhone {
                    scene.scaleMode = .aspectFill  // Melhor para iPhone
                } else {
                    scene.scaleMode = .aspectFit   // Melhor para iPad
                }
                
                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Adapta as orientações suportadas baseado no dispositivo
        if DeviceHelper.isIPhone {
            return .portrait  // iPhone 
        } else {
            return .landscapeRight      // iPad
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
