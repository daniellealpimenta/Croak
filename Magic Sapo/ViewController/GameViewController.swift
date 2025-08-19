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
        
        // MARK: Recebendo o aviso que o jogo vai ficar inativo
        NotificationCenter.default.addObserver(self, selector: #selector(PauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        
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
    
    // O erro era a falta do @objc (pesquisar dps)
    @objc func PauseGame() {
        print("Pausando o jogo")
        
        // MARK: as! -> Faz um cast formado para o SKView que pode ser vazio
        if let view = self.view as! SKView? {
            
            if let gameScene = view.scene as? GameScene {

                // Forcando um cast para a PauseScene
                if let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene {
                    
                    pauseScene.setGameScene(scene: gameScene)
                    
                    pauseScene.scaleMode = .aspectFill
                    let transicao = SKTransition.fade(withDuration: 0.5)
                    view.presentScene(pauseScene, transition: transicao)
                }
            }
            
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
