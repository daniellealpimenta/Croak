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
        
                print("--- LISTANDO FONTES DISPONÍVEIS NO APP ---")
                for family in UIFont.familyNames.sorted() {
                    let names = UIFont.fontNames(forFamilyName: family)
                    print("Família: \(family) | Nomes: \(names)")
                }
                print("--- FIM DA LISTA DE FONTES ---")
                
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                
                // CONFIGURAÇÃO ADAPTATIVA DO SCALE MODE
                if DeviceHelper.isIPhone {
                    scene.scaleMode = .aspectFit  // Melhor para iPhone
                } else {
                    scene.scaleMode = .aspectFill   // Melhor para iPad
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

//        print("--- LISTANDO FONTES DISPONÍVEIS NO APP ---")
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Família: \(family) | Nomes: \(names)")
//        }
//        print("--- FIM DA LISTA DE FONTES ---")
