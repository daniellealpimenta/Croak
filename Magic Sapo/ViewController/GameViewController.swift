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
    
    //                print("--- LISTANDO FONTES DISPONÍVEIS NO APP ---")
    //                for family in UIFont.familyNames.sorted() {
    //                    let names = UIFont.fontNames(forFamilyName: family)
    //                    print("Família: \(family) | Nomes: \(names)")
    //                }
    //                print("--- FIM DA LISTA DE FONTES ---")

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
